<?php

namespace App\Models;

use App\Enums\ApplicationStatus;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class PawnApplication extends Model
{
    protected $fillable = [
        'user_id',
        'category_id',
        'code',
        'status',
        'item_title',
        'item_details',
        'estimated_user_value',
        'preferred_tenor_days',
        'admin_note',
        'submitted_at',
    ];

    protected function casts(): array
    {
        return [
            'item_details' => 'array',
            'estimated_user_value' => 'decimal:2',
            'submitted_at' => 'datetime',
            'status' => ApplicationStatus::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function item(): HasOne
    {
        return $this->hasOne(PawnItem::class);
    }

    public function documents(): HasMany
    {
        return $this->hasMany(PawnDocument::class);
    }

    public function assessment(): HasOne
    {
        return $this->hasOne(PawnAssessment::class);
    }

    public function offer(): HasOne
    {
        return $this->hasOne(PawnOffer::class);
    }

    public function transaction(): HasOne
    {
        return $this->hasOne(PawnTransaction::class);
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(ApplicationStatusHistory::class)->orderBy('created_at');
    }

    public function scopeStatus(Builder $query, ?string $status): Builder
    {
        return $status ? $query->where('status', $status) : $query;
    }

    public function scopeSearch(Builder $query, ?string $search): Builder
    {
        if (! $search) {
            return $query;
        }

        return $query->where(function (Builder $q) use ($search): void {
            $q->where('code', 'like', "%{$search}%")
                ->orWhere('item_title', 'like', "%{$search}%")
                ->orWhereHas('user', function (Builder $u) use ($search): void {
                    $u->where('name', 'like', "%{$search}%");
                });
        });
    }
}
