<script setup>
defineProps({
  status: {
    type: String,
    required: true,
  },
  labels: {
    type: Object,
    required: true,
  },
  classes: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <span
    class="rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-[0.08em]"
    :class="classes[status] ?? Object.values(classes)[0]"
  >
    {{ labels[status] ?? status }}
  </span>
</template>
