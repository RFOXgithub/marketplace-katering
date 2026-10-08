<script setup>
import { computed } from 'vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import { formatRupiah, formatDate } from '@/utils/format'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  order: {
    type: Object,
    default: null,
  },
  note: {
    type: String,
    default: 'Jika Anda membatalkan pesanan, Anda mungkin akan dikenakan biaya pembatalan (jika berlaku).',
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['update:modelValue', 'confirm'])

const firstItem = computed(() => props.order?.items?.[0] ?? null)
const extraItems = computed(() => Math.max((props.order?.items?.length ?? 0) - 1, 0))

function close() {
  if (props.loading) return
  emit('update:modelValue', false)
}

function confirm() {
  if (props.loading) return
  emit('confirm')
}
</script>

<template>
  <div
    v-if="modelValue"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-6 backdrop-blur-sm"
    @click.self="close"
    @keydown.esc="close"
  >
    <!-- One single card: the illustration fades into the same background as the content -->
    <div
      class="relative w-full max-w-md overflow-hidden rounded-[2rem] bg-[#0b0b0c] ring-1 ring-primary/40 shadow-[0_0_70px_rgba(249,166,38,0.18)] md:max-w-4xl"
      role="dialog"
      aria-modal="true"
      aria-label="Batalkan Order"
    >
      <div class="pointer-events-none absolute -bottom-24 left-0 h-56 w-full bg-[radial-gradient(ellipse_at_center,rgba(249,166,38,0.22),transparent_70%)]"></div>

      <img
        src="/cancel-order-girl.png"
        alt=""
        draggable="false"
        class="pointer-events-none absolute bottom-0 left-0 hidden h-full w-[48%] select-none object-cover object-left md:block"
        style="-webkit-mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 18%, #000 85%, transparent 100%); -webkit-mask-composite: source-in; mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 18%, #000 85%, transparent 100%); mask-composite: intersect"
      />

      <div class="relative px-7 py-8 md:ml-[44%] md:pr-9">
        <svg class="mb-3 drop-shadow-[0_6px_14px_rgba(249,166,38,0.45)]" width="48" height="44" viewBox="0 0 64 58" fill="none">
          <path d="M27.5 5.5a5 5 0 0 1 9 0l24 41a5 5 0 0 1-4.5 7.5H8a5 5 0 0 1-4.5-7.5z" fill="#f9a626" stroke="#fbbf5a" stroke-width="2" stroke-linejoin="round" />
          <rect x="29.5" y="18" width="5" height="18" rx="2.5" fill="#1a1208" />
          <circle cx="32" cy="43" r="3" fill="#1a1208" />
        </svg>

        <h2 class="text-2xl font-extrabold text-white">
          Batalkan <span class="text-primary">Order?</span>
        </h2>
        <p class="mt-2 text-sm leading-relaxed text-white/60">
          Apakah Anda yakin ingin membatalkan pesanan ini? Pesanan yang sudah dibatalkan tidak dapat dikembalikan.
        </p>

        <div v-if="order" class="mt-5 overflow-hidden rounded-2xl bg-white/5 ring-1 ring-white/10">
          <div class="flex items-center gap-3 p-3">
            <span class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                <line x1="3" y1="6" x2="21" y2="6" />
                <path d="M16 10a4 4 0 0 1-8 0" />
              </svg>
            </span>
            <div class="min-w-0 flex-1">
              <p class="truncate text-sm font-bold text-white">
                {{ firstItem?.menu_name ?? `Order #${order.id}` }}
              </p>
              <p class="text-xs text-white/50">
                <template v-if="firstItem">{{ firstItem.quantity }} × {{ formatRupiah(firstItem.price) }}</template>
                <template v-if="extraItems"> · +{{ extraItems }} item lain</template>
              </p>
            </div>
            <p class="flex-shrink-0 text-sm font-bold text-primary">{{ formatRupiah(order.total_amount) }}</p>
          </div>

          <div class="grid grid-cols-1 gap-3 border-t border-white/10 px-3 py-3 text-xs sm:grid-cols-2">
            <div class="flex items-start gap-2">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 flex-shrink-0 text-primary">
                <circle cx="12" cy="12" r="10" />
                <polyline points="12 6 12 12 16 14" />
              </svg>
              <div class="min-w-0">
                <p class="text-white/40">Tanggal pengiriman</p>
                <p class="font-semibold text-white">{{ formatDate(order.delivery_date) }}</p>
              </div>
            </div>
            <div class="flex items-start gap-2">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 flex-shrink-0 text-primary">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                <circle cx="12" cy="10" r="3" />
              </svg>
              <div class="min-w-0">
                <p class="text-white/40">Alamat pengiriman</p>
                <p class="line-clamp-2 font-semibold text-white">{{ order.delivery_address }}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-4 flex items-start gap-3 rounded-2xl bg-primary/10 px-4 py-3 text-xs leading-relaxed text-primary ring-1 ring-primary/20">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-px flex-shrink-0">
            <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
            <line x1="12" y1="9" x2="12" y2="13" />
            <line x1="12" y1="17" x2="12.01" y2="17" />
          </svg>
          <span>{{ note }}</span>
        </div>

        <div class="mt-6 flex gap-3">
          <button
            type="button"
            :disabled="loading"
            @click="close"
            class="flex-1 rounded-full py-3 text-sm font-semibold text-white ring-1 ring-primary/50 transition-colors duration-200 hover:bg-white/10 disabled:opacity-60"
          >
            Kembali
          </button>
          <button
            type="button"
            :disabled="loading"
            @click="confirm"
            class="flex flex-[1.2] items-center justify-center gap-2 rounded-full bg-primary py-3 text-sm font-bold text-secondary transition-colors duration-200 hover:bg-[#ff9a1a] disabled:opacity-60"
          >
            <LatticeLoader
              v-if="loading"
              label="Membatalkan"
              status="working"
              :show-timer="false"
              color="currentColor"
              :cell-size="5"
              font-size="13"
            />
            <template v-else>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="3 6 5 6 21 6" />
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
              </svg>
              Batalkan Order
            </template>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
