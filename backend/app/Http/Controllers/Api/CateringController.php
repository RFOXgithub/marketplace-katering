<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Merchant;
use App\Models\Review;
use Illuminate\Http\Request;

class CateringController extends Controller
{
    public function index(Request $request)
    {
        $query = Merchant::query()->where('is_active', true);

        if ($request->filled('q')) {
            $query->whereRaw('LOWER(company_name) LIKE ?', ['%'.strtolower($request->input('q')).'%']);
        }

        if ($request->filled('city')) {
            $query->whereRaw('LOWER(city) LIKE ?', ['%'.strtolower($request->input('city')).'%']);
        }

        if ($request->filled('category')) {
            $query->whereHas('menus', function ($menuQuery) use ($request) {
                $menuQuery->where('category_id', $request->input('category'));
            });
        }

        match ($request->input('sort', 'popular')) {
            'name' => $query->orderBy('company_name'),
            'city' => $query->orderBy('city'),
            default => $query->orderByDesc('total_orders'),
        };

        // Note: a per-relation limit() here would cap the whole eager-load
        // query at 1 row total (not 1 per merchant), so every available
        // photo is fetched and the first one is picked in PHP below instead.
        $query->with(['menus' => function ($menuQuery) {
            $menuQuery->where('is_available', true)
                ->whereNotNull('photo_path')
                ->select('id', 'merchant_id', 'photo_path')
                ->orderBy('id');
        }]);

        $merchants = $query->paginate(10);

        $merchants->getCollection()->transform(function ($merchant) {
            $merchant->cover_photo = $merchant->menus->first()->photo_path ?? null;
            unset($merchant->menus);

            return $merchant;
        });

        return response()->json($merchants);
    }

    public function show(string $slug)
    {
        $merchant = Merchant::where('slug', $slug)
            ->where('is_active', true)
            ->with(['menus' => function ($menuQuery) {
                $menuQuery->where('is_available', true)->with('category');
            }])
            ->first();

        if (! $merchant) {
            return response()->json([
                'message' => 'Katering tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'data' => $merchant,
        ]);
    }

    public function reviews(Request $request, string $slug)
    {
        $merchant = Merchant::where('slug', $slug)->where('is_active', true)->first();

        if (! $merchant) {
            return response()->json([
                'message' => 'Katering tidak ditemukan.',
            ], 404);
        }

        $reviews = Review::where('merchant_id', $merchant->id)
            ->with('customer:id,office_name')
            ->latest()
            ->paginate($request->input('per_page', 10));

        return response()->json($reviews);
    }
}
