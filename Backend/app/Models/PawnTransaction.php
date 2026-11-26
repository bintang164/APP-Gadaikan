<?php

namespace App\Models;

use App\Enums\TransactionStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PawnTransaction extends Model
{
    protected $fillable = [
        'user_id',
        'pawn_application_id',
        'code',
        'principal_amount',
        'fee_amount',
        'paid_amount',
        'tenor_days',
        'start_date',
        'due_date',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'principal_amount' => 'decimal:2',
            'fee_amount' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'start_date' => 'date',
            'due_date' => 'date',
            'status' => TransactionStatus::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class)->orderByDesc('created_at');
    }

    public function remainingAmount(): float
    {
        return max(0, (float) $this->principal_amount + (float) $this->fee_amount - (float) $this->paid_amount);
    }
}
