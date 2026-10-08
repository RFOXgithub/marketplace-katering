<script setup>
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  confirmLabel: {
    type: String,
    default: 'Ya, Lanjutkan',
  },
  cancelLabel: {
    type: String,
    default: 'Batal',
  },
  danger: {
    type: Boolean,
    default: false,
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['update:modelValue', 'confirm'])

function close() {
  emit('update:modelValue', false)
}

function confirm() {
  emit('confirm')
}
</script>

<template>
  <div
    v-if="modelValue"
    class="fixed inset-0 z-50 flex items-center justify-center bg-secondary/60 p-4 backdrop-blur-sm"
  >
    <div class="w-full max-w-sm rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5">
      <SpotlightCard
        class="rounded-[1.625rem] border-0 bg-secondary p-7 text-center"
        :spotlight-color="danger ? 'rgba(239, 68, 68, 0.2)' : 'rgba(245, 166, 35, 0.25)'"
      >
        <span
          class="mx-auto w-max rounded-full px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em]"
          :class="danger ? 'bg-red-500/15 text-red-400' : 'bg-primary/15 text-primary'"
        >
          {{ danger ? 'Perlu Konfirmasi' : 'Konfirmasi' }}
        </span>

        <h2 class="mt-3 text-lg font-extrabold text-white">{{ title }}</h2>
        <p class="mt-2 mb-6 text-sm text-white/50">{{ message }}</p>

        <div class="flex flex-col gap-2">
          <button
            :disabled="loading"
            @click="confirm"
            class="flex items-center justify-center gap-2 rounded-full py-3 font-bold transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-60"
            :class="danger ? 'bg-red-500 text-white' : 'bg-primary text-secondary'"
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
            <span v-else>{{ confirmLabel }}</span>
          </button>
          <button
            :disabled="loading"
            @click="close"
            class="rounded-full py-3 text-sm font-medium text-white/60 ring-1 ring-white/15 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-60"
          >
            {{ cancelLabel }}
          </button>
        </div>
      </SpotlightCard>
    </div>
  </div>
</template>
