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
  <div class="flex flex-col gap-1">
    <label class="text-sm font-medium text-gray-700">{{ label }}</label>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      @input="$emit('update:modelValue', $event.target.value)"
      class="rounded-lg border border-gray-300 bg-white text-gray-800 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary placeholder-gray-400"
    />
    <p v-if="error" class="text-sm text-red-500">{{ error }}</p>
  </div>
</template>
