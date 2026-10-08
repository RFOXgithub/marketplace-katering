<script setup>
defineProps({
  modelValue: String,
  label: String,
  placeholder: String,
  type: {
    type: String,
    default: 'text',
  },
  error: String,
})

defineEmits(['update:modelValue'])
</script>

<template>
  <div class="flex flex-col gap-1.5">
    <label class="text-[11px] font-semibold tracking-[0.08em] text-secondary/40 uppercase">{{
      label
    }}</label>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      @input="$emit('update:modelValue', $event.target.value)"
      class="rounded-2xl bg-secondary/[0.04] px-4 py-3 text-sm text-secondary transition-colors duration-300 placeholder-secondary/30 focus:bg-secondary/[0.06] focus:outline-none focus:ring-2 focus:ring-primary"
    />
    <p v-if="error" class="text-xs text-red-500">{{ error }}</p>
  </div>
</template>
