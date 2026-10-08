<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            'Nasi Box',
            'Prasmanan',
            'Vegetarian',
            'Snack',
            'Jajanan Pasar',
            'Minuman',
            'Paket Diet',
            'Seafood',
            'Bakery',
            'Tumpeng',
        ];

        foreach ($categories as $name) {
            Category::create([
                'name' => $name,
                'slug' => Str::slug($name),
            ]);
        }
    }
}
