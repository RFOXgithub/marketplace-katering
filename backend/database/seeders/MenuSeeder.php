<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Menu;
use App\Models\Merchant;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;

class MenuSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $merchants = Merchant::orderBy('id')->get();
        $categories = Category::orderBy('id')->get();

        if ($merchants->isEmpty() || $categories->isEmpty()) {
            return;
        }

        // Two name/price variants per bundled photo, so each merchant can be
        // given a handful of different-looking menus drawn from one pool.
        $menuPool = [
            ['category' => 'Nasi Box', 'name' => 'Nasi Box Ayam Bakar', 'description' => 'Nasi putih, ayam bakar bumbu kecap, tempe, sambal, dan lalapan.', 'price' => 25000, 'photo_path' => 'menus/nasi-box-ayam-bakar.jpg'],
            ['category' => 'Nasi Box', 'name' => 'Nasi Box Ayam Kecap', 'description' => 'Nasi putih, ayam kecap pedas manis, tempe, dan lalapan.', 'price' => 24000, 'photo_path' => 'menus/nasi-box-ayam-bakar.jpg'],
            ['category' => 'Nasi Box', 'name' => 'Nasi Box Rendang', 'description' => 'Nasi putih dengan rendang daging sapi khas Padang.', 'price' => 30000, 'photo_path' => 'menus/nasi-box-rendang.jpg'],
            ['category' => 'Nasi Box', 'name' => 'Nasi Box Rendang Spesial', 'description' => 'Nasi putih, rendang daging sapi premium, dan sambal ijo.', 'price' => 32000, 'photo_path' => 'menus/nasi-box-rendang.jpg'],
            ['category' => 'Prasmanan', 'name' => 'Paket Prasmanan Sederhana', 'description' => 'Paket prasmanan untuk 20 orang: nasi, 2 lauk, sayur, dan kerupuk.', 'price' => 350000, 'photo_path' => 'menus/prasmanan-sederhana.jpg'],
            ['category' => 'Prasmanan', 'name' => 'Paket Prasmanan Lengkap', 'description' => 'Paket prasmanan untuk 30 orang: nasi, 3 lauk, sayur, buah, dan kerupuk.', 'price' => 420000, 'photo_path' => 'menus/prasmanan-sederhana.jpg'],
            ['category' => 'Vegetarian', 'name' => 'Nasi Box Vegetarian', 'description' => 'Nasi putih, tahu tempe bacem, sayur lodeh, dan sambal.', 'price' => 22000, 'photo_path' => 'menus/nasi-box-vegetarian.jpg'],
            ['category' => 'Vegetarian', 'name' => 'Nasi Box Tahu Tempe', 'description' => 'Nasi putih, tahu tempe goreng, orek tempe, dan lalapan.', 'price' => 20000, 'photo_path' => 'menus/nasi-box-vegetarian.jpg'],
            ['category' => 'Snack', 'name' => 'Snack Box Kue Kering', 'description' => 'Aneka kue kering dan air mineral dalam kemasan box.', 'price' => 15000, 'photo_path' => 'menus/snack-box-kue-kering.jpg'],
            ['category' => 'Snack', 'name' => 'Snack Box Rapat', 'description' => 'Aneka camilan ringan dan air mineral untuk kebutuhan rapat.', 'price' => 16000, 'photo_path' => 'menus/snack-box-kue-kering.jpg'],
            ['category' => 'Jajanan Pasar', 'name' => 'Paket Jajanan Pasar', 'description' => 'Aneka jajanan pasar tradisional: klepon, lemper, risoles.', 'price' => 18000, 'photo_path' => 'menus/jajanan-pasar.jpg'],
            ['category' => 'Jajanan Pasar', 'name' => 'Jajanan Pasar Komplit', 'description' => 'Jajanan pasar lengkap: klepon, lemper, risoles, dan kue lapis.', 'price' => 19000, 'photo_path' => 'menus/jajanan-pasar.jpg'],
            ['category' => 'Minuman', 'name' => 'Paket Minuman Segar', 'description' => 'Es teh manis, es jeruk, dan air mineral kemasan.', 'price' => 10000, 'photo_path' => 'menus/minuman-segar.jpg'],
            ['category' => 'Minuman', 'name' => 'Es Teh & Jus Segar', 'description' => 'Es teh manis dan jus buah segar dalam kemasan cup.', 'price' => 11000, 'photo_path' => 'menus/minuman-segar.jpg'],
            ['category' => 'Paket Diet', 'name' => 'Nasi Box Diet Sehat', 'description' => 'Nasi merah, dada ayam panggang, dan sayuran kukus rendah kalori.', 'price' => 28000, 'photo_path' => 'menus/diet-sehat.jpg'],
            ['category' => 'Paket Diet', 'name' => 'Nasi Box Rendah Kalori', 'description' => 'Nasi merah, ikan panggang, dan sayuran kukus untuk diet.', 'price' => 27000, 'photo_path' => 'menus/diet-sehat.jpg'],
            ['category' => 'Seafood', 'name' => 'Nasi Box Seafood', 'description' => 'Nasi putih, cumi saus padang, udang goreng tepung, dan lalapan.', 'price' => 35000, 'photo_path' => 'menus/nasi-box-seafood.jpg'],
            ['category' => 'Seafood', 'name' => 'Nasi Box Seafood Spesial', 'description' => 'Nasi putih, aneka seafood saus padang, dan lalapan.', 'price' => 37000, 'photo_path' => 'menus/nasi-box-seafood.jpg'],
            ['category' => 'Bakery', 'name' => 'Paket Bakery Box', 'description' => 'Aneka roti dan kue bakery untuk coffee break kantor.', 'price' => 20000, 'photo_path' => 'menus/bakery-box.jpg'],
            ['category' => 'Bakery', 'name' => 'Bakery Box Meeting', 'description' => 'Aneka roti manis dan kue bakery untuk kebutuhan meeting.', 'price' => 21000, 'photo_path' => 'menus/bakery-box.jpg'],
        ];

        foreach ($merchants as $merchant) {
            $menuCount = random_int(2, 5);

            foreach (collect($menuPool)->shuffle()->take($menuCount) as $menu) {
                $category = $categories->firstWhere('name', $menu['category']) ?? $categories->first();

                $this->copySeedImage($menu['photo_path']);

                Menu::create([
                    'merchant_id' => $merchant->id,
                    'category_id' => $category->id,
                    'name' => $menu['name'],
                    'description' => $menu['description'],
                    'price' => $menu['price'],
                    'photo_path' => $menu['photo_path'],
                    'is_available' => true,
                ]);
            }
        }
    }

    /**
     * Copy a bundled sample photo (database/seeders/assets/menus) into the
     * public storage disk so the seeded photo_path resolves to a real file.
     */
    private function copySeedImage(string $photoPath): void
    {
        $filename = basename($photoPath);
        $source = __DIR__ . '/assets/menus/' . $filename;

        if (is_file($source) && ! Storage::disk('public')->exists($photoPath)) {
            Storage::disk('public')->put($photoPath, file_get_contents($source));
        }
    }
}
