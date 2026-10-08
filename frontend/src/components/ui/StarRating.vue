<script setup>
defineProps({
  value: {
    type: Number,
    required: true,
  },
  size: {
    type: Number,
    default: 13,
  },
  colorClass: {
    type: String,
    default: 'text-primary-dark',
  },
})
</script>

<template>
  <div class="flex items-center gap-0.5">
    <svg
      v-for="n in 5"
      :key="n"
      :width="size"
      :height="size"
      viewBox="0 0 24 24"
      :fill="n <= value ? 'currentColor' : 'none'"
      stroke="currentColor"
      stroke-width="1.5"
      :class="colorClass"
    >
      <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
    </svg>
  </div>
</template>
