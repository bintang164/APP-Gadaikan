<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Promotion extends Model
{
    protected $fillable = [
        'title',
        'period',
        'summary',
        'terms',
        'badge_text',
        'is_demo',
    ];

    protected function casts(): array
    {
        return ['is_demo' => 'boolean'];
    }
}
