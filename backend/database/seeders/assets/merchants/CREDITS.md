# Image credits

Placeholder logos for seeded merchants (fictional companies, no real logo of their own):

- `merchant-1.png` .. `merchant-10.png` — one per merchant in `MerchantSeeder`.
- `rival-merchant.png` — the test merchant created by `TestAccountSeeder`.

Each is a colored initials-avatar icon, generated once via the
[ui-avatars.com](https://ui-avatars.com) API (free, no attribution required)
and committed here so seeding works offline — no internet needed at seed time.

`MerchantSeeder`/`TestAccountSeeder` resolve a merchant's logo in this order:

1. Already on the public storage disk (idempotent re-seeding).
2. The bundled file in this folder (drop a real logo here to override it for a given merchant).
3. Falls back to generating a fresh initials avatar from ui-avatars.com if the bundled file is missing.
