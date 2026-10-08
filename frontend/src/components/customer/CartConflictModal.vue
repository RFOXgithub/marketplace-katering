<script setup>
import { cartPendingItem, cartMerchant, confirmReplaceCart, cancelReplaceCart } from '@/services/cartStore'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'
</script>

<template>
  <div
    v-if="cartPendingItem"
    class="fixed inset-0 z-50 flex items-center justify-center bg-secondary/60 p-4 backdrop-blur-sm"
  >
    <div class="w-full max-w-sm rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5">
      <SpotlightCard
        class="rounded-[1.625rem] border-0 bg-secondary p-7 text-center"
        spotlight-color="rgba(245, 166, 35, 0.25)"
      >
        <span
          class="mx-auto w-max rounded-full bg-primary/15 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary"
        >
          Keranjang Berisi Katering Lain
        </span>

        <h2 class="mt-3 text-lg font-extrabold text-white">Ganti Katering?</h2>
        <p class="mt-2 mb-6 text-sm text-white/50">
          Keranjang kamu masih berisi menu dari
          <span class="font-semibold text-white/80">{{ cartMerchant?.company_name }}</span
          >. Satu pesanan hanya boleh dari satu katering. Kosongkan keranjang dan tambahkan menu
          dari
          <span class="font-semibold text-white/80">{{
            cartPendingItem.merchantInfo.company_name
          }}</span>
          ini?
        </p>

        <div class="flex flex-col gap-2">
          <button
            @click="confirmReplaceCart"
            class="group flex items-center justify-center gap-2 rounded-full bg-primary py-3 pr-2 pl-5 font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98]"
          >
            Kosongkan &amp; Tambahkan
            <span
              class="flex h-7 w-7 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
            >
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="5" y1="12" x2="19" y2="12" />
                <polyline points="12 5 19 12 12 19" />
              </svg>
            </span>
          </button>
          <button
            @click="cancelReplaceCart"
            class="rounded-full py-3 text-sm font-medium text-white/60 ring-1 ring-white/15 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
          >
            Batal
          </button>
        </div>
      </SpotlightCard>
    </div>
  </div>
</template>
