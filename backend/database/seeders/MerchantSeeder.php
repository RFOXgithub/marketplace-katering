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
            ['name' => 'Katering Berkah', 'city' => 'Jakarta', 'address' => 'Jl. Merdeka No. 10'],
            ['name' => 'Katering Sari Rasa', 'city' => 'Bandung', 'address' => 'Jl. Asia Afrika No. 22'],
            ['name' => 'Katering Nusantara', 'city' => 'Surabaya', 'address' => 'Jl. Pemuda No. 5'],
            ['name' => 'Katering Dapur Ibu', 'city' => 'Yogyakarta', 'address' => 'Jl. Malioboro No. 15'],
            ['name' => 'Katering Rasa Nusantara', 'city' => 'Semarang', 'address' => 'Jl. Pandanaran No. 8'],
            ['name' => 'Katering Mitra Boga', 'city' => 'Medan', 'address' => 'Jl. Gatot Subroto No. 33'],
            ['name' => 'Katering Sedap Malam', 'city' => 'Makassar', 'address' => 'Jl. Pettarani No. 12'],
            ['name' => 'Katering Bunda Catering', 'city' => 'Denpasar', 'address' => 'Jl. Sunset Road No. 7'],
            ['name' => 'Katering Gurih Lezat', 'city' => 'Palembang', 'address' => 'Jl. Sudirman No. 19'],
            ['name' => 'Katering Sejahtera', 'city' => 'Balikpapan', 'address' => 'Jl. MT Haryono No. 4'],
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
