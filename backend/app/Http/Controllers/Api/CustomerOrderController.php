<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Menu;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class CustomerOrderController extends Controller
{
    public function store(Request $request)
    {
        $customer = $request->user()->customer;

        $validator = Validator::make($request->all(), [
            'merchant_id' => ['required', Rule::exists('merchants', 'id')],
            'delivery_date' => ['required', 'date', 'after:today'],
            'delivery_address' => ['required', 'string'],
            'notes' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.menu_id' => ['required', 'integer'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        $menus = Menu::where('merchant_id', $data['merchant_id'])
            ->where('is_available', true)
            ->whereIn('id', collect($data['items'])->pluck('menu_id'))
            ->get()
            ->keyBy('id');

        if ($menus->count() !== count($data['items'])) {
            return response()->json([
                'message' => 'Salah satu menu tidak tersedia atau bukan milik katering yang dipilih.',
            ], 422);
        }

        $order = DB::transaction(function () use ($data, $customer, $menus) {
            $totalAmount = 0;

            foreach ($data['items'] as $item) {
                $totalAmount += $menus[$item['menu_id']]->price * $item['quantity'];
            }

            $order = Order::create([
                'customer_id' => $customer->id,
                'merchant_id' => $data['merchant_id'],
                'delivery_date' => $data['delivery_date'],
                'delivery_address' => $data['delivery_address'],
                'notes' => $data['notes'] ?? null,
                'total_amount' => $totalAmount,
                'status' => 'pending',
            ]);

            foreach ($data['items'] as $item) {
                $menu = $menus[$item['menu_id']];

                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_id' => $menu->id,
                    'menu_name' => $menu->name,
                    'price' => $menu->price,
                    'quantity' => $item['quantity'],
                    'subtotal' => $menu->price * $item['quantity'],
                ]);
            }

            Invoice::create([
                'order_id' => $order->id,
                'invoice_number' => $this->generateInvoiceNumber(),
                'issued_at' => now(),
                'due_date' => now()->addDays(7),
                'total_amount' => $totalAmount,
                'status' => 'unpaid',
            ]);

            return $order;
        });

        return response()->json([
            'message' => 'Order berhasil dibuat.',
            'data' => $order->load('items', 'invoice'),
        ], 201);
    }

    public function index(Request $request)
    {
        $customer = $request->user()->customer;

        $query = Order::where('customer_id', $customer->id)
            ->with(['merchant', 'items'])
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $orders = $query->paginate(10);

        return response()->json($orders);
    }

    public function show(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);

        return response()->json([
            'data' => $order->load(['merchant', 'items.menu', 'invoice']),
        ]);
    }

    public function cancel(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);

        if ($order->status !== 'pending') {
            return response()->json([
                'message' => "Order dengan status '{$order->status}' tidak dapat dibatalkan.",
            ], 422);
        }

        DB::transaction(function () use ($order) {
            $order->update(['status' => 'cancelled']);

            if ($order->invoice) {
                $order->invoice->update(['status' => 'cancelled']);
            }
        });

        return response()->json([
            'message' => 'Order berhasil dibatalkan.',
            'data' => $order->refresh()->load('invoice'),
        ]);
    }

    private function generateInvoiceNumber(): string
    {
        $prefix = 'INV-'.now()->format('Ymd').'-';
        $countToday = Invoice::where('invoice_number', 'like', $prefix.'%')->count();

        return $prefix.str_pad((string) ($countToday + 1), 4, '0', STR_PAD_LEFT);
    }

    private function authorizeOrder(Request $request, Order $order): void
    {
        if ($order->customer_id !== $request->user()->customer->id) {
            abort(403, 'Anda tidak memiliki akses ke order ini.');
        }
    }
}
