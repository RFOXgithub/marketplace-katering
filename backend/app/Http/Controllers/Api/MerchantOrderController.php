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

        $baseQuery = Order::where('merchant_id', $merchant->id);

        if ($request->filled('delivery_date')) {
            $baseQuery->whereDate('delivery_date', $request->input('delivery_date'));
        }

        $counts = $this->statusCounts(clone $baseQuery);

        $query = (clone $baseQuery)
            ->with(['customer', 'items.menu:id,photo_path'])
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $orders = $query->paginate($request->input('per_page', 10));

        return response()->json([
            ...$orders->toArray(),
            'counts' => $counts,
        ]);
    }

    private function statusCounts($query): array
    {
        $byStatus = $query->selectRaw('status, count(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $statuses = ['pending', 'confirmed', 'delivered', 'completed', 'cancelled'];
        $counts = ['' => $byStatus->sum()];
        foreach ($statuses as $status) {
            $counts[$status] = $byStatus[$status] ?? 0;
        }

        return $counts;
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
