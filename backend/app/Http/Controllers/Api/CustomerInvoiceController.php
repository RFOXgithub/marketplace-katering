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

        $query = Invoice::whereHas('order', function ($orderQuery) use ($customer) {
            $orderQuery->where('customer_id', $customer->id);
        })
            ->with('order.merchant')
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $invoices = $query->paginate(10);

        return response()->json($invoices);
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
