<script setup>
import { useRouter } from 'vue-router'
import { cartCount } from '@/services/cartStore'

const router = useRouter()

function goToCheckout() {
  if (cartCount.value === 0) return
  router.push('/checkout')
}
</script>

<template>
  <button
    type="button"
    :disabled="cartCount === 0"
    @click="goToCheckout"
    aria-label="Keranjang"
    class="relative flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-white/15 text-white/70 transition-[transform,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary disabled:opacity-40 disabled:hover:translate-y-0"
  >
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <circle cx="9" cy="21" r="1" />
      <circle cx="20" cy="21" r="1" />
      <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
    </svg>
    <span
      v-if="cartCount > 0"
      class="absolute -top-1.5 -right-1.5 flex h-5 min-w-5 items-center justify-center rounded-full bg-primary px-1 text-[10px] font-bold text-secondary"
    >
      {{ cartCount }}
    </span>
  </button>
</template>
