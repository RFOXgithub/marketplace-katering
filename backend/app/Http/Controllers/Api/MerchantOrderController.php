<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class MerchantOrderController extends Controller
{
    private const ALLOWED_TRANSITIONS = [
        'pending' => ['confirmed', 'cancelled'],
        'confirmed' => ['delivered', 'cancelled'],
        'delivered' => ['completed'],
        'completed' => [],
        'cancelled' => [],
    ];

    public function index(Request $request)
    {
        $merchant = $request->user()->merchant;

        $query = Order::where('merchant_id', $merchant->id)
            ->with(['customer', 'items.menu:id,photo_path'])
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->filled('delivery_date')) {
            $query->whereDate('delivery_date', $request->input('delivery_date'));
        }

        $orders = $query->paginate(10);

        return response()->json($orders);
    }

    public function show(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);

        return response()->json([
            'data' => $order->load(['customer', 'items.menu', 'invoice']),
        ]);
    }

    public function updateStatus(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);

        $validator = Validator::make($request->all(), [
            'status' => ['required', Rule::in(['confirmed', 'delivered', 'completed', 'cancelled'])],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $newStatus = $request->input('status');
        $allowed = self::ALLOWED_TRANSITIONS[$order->status] ?? [];

        if (! in_array($newStatus, $allowed, true)) {
            return response()->json([
                'message' => "Order dengan status '{$order->status}' tidak dapat diubah menjadi '{$newStatus}'.",
            ], 422);
        }

        DB::transaction(function () use ($order, $newStatus) {
            $order->update(['status' => $newStatus]);

            if ($newStatus === 'cancelled' && $order->invoice) {
                $order->invoice->update(['status' => 'cancelled']);
            }
        });

        return response()->json([
            'message' => 'Status order berhasil diperbarui.',
            'data' => $order->refresh()->load('invoice'),
        ]);
    }

    private function authorizeOrder(Request $request, Order $order): void
    {
        if ($order->merchant_id !== $request->user()->merchant->id) {
            abort(403, 'Anda tidak memiliki akses ke order ini.');
        }
    }
}
