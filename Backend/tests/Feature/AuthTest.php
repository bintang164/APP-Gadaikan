<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\AdminSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_validates_input_and_returns_token(): void
    {
        $this->postJson('/api/register', [
            'name' => 'U',
            'phone' => 'abc',
            'email' => 'bukan-email',
            'password' => 'pendek',
        ])->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'phone', 'email', 'password']);

        $response = $this->postJson('/api/register', [
            'name' => 'Pelanggan Demo',
            'phone' => '081234567890',
            'email' => 'pelanggan.demo@gadaikan.test',
            'password' => 'demo1234',
            'password_confirmation' => 'demo1234',
        ]);

        $response->assertCreated()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'phone', 'email', 'role']]);

        $this->assertDatabaseHas('users', [
            'phone' => '081234567890',
            'role' => 'customer',
        ]);

        $this->assertNotEquals(
            'demo1234',
            User::where('phone', '081234567890')->firstOrFail()->password,
        );
    }

    public function test_login_rejects_wrong_password_with_401(): void
    {
        $user = User::factory()->create([
            'phone' => '081234567890',
            'email' => 'pelanggan@gadaikan.test',
            'password' => 'demo1234',
        ]);

        $this->postJson('/api/login', [
            'identifier' => '081234567890',
            'password' => 'salah12345',
        ])->assertStatus(401);

        $this->postJson('/api/login', [
            'identifier' => '081234567890',
            'password' => 'demo1234',
        ])->assertOk()->assertJsonStructure(['token', 'user']);
    }

    public function test_admin_endpoint_rejects_customer(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $token = $customer->createToken('test')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/admin/dashboard')
            ->assertStatus(403);
    }

    public function test_admin_endpoint_allows_admin(): void
    {
        $this->seed(AdminSeeder::class);

        $response = $this->postJson('/api/login', [
            'identifier' => 'admin.demo@gadaikan.test',
            'password' => 'demo1234',
        ])->assertOk();

        $this->withToken($response->json('token'))
            ->getJson('/api/admin/dashboard')
            ->assertOk()
            ->assertJsonStructure(['total', 'submitted', 'approved']);
    }
}
