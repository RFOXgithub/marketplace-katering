# Marketplace Katering

Platform kerjasama antara perusahaan katering (**Merchant**) dan kantor yang membutuhkan makan siang untuk karyawannya (**Customer**).

- **Backend**: Laravel 13 (REST API) + Laravel Sanctum (token), PostgreSQL
- **Frontend**: Vue 3 + Vite + Vue Router + Tailwind CSS

```
marketplace-katering/
├── backend/    # REST API Laravel  -> lihat backend/README.md
└── frontend/   # SPA Vue 3         -> lihat frontend/README.md
```

## Fitur

**Portal Merchant**
- Registrasi, login, dan pengelolaan profil (nama perusahaan, alamat, kontak, deskripsi, logo)
- CRUD menu (deskripsi, foto, harga, status tersedia)
- Daftar order masuk dengan filter, detail, dan perubahan status (konfirmasi, tolak, tandai terkirim)
- Daftar & detail invoice, tandai invoice lunas
- Dashboard statistik dan daftar ulasan

**Portal Customer (Kantor)**
- Registrasi, login, dan pengelolaan profil kantor
- Pencarian katering berdasarkan kata kunci, kota, dan jenis makanan
- Detail katering dan menu, keranjang, checkout (pilih menu, jumlah porsi, tanggal kirim, catatan)
- Riwayat order, pembatalan order `pending`, daftar & detail invoice
- Favorit katering dan rating/ulasan

Setiap checkout otomatis membuat order, rincian order, dan invoice dalam satu transaksi database. Invoice dapat dibaca oleh kedua belah pihak.

## Prasyarat

| Tool       | Versi                         |
| ---------- | ----------------------------- |
| PHP        | 8.3+ (ekstensi `pdo_pgsql`)   |
| Composer   | 2.x                           |
| PostgreSQL | 14+ (dikembangkan di 18)      |
| Node.js    | 22.18+ atau 24.12+            |

## Menjalankan Aplikasi

### 1. Database

Buat database kosong, mis. `marketplace_katering`:

```sh
createdb -U postgres marketplace_katering
```

### 2. Backend

```sh
cd backend
composer install
cp .env.example .env        # Windows PowerShell: copy .env.example .env
php artisan key:generate
```

Sesuaikan `DB_DATABASE`, `DB_USERNAME`, dan `DB_PASSWORD` di `backend/.env`, lalu isi database dengan **salah satu** cara:

```sh
# Opsi A - migrasi + seeder (data demo ikut dibuat)
php artisan migrate --seed

# Opsi B - import file SQL siap pakai (skema + data demo)
psql -U postgres -d marketplace_katering -f database/schema.sql
```

Lalu:

```sh
php artisan storage:link    # agar foto menu & logo bisa diakses publik
php artisan serve           # http://127.0.0.1:8000
```

### 3. Frontend

```sh
cd frontend
npm install
cp .env.example .env        # Windows PowerShell: copy .env.example .env
npm run dev                 # http://localhost:5173
```

Pastikan `VITE_API_URL` di `frontend/.env` menunjuk ke backend (default `http://127.0.0.1:8000/api`).

## Akun Demo

| Peran    | Email                      | Password      |
| -------- | -------------------------- | ------------- |
| Merchant | `rival@merchant.com`       | `BAPAKKAO`    |
| Customer | `rival@customer.com`       | `BAPAKKAO`    |
| Merchant | `merchant1@gmail.com` ... `merchant10@gmail.com` | `merchant123` |
| Customer | `customer1@gmail.com` ... `customer10@gmail.com` | `customer123` |

Akun `rival@*` sudah berisi menu dan order contoh dengan semua status, cocok untuk menguji alur lengkap customer <-> merchant.

## Alur Status

```
Order:    pending -> confirmed -> delivered -> completed
             |            |
             +------------+--> cancelled

Invoice:  unpaid -> paid
             +----> cancelled   (otomatis saat order dibatalkan)
```

## Dokumentasi Lanjutan

- [backend/README.md](backend/README.md) - setup, struktur, endpoint API, testing
- [frontend/README.md](frontend/README.md) - setup, struktur, route halaman
