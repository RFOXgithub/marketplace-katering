# Marketplace Katering - Frontend

Single Page Application untuk portal Merchant dan Customer, dibangun dengan **Vue 3**, **Vite**, **Vue Router**, dan **Tailwind CSS 4**. Mendukung tema gelap/terang dan tampilan responsif (navigasi bawah di mobile).

## Prasyarat

- Node.js `^22.18.0` atau `>=24.12.0`
- Backend berjalan (lihat [../backend/README.md](../backend/README.md))

## Setup

```sh
npm install
cp .env.example .env        # Windows PowerShell: copy .env.example .env
```

Isi `VITE_API_URL` di `.env` dengan URL API backend:

```env
VITE_API_URL=http://127.0.0.1:8000/api
```

URL file (foto menu, logo) diturunkan otomatis dari nilai ini (`/api` diganti `/storage`), jadi backend harus sudah menjalankan `php artisan storage:link`.

## Perintah

| Perintah          | Fungsi                                  |
| ----------------- | --------------------------------------- |
| `npm run dev`     | Dev server dengan hot reload (`:5173`)  |
| `npm run build`   | Build produksi ke `dist/`               |
| `npm run preview` | Pratinjau hasil build                   |
| `npm run format`  | Format kode dengan Prettier             |

## Akun Demo

| Peran    | Email                | Password   |
| -------- | -------------------- | ---------- |
| Merchant | `rival@merchant.com` | `BAPAKKAO` |
| Customer | `rival@customer.com` | `BAPAKKAO` |

## Route Halaman

**Publik**: `/login`, `/register`

**Merchant**: `/merchant/dashboard`, `/merchant/profile`, `/merchant/menus`, `/merchant/orders`, `/merchant/orders/:id`, `/merchant/invoices`, `/merchant/invoices/:id`, `/merchant/reviews`

**Customer**: `/customer/home`, `/customer/profile`, `/caterings/:slug`, `/checkout`, `/customer/orders`, `/customer/orders/:id`, `/customer/invoices`, `/customer/invoices/:id`, `/customer/favorites`

Route dilindungi guard di `src/router/index.js` berdasarkan token dan peran pengguna.

## Struktur

```
src/
├── views/          # halaman: auth/, merchant/, customer/
├── components/     # auth/, customer/, ui/ (komponen umum), animations/
├── services/       # klien API (http.js, authService, merchantService, customerService, cartStore, ...)
├── composables/    # logika reaktif yang dipakai ulang
├── router/         # definisi route & guard
├── constants/      # konstanta (status, label, dll.)
└── utils/          # helper (format harga, tanggal, ...)
```

- `services/http.js` membungkus `fetch` dengan header `Authorization: Bearer <token>` dan otomatis mengarahkan ke `/login` saat token tidak valid (401).
- Token dan data user disimpan di `localStorage`; keranjang dikelola oleh `services/cartStore.js` (satu keranjang hanya untuk satu merchant).
- Error validasi dari backend (`message`, `errors`) ditampilkan langsung di form.
