<script setup>
defineProps({
  label: {
    type: String,
    required: true,
  },
  error: {
    type: String,
    default: '',
  },
  hint: {
    type: String,
    default: '',
  },
})
</script>

<template>
  <div class="flex flex-col gap-1">
    <div class="flex flex-wrap items-center justify-between gap-x-3 gap-y-1">
      <label
        class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle"
      >
        <slot name="icon" />
        {{ label }}
      </label>
      <slot name="label-action" />
    </div>

    <slot />
    <slot name="footer" />

    <p v-if="hint" class="text-xs text-subtle">{{ hint }}</p>
    <p v-if="error" class="text-xs text-red-600 dark:text-red-400">{{ error }}</p>
  </div>
</template>
