<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use Illuminate\Http\Request;

class CustomerInvoiceController extends Controller
{
    public function index(Request $request)
    {
        $customer = $request->user()->customer;

        $baseQuery = Invoice::whereHas('order', function ($orderQuery) use ($customer) {
            $orderQuery->where('customer_id', $customer->id);
        });

        $counts = $this->statusCounts(clone $baseQuery);

        $query = (clone $baseQuery)
            ->with('order.merchant')
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
            'data' => $invoice->load('order.merchant', 'order.items'),
        ]);
    }

    private function authorizeInvoice(Request $request, Invoice $invoice): void
    {
        $invoice->loadMissing('order');

        if ($invoice->order->customer_id !== $request->user()->customer->id) {
            abort(403, 'Anda tidak memiliki akses ke invoice ini.');
        }
    }
}
