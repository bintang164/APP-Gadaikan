<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        // Kredensial demo dibaca dari environment. Jangan gunakan
        // kredensial produksi di sini.
        $email = env('DEMO_ADMIN_EMAIL', 'admin.demo@gadaikan.test');
        $phone = env('DEMO_ADMIN_PHONE', '081200000000');
        $password = env('DEMO_ADMIN_PASSWORD', 'demo1234');

        $admin = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Admin Demo',
                'phone' => $phone,
                'password' => $password,
                'role' => 'admin',
            ],
        );

        $admin->profile()->firstOrCreate([]);
    }
}
