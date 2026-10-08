<?php

namespace Database\Seeders;

use App\Models\Merchant;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MerchantSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $logoPath = $this->seedLogoPath();

        $merchants = [
            ['name' => 'Katering Berkah', 'city' => 'Jakarta', 'address' => 'Jl. Merdeka No. 10', 'min_order_pax' => 10, 'total_orders' => 120, 'rating_avg' => 4.8, 'rating_count' => 96],
            ['name' => 'Katering Sari Rasa', 'city' => 'Bandung', 'address' => 'Jl. Asia Afrika No. 22', 'min_order_pax' => 15, 'total_orders' => 98, 'rating_avg' => 4.7, 'rating_count' => 80],
            ['name' => 'Katering Nusantara', 'city' => 'Surabaya', 'address' => 'Jl. Pemuda No. 5', 'min_order_pax' => 10, 'total_orders' => 85, 'rating_avg' => 4.6, 'rating_count' => 70],
            ['name' => 'Katering Dapur Ibu', 'city' => 'Yogyakarta', 'address' => 'Jl. Malioboro No. 15', 'min_order_pax' => 20, 'total_orders' => 64, 'rating_avg' => 4.5, 'rating_count' => 52],
            ['name' => 'Katering Rasa Nusantara', 'city' => 'Semarang', 'address' => 'Jl. Pandanaran No. 8', 'min_order_pax' => 10, 'total_orders' => 72, 'rating_avg' => 4.6, 'rating_count' => 58],
            ['name' => 'Katering Mitra Boga', 'city' => 'Medan', 'address' => 'Jl. Gatot Subroto No. 33', 'min_order_pax' => 25, 'total_orders' => 45, 'rating_avg' => 4.3, 'rating_count' => 36],
            ['name' => 'Katering Sedap Malam', 'city' => 'Makassar', 'address' => 'Jl. Pettarani No. 12', 'min_order_pax' => 15, 'total_orders' => 53, 'rating_avg' => 4.4, 'rating_count' => 41],
            ['name' => 'Katering Bunda Catering', 'city' => 'Denpasar', 'address' => 'Jl. Sunset Road No. 7', 'min_order_pax' => 10, 'total_orders' => 39, 'rating_avg' => 4.2, 'rating_count' => 30],
            ['name' => 'Katering Gurih Lezat', 'city' => 'Palembang', 'address' => 'Jl. Sudirman No. 19', 'min_order_pax' => 20, 'total_orders' => 28, 'rating_avg' => 4.1, 'rating_count' => 22],
            ['name' => 'Katering Sejahtera', 'city' => 'Balikpapan', 'address' => 'Jl. MT Haryono No. 4', 'min_order_pax' => 10, 'total_orders' => 17, 'rating_avg' => 4.0, 'rating_count' => 13],
        ];

        foreach ($merchants as $index => $merchant) {
            $number = $index + 1;

            $user = User::create([
                'name' => $merchant['name'],
                'email' => "merchant{$number}@gmail.com",
                'password' => Hash::make('merchant123'),
                'role' => 'merchant',
                'phone' => '08123456' . str_pad((string) $number, 4, '0', STR_PAD_LEFT),
            ]);

            Merchant::create([
                'user_id' => $user->id,
                'company_name' => $merchant['name'],
                'slug' => Str::slug($merchant['name']),
                'address' => $merchant['address'],
                'city' => $merchant['city'],
                'contact_phone' => $user->phone,
                'contact_email' => $user->email,
                'description' => "Katering harian untuk kantor dengan menu bervariasi di {$merchant['city']}.",
                'logo_path' => $logoPath,
                'min_order_pax' => $merchant['min_order_pax'],
                'total_orders' => $merchant['total_orders'],
                'rating_avg' => $merchant['rating_avg'],
                'rating_count' => $merchant['rating_count'],
                'is_active' => true,
            ]);
        }
    }

    /**
     * Copy the bundled generic catering icon (database/seeders/assets/merchants)
     * into the public storage disk and return its path, used as a placeholder
     * logo for every seeded merchant since these are fictional companies.
     */
    private function seedLogoPath(): ?string
    {
        $filename = 'catering-logo.png';
        $source = __DIR__ . '/assets/merchants/' . $filename;

        if (! is_file($source)) {
            return null;
        }

        $logoPath = 'merchants/logos/' . $filename;

        if (! Storage::disk('public')->exists($logoPath)) {
            Storage::disk('public')->put($logoPath, file_get_contents($source));
        }

        return $logoPath;
    }
}
