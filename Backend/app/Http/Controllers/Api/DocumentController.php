<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\DocumentUploadRequest;
use App\Models\PawnDocument;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class DocumentController extends Controller
{
    public function store(DocumentUploadRequest $request): JsonResponse
    {
        $file = $request->file('file');
        $mime = $file->getMimeType();

        if (! in_array($mime, ['image/jpeg', 'image/png', 'application/pdf'], true)) {
            return response()->json([
                'message' => 'Tipe MIME berkas tidak diizinkan.',
                'errors' => ['file' => ['Gunakan JPG, PNG, atau PDF.']],
            ], 422);
        }

        // Disk "local" mengarah ke storage/app/private, bukan public.
        $path = $file->store('documents/'.$request->user()->id, 'local');

        $document = PawnDocument::create([
            'uploaded_by' => $request->user()->id,
            'label' => $request->input('label', 'Berkas'),
            'file_name' => $file->getClientOriginalName(),
            'path' => $path,
            'mime_type' => $mime,
            'size_bytes' => $file->getSize(),
            'is_sensitive' => $request->boolean('is_sensitive'),
        ]);

        // Tidak mengembalikan path/URL privat ke klien.
        return response()->json([
            'id' => $document->id,
            'label' => $document->label,
            'file_name' => $document->file_name,
            'size_label' => round($document->size_bytes / 1024 / 1024, 2).' MB',
            'is_sensitive' => (bool) $document->is_sensitive,
        ], 201);
    }
}
