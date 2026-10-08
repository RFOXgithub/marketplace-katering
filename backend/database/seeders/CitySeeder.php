<?php

namespace Database\Seeders;

use App\Models\City;
use Illuminate\Database\Seeder;

class CitySeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * List of Indonesia's officially administrated "Kota" (cities),
     * grouped by province. Compiled from general knowledge, not scraped
     * from an official source — flag any missing/misspelled entry so it
     * can be corrected here.
     */
    public function run(): void
    {
        $citiesByProvince = [
            'Aceh' => ['Banda Aceh', 'Sabang', 'Langsa', 'Lhokseumawe', 'Subulussalam'],
            'Sumatera Utara' => ['Medan', 'Binjai', 'Tebing Tinggi', 'Pematangsiantar', 'Tanjungbalai', 'Sibolga', 'Padangsidempuan', 'Gunungsitoli'],
            'Sumatera Barat' => ['Padang', 'Bukittinggi', 'Padang Panjang', 'Pariaman', 'Payakumbuh', 'Sawahlunto', 'Solok'],
            'Riau' => ['Pekanbaru', 'Dumai'],
            'Kepulauan Riau' => ['Batam', 'Tanjungpinang'],
            'Jambi' => ['Jambi', 'Sungai Penuh'],
            'Sumatera Selatan' => ['Palembang', 'Lubuklinggau', 'Pagar Alam', 'Prabumulih'],
            'Kepulauan Bangka Belitung' => ['Pangkalpinang'],
            'Bengkulu' => ['Bengkulu'],
            'Lampung' => ['Bandar Lampung', 'Metro'],
            'DKI Jakarta' => ['Jakarta Pusat', 'Jakarta Utara', 'Jakarta Barat', 'Jakarta Selatan', 'Jakarta Timur'],
            'Jawa Barat' => ['Bandung', 'Banjar', 'Bekasi', 'Bogor', 'Cimahi', 'Cirebon', 'Depok', 'Sukabumi', 'Tasikmalaya'],
            'Jawa Tengah' => ['Semarang', 'Magelang', 'Pekalongan', 'Salatiga', 'Surakarta', 'Tegal'],
            'DI Yogyakarta' => ['Yogyakarta'],
            'Jawa Timur' => ['Surabaya', 'Batu', 'Blitar', 'Kediri', 'Madiun', 'Malang', 'Mojokerto', 'Pasuruan', 'Probolinggo'],
            'Banten' => ['Serang', 'Cilegon', 'Tangerang', 'Tangerang Selatan'],
            'Bali' => ['Denpasar'],
            'Nusa Tenggara Barat' => ['Mataram', 'Bima'],
            'Nusa Tenggara Timur' => ['Kupang'],
            'Kalimantan Barat' => ['Pontianak', 'Singkawang'],
            'Kalimantan Tengah' => ['Palangka Raya'],
            'Kalimantan Selatan' => ['Banjarmasin', 'Banjarbaru'],
            'Kalimantan Timur' => ['Balikpapan', 'Samarinda', 'Bontang'],
            'Kalimantan Utara' => ['Tarakan'],
            'Sulawesi Utara' => ['Manado', 'Bitung', 'Tomohon', 'Kotamobagu'],
            'Gorontalo' => ['Gorontalo'],
            'Sulawesi Tengah' => ['Palu'],
            'Sulawesi Selatan' => ['Makassar', 'Palopo', 'Parepare'],
            'Sulawesi Tenggara' => ['Kendari', 'Baubau'],
            'Maluku' => ['Ambon', 'Tual'],
            'Maluku Utara' => ['Ternate', 'Tidore Kepulauan'],
            'Papua' => ['Jayapura'],
            'Papua Barat' => ['Sorong'],
        ];

        foreach ($citiesByProvince as $province => $cities) {
            foreach ($cities as $city) {
                City::updateOrCreate(
                    ['name' => $city],
                    ['province' => $province],
                );
            }
        }
    }
}
