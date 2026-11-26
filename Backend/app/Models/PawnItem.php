<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PawnItem extends Model
{
    protected $fillable = [
        'pawn_application_id',
        'details',
        'condition_notes',
    ];

    protected function casts(): array
    {
        return ['details' => 'array'];
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }
}
