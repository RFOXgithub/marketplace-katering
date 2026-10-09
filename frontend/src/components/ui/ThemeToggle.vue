<script setup>
import { computed } from 'vue'
import { theme, toggleTheme } from '@/services/theme'

const isDark = computed(() => theme.value === 'dark')
</script>

<template>
  <button
    type="button"
    :aria-label="isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap'"
    :title="isDark ? 'Mode terang' : 'Mode gelap'"
    class="fixed right-4 bottom-20 z-40 flex h-11 w-11 items-center justify-center rounded-full bg-card text-ink shadow-[0_10px_30px_-10px_rgba(0,0,0,0.5)] ring-1 ring-ink/10 transition-[transform,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary-dark active:scale-95 sm:right-6 sm:bottom-6"
    @click="toggleTheme"
  >
    <svg
      v-if="isDark"
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <circle cx="12" cy="12" r="4" />
      <path
        d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"
      />
    </svg>
    <svg
      v-else
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
    </svg>
  </button>
</template>
