<script setup>
defineProps({
  width: {
    type: String,
    default: '100%',
  },
  height: {
    type: String,
    default: '1rem',
  },
  rounded: {
    type: String,
    default: '0.5rem',
  },
})
</script>

<template>
  <span
    class="skeleton-shimmer block"
    :style="{ width, height, borderRadius: rounded }"
    aria-hidden="true"
  />
</template>

<style scoped>
.skeleton-shimmer {
  background: linear-gradient(
    90deg,
    var(--skeleton-base, #e5e7eb) 25%,
    rgba(245, 166, 35, 0.25) 50%,
    var(--skeleton-base, #e5e7eb) 75%
  );
  background-size: 200% 100%;
  animation: skeleton-wave 1.6s ease-in-out infinite;
}

@keyframes skeleton-wave {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .skeleton-shimmer {
    animation: none;
    opacity: 0.6;
  }
}
</style>
