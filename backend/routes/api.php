<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CateringController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\CustomerFavoriteController;
use App\Http\Controllers\Api\CustomerInvoiceController;
use App\Http\Controllers\Api\CustomerOrderController;
use App\Http\Controllers\Api\CustomerProfileController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\MerchantDashboardController;
use App\Http\Controllers\Api\MerchantInvoiceController;
use App\Http\Controllers\Api\MerchantOrderController;
use App\Http\Controllers\Api\MerchantProfileController;
use Illuminate\Support\Facades\Route;

// Guest
Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:6,1');
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/cities', [CityController::class, 'index']);
Route::get('/caterings', [CateringController::class, 'index']);
Route::get('/caterings/{slug}', [CateringController::class, 'show']);

// Auth
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Role Merchant
    Route::middleware('role:merchant')->prefix('merchant')->group(function () {
        Route::get('/profile', [MerchantProfileController::class, 'show']);
        Route::put('/profile', [MerchantProfileController::class, 'update']);

        Route::get('/dashboard-stats', [MerchantDashboardController::class, 'stats']);

        Route::apiResource('menus', MenuController::class);

        Route::get('/orders', [MerchantOrderController::class, 'index']);
        Route::get('/orders/{order}', [MerchantOrderController::class, 'show']);
        Route::patch('/orders/{order}/status', [MerchantOrderController::class, 'updateStatus']);

        Route::get('/invoices', [MerchantInvoiceController::class, 'index']);
        Route::get('/invoices/{invoice}', [MerchantInvoiceController::class, 'show']);
        Route::patch('/invoices/{invoice}/paid', [MerchantInvoiceController::class, 'markPaid']);
    });

    // Role Customer
    Route::middleware('role:customer')->prefix('customer')->group(function () {
        Route::get('/profile', [CustomerProfileController::class, 'show']);
        Route::put('/profile', [CustomerProfileController::class, 'update']);

        Route::post('/orders', [CustomerOrderController::class, 'store']);
        Route::get('/orders', [CustomerOrderController::class, 'index']);
        Route::get('/orders/{order}', [CustomerOrderController::class, 'show']);
        Route::patch('/orders/{order}/cancel', [CustomerOrderController::class, 'cancel']);
        Route::post('/orders/{order}/review', [CustomerOrderController::class, 'review']);

        Route::get('/invoices', [CustomerInvoiceController::class, 'index']);
        Route::get('/invoices/{invoice}', [CustomerInvoiceController::class, 'show']);

        Route::get('/favorites', [CustomerFavoriteController::class, 'index']);
        Route::post('/favorites/{merchant}', [CustomerFavoriteController::class, 'store']);
        Route::delete('/favorites/{merchant}', [CustomerFavoriteController::class, 'destroy']);
    });
});
