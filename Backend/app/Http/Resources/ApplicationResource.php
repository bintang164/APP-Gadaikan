<?php

namespace App\Http\Resources;

use App\Enums\ApplicationStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $status = $this->status instanceof ApplicationStatus
            ? $this->status
            : ApplicationStatus::from((string) $this->status);

        return [
            'id' => $this->id,
            'code' => $this->code,
            'category' => $this->whenLoaded('category', fn () => $this->category->code),
            'category_id' => $this->category_id,
            'item_title' => $this->item_title,
            'item_details' => $this->item_details ?? [],
            'status' => $status->value,
            'status_label' => $status->label(),
            'estimated_value' => $this->estimated_user_value !== null ? (float) $this->estimated_user_value : null,
            'preferred_tenor_days' => $this->preferred_tenor_days,
            'admin_note' => $this->admin_note,
            'applicant' => $this->whenLoaded('user', fn () => [
                'name' => $this->user->name,
                'phone' => $this->user->phone,
                'email' => $this->user->email,
            ]),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
            'assessment' => $this->whenLoaded('assessment', function (): array {
                $assessment = $this->assessment;

                if (! $assessment) {
                    return [];
                }

                return [
                    'assessed_value' => (float) $assessment->assessed_value,
                    'plafon_percentage' => $assessment->plafon_percentage !== null
                        ? (float) $assessment->plafon_percentage
                        : null,
                    'approved_principal' => (float) $assessment->approved_principal,
                    'service_fee' => (float) $assessment->service_fee,
                    'tenor_days' => $assessment->tenor_days,
                    'start_date' => $assessment->start_date?->toISOString(),
                    'due_date' => $assessment->due_date?->toISOString(),
                    'notes' => $assessment->customer_note,
                ];
            }),
            'status_history' => $this->whenLoaded('statusHistory', fn () => $this->statusHistory->map(fn ($item) => [
                'status' => $item->status instanceof ApplicationStatus ? $item->status->value : $item->status,
                'title' => $item->title,
                'note' => $item->note,
                'timestamp' => $item->created_at?->toISOString(),
            ])->values()->all()),
            'documents' => $this->whenLoaded('documents', fn () => $this->documents->map(fn ($doc) => [
                'id' => $doc->id,
                'label' => $doc->label,
                'file_name' => $doc->file_name,
                'size_label' => round($doc->size_bytes / 1024 / 1024, 2).' MB',
                'is_sensitive' => (bool) $doc->is_sensitive,
            ])->values()->all()),
        ];
    }
}
