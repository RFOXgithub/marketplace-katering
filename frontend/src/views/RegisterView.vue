<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import RegisterForm from '@/components/auth/RegisterForm.vue'
import { register } from '@/services/authService'
import ScrambleText from '@/components/animations/ScrambleText.vue'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'

const router = useRouter()
const errorMessage = ref('')
const showSuccessModal = ref(false)
const isLoading = ref(false)

async function handleRegister(data) {
  errorMessage.value = ''
  isLoading.value = true
  try {
    await register(data)
    showSuccessModal.value = true
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function goToLogin() {
  showSuccessModal.value = false
  router.push('/login')
}
</script>

<template>
  <main class="flex min-h-screen">
    <div class="hidden md:block w-2/3 h-full">
      <img src="/register.png" alt="registerIlustrasi" class="w-full h-full object-cover" />
    </div>

    <div class="flex w-full md:w-1/3 items-center justify-center bg-white p-6 relative">
      <img src="/logo-mark.svg" alt="logo" class="absolute w-10 h-10 top-3 right-3" />
      <div class="w-full max-w-[260px] text-sm">
        <h1 class="mb-1.5 text-lg font-bold text-primary"><ScrambleText text="Daftar" /></h1>
        <p class="mb-4 text-xs text-gray-500">
          <ScrambleText text="Silahkan isi data anda untuk mendaftar" />
        </p>
        <RegisterForm :loading="isLoading" @submit="handleRegister" />
        <p v-if="errorMessage" class="mt-3 text-xs text-red-400">{{ errorMessage }}</p>
        <p class="pt-3 text-center text-xs text-gray-500">
          Anda sudah memiliki akun?
          <RouterLink to="/login" class="text-primary cursor-pointer hover:text-primary-dark"
            >Login disini</RouterLink
          >
        </p>
      </div>
    </div>
  </main>

  <div
    v-if="showSuccessModal"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
  >
    <SpotlightCard
      class="custom-spotlight-card max-w-sm w-full bg-secondary"
      spotlight-color="rgba(245, 166, 35, 0.2)"
    >
      <div class="text-center p-6">
        <h2 class="text-lg font-bold text-primary mb-2">Registrasi Berhasil!</h2>
        <p class="text-sm text-gray-300 mb-4">
          Akun kamu sudah dibuat. Silakan login untuk melanjutkan.
        </p>
        <button
          @click="goToLogin"
          class="w-full rounded-lg bg-primary hover:bg-primary-dark py-2 font-bold text-secondary transition"
        >
          Lanjut ke Login
        </button>
      </div>
    </SpotlightCard>
  </div>
</template>
