<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use Illuminate\Http\Request;

class MerchantInvoiceController extends Controller
{
    public function index(Request $request)
    {
        $merchant = $request->user()->merchant;

        $baseQuery = Invoice::whereHas('order', function ($orderQuery) use ($merchant) {
            $orderQuery->where('merchant_id', $merchant->id);
        });

        $counts = $this->statusCounts(clone $baseQuery);

        $query = (clone $baseQuery)
            ->with(['order.customer', 'order.items.menu:id,photo_path'])
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $invoices = $query->paginate($request->input('per_page', 10));

        return response()->json([
            ...$invoices->toArray(),
            'counts' => $counts,
        ]);
    }

    private function statusCounts($query): array
    {
        $byStatus = $query->selectRaw('status, count(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $statuses = ['unpaid', 'paid', 'cancelled'];
        $counts = ['' => $byStatus->sum()];
        foreach ($statuses as $status) {
            $counts[$status] = $byStatus[$status] ?? 0;
        }

        return $counts;
    }

    public function show(Request $request, Invoice $invoice)
    {
        $this->authorizeInvoice($request, $invoice);

        return response()->json([
            'data' => $invoice->load('order.customer', 'order.items'),
        ]);
    }

    public function markPaid(Request $request, Invoice $invoice)
    {
        $this->authorizeInvoice($request, $invoice);

        if ($invoice->status !== 'unpaid') {
            return response()->json([
                'message' => "Invoice dengan status '{$invoice->status}' tidak dapat ditandai lunas.",
            ], 422);
        }

        $invoice->update([
            'status' => 'paid',
            'paid_at' => now(),
        ]);

        return response()->json([
            'message' => 'Invoice berhasil ditandai lunas.',
            'data' => $invoice->refresh(),
        ]);
    }

    private function authorizeInvoice(Request $request, Invoice $invoice): void
    {
        $invoice->loadMissing('order');

        if ($invoice->order->merchant_id !== $request->user()->merchant->id) {
            abort(403, 'Anda tidak memiliki akses ke invoice ini.');
        }
    }
}
