<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pawn_offers', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('pawn_application_id')->constrained()->cascadeOnDelete();
            $table->foreignId('pawn_assessment_id')->constrained()->cascadeOnDelete();
            $table->string('status')->default('pending')->index();
            $table->timestamp('decided_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pawn_offers');
    }
};
