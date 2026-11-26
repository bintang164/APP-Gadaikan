<?php

namespace Tests\Feature;

use App\Models\PawnApplication;
use Database\Seeders\AdminSeeder;
use Database\Seeders\CategorySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class EndToEndFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([CategorySeeder::class, AdminSeeder::class]);
        Storage::fake('local');
    }

    public function test_full_customer_and_admin_flow(): void
    {
        // 1. Register nasabah.
        $register = $this->postJson('/api/register', [
            'name' => 'Pelanggan Demo',
            'phone' => '081234567890',
            'email' => 'pelanggan@gadaikan.test',
            'password' => 'demo1234',
            'password_confirmation' => 'demo1234',
        ])->assertCreated();

        $customerToken = $register->json('token');
        $this->assertNotEmpty($customerToken);

        // 2/3. Login & profil/kategori.
        $this->withToken($customerToken)
            ->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('role', 'customer');

        $categories = $this->withToken($customerToken)
            ->getJson('/api/categories')
            ->assertOk();
        $this->assertCount(3, $categories->json('data'));

        // 4/5. Upload dokumen privat lalu pilih kategori & isi form.
        // Multipart request: gunakan post(), bukan postJson().
        $upload = $this->withToken($customerToken)
            ->post('/api/pawn-applications/documents', [
                'file' => UploadedFile::fake()->image('foto-depan.jpg', 120, 120),
                'label' => 'Foto Barang (Tampak Depan)',
                'is_sensitive' => false,
            ])->assertCreated();

        $documentId = $upload->json('id');
        $this->assertNotNull($documentId);
        $this->assertArrayNotHasKey('path', $upload->json());

        // 6/7. Review & submit pengajuan.
        $application = $this->withToken($customerToken)
            ->postJson('/api/pawn-applications', [
                'category' => 'elektronik',
                'item_title' => 'Laptop Demo',
                'item_details' => [
                    'Merek' => 'Contoh',
                    'Model/Tipe' => 'Demo 1',
                    'Kondisi Fisik' => 'Baik',
                ],
                'estimated_value' => 5000000,
                'preferred_tenor_days' => 30,
                'documents' => [['id' => $documentId]],
            ])
            ->assertCreated()
            ->json();

        $applicationId = $application['id'];
        $applicationCode = $application['code'];
        $this->assertSame('submitted', $application['status']);

        // 8. Pengajuan tampil di akun nasabah.
        $this->withToken($customerToken)
            ->getJson('/api/pawn-applications')
            ->assertOk()
            ->assertJsonFragment(['code' => $applicationCode]);

        // 9. Admin login & melihat pengajuan.
        $adminLogin = $this->postJson('/api/login', [
            'identifier' => 'admin.demo@gadaikan.test',
            'password' => 'demo1234',
        ])->assertOk();
        $adminToken = $adminLogin->json('token');

        $this->withToken($adminToken)
            ->getJson('/api/admin/dashboard')
            ->assertOk()
            ->assertJsonPath('total', 1);

        $this->withToken($adminToken)
            ->getJson('/api/admin/applications?search='.urlencode($applicationCode))
            ->assertOk()
            ->assertJsonFragment(['code' => $applicationCode]);

        // 10. Admin meminta revisi.
        $this->withToken($adminToken)
            ->postJson("/api/admin/applications/{$applicationId}/request-revision", [
                'reason' => 'Mohon tambahkan foto sisi belakang perangkat.',
            ])->assertOk();

        $this->withToken($customerToken)
            ->getJson("/api/pawn-applications/{$applicationId}")
            ->assertOk()
            ->assertJsonPath('status', 'revision_required')
            ->assertJsonFragment(['title' => 'Perlu Perbaikan']);

        // 11. Admin memasukkan penaksiran & keputusan (approval).
        $assessment = [
            'assessed_value' => 5000000,
            'plafon_percentage' => 80,
            'approved_principal' => 4000000,
            'service_fee' => 180000,
            'tenor_days' => 30,
            'start_date' => now()->toDateString(),
            'due_date' => now()->addDays(30)->toDateString(),
            'customer_note' => 'Penawaran siap ditinjau.',
        ];

        $this->withToken($adminToken)
            ->postJson("/api/admin/applications/{$applicationId}/assessment", $assessment)
            ->assertOk()
            ->assertJsonPath('status', 'approved');

        // 12. Nasabah melihat timeline & penawaran.
        $detail = $this->withToken($customerToken)
            ->getJson("/api/pawn-applications/{$applicationId}")
            ->assertOk()
            ->assertJsonPath('status', 'approved');

        $this->assertEquals(4000000, (float) $detail->json('assessment.approved_principal'));
        $this->assertCount(4, $detail->json('status_history'));

        // 13/14. Terima penawaran -> transaksi terbentuk.
        $transaction = $this->withToken($customerToken)
            ->postJson("/api/pawn-applications/{$applicationId}/accept-offer")
            ->assertOk()
            ->json();

        $this->assertSame('active', $transaction['status']);
        $this->assertStringStartsWith('TRX-', $transaction['code']);

        $this->withToken($customerToken)
            ->getJson('/api/transactions')
            ->assertOk()
            ->assertJsonFragment(['code' => $transaction['code']]);

        // 15. Pembayaran demo dicatat backend.
        $paid = $this->withToken($customerToken)
            ->postJson("/api/transactions/{$transaction['id']}/demo-payment", [
                'amount' => 1000000,
                'method' => 'Transfer Bank',
            ])
            ->assertOk();

        $this->assertSame('1000000.00', $paid->json('paid_amount'));
        $this->assertTrue($paid->json('payments.0.is_demo'));
        $this->assertSame('active', $paid->json('status'));

        // 16. Riwayat & notifikasi konsisten.
        $notifications = $this->withToken($customerToken)
            ->getJson('/api/notifications')
            ->assertOk();
        $this->assertNotEmpty($notifications->json('data'));

        $this->withToken($customerToken)
            ->postJson('/api/notifications/read-all')
            ->assertOk();

        $this->withToken($customerToken)
            ->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonPath('data.0.is_read', true);

        // Tidak ada data pengguna lain yang bocor.
        $other = $this->postJson('/api/register', [
            'name' => 'Pengguna Lain',
            'phone' => '081299999999',
            'email' => 'lain@gadaikan.test',
            'password' => 'demo1234',
            'password_confirmation' => 'demo1234',
        ])->assertCreated()->json('token');

        $this->withToken($other)
            ->getJson("/api/pawn-applications/{$applicationId}")
            ->assertNotFound();

        $this->assertDatabaseCount('admin_activity_logs', 6);
    }
}
