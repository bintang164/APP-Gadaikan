<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Outlet extends Model
{
    protected $fillable = [
        'name',
        'address',
        'city',
        'hours',
        'phone',
        'latitude',
        'longitude',
        'is_demo',
    ];

    protected function casts(): array
    {
        return [
            'is_demo' => 'boolean',
            'latitude' => 'float',
            'longitude' => 'float',
        ];
    }
}
