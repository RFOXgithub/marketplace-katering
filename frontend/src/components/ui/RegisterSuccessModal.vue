<script setup>
defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  actionLabel: {
    type: String,
    default: 'Lanjut ke Login',
  },
})

const emit = defineEmits(['update:modelValue', 'action'])

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
      aria-label="Registrasi Berhasil"
    >
      <div class="pointer-events-none absolute -bottom-24 left-0 h-56 w-full bg-[radial-gradient(ellipse_at_center,rgba(249,166,38,0.22),transparent_70%)]"></div>

      <img
        src="/register-success-girl.png"
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
          Registrasi <span class="text-primary">Berhasil!</span>
        </h2>
        <p class="mt-2 text-sm leading-relaxed text-white/60">
          Selamat datang di Marketplace Katering! Akun Anda telah berhasil dibuat dan siap untuk memesan katering terbaik.
        </p>

        <div class="mt-5 grid grid-cols-3 divide-x divide-white/10 rounded-2xl bg-white/5 py-4 ring-1 ring-white/10">
          <div class="flex flex-col items-center gap-2 px-2 text-center text-[11px] leading-tight text-white/70">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#f9a626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M6 13.87A4 4 0 0 1 7.41 6a5.11 5.11 0 0 1 9.18 0A4 4 0 0 1 18 13.87V21H6z" />
              <line x1="6" y1="17" x2="18" y2="17" />
            </svg>
            <span>Nikmati<br />Beragam Menu</span>
          </div>
          <div class="flex flex-col items-center gap-2 px-2 text-center text-[11px] leading-tight text-white/70">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#f9a626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <polyline points="9 12 11 14 15 10" />
            </svg>
            <span>Transaksi<br />Aman &amp; Terpercaya</span>
          </div>
          <div class="flex flex-col items-center gap-2 px-2 text-center text-[11px] leading-tight text-white/70">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#f9a626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="1" y="3" width="15" height="13" rx="1" />
              <polygon points="16 8 20 8 23 11 23 16 16 16 16 8" />
              <circle cx="5.5" cy="18.5" r="2.5" />
              <circle cx="18.5" cy="18.5" r="2.5" />
            </svg>
            <span>Pengiriman<br />Tepat Waktu</span>
          </div>
        </div>

        <button
          type="button"
          class="group mt-6 flex w-full items-center justify-center gap-2 rounded-full bg-primary py-3 text-sm font-bold text-secondary transition-colors duration-200 hover:bg-[#ff9a1a]"
          @click="emit('action')"
        >
          {{ actionLabel }}
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="transition-transform duration-300 group-hover:translate-x-0.5">
            <line x1="5" y1="12" x2="19" y2="12" />
            <polyline points="12 5 19 12 12 19" />
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>
