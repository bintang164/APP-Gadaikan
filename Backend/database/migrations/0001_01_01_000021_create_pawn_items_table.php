<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pawn_items', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('pawn_application_id')->constrained()->cascadeOnDelete();
            $table->json('details');
            $table->text('condition_notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pawn_items');
    }
};
