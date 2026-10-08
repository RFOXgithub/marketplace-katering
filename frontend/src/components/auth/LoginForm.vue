<script setup>
import { ref } from 'vue'
import InputField from './InputField.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['submit'])

const email = ref('')
const password = ref('')
const errors = ref({})

function validate() {
  errors.value = {}
  if (!email.value) errors.value.email = 'Email wajib di isi'
  if (password.value.length < 6) errors.value.password = 'Minimal 6 karakter'
  return Object.keys(errors.value).length === 0
}

function handelSubmit() {
  if (validate()) {
    emit('submit', {
      email: email.value,
      password: password.value,
    })
  }
}
</script>

<template>
  <form @submit.prevent="handelSubmit" class="flex flex-col gap-4">
    <InputField
      v-model="email"
      label="Email"
      type="email"
      :error="errors.email"
      placeholder="nama@perusahaan.com"
    ></InputField>
    <InputField
      v-model="password"
      placeholder="••••••••"
      label="Password"
      type="password"
      :error="errors.password"
    ></InputField>
    <button
      type="submit"
      :disabled="loading"
      class="group mt-1 flex items-center justify-center gap-2 rounded-full bg-primary py-3 pr-2 pl-5 font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-70"
    >
      <LatticeLoader
        v-if="loading"
        label="Memproses"
        status="working"
        :show-timer="false"
        color="currentColor"
        :cell-size="5"
        font-size="13"
      />
      <template v-else>
        Masuk
        <span
          class="flex h-7 w-7 items-center justify-center rounded-full bg-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
        >
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="5" y1="12" x2="19" y2="12" />
            <polyline points="12 5 19 12 12 19" />
          </svg>
        </span>
      </template>
    </button>
  </form>
</template>
