<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type,
            'application_id' => $this->pawn_application_id,
            'transaction_id' => $this->pawn_transaction_id,
            'is_read' => $this->isRead(),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
