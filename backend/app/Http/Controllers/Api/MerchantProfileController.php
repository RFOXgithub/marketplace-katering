<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class MerchantProfileController extends Controller
{
    public function show(Request $request)
    {
        return response()->json([
            'data' => $request->user()->merchant,
        ]);
    }

    public function update(Request $request)
    {
        $merchant = $request->user()->merchant;

        $validator = Validator::make($request->all(), [
            'company_name' => ['sometimes', 'required', 'string', 'max:255'],
            'address' => ['sometimes', 'required', 'string'],
            'city' => ['sometimes', 'required', 'string', 'max:100'],
            'contact_phone' => ['sometimes', 'required', 'string', 'max:20'],
            'contact_email' => ['nullable', 'email', 'max:255'],
            'description' => ['nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
            'logo' => ['nullable', 'image', 'max:2048'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        unset($data['logo']);

        if ($request->hasFile('logo')) {
            if ($merchant->logo_path) {
                Storage::disk('public')->delete($merchant->logo_path);
            }

            $data['logo_path'] = $request->file('logo')->store('merchants/logos', 'public');
        }

        $merchant->update($data);

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'data' => $merchant->refresh(),
        ]);
    }
}
