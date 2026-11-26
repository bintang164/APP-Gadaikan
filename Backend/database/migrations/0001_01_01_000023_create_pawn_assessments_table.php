<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pawn_assessments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('pawn_application_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('assessed_by')->constrained('users')->restrictOnDelete();
            $table->decimal('assessed_value', 15, 2);
            $table->decimal('plafon_percentage', 5, 2)->nullable();
            $table->decimal('approved_principal', 15, 2);
            $table->decimal('service_fee', 15, 2)->default(0);
            $table->unsignedSmallInteger('tenor_days');
            $table->date('start_date');
            $table->date('due_date');
            $table->text('customer_note')->nullable();
            $table->text('internal_note')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pawn_assessments');
    }
};
