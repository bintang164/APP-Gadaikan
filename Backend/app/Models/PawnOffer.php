<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PawnOffer extends Model
{
    protected $fillable = [
        'pawn_application_id',
        'pawn_assessment_id',
        'status',
        'decided_at',
    ];

    protected function casts(): array
    {
        return ['decided_at' => 'datetime'];
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }

    public function assessment(): BelongsTo
    {
        return $this->belongsTo(PawnAssessment::class);
    }
}
