<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Merchant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', Rule::in(['merchant', 'customer'])],
            'address' => ['nullable', 'string'],
            'city' => ['nullable', 'string', 'max:100'],
            'contact_phone' => ['nullable', 'string', 'max:20'],

            // role = merchant
            'company_name' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],

            // role = customer
            'office_name' => ['nullable', 'string', 'max:255'],
            'pic_name' => ['nullable', 'string', 'max:255'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        $user = DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'role' => $data['role'],
                'phone' => $data['phone'] ?? null,
            ]);

            if ($data['role'] === 'merchant') {
                $companyName = $data['company_name'] ?? $data['name'];

                Merchant::create([
                    'user_id' => $user->id,
                    'company_name' => $companyName,
                    'slug' => Str::slug($companyName).'-'.Str::random(5),
                    'address' => $data['address'] ?? null,
                    'city' => $data['city'] ?? null,
                    'contact_phone' => $data['contact_phone'] ?? null,
                    'email' => $data['email'],
                    'description' => $data['description'] ?? null,
                    'is_active' => true,
                ]);
            } else {
                Customer::create([
                    'user_id' => $user->id,
                    'office_name' => $data['office_name'] ?? $data['name'],
                    'address' => $data['address'] ?? null,
                    'city' => $data['city'] ?? null,
                    'contact_phone' => $data['contact_phone'] ?? null,
                    'pic_name' => $data['pic_name'] ?? null,
                ]);
            }

            return $user;
        });

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registrasi berhasil',
            'user' => $user->load($user->role === 'merchant' ? 'merchant' : 'customer'),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data yang dikirim tidak valid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau passowrd salah',
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'user' => $user->load($user->role === 'merchant' ? 'merchant' : 'customer'),
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil',
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'user' => $user->load($user->role === 'merchant' ? 'merchant' : 'customer'),
        ]);
    }
}
