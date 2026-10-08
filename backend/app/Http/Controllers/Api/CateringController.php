<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Merchant;
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

        $merchants = $query->paginate(10);

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
}
