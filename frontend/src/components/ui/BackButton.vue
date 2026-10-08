<script setup>
import { useRouter } from 'vue-router'

const props = defineProps({
  to: {
    type: String,
    required: true,
  },
  label: {
    type: String,
    default: 'Kembali',
  },
})

const router = useRouter()
</script>

<template>
  <button
    @click="router.push(to)"
    class="group flex items-center gap-2 rounded-full border border-white/15 py-1.5 pr-4 pl-1.5 text-sm font-medium text-white/70 transition-[transform,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
  >
    <span
      class="flex h-6 w-6 items-center justify-center rounded-full bg-white/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:-translate-x-0.5"
    >
      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12" />
        <polyline points="12 19 5 12 12 5" />
      </svg>
    </span>
    {{ label }}
  </button>
</template>
