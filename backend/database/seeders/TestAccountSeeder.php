<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Customer;
use App\Models\Favorite;
use App\Models\Invoice;
use App\Models\Menu;
use App\Models\Merchant;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Review;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Dedicated test-account seeder for manual QA.
 *
 * Creates one merchant (rival@merchant.com) and one customer (rival@customer.com),
 * both password BAPAKKAO, with 10 menus and 10 orders (+ invoices, reviews, a
 * favorite) linking them together so the two accounts can be used to test the
 * full customer <-> merchant order/invoice flow end to end.
 *
 * Safe to re-run: every record is created with updateOrCreate / firstOrCreate.
 */
class TestAccountSeeder extends Seeder
{
    private const MERCHANT_EMAIL = 'rival@merchant.com';
    private const CUSTOMER_EMAIL = 'rival@customer.com';
    private const PASSWORD = 'BAPAKKAO';

    private const MENU_POOL = [
        ['name' => 'Nasi Box Ayam Geprek', 'category' => 'Nasi Box', 'price' => 23000, 'photo' => 'menus/nasi-box-ayam-bakar.jpg'],
        ['name' => 'Nasi Box Rendang Spesial', 'category' => 'Nasi Box', 'price' => 32000, 'photo' => 'menus/nasi-box-rendang.jpg'],
        ['name' => 'Prasmanan Syukuran', 'category' => 'Prasmanan', 'price' => 380000, 'photo' => 'menus/prasmanan-sederhana.jpg'],
        ['name' => 'Nasi Box Tahu Tempe', 'category' => 'Vegetarian', 'price' => 20000, 'photo' => 'menus/nasi-box-vegetarian.jpg'],
        ['name' => 'Snack Box Rapat', 'category' => 'Snack', 'price' => 16000, 'photo' => 'menus/snack-box-kue-kering.jpg'],
        ['name' => 'Jajanan Pasar Komplit', 'category' => 'Jajanan Pasar', 'price' => 19000, 'photo' => 'menus/jajanan-pasar.jpg'],
        ['name' => 'Es Teh & Jus Segar', 'category' => 'Minuman', 'price' => 11000, 'photo' => 'menus/minuman-segar.jpg'],
        ['name' => 'Nasi Box Diet Sehat', 'category' => 'Paket Diet', 'price' => 29000, 'photo' => 'menus/diet-sehat.jpg'],
        ['name' => 'Nasi Box Seafood Spesial', 'category' => 'Seafood', 'price' => 37000, 'photo' => 'menus/nasi-box-seafood.jpg'],
        ['name' => 'Bakery Box Meeting', 'category' => 'Bakery', 'price' => 21000, 'photo' => 'menus/bakery-box.jpg'],
    ];

    // 2 pending, 2 confirmed, 2 delivered, 3 completed, 1 cancelled - exercises every status filter.
    private const ORDER_STATUSES = [
        'pending', 'pending',
        'confirmed', 'confirmed',
        'delivered', 'delivered',
        'completed', 'completed', 'completed',
        'cancelled',
    ];

    private const NOTES_POOL = [
        'Tolong diantar sebelum jam 11 siang.',
        'Mohon sertakan sendok dan tisu.',
        'Antar ke lobby lantai 1, hubungi satpam.',
        null,
        null,
    ];

    public function run(): void
    {
        DB::transaction(function () {
            $merchant = $this->createMerchant();
            $menus = $this->createMenus($merchant);
            $customer = $this->createCustomer();
            $this->createOrders($customer, $merchant, $menus);

            Favorite::firstOrCreate([
                'customer_id' => $customer->id,
                'merchant_id' => $merchant->id,
            ]);
        });

        $this->command?->info('Test accounts ready: rival@merchant.com / rival@customer.com (password: BAPAKKAO)');
    }

    private function createMerchant(): Merchant
    {
        $user = User::updateOrCreate(
            ['email' => self::MERCHANT_EMAIL],
            [
                'name' => 'Katering Rival Testing',
                'password' => Hash::make(self::PASSWORD),
                'role' => 'merchant',
                'phone' => '081200000001',
            ],
        );

        return Merchant::updateOrCreate(
            ['user_id' => $user->id],
            [
                'company_name' => 'Katering Rival Testing',
                'slug' => 'katering-rival-testing',
                'address' => 'Jl. Testing Raya No. 99',
                'city' => 'Jakarta',
                'contact_phone' => $user->phone,
                'contact_email' => $user->email,
                'description' => 'Akun merchant khusus untuk testing fitur, berisi menu dan pesanan contoh.',
                'logo_path' => $this->seedMerchantLogo(),
                'min_order_pax' => 10,
                // Kept above every merchant seeded by MerchantSeeder (max 120) so this
                // test account always sorts first under the default "Terpopuler" order.
                'total_orders' => 999,
                'rating_avg' => 4.5,
                'rating_count' => 2,
                'is_active' => true,
            ],
        );
    }

    private function createCustomer(): Customer
    {
        $user = User::updateOrCreate(
            ['email' => self::CUSTOMER_EMAIL],
            [
                'name' => 'PT Rival Testing',
                'password' => Hash::make(self::PASSWORD),
                'role' => 'customer',
                'phone' => '081300000001',
            ],
        );

        return Customer::updateOrCreate(
            ['user_id' => $user->id],
            [
                'office_name' => 'PT Rival Testing',
                'address' => 'Jl. Uji Coba No. 7, Jakarta Selatan',
                'city' => 'Jakarta',
                'contact_phone' => $user->phone,
                'pic_name' => 'Rival',
            ],
        );
    }

    private function createMenus(Merchant $merchant): \Illuminate\Support\Collection
    {
        $categories = Category::orderBy('id')->get()->keyBy('name');

        return collect(self::MENU_POOL)->map(function ($item) use ($merchant, $categories) {
            $this->copySeedImage($item['photo']);

            return Menu::updateOrCreate(
                ['merchant_id' => $merchant->id, 'name' => $item['name']],
                [
                    'category_id' => $categories->get($item['category'])?->id ?? $categories->first()->id,
                    'description' => "Menu {$item['name']} dari {$merchant->company_name}, cocok untuk kebutuhan kantor.",
                    'price' => $item['price'],
                    'photo_path' => $item['photo'],
                    'is_available' => true,
                ],
            );
        });
    }

    private function createOrders(Customer $customer, Merchant $merchant, \Illuminate\Support\Collection $menus): void
    {
        // clear previous runs so re-seeding doesn't keep piling up duplicate orders
        Order::where('customer_id', $customer->id)->where('merchant_id', $merchant->id)->get()->each(function (Order $order) {
            $order->items()->delete();
            $order->invoice()->delete();
            $order->review()->delete();
            $order->delete();
        });

        foreach (self::ORDER_STATUSES as $index => $status) {
            $itemCount = random_int(1, 3);
            $orderMenus = $menus->random(min($itemCount, $menus->count()));
            $isPast = in_array($status, ['delivered', 'completed', 'cancelled'], true);
            $deliveryDate = $isPast
                ? now()->subDays(random_int(2, 30))
                : now()->addDays(random_int(1, 14));

            $order = Order::create([
                'customer_id' => $customer->id,
                'merchant_id' => $merchant->id,
                'delivery_date' => $deliveryDate->toDateString(),
                'delivery_address' => $customer->address,
                'notes' => self::NOTES_POOL[array_rand(self::NOTES_POOL)],
                'total_amount' => 0,
                'status' => $status,
            ]);

            $totalAmount = 0;
            foreach ($orderMenus as $menu) {
                $quantity = random_int(5, 25);
                $subtotal = $menu->price * $quantity;
                $totalAmount += $subtotal;

                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_id' => $menu->id,
                    'menu_name' => $menu->name,
                    'price' => $menu->price,
                    'quantity' => $quantity,
                    'subtotal' => $subtotal,
                ]);
            }

            $order->update(['total_amount' => $totalAmount]);

            $invoiceStatus = match (true) {
                $status === 'cancelled' => 'cancelled',
                $status === 'completed' && $index !== 8 => 'paid', // leave the last completed order unpaid
                default => 'unpaid',
            };

            Invoice::create([
                'order_id' => $order->id,
                'invoice_number' => 'INV-RIVAL-' . str_pad((string) ($index + 1), 3, '0', STR_PAD_LEFT),
                'issued_at' => $order->created_at,
                'due_date' => $deliveryDate->copy()->addDays(7),
                'total_amount' => $totalAmount,
                'status' => $invoiceStatus,
                'paid_at' => $invoiceStatus === 'paid' ? $deliveryDate->copy()->addDay() : null,
            ]);

            // give a review to the two paid/completed orders, leave the unpaid one without a review
            if ($status === 'completed' && $invoiceStatus === 'paid') {
                Review::create([
                    'order_id' => $order->id,
                    'customer_id' => $customer->id,
                    'merchant_id' => $merchant->id,
                    'rating' => random_int(4, 5),
                    'comment' => 'Makanannya enak dan datang tepat waktu, recommended untuk katering kantor.',
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

    /**
     * Resolve the test merchant's logo: prefer the bundled asset shipped in
     * database/seeders/assets/merchants (offline-friendly, same as
     * MerchantSeeder), falling back to a generated initials avatar from
     * ui-avatars.com if that file isn't present. Fails soft to null if
     * offline, since the frontend already falls back to a placeholder icon.
     */
    private function seedMerchantLogo(): ?string
    {
        $filename = 'rival-merchant.png';
        $logoPath = 'merchants/logos/' . $filename;

        if (Storage::disk('public')->exists($logoPath)) {
            return $logoPath;
        }

        $source = __DIR__ . '/assets/merchants/' . $filename;
        if (is_file($source)) {
            Storage::disk('public')->put($logoPath, file_get_contents($source));
            return $logoPath;
        }

        $url = 'https://ui-avatars.com/api/?' . http_build_query([
            'name' => 'RT',
            'background' => '2ECC71',
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
            Log::warning("TestAccountSeeder: gagal mengunduh logo merchant testing: {$e->getMessage()}");
        }

        return null;
    }
}
