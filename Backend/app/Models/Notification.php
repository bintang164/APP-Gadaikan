<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'title',
        'body',
        'application_id',
        'transaction_id',
        'read_at',
    ];

    protected function casts(): array
    {
        return ['read_at' => 'datetime'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(PawnTransaction::class);
    }

    public function isRead(): bool
    {
        return $this->read_at !== null;
    }
}
