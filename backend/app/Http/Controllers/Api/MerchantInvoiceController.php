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

        $invoices = Invoice::whereHas('order', function ($query) use ($merchant) {
            $query->where('merchant_id', $merchant->id);
        })
            ->with('order.customer')
            ->latest()
            ->paginate(10);

        return response()->json($invoices);
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
