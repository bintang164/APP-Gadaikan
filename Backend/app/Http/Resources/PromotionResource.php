<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PromotionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'period' => $this->period,
            'summary' => $this->summary,
            'terms' => $this->terms,
            'badge_text' => $this->badge_text,
            'is_demo' => (bool) $this->is_demo,
        ];
    }
}
