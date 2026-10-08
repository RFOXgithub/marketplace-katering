<script setup>
defineProps({
  eyebrow: {
    type: String,
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  maxWidth: {
    type: String,
    default: 'max-w-3xl',
  },
  sticky: {
    type: Boolean,
    default: true,
  },
})
</script>

<template>
  <header
    :class="[
      'z-40 mx-4 sm:mx-6',
      sticky ? 'sticky top-4 sm:top-6' : 'relative mt-4 sm:mt-6',
    ]"
  >
    <div
      :class="[
        'mx-auto flex flex-wrap items-center justify-between gap-3 rounded-[1.75rem] border border-white/10 bg-secondary/90 px-4 py-3 shadow-[0_20px_50px_-20px_rgba(18,18,18,0.45)] backdrop-blur-xl sm:px-6 sm:py-3.5',
        maxWidth,
      ]"
    >
      <div class="min-w-0">
        <p class="text-[10px] font-semibold uppercase tracking-[0.2em] text-white/40">
          {{ eyebrow }}
        </p>
        <h1 class="flex items-center gap-2 truncate text-base font-bold text-primary sm:text-lg">
          <slot name="title-icon" />
          <span class="truncate">{{ title }}</span>
        </h1>
      </div>

      <div class="flex flex-wrap items-center gap-1 sm:gap-2">
        <slot />
      </div>
    </div>
  </header>
</template>
