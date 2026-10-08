<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import LoginForm from '@/components/auth/LoginForm.vue'
import { login } from '@/services/authService'
import ScrambleText from '@/components/animations/ScrambleText.vue'

const router = useRouter()
const errorMessage = ref('')
const isLoading = ref(false)

async function handleLogin(credentials) {
  errorMessage.value = ''
  isLoading.value = true
  try {
    await login(credentials)
    router.push('/')
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <main class="flex min-h-screen">
    <div class="hidden md:block w-2/3 h-full">
      <img src="/login.png" alt="loginIlustrasi" class="w-full h-full object-cover" />
    </div>

    <div class="flex w-full md:w-1/3 items-center justify-center bg-white p-6 relative">
      <img src="/logo-mark.svg" alt="logo" class="absolute w-10 h-10 top-3 right-3" />
      <div class="w-full max-w-[260px] text-sm">
        <h1 class="mb-1.5 text-lg font-bold text-primary"><ScrambleText text="Login" /></h1>
        <p class="mb-4 text-xs text-gray-500">
          <ScrambleText text="Silahkan memasukan data untuk masuk" />
        </p>
        <LoginForm :loading="isLoading" @submit="handleLogin" />
        <p v-if="errorMessage" class="mt-3 text-xs text-red-400">{{ errorMessage }}</p>
        <p class="pt-3 text-center text-xs text-gray-500">
          Anda belum memiliki akun?
          <RouterLink to="/register" class="text-primary cursor-pointer hover:text-primary-dark"
            >Daftar sekarang!</RouterLink
          >
        </p>
      </div>
    </div>
  </main>
</template>
