<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Menu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class MenuController extends Controller
{
    public function index(Request $request)
    {
        $merchant = $request->user()->merchant;

        $counts = $this->categoryCounts($merchant->id);

        $query = $merchant->menus()
            ->with('category')
            ->latest();

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->input('category_id'));
        }

        $menus = $query->paginate($request->input('per_page', 10));

        return response()->json([
            ...$menus->toArray(),
            'counts' => $counts,
        ]);
    }

    private function categoryCounts(int $merchantId): array
    {
        $rows = Menu::where('merchant_id', $merchantId)
            ->selectRaw('category_id, count(*) as aggregate')
            ->groupBy('category_id')
            ->get();

        $categories = Category::whereIn('id', $rows->pluck('category_id'))->get()->keyBy('id');

        return [
            'total' => $rows->sum('aggregate'),
            'categories' => $rows->map(fn ($row) => [
                'id' => $row->category_id,
                'name' => $categories[$row->category_id]->name ?? '-',
                'count' => $row->aggregate,
            ])->values(),
        ];
    }

    public function store(Request $request)
    {
        $merchant = $request->user()->merchant;

        $validator = Validator::make($request->all(), [
            'category_id' => ['required', Rule::exists('categories', 'id')],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'photo' => ['required', 'image', 'max:2048'],
            'is_available' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        $data['photo_path'] = $request->file('photo')->store('menus', 'public');
        $data['merchant_id'] = $merchant->id;
        $data['is_available'] = $data['is_available'] ?? true;
        unset($data['photo']);

        $menu = Menu::create($data);

        return response()->json([
            'message' => 'Menu berhasil ditambahkan.',
            'data' => $menu->load('category'),
        ], 201);
    }

    public function show(Request $request, Menu $menu)
    {
        $this->authorizeMenu($request, $menu);

        return response()->json([
            'data' => $menu->load('category'),
        ]);
    }

    public function update(Request $request, Menu $menu)
    {
        $this->authorizeMenu($request, $menu);

        $validator = Validator::make($request->all(), [
            'category_id' => ['sometimes', 'required', Rule::exists('categories', 'id')],
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['sometimes', 'required', 'string'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'photo' => ['nullable', 'image', 'max:2048'],
            'is_available' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        unset($data['photo']);

        if ($request->hasFile('photo')) {
            Storage::disk('public')->delete($menu->photo_path);
            $data['photo_path'] = $request->file('photo')->store('menus', 'public');
        }

        $menu->update($data);

        return response()->json([
            'message' => 'Menu berhasil diperbarui.',
            'data' => $menu->refresh()->load('category'),
        ]);
    }

    public function destroy(Request $request, Menu $menu)
    {
        $this->authorizeMenu($request, $menu);

        $menu->delete();

        return response()->json([
            'message' => 'Menu berhasil dihapus.',
        ]);
    }

    private function authorizeMenu(Request $request, Menu $menu): void
    {
        if ($menu->merchant_id !== $request->user()->merchant->id) {
            abort(403, 'Anda tidak memiliki akses ke menu ini.');
        }
    }
}
