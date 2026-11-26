<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'code' => 'elektronik',
                'name' => 'Elektronik',
                'description' => 'Ponsel, laptop, kamera, dan perangkat gadget lain.',
                'requirements' => [
                    'Jenis, merek, dan model perangkat',
                    'Kondisi fisik dan fungsi',
                    'Kelengkapan (charger, dus, aksesori)',
                    'Foto barang dari beberapa sisi',
                ],
            ],
            [
                'code' => 'emas',
                'name' => 'Emas',
                'description' => 'Perhiasan atau emas batangan.',
                'requirements' => [
                    'Jenis emas/perhiasan dan perkiraan berat',
                    'Kadar/karat bila diketahui',
                    'Foto barang dengan pencahayaan jelas',
                    'Bukti pembelian/sertifikat bila tersedia',
                ],
            ],
            [
                'code' => 'bpkb',
                'name' => 'BPKB Kendaraan',
                'description' => 'Pengajuan dengan dokumen kendaraan.',
                'requirements' => [
                    'Jenis kendaraan, merek/model, dan tahun',
                    'Nomor polisi serta nama pemilik sesuai dokumen',
                    'Foto BPKB dan dokumen pendukung',
                    'Foto kendaraan tampak depan/samping',
                ],
            ],
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate(['code' => $category['code']], $category);
        }
    }
}
