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

    /**
     * List the customer's favorited merchants in full, in the same shape as
     * CateringController@index, so the favorites page can reuse the same
     * catering-card markup as the home listing.
     */
    public function merchants(Request $request)
    {
        $customer = $request->user()->customer;

        $query = Merchant::where('is_active', true)
            ->whereHas('favoritedBy', function ($favoriteQuery) use ($customer) {
                $favoriteQuery->where('customer_id', $customer->id);
            });

        $query->with(['menus' => function ($menuQuery) {
            $menuQuery->where('is_available', true)
                ->whereNotNull('photo_path')
                ->select('id', 'merchant_id', 'photo_path')
                ->orderBy('id');
        }]);

        $merchants = $query->paginate($request->input('per_page', 10));

        $merchants->getCollection()->transform(function ($merchant) {
            $merchant->cover_photo = $merchant->menus->first()->photo_path ?? null;
            unset($merchant->menus);

            return $merchant;
        });

        return response()->json($merchants);
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
