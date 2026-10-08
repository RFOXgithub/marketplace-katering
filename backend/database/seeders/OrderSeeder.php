<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Invoice;
use App\Models\Menu;
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
        $customers = Customer::orderBy('id')->get();
        $menus = Menu::orderBy('id')->with('merchant')->get();

        if ($customers->isEmpty() || $menus->isEmpty()) {
            return;
        }

        $statuses = ['pending', 'confirmed', 'delivered', 'completed'];
        $invoiceStatuses = ['unpaid', 'paid'];

        DB::transaction(function () use ($customers, $menus, $statuses, $invoiceStatuses) {
            for ($i = 0; $i < 10; $i++) {
                $customer = $customers[$i % $customers->count()];
                $menu = $menus[$i % $menus->count()];
                $quantity = 10 + $i;
                $subtotal = $menu->price * $quantity;
                $status = $statuses[$i % count($statuses)];

                $order = Order::create([
                    'customer_id' => $customer->id,
                    'merchant_id' => $menu->merchant_id,
                    'delivery_date' => now()->addDays($i + 1)->toDateString(),
                    'delivery_address' => $customer->address,
                    'notes' => 'Tolong diantar sebelum jam 11 siang.',
                    'total_amount' => $subtotal,
                    'status' => $status,
                ]);

                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_id' => $menu->id,
                    'menu_name' => $menu->name,
                    'price' => $menu->price,
                    'quantity' => $quantity,
                    'subtotal' => $subtotal,
                ]);

                $invoiceStatus = $invoiceStatuses[$i % count($invoiceStatuses)];
                $number = $i + 1;

                Invoice::create([
                    'order_id' => $order->id,
                    'invoice_number' => 'INV-' . now()->format('Ymd') . '-' . str_pad((string) $number, 4, '0', STR_PAD_LEFT),
                    'issued_at' => now(),
                    'due_date' => now()->addDays(7)->toDateString(),
                    'total_amount' => $subtotal,
                    'status' => $invoiceStatus,
                    'paid_at' => $invoiceStatus === 'paid' ? now()->toDateString() : null,
                ]);
            }
        });
    }
}
