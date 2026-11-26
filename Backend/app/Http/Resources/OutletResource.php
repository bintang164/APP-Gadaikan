<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OutletResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'city' => $this->city,
            'hours' => $this->hours,
            'phone' => $this->phone ?? '',
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'is_demo' => (bool) $this->is_demo,
        ];
    }
}
