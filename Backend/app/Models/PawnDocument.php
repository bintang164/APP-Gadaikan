<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PawnDocument extends Model
{
    protected $fillable = [
        'pawn_application_id',
        'uploaded_by',
        'label',
        'file_name',
        'path',
        'mime_type',
        'size_bytes',
        'is_sensitive',
    ];

    protected $hidden = ['path'];

    protected function casts(): array
    {
        return ['is_sensitive' => 'boolean'];
    }

    public function application(): BelongsTo
    {
        return $this->belongsTo(PawnApplication::class);
    }
}
