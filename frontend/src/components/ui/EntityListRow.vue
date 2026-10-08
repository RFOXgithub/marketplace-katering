<script setup>
defineProps({
  thumbnail: {
    type: String,
    default: null,
  },
  alt: {
    type: String,
    default: '',
  },
  dotClass: {
    type: String,
    default: '',
  },
})

defineEmits(['click', 'thumbnail-error'])
</script>

<template>
  <div
    class="group relative flex cursor-pointer items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4 shadow-[0_1px_2px_rgba(18,18,18,0.04)] transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:border-primary/30"
    @click="$emit('click')"
  >
    <!-- thumbnail + dot status indikator -->
    <div class="relative h-[4.5rem] w-[4.5rem] shrink-0">
      <div class="h-full w-full overflow-hidden rounded-xl bg-ink/10">
        <img
          v-if="thumbnail"
          :src="thumbnail"
          :alt="alt"
          class="h-full w-full object-cover"
          @error="$emit('thumbnail-error')"
        />
        <div v-else class="flex h-full w-full items-center justify-center">
          <slot name="fallback-icon" />
        </div>
      </div>
      <span
        v-if="dotClass"
        class="absolute -bottom-1 -right-1 h-4 w-4 rounded-full ring-2 ring-card"
        :class="dotClass"
      />
    </div>

    <!-- info -->
    <div class="min-w-0 flex-1">
      <slot name="info" />
    </div>

    <!-- trailing (harga, badge, arrow, dll) -->
    <div class="flex shrink-0 items-center gap-3">
      <slot name="trailing" />
    </div>
  </div>
</template>
