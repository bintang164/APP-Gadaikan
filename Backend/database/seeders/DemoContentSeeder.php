<?php

namespace Database\Seeders;

use App\Models\Faq;
use App\Models\Outlet;
use App\Models\Promotion;
use App\Models\SimulationConfig;
use Illuminate\Database\Seeder;

class DemoContentSeeder extends Seeder
{
    public function run(): void
    {
        SimulationConfig::updateOrCreate(['id' => 1], [
            'plafon_percentage_by_category' => [
                'elektronik' => 0.70,
                'emas' => 0.85,
                'bpkb' => 0.75,
            ],
            'fee_rate_per_period' => 0.015,
            'period_days' => 15,
            'allowed_tenor_days' => [15, 30, 60, 90],
            'min_estimated_value' => 300000,
            'max_estimated_value' => 100000000,
            'disclaimer' => 'Hasil simulasi, bukan penawaran final. Tarif dan plafon akhir ditentukan setelah pemeriksaan fisik dan dokumen.',
            'is_demo' => true,
        ]);

        Outlet::updateOrCreate(['name' => 'Gadaikan Cabang Demo Pusat'], [
            'address' => 'Jl. Contoh No. 1 (alamat demo, bukan outlet nyata)',
            'city' => 'Jakarta',
            'hours' => 'Senin - Jumat, 09.00 - 16.00 WIB',
            'phone' => '(021) 000-0000',
            'latitude' => null,
            'longitude' => null,
            'is_demo' => true,
        ]);

        Promotion::updateOrCreate(['title' => 'Promo Contoh (Demo)'], [
            'period' => 'Berlaku selama masa demo',
            'summary' => 'Contoh informasi promo untuk menguji tampilan aplikasi. Bukan promo resmi.',
            'terms' => 'Tidak dapat dicairkan atau ditukar dengan uang.',
            'badge_text' => 'Simulasi Demo',
            'is_demo' => true,
        ]);

        Faq::updateOrCreate(['question' => 'Apakah data di aplikasi ini nyata?'], [
            'answer' => ' Sebagian besar data adalah simulasi demo untuk keperluan pengujian. Tidak ada transaksi uang sungguhan.',
            'is_demo' => true,
        ]);
    }
}
