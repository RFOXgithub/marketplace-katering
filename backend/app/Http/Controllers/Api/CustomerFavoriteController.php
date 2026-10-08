<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Merchant;
use Illuminate\Http\Request;

class CustomerFavoriteController extends Controller
{
    /**
     * List the merchant ids the current customer has favorited, so the
     * frontend can mark hearts as filled across the catering listing.
     */
    public function index(Request $request)
    {
        $customer = $request->user()->customer;

        $merchantIds = Favorite::where('customer_id', $customer->id)->pluck('merchant_id');

        return response()->json([
            'data' => $merchantIds,
        ]);
    }

    public function store(Request $request, Merchant $merchant)
    {
        $customer = $request->user()->customer;

        Favorite::firstOrCreate([
            'customer_id' => $customer->id,
            'merchant_id' => $merchant->id,
        ]);

        return response()->json([
            'message' => 'Katering ditambahkan ke favorit.',
            'favorited' => true,
        ], 201);
    }

    public function destroy(Request $request, Merchant $merchant)
    {
        $customer = $request->user()->customer;

        Favorite::where('customer_id', $customer->id)
            ->where('merchant_id', $merchant->id)
            ->delete();

        return response()->json([
            'message' => 'Katering dihapus dari favorit.',
            'favorited' => false,
        ]);
    }
}
