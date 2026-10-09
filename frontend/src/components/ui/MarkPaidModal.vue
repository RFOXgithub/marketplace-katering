<script setup>
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  message: {
    type: String,
    default: 'Invoice ini akan ditandai sebagai lunas. Pastikan pembayaran dari customer sudah diterima.',
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['update:modelValue', 'confirm'])

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
    <div
      class="relative max-h-[90vh] w-full max-w-md overflow-hidden rounded-[2rem] bg-[#0b0b0c] ring-1 ring-primary/40 shadow-[0_0_70px_rgba(249,166,38,0.18)] md:min-h-[30rem] md:max-w-4xl"
      role="dialog"
      aria-modal="true"
      aria-label="Tandai Lunas"
    >
      <div class="pointer-events-none absolute -bottom-24 left-0 h-56 w-full bg-[radial-gradient(ellipse_at_center,rgba(249,166,38,0.22),transparent_70%)]"></div>

      <img
        src="/mark-paid-chef.png"
        alt=""
        draggable="false"
        loading="lazy"
        class="pointer-events-none absolute bottom-0 left-0 hidden h-full w-[50%] select-none object-cover object-left md:block"
        style="-webkit-mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 8%, #000 85%, transparent 100%); -webkit-mask-composite: source-in; mask-image: linear-gradient(to right, #000 60%, transparent 100%), linear-gradient(to bottom, transparent 0, #000 8%, #000 85%, transparent 100%); mask-composite: intersect"
      />

      <div
        class="relative max-h-[90vh] overflow-y-auto px-7 py-8 md:ml-[46%] md:flex md:min-h-[30rem] md:flex-col md:justify-center md:pr-9"
      >
        <span class="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-b from-[#fbbf5a] to-[#f9a626] shadow-[0_6px_18px_rgba(249,166,38,0.45)]">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12" />
          </svg>
        </span>

        <h2 class="text-2xl font-extrabold text-white">
          Tandai <span class="text-primary">Lunas?</span>
        </h2>
        <p class="mt-2 text-sm leading-relaxed text-white/60">{{ message }}</p>

        <div class="mt-6 flex gap-3">
          <button
            type="button"
            :disabled="loading"
            @click="close"
            class="flex-1 rounded-full py-3 text-sm font-semibold text-white ring-1 ring-primary/50 transition-colors duration-200 hover:bg-white/10 disabled:opacity-60"
          >
            Batal
          </button>
          <button
            type="button"
            :disabled="loading"
            @click="confirm"
            class="flex flex-[1.2] items-center justify-center gap-2 rounded-full bg-primary py-3 text-sm font-bold text-secondary transition-colors duration-200 hover:bg-[#ff9a1a] disabled:opacity-60"
          >
            <LatticeLoader
              v-if="loading"
              label="Memproses"
              status="working"
              :show-timer="false"
              color="currentColor"
              :cell-size="5"
              font-size="13"
            />
            <template v-else>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12" />
              </svg>
              Tandai Lunas
            </template>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
