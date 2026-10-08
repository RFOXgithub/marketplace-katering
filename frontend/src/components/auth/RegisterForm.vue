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
      <h2 class="text-[11px] font-semibold tracking-[0.08em] text-secondary/40 uppercase">
        Pilih Role Anda
      </h2>
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
        :radius="18"
        :inset="3"
        equalSlots
        :stretch="100"
        :squash="3"
        :speed="1"
        :glide="75"
        draggable
        ariaLabel="Role"
        className="border border-secondary/10"
        @change="(value, index) => (role = value)"
      />
    </div>
    <InputField
      v-model="name"
      label="Nama"
      type="text"
      :error="errors.name"
      placeholder="Nama lengkap"
    ></InputField>
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
    <InputField
      v-model="passwordConfirmation"
      placeholder="••••••••"
      label="Konfirmasi Password"
      type="password"
      :error="errors.passwordConfirmation"
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
        Daftar
        <span
          class="flex h-7 w-7 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
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
