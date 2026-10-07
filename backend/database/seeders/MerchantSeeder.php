<?php

namespace Database\Seeders;

use App\Models\Merchant;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class MerchantSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::create([
            'name' => 'Katering Berkah',
            'email' => 'merchant@gmail.com',
            'password' => Hash::make('merchant123'),
            'role' => 'merchant',
            'phone' => '081234567890',
        ]);

        Merchant::create([
            'user_id' => $user->id,
            'company_name' => 'Katering Berkah',
            'slug' => Str::slug('Katering Berkah'),
            'address' => 'Jl. Merdeka No. 10',
            'city' => 'Jakarta',
            'contact_phone' => '081234567890',
            'contact_email' => 'merchant@gmail.com',
            'description' => 'Katering harian untuk kantor dengan menu bervariasi.',
            'logo_path' => null,
            'is_active' => true,
        ]);
    }
}
