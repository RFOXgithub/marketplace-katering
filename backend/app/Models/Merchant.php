<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Merchant extends Model
{
    protected $fillable = [
        'user_id',
        'company_name',
        'slug',
        'address',
        'city',
        'contact_phone',
        'contact_email',
        'description',
        'logo_path',
        'min_order_pax',
        'total_orders',
        'rating_avg',
        'rating_count',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'min_order_pax' => 'integer',
        'total_orders' => 'integer',
        'rating_avg' => 'decimal:1',
        'rating_count' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function menus()
    {
        return $this->hasMany(Menu::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function favoritedBy()
    {
        return $this->hasMany(Favorite::class);
    }
}
