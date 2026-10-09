<script setup>
import { cartPendingItem, cartMerchant, confirmReplaceCart, cancelReplaceCart } from '@/services/cartStore'
</script>

<template>
  <div
    v-if="cartPendingItem"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-6 backdrop-blur-sm"
    @click.self="cancelReplaceCart"
    @keydown.esc="cancelReplaceCart"
  >
    <div
      class="relative max-h-[90vh] w-full max-w-md overflow-hidden rounded-[2rem] bg-[#0b0b0c] ring-1 ring-primary/40 shadow-[0_0_70px_rgba(249,166,38,0.18)] md:min-h-[30rem] md:max-w-4xl"
      role="dialog"
      aria-modal="true"
      aria-label="Ganti Katering"
    >
      <div class="pointer-events-none absolute -bottom-24 left-0 h-56 w-full bg-[radial-gradient(ellipse_at_center,rgba(249,166,38,0.22),transparent_70%)]"></div>

      <img
        src="/switch-caterer-chef.png"
        alt=""
        draggable="false"
        loading="lazy"
        class="pointer-events-none absolute bottom-0 left-0 hidden h-full w-[50%] select-none object-cover object-left md:block"
        style="-webkit-mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 8%, #000 85%, transparent 100%); -webkit-mask-composite: source-in; mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 8%, #000 85%, transparent 100%); mask-composite: intersect"
      />

      <div
        class="relative max-h-[90vh] overflow-y-auto px-7 py-8 md:ml-[46%] md:flex md:min-h-[30rem] md:flex-col md:justify-center md:pr-9"
      >
        <span class="mb-3 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-b from-[#fbbf5a] to-[#f9a626] shadow-[0_6px_18px_rgba(249,166,38,0.45)]">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="17 1 21 5 17 9" />
            <path d="M3 11V9a4 4 0 0 1 4-4h14" />
            <polyline points="7 23 3 19 7 15" />
            <path d="M21 13v2a4 4 0 0 1-4 4H3" />
          </svg>
        </span>

        <h2 class="text-2xl font-extrabold text-white">
          Ganti <span class="text-primary">Katering?</span>
        </h2>
        <p class="mt-2 text-sm leading-relaxed text-white/60">
          Keranjang Anda masih berisi menu dari
          <span class="font-semibold text-white">{{ cartMerchant?.company_name }}</span>.
          Satu pesanan hanya boleh dari satu katering. Kosongkan keranjang dan tambahkan menu dari
          <span class="font-semibold text-white">{{ cartPendingItem.merchantInfo.company_name }}</span>
          ini?
        </p>

        <div class="mt-6 flex gap-3">
          <button
            type="button"
            @click="cancelReplaceCart"
            class="flex-1 rounded-full py-3 text-sm font-semibold text-white ring-1 ring-primary/50 transition-colors duration-200 hover:bg-white/10"
          >
            Batal
          </button>
          <button
            type="button"
            @click="confirmReplaceCart"
            class="flex flex-[1.4] items-center justify-center gap-2 rounded-full bg-primary py-3 text-sm font-bold text-secondary transition-colors duration-200 hover:bg-[#ff9a1a]"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="17 1 21 5 17 9" />
              <path d="M3 11V9a4 4 0 0 1 4-4h14" />
              <polyline points="7 23 3 19 7 15" />
              <path d="M21 13v2a4 4 0 0 1-4 4H3" />
            </svg>
            Ganti Katering
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
