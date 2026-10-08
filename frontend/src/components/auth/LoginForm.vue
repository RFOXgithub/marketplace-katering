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
      placeholder="Email"
    ></InputField>
    <InputField
      v-model="password"
      placeholder="Password"
      label="Password"
      type="password"
      :error="errors.password"
    ></InputField>
    <button
      type="submit"
      :disabled="loading"
      class="flex items-center justify-center rounded-lg bg-primary hover:bg-primary-dark py-2 font-bold text-secondary transition disabled:opacity-70 disabled:cursor-not-allowed"
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
      <span v-else>Masuk</span>
    </button>
  </form>
</template>
