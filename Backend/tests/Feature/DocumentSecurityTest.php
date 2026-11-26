<?php

namespace Tests\Feature;

use App\Models\PawnApplication;
use App\Models\PawnDocument;
use App\Models\User;
use Database\Seeders\AdminSeeder;
use Database\Seeders\CategorySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DocumentSecurityTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([CategorySeeder::class, AdminSeeder::class]);
        Storage::fake('local');
    }

    public function test_invalid_file_type_is_rejected(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $this->withToken($token)
            ->post('/api/pawn-applications/documents', [
                'file' => UploadedFile::fake()->create('script.exe', 10),
                'label' => 'Berkas',
            ])->assertStatus(422);

        $this->withToken($token)
            ->post('/api/pawn-applications/documents', [
                'file' => UploadedFile::fake()->create('besar.pdf', 6000, 'application/pdf'),
                'label' => 'Berkas',
            ])->assertStatus(422);
    }

    public function test_private_document_is_not_public(): void
    {
        $customer = User::factory()->create();
        $application = PawnApplication::create([
            'user_id' => $customer->id,
            'category_id' => 1,
            'code' => 'GDK-TEST-0001',
            'status' => 'submitted',
            'item_title' => 'Barang',
            'item_details' => [],
        ]);

        $document = PawnDocument::create([
            'pawn_application_id' => $application->id,
            'uploaded_by' => $customer->id,
            'label' => 'BPKB',
            'file_name' => 'bpkb.jpg',
            'path' => 'documents/1/bpkb.jpg',
            'mime_type' => 'image/jpeg',
            'size_bytes' => 1024,
            'is_sensitive' => true,
        ]);

        Storage::disk('local')->put('documents/1/bpkb.jpg', 'isi privat');

        // Endpoint publik tidak ada; hanya endpoint admin terotorisasi.
        $this->get("/api/documents/{$document->id}")->assertNotFound();

        $customerToken = $customer->createToken('test')->plainTextToken;
        $this->withToken($customerToken)
            ->get("/api/admin/applications/{$application->id}/documents/{$document->id}")
            ->assertStatus(403);

        $admin = User::where('role', 'admin')->firstOrFail();
        $adminToken = $admin->createToken('test')->plainTextToken;
        $this->withToken($adminToken)
            ->get("/api/admin/applications/{$application->id}/documents/{$document->id}")
            ->assertOk();
    }
}
