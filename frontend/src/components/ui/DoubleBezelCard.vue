<script setup>
defineProps({
  delay: {
    type: String,
    default: '0s',
  },
  padding: {
    type: String,
    default: 'p-6 sm:p-7',
  },
  animate: {
    type: Boolean,
    default: true,
  },
})
</script>

<template>
  <div
    :class="['rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5', { 'animate-fade-up': animate }]"
    :style="{ animationDelay: delay }"
  >
    <div :class="['rounded-[1.625rem] bg-card', padding]">
      <slot />
    </div>
  </div>
</template>
