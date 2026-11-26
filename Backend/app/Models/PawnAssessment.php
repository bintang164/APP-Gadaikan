<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class PawnAssessment extends Model
{
    protected $fillable = [
        'pawn_application_id',
        'assessed_by',
        'assessed_value',
        'plafon_percentage',
        'approved_principal',
        'service_fee',
        'tenor_days',
        'start_date',
        'due_date',
        'customer_note',
        'internal_note',
    ];

    protected function casts(): array
    {
        return [
            'assessed_value' => 'decimal:2',
            'plafon_percentage' => 'decimal:2',
            'approved_principal' => 'decimal:2',
            'service_fee' => 'decimal:2',
            'start_date' => 'date',
            'due_date' => 'date',
        ];
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }

    public function assessor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assessed_by');
    }

    public function offer(): HasOne
    {
        return $this->hasOne(PawnOffer::class);
    }
}
