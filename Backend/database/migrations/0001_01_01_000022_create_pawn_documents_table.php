<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pawn_documents', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('pawn_application_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('uploaded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('label');
            $table->string('file_name');
            $table->string('path');
            $table->string('mime_type', 100);
            $table->unsignedBigInteger('size_bytes');
            $table->boolean('is_sensitive')->default(false);
            $table->timestamps();

            $table->index(['pawn_application_id', 'is_sensitive']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pawn_documents');
    }
};
