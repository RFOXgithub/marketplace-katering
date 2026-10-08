<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Menu;
use App\Models\Order;
use Illuminate\Http\Request;

class MerchantDashboardController extends Controller
{
    /**
     * Aggregated numbers for the dashboard's stat tiles, computed from real
     * timestamps rather than fabricated placeholders.
     */
    public function stats(Request $request)
    {
        $merchant = $request->user()->merchant;

        $totalMenu = Menu::where('merchant_id', $merchant->id)->count();

        // "Growth" compares the current total against how many menus already
        // existed by the end of last month, using each menu's created_at.
        $endOfLastMonth = now()->subMonthNoOverflow()->endOfMonth();
        $menuCountEndOfLastMonth = Menu::where('merchant_id', $merchant->id)
            ->where('created_at', '<=', $endOfLastMonth)
            ->count();

        $menuGrowthPercent = $menuCountEndOfLastMonth > 0
            ? (int) round((($totalMenu - $menuCountEndOfLastMonth) / $menuCountEndOfLastMonth) * 100)
            : ($totalMenu > 0 ? 100 : 0);

        $monthlyMenuCounts = collect(range(5, 0))
            ->map(function ($monthsAgo) use ($merchant) {
                $month = now()->subMonthsNoOverflow($monthsAgo);

                return Menu::where('merchant_id', $merchant->id)
                    ->whereYear('created_at', $month->year)
                    ->whereMonth('created_at', $month->month)
                    ->count();
            })
            ->values();

        $pendingOrders = Order::where('merchant_id', $merchant->id)
            ->where('status', 'pending')
            ->count();

        $totalInvoices = Invoice::whereHas('order', function ($query) use ($merchant) {
            $query->where('merchant_id', $merchant->id);
        })->count();

        $unpaidInvoices = Invoice::whereHas('order', function ($query) use ($merchant) {
            $query->where('merchant_id', $merchant->id);
        })->where('status', 'unpaid')->count();

        return response()->json([
            'data' => [
                'pending_orders' => $pendingOrders,
                'total_menu' => $totalMenu,
                'menu_growth_percent' => $menuGrowthPercent,
                'monthly_menu_counts' => $monthlyMenuCounts,
                'total_invoices' => $totalInvoices,
                'unpaid_invoices' => $unpaidInvoices,
            ],
        ]);
    }
}
