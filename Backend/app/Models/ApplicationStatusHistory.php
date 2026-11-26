<?php

namespace App\Models;

use App\Enums\ApplicationStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ApplicationStatusHistory extends Model
{
    protected $fillable = [
        'pawn_application_id',
        'status',
        'title',
        'note',
        'changed_by',
    ];

    protected function casts(): array
    {
        return ['status' => ApplicationStatus::class];
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }

    public function changer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
