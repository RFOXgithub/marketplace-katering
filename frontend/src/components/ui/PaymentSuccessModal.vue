<script setup>
import { formatRupiah, formatDate } from '@/utils/format'

defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  summary: {
    type: Object,
    default: null,
  },
  title: {
    type: String,
    default: 'Pembayaran',
  },
  highlight: {
    type: String,
    default: 'Berhasil!',
  },
  message: {
    type: String,
    default: 'Pesanan Anda telah ditandai lunas dan sedang diproses oleh penjual.',
  },
  note: {
    type: String,
    default: 'Terima kasih! Pesanan Anda akan segera diproses.',
  },
  primaryLabel: {
    type: String,
    default: 'Lihat Pesanan Saya',
  },
  secondaryLabel: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['update:modelValue', 'primary', 'secondary'])

function close() {
  emit('update:modelValue', false)
}
</script>

<template>
  <div
    v-if="modelValue"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-6 backdrop-blur-sm"
    @click.self="close"
    @keydown.esc="close"
  >
    <div
      class="relative w-full max-w-md overflow-hidden rounded-[2rem] bg-[#0b0b0c] ring-1 ring-primary/40 shadow-[0_0_70px_rgba(249,166,38,0.18)] md:max-w-4xl"
      role="dialog"
      aria-modal="true"
      :aria-label="`${title} ${highlight}`"
    >
      <div class="pointer-events-none absolute -bottom-24 left-0 h-56 w-full bg-[radial-gradient(ellipse_at_center,rgba(249,166,38,0.22),transparent_70%)]"></div>

      <img
        src="/payment-success-girl.png"
        alt=""
        draggable="false"
        class="pointer-events-none absolute bottom-0 left-0 hidden h-full w-[50%] select-none object-cover object-left md:block"
        style="-webkit-mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 18%, #000 85%, transparent 100%); -webkit-mask-composite: source-in; mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 18%, #000 85%, transparent 100%); mask-composite: intersect"
      />

      <div class="relative px-7 py-8 md:ml-[46%] md:pr-9">
        <span class="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-b from-[#4ade80] to-[#16a34a] shadow-[0_6px_18px_rgba(34,197,94,0.45)]">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12" />
          </svg>
        </span>

        <h2 class="text-2xl font-extrabold text-white">
          {{ title }} <span class="text-primary">{{ highlight }}</span>
        </h2>
        <p class="mt-2 text-sm leading-relaxed text-white/60">{{ message }}</p>

        <div v-if="summary" class="mt-5 overflow-hidden rounded-2xl bg-white/5 ring-1 ring-white/10">
          <div class="flex items-center gap-3 p-3">
            <span class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                <line x1="3" y1="6" x2="21" y2="6" />
                <path d="M16 10a4 4 0 0 1-8 0" />
              </svg>
            </span>
            <div class="min-w-0 flex-1">
              <p class="truncate text-sm font-bold text-white">{{ summary.name }}</p>
              <p class="text-xs text-white/50">
                {{ summary.quantity }} × {{ formatRupiah(summary.price) }}
                <template v-if="summary.extra"> · +{{ summary.extra }} item lain</template>
              </p>
            </div>
            <p class="flex-shrink-0 text-sm font-bold text-primary">{{ formatRupiah(summary.total) }}</p>
          </div>

          <div class="grid grid-cols-1 gap-3 border-t border-white/10 px-3 py-3 text-xs sm:grid-cols-2">
            <div class="flex items-start gap-2">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 flex-shrink-0 text-primary">
                <circle cx="12" cy="12" r="10" />
                <polyline points="12 6 12 12 16 14" />
              </svg>
              <div class="min-w-0">
                <p class="text-white/40">Tanggal pengiriman</p>
                <p class="font-semibold text-white">{{ formatDate(summary.date) }}</p>
              </div>
            </div>
            <div class="flex items-start gap-2">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 flex-shrink-0 text-primary">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                <circle cx="12" cy="10" r="3" />
              </svg>
              <div class="min-w-0">
                <p class="text-white/40">Alamat pengiriman</p>
                <p class="line-clamp-2 font-semibold text-white">{{ summary.address }}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-4 flex items-center gap-3 rounded-full bg-[#0f2a1c] px-4 py-3 text-xs text-[#6ee7a0] ring-1 ring-[#22c55e]/40">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="flex-shrink-0">
            <circle cx="12" cy="12" r="10" />
            <polyline points="8 12 11 15 16 9" />
          </svg>
          <span>{{ note }}</span>
        </div>

        <button
          type="button"
          class="group mt-6 flex w-full items-center justify-center gap-2 rounded-full bg-primary py-3 text-sm font-bold text-secondary transition-colors duration-200 hover:bg-[#ff9a1a]"
          @click="emit('primary')"
        >
          {{ primaryLabel }}
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="transition-transform duration-300 group-hover:translate-x-0.5">
            <line x1="5" y1="12" x2="19" y2="12" />
            <polyline points="12 5 19 12 12 19" />
          </svg>
        </button>
        <button
          v-if="secondaryLabel"
          type="button"
          class="mt-2 w-full rounded-full py-2.5 text-sm font-medium text-white/60 transition-colors duration-200 hover:text-white"
          @click="emit('secondary')"
        >
          {{ secondaryLabel }}
        </button>
      </div>
    </div>
  </div>
</template>
