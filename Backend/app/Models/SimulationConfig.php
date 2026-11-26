<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SimulationConfig extends Model
{
    protected $fillable = [
        'plafon_percentage_by_category',
        'fee_rate_per_period',
        'period_days',
        'allowed_tenor_days',
        'min_estimated_value',
        'max_estimated_value',
        'disclaimer',
        'is_demo',
    ];

    protected function casts(): array
    {
        return [
            'plafon_percentage_by_category' => 'array',
            'allowed_tenor_days' => 'array',
            'fee_rate_per_period' => 'decimal:5',
            'min_estimated_value' => 'decimal:2',
            'max_estimated_value' => 'decimal:2',
            'is_demo' => 'boolean',
        ];
    }
}
