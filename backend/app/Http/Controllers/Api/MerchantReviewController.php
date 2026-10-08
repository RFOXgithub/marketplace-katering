<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use Illuminate\Http\Request;

class MerchantReviewController extends Controller
{
    public function index(Request $request)
    {
        $merchant = $request->user()->merchant;

        $baseQuery = Review::where('merchant_id', $merchant->id);

        $counts = $this->ratingCounts(clone $baseQuery);
        $averageRating = round((clone $baseQuery)->avg('rating') ?? 0, 2);

        $query = (clone $baseQuery)
            ->with(['customer:id,office_name', 'order:id,delivery_date'])
            ->latest();

        if ($request->filled('rating')) {
            $query->where('rating', $request->input('rating'));
        }

        $reviews = $query->paginate($request->input('per_page', 10));

        return response()->json([
            ...$reviews->toArray(),
            'counts' => $counts,
            'average_rating' => $averageRating,
        ]);
    }

    private function ratingCounts($query): array
    {
        $byRating = $query->selectRaw('rating, count(*) as aggregate')
            ->groupBy('rating')
            ->pluck('aggregate', 'rating');

        $counts = ['' => $byRating->sum()];
        for ($rating = 1; $rating <= 5; $rating++) {
            $counts[(string) $rating] = $byRating[$rating] ?? 0;
        }

        return $counts;
    }
}
