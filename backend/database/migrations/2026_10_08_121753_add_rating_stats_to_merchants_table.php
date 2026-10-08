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
            // Cached aggregate so catering listings don't need to recompute an
            // AVG() over the reviews table on every search. Updated whenever a
            // review is created (see ReviewController).
            $table->decimal('rating_avg', 2, 1)->default(0)->after('total_orders');
            $table->unsignedInteger('rating_count')->default(0)->after('rating_avg');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('merchants', function (Blueprint $table) {
            $table->dropColumn(['rating_avg', 'rating_count']);
        });
    }
};
