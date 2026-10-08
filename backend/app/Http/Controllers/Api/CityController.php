<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\City;

class CityController extends Controller
{
    public function index()
    {
        $cities = City::orderBy('name')->get();

        return response()->json([
            'data' => $cities,
        ]);
    }
}
