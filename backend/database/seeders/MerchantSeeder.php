<?php

namespace Database\Seeders;

use App\Models\Merchant;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MerchantSeeder extends Seeder
{
    /**
     * Brand color per seeded merchant (used for the generated logo avatar).
     */
    private const LOGO_COLORS = [
        'F5A623', 'D0021B', '7ED321', '4A90E2', 'BD10E0',
        'F8E71C', '50E3C2', 'B8860B', 'E91E8C', '2ECC71',
    ];

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
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
                'logo_path' => $this->seedLogoPath($merchant['name'], $index),
                'min_order_pax' => $merchant['min_order_pax'],
                'total_orders' => $merchant['total_orders'],
                'rating_avg' => $merchant['rating_avg'],
                'rating_count' => $merchant['rating_count'],
                'is_active' => true,
            ]);
        }
    }

    /**
     * Resolve a per-merchant logo and return its storage path.
     *
     * Order of preference:
     *  1. Already on the public disk (idempotent re-seeding).
     *  2. A bundled asset shipped in database/seeders/assets/merchants.
     *  3. A generated initials avatar fetched from ui-avatars.com, since
     *     these are fictional companies with no real logo of their own.
     */
    private function seedLogoPath(string $companyName, int $index): ?string
    {
        $filename = 'merchant-' . ($index + 1) . '.png';
        $logoPath = 'merchants/logos/' . $filename;

        if (Storage::disk('public')->exists($logoPath)) {
            return $logoPath;
        }

        $source = __DIR__ . '/assets/merchants/' . $filename;
        if (is_file($source)) {
            Storage::disk('public')->put($logoPath, file_get_contents($source));
            return $logoPath;
        }

        return $this->downloadLogo($companyName, $index, $logoPath);
    }

    /**
     * Download a generated initials-avatar logo for the merchant from the
     * internet. Fails soft (returns null) if offline or the request errors,
     * since the frontend already falls back to a placeholder icon.
     */
    private function downloadLogo(string $companyName, int $index, string $logoPath): ?string
    {
        $initials = collect(explode(' ', $companyName))
            ->filter()
            ->map(fn ($word) => mb_strtoupper(mb_substr($word, 0, 1)))
            ->take(2)
            ->implode('');

        $url = 'https://ui-avatars.com/api/?' . http_build_query([
            'name' => $initials,
            'background' => self::LOGO_COLORS[$index % count(self::LOGO_COLORS)],
            'color' => 'ffffff',
            'size' => 256,
            'bold' => 'true',
            'format' => 'png',
        ]);

        try {
            $response = Http::timeout(5)->get($url);

            if ($response->successful()) {
                Storage::disk('public')->put($logoPath, $response->body());
                return $logoPath;
            }
        } catch (\Throwable $e) {
            Log::warning("MerchantSeeder: gagal mengunduh logo untuk {$companyName}: {$e->getMessage()}");
        }

        return null;
    }
}
