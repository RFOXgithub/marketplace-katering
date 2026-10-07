<script setup>
import { ref } from 'vue'
import InputField from './InputField.vue'

const emit = defineEmits(['submit'])

const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const errors = ref({})

function validate() {
  errors.value = {}
  if (!name.value) errors.value.name = 'Nama wajib di isi'
  if (!email.value) errors.value.email = 'Email wajib di isi'
  if (password.value.length < 6) errors.value.password = 'Minimal 6 karakter'
  if (password.value !== passwordConfirmation.value)
    errors.value.passwordConfirmation = 'Konfirmasi password tidak sama'
  return Object.keys(errors.value).length === 0
}

function handelSubmit() {
  if (validate) {
    emit('submit', {
      name: name.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation,
    })
  }
}
</script>

<template>
  <form @submit.prevent="handelSubmit" class="flex flex-col gap-4">
    <InputField
      v-model="name"
      label="Name"
      type="text"
      :error="errors.name"
      placeholder="Name"
    ></InputField>
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
    <InputField
      v-model="passwordConfirmation"
      placeholder="Confirm Password"
      label="Confirm Password"
      type="password"
      :error="errors.passwordConfirmation"
    ></InputField>
    <button
      type="submit"
      class="rounded-lg bg-primary hover:bg-primary-dark py-2 font-bold text-secondary transition"
    >
      Daftar
    </button>
  </form>
</template>
