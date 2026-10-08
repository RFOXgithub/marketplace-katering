<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class CustomerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $customers = [
            ['office' => 'PT Maju Jaya', 'pic' => 'Budi Santoso', 'city' => 'Jakarta', 'address' => 'Jl. Sudirman No. 25'],
            ['office' => 'PT Sentosa Abadi', 'pic' => 'Siti Aminah', 'city' => 'Bandung', 'address' => 'Jl. Dago No. 11'],
            ['office' => 'PT Cipta Karya', 'pic' => 'Agus Wijaya', 'city' => 'Surabaya', 'address' => 'Jl. Darmo No. 30'],
            ['office' => 'PT Mitra Sukses', 'pic' => 'Dewi Lestari', 'city' => 'Yogyakarta', 'address' => 'Jl. Kaliurang No. 6'],
            ['office' => 'PT Bina Usaha', 'pic' => 'Hendra Gunawan', 'city' => 'Semarang', 'address' => 'Jl. Pahlawan No. 9'],
            ['office' => 'PT Karya Mandiri', 'pic' => 'Rina Marlina', 'city' => 'Medan', 'address' => 'Jl. Imam Bonjol No. 14'],
            ['office' => 'PT Sumber Rejeki', 'pic' => 'Fajar Nugroho', 'city' => 'Makassar', 'address' => 'Jl. Veteran No. 21'],
            ['office' => 'PT Anugrah Sejati', 'pic' => 'Lina Kartika', 'city' => 'Denpasar', 'address' => 'Jl. Teuku Umar No. 17'],
            ['office' => 'PT Bumi Perkasa', 'pic' => 'Yoga Pratama', 'city' => 'Palembang', 'address' => 'Jl. R Sukamto No. 2'],
            ['office' => 'PT Cahaya Timur', 'pic' => 'Maya Puspita', 'city' => 'Balikpapan', 'address' => 'Jl. Jendral Sudirman No. 13'],
        ];

        foreach ($customers as $index => $customer) {
            $number = $index + 1;

            $user = User::create([
                'name' => $customer['office'],
                'email' => "customer{$number}@gmail.com",
                'password' => Hash::make('customer123'),
                'role' => 'customer',
                'phone' => '08129876' . str_pad((string) $number, 4, '0', STR_PAD_LEFT),
            ]);

            Customer::create([
                'user_id' => $user->id,
                'office_name' => $customer['office'],
                'address' => $customer['address'],
                'city' => $customer['city'],
                'contact_phone' => $user->phone,
                'pic_name' => $customer['pic'],
            ]);
        }
    }
}
