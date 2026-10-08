<script setup>
import { ref } from 'vue'
import InputField from './InputField.vue'
import RubberSegment from '@/components/animations/RubberSegment.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['submit'])

const role = ref('customer')
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
  if (validate()) {
    emit('submit', {
      name: name.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value,
      role: role.value,
    })
  }
}
</script>

<template>
  <form @submit.prevent="handelSubmit" class="flex flex-col gap-4">
    <div class="flex flex-col gap-1.5">
      <h2 class="text-sm font-medium text-gray-700">Pilih Role Anda</h2>
      <RubberSegment
        :items="[
          { value: 'customer', label: 'Customer' },
          { value: 'merchant', label: 'Merchant' },
        ]"
        :value="role"
        trackColor="var(--color-secondary)"
        thumbColor="var(--color-primary)"
        textColor="#ffffff"
        activeTextColor="var(--color-secondary)"
        size="md"
        :radius="10"
        :inset="3"
        equalSlots
        :stretch="100"
        :squash="3"
        :speed="1"
        :glide="75"
        draggable
        ariaLabel="Role"
        className="border border-gray-200"
        @change="(value, index) => (role = value)"
      />
    </div>
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
      <span v-else>Daftar</span>
    </button>
  </form>
</template>
