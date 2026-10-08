<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('merchants', function (Blueprint $table) {
            // Minimum order quantity (in pax) the merchant is willing to serve per order.
            $table->unsignedInteger('min_order_pax')->default(10)->after('description');

            // Running total of orders received, shown on catering cards as a track
            // record (e.g. "120+ pesanan"). Seeded with a baseline figure and then
            // incremented whenever a customer places a new order.
            $table->unsignedInteger('total_orders')->default(0)->after('min_order_pax');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('merchants', function (Blueprint $table) {
            $table->dropColumn(['min_order_pax', 'total_orders']);
        });
    }
};
