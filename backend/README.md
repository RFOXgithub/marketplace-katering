# Marketplace Katering - Backend

REST API untuk Marketplace Katering, dibangun dengan **Laravel 13**, **PHP 8.3**, **Laravel Sanctum** (token), dan **PostgreSQL**.

## Setup

```sh
composer install
cp .env.example .env        # Windows PowerShell: copy .env.example .env
php artisan key:generate
```

Atur koneksi database di `.env`:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=marketplace_katering
DB_USERNAME=postgres
DB_PASSWORD=
```

Isi database dengan salah satu cara:

```sh
php artisan migrate --seed                                         # migrasi + data demo
psql -U postgres -d marketplace_katering -f database/schema.sql    # atau import dump SQL
```

Lalu:

```sh
php artisan storage:link    # wajib, agar foto menu & logo dapat diakses lewat /storage
php artisan serve           # http://127.0.0.1:8000
```

> `database/schema.sql` adalah hasil `pg_dump` (skema + data demo). Untuk membuat ulang:
> `pg_dump -U postgres -d <db> --no-owner --no-privileges --column-inserts -f database/schema.sql`

## Seeder

`php artisan db:seed` menjalankan, berurutan: `CitySeeder`, `CategorySeeder`, `MerchantSeeder`, `CustomerSeeder`, `MenuSeeder`, `OrderSeeder`, `TestAccountSeeder`. Foto contoh diambil dari `database/seeders/assets` dan disalin ke disk `public`.

Akun login hasil seed:

| Peran    | Email                                            | Password      |
| -------- | ------------------------------------------------ | ------------- |
| Merchant | `rival@merchant.com`                             | `BAPAKKAO`    |
| Customer | `rival@customer.com`                             | `BAPAKKAO`    |
| Merchant | `merchant1@gmail.com` ... `merchant10@gmail.com` | `merchant123` |
| Customer | `customer1@gmail.com` ... `customer10@gmail.com` | `customer123` |

## Autentikasi

Sanctum token-based. Login/registrasi mengembalikan token; kirim di setiap request terproteksi:

```
Authorization: Bearer <token>
Accept: application/json
```

- Pembatasan per peran lewat middleware `role:merchant` / `role:customer` (`App\Http\Middleware\EnsureUserHasRole`).
- Rate limiting: `throttle:login` pada login, `throttle:6,1` pada register.
- Registrasi membuat `User` dan profil (Merchant/Customer) dalam satu transaksi.

## Endpoint API

Prefix `/api`. Semua endpoint di luar bagian "Publik" membutuhkan token.

**Publik**

| Method | Endpoint                         | Fungsi                                   |
| ------ | -------------------------------- | ---------------------------------------- |
| POST   | `/register`                      | Registrasi merchant / customer           |
| POST   | `/login`                         | Login, mengembalikan token               |
| GET    | `/categories`                    | Daftar jenis makanan                     |
| GET    | `/cities`                        | Daftar kota                              |
| GET    | `/caterings`                     | Cari katering (`q`, `city`, `category`)  |
| GET    | `/caterings/{slug}`              | Detail katering + menu                   |
| GET    | `/caterings/{slug}/reviews`      | Ulasan katering                          |

**Semua peran**

| Method | Endpoint   | Fungsi              |
| ------ | ---------- | ------------------- |
| POST   | `/logout`  | Cabut token         |
| GET    | `/me`      | Data akun & profil  |

**Merchant** (`/merchant/...`)

| Method    | Endpoint                  | Fungsi                       |
| --------- | ------------------------- | ---------------------------- |
| GET / PUT | `/profile`                | Lihat / ubah profil          |
| GET       | `/dashboard-stats`        | Statistik dashboard          |
| CRUD      | `/menus`                  | Kelola menu (upload foto)    |
| GET       | `/orders`, `/orders/{id}` | Daftar & detail order masuk  |
| PATCH     | `/orders/{id}/status`     | Ubah status order            |
| GET       | `/invoices`, `/invoices/{id}` | Daftar & detail invoice  |
| PATCH     | `/invoices/{id}/paid`     | Tandai invoice lunas         |
| GET       | `/reviews`                | Daftar ulasan                |

**Customer** (`/customer/...`)

| Method      | Endpoint                      | Fungsi                              |
| ----------- | ----------------------------- | ----------------------------------- |
| GET / PUT   | `/profile`                    | Lihat / ubah profil kantor          |
| POST        | `/orders`                     | Checkout: buat order + invoice      |
| GET         | `/orders`, `/orders/{id}`     | Riwayat & detail order              |
| PATCH       | `/orders/{id}/cancel`         | Batalkan order `pending`            |
| POST        | `/orders/{id}/review`         | Beri rating & ulasan                |
| GET         | `/invoices`, `/invoices/{id}` | Daftar & detail invoice (read-only) |
| GET         | `/favorites`, `/favorites/merchants` | Daftar favorit               |
| POST/DELETE | `/favorites/{merchant}`       | Tambah / hapus favorit              |

## Aturan Bisnis Penting

- Satu order hanya berisi menu dari **satu merchant** dan hanya menu yang tersedia.
- `delivery_date` minimal **H+1** (`after:today`).
- `order_items` menyimpan snapshot `menu_name` dan `price`; menu memakai **soft delete** sehingga riwayat order tetap valid.
- Order, order items, dan invoice dibuat dalam satu `DB::transaction`.
- Transisi status order dibatasi: `pending -> confirmed/cancelled`, `confirmed -> delivered/cancelled`, `delivered -> completed`. Membatalkan order otomatis membatalkan invoice-nya.
- Customer hanya dapat membatalkan order `pending`; invoice hanya dapat ditandai lunas oleh merchant dari status `unpaid`.
- Setiap akses data divalidasi kepemilikannya (merchant/customer hanya melihat datanya sendiri).
- Nomor invoice berformat `INV-YYYYMMDD-XXXX`.

## Format Error

Semua error API mengembalikan JSON dengan kode HTTP yang sesuai (401, 403, 404, 422, 429, ...):

```json
{
  "message": "The given data was invalid.",
  "errors": { "email": ["The email field is required."] }
}
```

## Testing

```sh
php artisan test
```

## Struktur Singkat

```
app/Http/Controllers/Api/   # controller per domain (Auth, Menu, Order, Invoice, ...)
app/Http/Middleware/        # EnsureUserHasRole
app/Models/                 # User, Merchant, Customer, Category, Menu, Order, OrderItem, Invoice, Review, Favorite, City
database/migrations/        # skema database
database/seeders/           # data demo + aset foto contoh
database/schema.sql         # dump SQL (skema + data)
routes/api.php              # seluruh endpoint
```
