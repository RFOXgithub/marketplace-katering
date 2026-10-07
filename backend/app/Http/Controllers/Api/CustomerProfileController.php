<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CustomerProfileController extends Controller
{
    public function show(Request $request)
    {
        return response()->json([
            'data' => $request->user()->customer,
        ]);
    }

    public function update(Request $request)
    {
        $customer = $request->user()->customer;

        $validator = Validator::make($request->all(), [
            'office_name' => ['sometimes', 'required', 'string', 'max:255'],
            'address' => ['sometimes', 'required', 'string'],
            'city' => ['sometimes', 'required', 'string', 'max:100'],
            'contact_phone' => ['sometimes', 'required', 'string', 'max:20'],
            'pic_name' => ['nullable', 'string', 'max:255'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $customer->update($validator->validated());

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'data' => $customer->refresh(),
        ]);
    }
}
