<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Menu;
use App\Models\Merchant;
use Illuminate\Database\Seeder;

class MenuSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $merchant = Merchant::first();

        $nasiBox = Category::where('name', 'Nasi Box')->first();
        $prasmanan = Category::where('name', 'Prasmanan')->first();
        $snack = Category::where('name', 'Snack')->first();

        $menus = [
            [
                'category_id' => $nasiBox->id,
                'name' => 'Nasi Box Ayam Bakar',
                'description' => 'Nasi putih, ayam bakar bumbu kecap, tempe, sambal, dan lalapan.',
                'price' => 25000,
                'photo_path' => 'menus/nasi-box-ayam-bakar.jpg',
            ],
            [
                'category_id' => $nasiBox->id,
                'name' => 'Nasi Box Rendang',
                'description' => 'Nasi putih dengan rendang daging sapi khas Padang.',
                'price' => 30000,
                'photo_path' => 'menus/nasi-box-rendang.jpg',
            ],
            [
                'category_id' => $prasmanan->id,
                'name' => 'Paket Prasmanan Sederhana',
                'description' => 'Paket prasmanan untuk 20 orang: nasi, 2 lauk, sayur, dan kerupuk.',
                'price' => 350000,
                'photo_path' => 'menus/prasmanan-sederhana.jpg',
            ],
            [
                'category_id' => $snack->id,
                'name' => 'Snack Box Kue Kering',
                'description' => 'Aneka kue kering dan air mineral dalam kemasan box.',
                'price' => 15000,
                'photo_path' => 'menus/snack-box-kue-kering.jpg',
            ],
        ];

        foreach ($menus as $menu) {
            Menu::create([
                'merchant_id' => $merchant->id,
                'category_id' => $menu['category_id'],
                'name' => $menu['name'],
                'description' => $menu['description'],
                'price' => $menu['price'],
                'photo_path' => $menu['photo_path'],
                'is_available' => true,
            ]);
        }
    }
}
