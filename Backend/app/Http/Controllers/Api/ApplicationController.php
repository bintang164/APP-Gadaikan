<?php

namespace App\Http\Controllers\Api;

use App\Enums\ApplicationStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\ApplicationStoreRequest;
use App\Http\Resources\ApplicationResource;
use App\Http\Resources\TransactionResource;
use App\Models\Category;
use App\Models\Notification;
use App\Models\PawnApplication;
use App\Models\PawnDocument;
use App\Models\PawnItem;
use App\Models\PawnOffer;
use App\Models\PawnTransaction;
use App\Services\StatusTransitionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ApplicationController extends Controller
{
    public function __construct(private readonly StatusTransitionService $transitions)
    {
    }

    public function store(ApplicationStoreRequest $request): JsonResponse
    {
        $user = $request->user();
        $category = Category::where('code', $request->input('category'))->firstOrFail();

        $application = DB::transaction(function () use ($request, $user, $category): PawnApplication {
            $application = PawnApplication::create([
                'user_id' => $user->id,
                'category_id' => $category->id,
                'code' => $this->generateCode('GDK'),
                'status' => ApplicationStatus::Draft->value,
                'item_title' => $request->input('item_title'),
                'item_details' => $request->input('item_details'),
                'estimated_user_value' => $request->input('estimated_value'),
                'preferred_tenor_days' => $request->input('preferred_tenor_days'),
                'submitted_at' => now(),
            ]);

            PawnItem::create([
                'pawn_application_id' => $application->id,
                'details' => $request->input('item_details'),
                'condition_notes' => $request->input('item_details.kondisi', ''),
            ]);

            $documentIds = collect($request->input('documents', []))->pluck('id')->all();
            if ($documentIds !== []) {
                PawnDocument::whereIn('id', $documentIds)
                    ->where('uploaded_by', $user->id)
                    ->whereNull('pawn_application_id')
                    ->update(['pawn_application_id' => $application->id]);
            }

            $this->transitions->submit($application, $user);

            Notification::create([
                'user_id' => $user->id,
                'type' => 'application_submitted',
                'title' => 'Pengajuan diterima',
                'body' => "Pengajuan {$application->code} sedang menunggu pemeriksaan.",
                'application_id' => $application->id,
            ]);

            return $application;
        });

        return (new ApplicationResource($application->load(['category', 'assessment', 'statusHistory', 'documents'])))
            ->response()
            ->setStatusCode(201);
    }

    public function index(Request $request)
    {
        $query = PawnApplication::where('user_id', $request->user()->id)
            ->with(['category', 'assessment'])
            ->search($request->query('search'))
            ->status($request->query('status') === 'all' ? null : $request->query('status'));

        if ($category = $request->query('category')) {
            $query->whereHas('category', fn ($q) => $q->where('code', $category));
        }

        $direction = $request->query('sort') === 'asc' ? 'asc' : 'desc';
        $applications = $query->orderBy('created_at', $direction)
            ->paginate(min((int) $request->query('per_page', 10), 100));

        return ApplicationResource::collection($applications);
    }

    public function show(Request $request, int $id): ApplicationResource
    {
        $application = PawnApplication::where('user_id', $request->user()->id)
            ->with(['category', 'assessment', 'statusHistory', 'documents'])
            ->findOrFail($id);

        return new ApplicationResource($application);
    }

    public function statusHistory(Request $request, int $id): JsonResponse
    {
        $application = PawnApplication::where('user_id', $request->user()->id)->findOrFail($id);

        return response()->json([
            'data' => $application->statusHistory->map(fn ($item) => [
                'status' => $item->status instanceof ApplicationStatus ? $item->status->value : $item->status,
                'title' => $item->title,
                'note' => $item->note,
                'timestamp' => $item->created_at?->toISOString(),
            ]),
        ]);
    }

    public function acceptOffer(Request $request, int $id): TransactionResource
    {
        $user = $request->user();
        $application = PawnApplication::where('user_id', $user->id)->findOrFail($id);

        if ($application->status !== ApplicationStatus::Approved || ! $application->assessment) {
            abort(422, 'Penawaran belum tersedia untuk pengajuan ini.');
        }

        $transaction = DB::transaction(function () use ($application, $user): PawnTransaction {
            $transaction = PawnTransaction::firstOrCreate(
                ['pawn_application_id' => $application->id],
                [
                    'user_id' => $user->id,
                    'code' => $this->generateCode('TRX'),
                    'principal_amount' => $application->assessment->approved_principal,
                    'fee_amount' => $application->assessment->service_fee,
                    'tenor_days' => $application->assessment->tenor_days,
                    'start_date' => $application->assessment->start_date,
                    'due_date' => $application->assessment->due_date,
                    'status' => 'active',
                ],
            );

            $offer = PawnOffer::where('pawn_application_id', $application->id)->first();
            if ($offer) {
                $offer->forceFill(['status' => 'accepted', 'decided_at' => now()])->save();
            }

            $this->transitions->acceptOffer($application, $user);

            return $transaction;
        });

        return new TransactionResource($transaction->load(['application.category', 'payments']));
    }

    public function declineOffer(Request $request, int $id): ApplicationResource
    {
        $user = $request->user();
        $application = PawnApplication::where('user_id', $user->id)->findOrFail($id);

        if ($application->status !== ApplicationStatus::Approved) {
            abort(422, 'Penawaran tidak dapat ditolak pada status ini.');
        }

        DB::transaction(function () use ($application, $user): void {
            $offer = PawnOffer::where('pawn_application_id', $application->id)->first();
            if ($offer) {
                $offer->forceFill(['status' => 'declined', 'decided_at' => now()])->save();
            }
            $this->transitions->declineOffer($application, $user);
        });

        return new ApplicationResource($application->load(['category', 'assessment', 'statusHistory']));
    }

    private function generateCode(string $prefix): string
    {
        $last = DB::table('pawn_applications')->count() + 1;
        if ($prefix === 'TRX') {
            $last = PawnTransaction::count() + 1;
        }

        return $prefix.'-'.now()->year.'-'.str_pad((string) $last, 4, '0', STR_PAD_LEFT);
    }
}
