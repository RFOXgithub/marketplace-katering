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
        $user = User::create([
            'name' => 'Kantor Maju Jaya',
            'email' => 'customer@gmail.com',
            'password' => Hash::make('customer123'),
            'role' => 'customer',
            'phone' => '081298765432',
        ]);

        Customer::create([
            'user_id' => $user->id,
            'office_name' => 'PT Maju Jaya',
            'address' => 'Jl. Sudirman No. 25',
            'city' => 'Jakarta',
            'contact_phone' => '081298765432',
            'pic_name' => 'Budi Santoso',
        ]);
    }
}
