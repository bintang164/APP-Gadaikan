<?php

namespace App\Http\Resources;

use App\Enums\TransactionStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $status = $this->status instanceof TransactionStatus
            ? $this->status
            : TransactionStatus::from((string) $this->status);

        return [
            'id' => $this->id,
            'code' => $this->code,
            'application_id' => $this->pawn_application_id,
            'item_title' => $this->whenLoaded('application', fn () => $this->application?->item_title ?? ''),
            'category' => $this->whenLoaded('application', fn () => $this->application?->category?->code ?? ''),
            'principal_amount' => (float) $this->principal_amount,
            'fee_amount' => (float) $this->fee_amount,
            'paid_amount' => (float) $this->paid_amount,
            'tenor_days' => $this->tenor_days,
            'start_date' => $this->start_date?->toISOString(),
            'due_date' => $this->due_date?->toISOString(),
            'status' => $status->value,
            'status_label' => $status->label(),
            'remaining_amount' => $this->remainingAmount(),
            'payments' => $this->whenLoaded('payments', fn () => $this->payments->map(fn ($payment) => [
                'id' => $payment->id,
                'amount' => (float) $payment->amount,
                'method' => $payment->method,
                'paid_at' => $payment->created_at?->toISOString(),
                'note' => $payment->note,
                'is_demo' => (bool) $payment->is_demo,
            ])->values()->all()),
        ];
    }
}
