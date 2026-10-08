<script setup>
defineProps({
  filters: {
    type: Array,
    required: true,
  },
  modelValue: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['update:modelValue'])
</script>

<template>
  <div class="animate-fade-up mb-6 flex flex-wrap gap-2">
    <button
      v-for="filter in filters"
      :key="filter.value"
      @click="emit('update:modelValue', filter.value)"
      class="rounded-full px-4 py-2 text-sm font-medium transition-[transform,background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
      :class="
        modelValue === filter.value
          ? 'bg-secondary text-white'
          : 'bg-white text-secondary/60 ring-1 ring-secondary/10'
      "
    >
      {{ filter.label }}
    </button>
  </div>
</template>
