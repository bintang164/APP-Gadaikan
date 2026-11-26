<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('simulation_configs', function (Blueprint $table): void {
            $table->id();
            $table->json('plafon_percentage_by_category');
            $table->decimal('fee_rate_per_period', 8, 5);
            $table->unsignedSmallInteger('period_days');
            $table->json('allowed_tenor_days');
            $table->decimal('min_estimated_value', 15, 2);
            $table->decimal('max_estimated_value', 15, 2);
            $table->text('disclaimer');
            $table->boolean('is_demo')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('simulation_configs');
    }
};
