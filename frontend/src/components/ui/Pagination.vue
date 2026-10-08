<script setup>
defineProps({
  currentPage: {
    type: Number,
    required: true,
  },
  lastPage: {
    type: Number,
    required: true,
  },
  total: {
    type: Number,
    required: true,
  },
  label: {
    type: String,
    default: 'item',
  },
})

const emit = defineEmits(['change'])
</script>

<template>
  <div class="flex items-center justify-between text-sm text-subtle">
    <p class="flex items-center gap-1.5">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
      Total {{ total }} {{ label }}
    </p>
    <div class="flex items-center gap-2">
      <button
        :disabled="currentPage <= 1"
        @click="emit('change', currentPage - 1)"
        class="rounded-full px-4 py-1.5 font-medium ring-1 ring-ink/10 transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-30 disabled:hover:translate-y-0"
      >
        Sebelumnya
      </button>
      <span class="px-2 font-medium text-ink">{{ currentPage }} / {{ lastPage }}</span>
      <button
        :disabled="currentPage >= lastPage"
        @click="emit('change', currentPage + 1)"
        class="rounded-full px-4 py-1.5 font-medium ring-1 ring-ink/10 transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-30 disabled:hover:translate-y-0"
      >
        Berikutnya
      </button>
    </div>
  </div>
</template>
