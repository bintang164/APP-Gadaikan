<?php

namespace App\Services;

use App\Enums\ApplicationStatus;
use App\Models\AdminActivityLog;
use App\Models\ApplicationStatusHistory;
use App\Models\Notification;
use App\Models\PawnApplication;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/**
 * Satu-satunya tempat transisi status divalidasi dan dicatat.
 * Controller tidak boleh mengubah status pengajuan secara langsung.
 */
class StatusTransitionService
{
    /** @var array<string, array<int, string>> */
    private const ALLOWED = [
        'submitted' => ['under_review', 'revision_required', 'rejected', 'cancelled'],
        'under_review' => ['revision_required', 'approved', 'rejected'],
        'revision_required' => ['under_review', 'submitted'],
        'approved' => ['offer_accepted', 'offer_declined', 'cancelled'],
        'rejected' => [],
        'offer_accepted' => [],
        'offer_declined' => [],
        'cancelled' => [],
        'draft' => ['submitted'],
    ];

    public function submit(PawnApplication $application, User $actor): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::Submitted,
            $actor,
            'Pengajuan diterima dan menunggu pemeriksaan.',
            ['event' => 'application_submitted'],
            'application_submitted',
        );
    }

    public function requestRevision(PawnApplication $application, User $actor, string $reason): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::RevisionRequired,
            $actor,
            $reason,
            ['event' => 'request_revision'],
            'revision_required',
        );
    }

    public function startReview(PawnApplication $application, User $actor): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::UnderReview,
            $actor,
            'Pengajuan sedang diperiksa petugas.',
            ['event' => 'review_started'],
        );
    }

    public function approve(PawnApplication $application, User $actor, ?string $note): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::Approved,
            $actor,
            $note ?? 'Penaksiran selesai. Penawaran siap ditinjau.',
            ['event' => 'approved'],
            'offer_available',
        );
    }

    public function reject(PawnApplication $application, User $actor, string $reason): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::Rejected,
            $actor,
            $reason,
            ['event' => 'rejected'],
            'rejected',
        );
    }

    public function acceptOffer(PawnApplication $application, User $actor): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::OfferAccepted,
            $actor,
            'Nasabah menerima penawaran.',
            ['event' => 'offer_accepted'],
        );
    }

    public function declineOffer(PawnApplication $application, User $actor): PawnApplication
    {
        return $this->transition(
            $application,
            ApplicationStatus::OfferDeclined,
            $actor,
            'Nasabah menolak penawaran.',
            ['event' => 'offer_declined'],
        );
    }

    public function canTransition(ApplicationStatus $from, ApplicationStatus $to): bool
    {
        return in_array($to->value, self::ALLOWED[$from->value] ?? [], true);
    }

    private function transition(
        PawnApplication $application,
        ApplicationStatus $next,
        User $actor,
        string $note,
        array $metadata,
        ?string $notificationType = null,
    ): PawnApplication {
        $current = $application->status instanceof ApplicationStatus
            ? $application->status
            : ApplicationStatus::from((string) $application->status);

        if (! $this->canTransition($current, $next)) {
            throw new InvalidArgumentException(
                "Transisi status {$current->value} -> {$next->value} tidak diizinkan.",
            );
        }

        return DB::transaction(function () use ($application, $next, $actor, $note, $metadata, $notificationType, $current): PawnApplication {
            $application->forceFill([
                'status' => $next->value,
                'admin_note' => $note,
            ])->save();

            ApplicationStatusHistory::create([
                'pawn_application_id' => $application->id,
                'status' => $next->value,
                'title' => $next->label(),
                'note' => $note,
                'changed_by' => $actor->id,
            ]);

            AdminActivityLog::create([
                'actor_id' => $actor->id,
                'action' => $metadata['event'] ?? 'status_changed',
                'subject_type' => PawnApplication::class,
                'subject_id' => $application->id,
                'metadata' => array_merge($metadata, [
                    'from' => $current->value,
                    'to' => $next->value,
                ]),
                'ip_address' => request()?->ip(),
            ]);

            if ($notificationType !== null && $application->user_id !== $actor->id) {
                Notification::create([
                    'user_id' => $application->user_id,
                    'type' => $notificationType,
                    'title' => $next->label(),
                    'body' => $note,
                    'application_id' => $application->id,
                ]);
            }

            return $application->refresh();
        });
    }
}
