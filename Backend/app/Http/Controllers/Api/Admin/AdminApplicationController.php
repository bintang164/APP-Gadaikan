<?php

namespace App\Http\Controllers\Api\Admin;

use App\Enums\ApplicationStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\AssessmentRequest;
use App\Http\Requests\DecisionRequest;
use App\Http\Requests\ReasonRequest;
use App\Http\Resources\ApplicationResource;
use App\Models\AdminActivityLog;
use App\Models\PawnApplication;
use App\Models\PawnAssessment;
use App\Models\PawnDocument;
use App\Models\PawnOffer;
use App\Services\StatusTransitionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminApplicationController extends Controller
{
    public function __construct(private readonly StatusTransitionService $transitions)
    {
    }

    public function index(Request $request)
    {
        $query = PawnApplication::with(['user', 'category', 'assessment'])
            ->search($request->query('search'))
            ->status($request->query('status') === 'all' ? null : $request->query('status'));

        if ($category = $request->query('category')) {
            $query->whereHas('category', fn ($q) => $q->where('code', $category));
        }

        $applications = $query->orderByDesc('created_at')
            ->paginate(min((int) $request->query('per_page', 15), 100));

        return ApplicationResource::collection($applications);
    }

    public function show(int $id): ApplicationResource
    {
        $application = PawnApplication::with([
            'user', 'category', 'assessment', 'statusHistory', 'documents',
        ])->findOrFail($id);

        return new ApplicationResource($application);
    }

    public function assessment(AssessmentRequest $request, int $id): ApplicationResource
    {
        $admin = $request->user();
        $application = PawnApplication::findOrFail($id);

        $application = DB::transaction(function () use ($request, $admin, $application): PawnApplication {
            $assessment = PawnAssessment::updateOrCreate(
                ['pawn_application_id' => $application->id],
                [
                    'assessed_by' => $admin->id,
                    'assessed_value' => $request->input('assessed_value'),
                    'plafon_percentage' => $request->input('plafon_percentage'),
                    'approved_principal' => $request->input('approved_principal'),
                    'service_fee' => $request->input('service_fee'),
                    'tenor_days' => $request->input('tenor_days'),
                    'start_date' => $request->input('start_date'),
                    'due_date' => $request->input('due_date'),
                    'customer_note' => $request->input('customer_note'),
                    'internal_note' => $request->input('internal_note'),
                ],
            );

            PawnOffer::firstOrCreate(['pawn_application_id' => $application->id], [
                'pawn_assessment_id' => $assessment->id,
                'status' => 'pending',
            ]);

            if (in_array($application->status, [
                ApplicationStatus::Submitted,
                ApplicationStatus::RevisionRequired,
            ], true)) {
                $this->transitions->startReview($application, $admin);
            }

            $this->transitions->approve(
                $application,
                $admin,
                $request->input('customer_note') ?: 'Penaksiran selesai. Penawaran siap ditinjau.',
            );

            AdminActivityLog::create([
                'actor_id' => $admin->id,
                'action' => 'assessment_saved',
                'subject_type' => PawnApplication::class,
                'subject_id' => $application->id,
                'metadata' => [
                    'assessed_value' => $request->input('assessed_value'),
                    'approved_principal' => $request->input('approved_principal'),
                ],
                'ip_address' => $request->ip(),
            ]);

            return $application->load(['user', 'category', 'assessment', 'statusHistory', 'documents']);
        });

        return new ApplicationResource($application);
    }

    public function requestRevision(ReasonRequest $request, int $id): ApplicationResource
    {
        $application = PawnApplication::findOrFail($id);
        $this->transitions->requestRevision($application, $request->user(), $request->input('reason'));

        return new ApplicationResource($application->load(['user', 'category', 'assessment', 'statusHistory']));
    }

    public function review(int $id): ApplicationResource
    {
        $application = PawnApplication::findOrFail($id);
        $this->transitions->startReview($application, request()->user());

        return new ApplicationResource($application->load(['user', 'category', 'statusHistory']));
    }

    public function decision(DecisionRequest $request, int $id): ApplicationResource
    {
        $application = PawnApplication::findOrFail($id);

        if ($request->input('decision') === 'approved') {
            if (! $application->assessment) {
                abort(422, 'Penaksiran harus diisi sebelum menyetujui.');
            }
            $this->transitions->approve($application, $request->user(), $request->input('internal_note'));
        } else {
            $this->transitions->reject($application, $request->user(), $request->input('reason'));
        }

        return new ApplicationResource($application->load(['user', 'category', 'assessment', 'statusHistory']));
    }

    public function statusHistory(int $id): JsonResponse
    {
        $application = PawnApplication::findOrFail($id);

        return response()->json(['data' => $application->statusHistory]);
    }

    public function document(int $id, int $documentId): StreamedResponse
    {
        $application = PawnApplication::findOrFail($id);
        $document = PawnDocument::where('pawn_application_id', $application->id)
            ->findOrFail($documentId);

        if (! Storage::disk('local')->exists($document->path)) {
            abort(404, 'Berkas tidak ditemukan di storage privat.');
        }

        // Akses terotorisasi: admin saja, lewat endpoint ini.
        return Storage::disk('local')->download($document->path, $document->file_name);
    }
}
