<script setup>
import { ref } from 'vue'

const props = defineProps({
  label: {
    type: String,
    default: 'Pilih File',
  },
  accept: {
    type: String,
    default: 'image/*',
  },
})

const emit = defineEmits(['change'])

const fileInput = ref(null)
const fileName = ref('')

function openPicker() {
  fileInput.value?.click()
}

function handleChange(event) {
  const file = event.target.files[0]
  fileName.value = file ? file.name : ''
  emit('change', event)
}
</script>

<template>
  <div class="flex min-w-0 items-center gap-3">
    <input ref="fileInput" type="file" :accept="accept" class="hidden" @change="handleChange" />
    <button
      type="button"
      @click="openPicker"
      class="shrink-0 rounded-full bg-secondary/[0.06] px-4 py-2 text-xs font-semibold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
    >
      {{ label }}
    </button>
    <span class="min-w-0 flex-1 truncate text-xs text-secondary/40">
      {{ fileName || 'Belum ada file dipilih' }}
    </span>
  </div>
</template>
