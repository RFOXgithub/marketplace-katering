<script setup>
defineProps({
  filters: {
    type: Array,
    required: true,
  },
  modelValue: {
    type: [String, Number],
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
      class="flex items-center gap-2 rounded-full px-4 py-2 text-sm font-medium transition-[transform,background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
      :class="modelValue === filter.value ? 'bg-primary/10 text-primary-dark' : 'bg-card text-muted ring-1 ring-ink/10'"
    >
      <slot name="icon" :filter="filter" />
      {{ filter.label }}
      <span
        v-if="filter.count !== undefined"
        class="min-w-[1.25rem] rounded-full px-1 text-center text-xs font-bold leading-5"
        :class="modelValue === filter.value ? 'bg-primary/20 text-primary-dark' : 'bg-ink/10 text-subtle'"
      >
        {{ filter.count }}
      </span>
    </button>
  </div>
</template>
