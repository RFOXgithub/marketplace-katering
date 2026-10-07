<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    protected $fillable = [
        'order_id',
        'invoice_number',
        'issued_at',
        'due_date',
        'total_amount',
        'status',
        'paid_at',
    ];

    protected $casts = [
        'issued_at' => 'datetime',
        'due_date' => 'date',
        'total_amount' => 'decimal:2',
        'paid_at' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
