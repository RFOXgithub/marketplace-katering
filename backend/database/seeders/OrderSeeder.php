<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Invoice;
use App\Models\Menu;
use App\Models\Merchant;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OrderSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $customer = Customer::first();
        $merchant = Merchant::first();
        $menus = $merchant ? Menu::where('merchant_id', $merchant->id)->take(2)->get() : collect();

        if (! $customer || $menus->isEmpty()) {
            return;
        }

        DB::transaction(function () use ($customer, $menus) {
            $items = $menus->map(fn ($menu) => [
                'menu' => $menu,
                'quantity' => 10,
            ]);

            $totalAmount = $items->sum(fn ($item) => $item['menu']->price * $item['quantity']);

            $order = Order::create([
                'customer_id' => $customer->id,
                'merchant_id' => $menus->first()->merchant_id,
                'delivery_date' => now()->addDay()->toDateString(),
                'delivery_address' => $customer->address,
                'notes' => 'Tolong diantar sebelum jam 11 siang.',
                'total_amount' => $totalAmount,
                'status' => 'pending',
            ]);

            foreach ($items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_id' => $item['menu']->id,
                    'menu_name' => $item['menu']->name,
                    'price' => $item['menu']->price,
                    'quantity' => $item['quantity'],
                    'subtotal' => $item['menu']->price * $item['quantity'],
                ]);
            }

            Invoice::create([
                'order_id' => $order->id,
                'invoice_number' => 'INV-' . now()->format('Ymd') . '-0001',
                'issued_at' => now(),
                'due_date' => now()->addDays(7)->toDateString(),
                'total_amount' => $totalAmount,
                'status' => 'unpaid',
                'paid_at' => null,
            ]);
        });
    }
}
