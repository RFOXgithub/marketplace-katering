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
    const data = await login(credentials)
    if (data.user.role === 'merchant') {
      router.push('/merchant/dashboard')
    } else {
      router.push('/customer/home')
    }
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <main class="flex min-h-[100dvh]">
    <div class="relative hidden w-2/3 overflow-hidden md:block">
      <img src="/login.png" alt="loginIlustrasi" class="h-full w-full object-cover" />
      <div
        class="absolute inset-0 bg-gradient-to-t from-secondary/80 via-secondary/0 to-secondary/10"
      />
      <div class="absolute bottom-0 left-0 p-10">
        <span
          class="w-max rounded-full bg-white/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary backdrop-blur-sm"
        >
          Marketplace Katering
        </span>
        <p class="mt-4 max-w-sm text-2xl font-bold text-white">
          Hubungkan katering Anda dengan kantor yang butuh makan siang setiap hari.
        </p>
      </div>
    </div>

    <div class="relative flex w-full items-center justify-center bg-[#fbfaf8] p-6 md:w-1/3">
      <div
        class="pointer-events-none absolute inset-0 overflow-hidden"
        style="
          background: radial-gradient(
            28rem 20rem at 50% -10%,
            rgba(245, 166, 35, 0.12),
            transparent 60%
          );
        "
      />

      <div class="animate-fade-up relative w-full max-w-[280px]">
        <div class="mb-8 flex items-center gap-2.5">
          <img src="/logo-mark.svg" alt="logo" class="h-8 w-8" />
          <span class="text-sm font-bold text-secondary">Marketplace Katering</span>
        </div>

        <span
          class="w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
        >
          Portal Masuk
        </span>
        <h1 class="mt-3 text-2xl font-extrabold text-secondary">
          <ScrambleText text="Selamat Datang" />
        </h1>
        <p class="mt-1.5 mb-7 text-sm text-secondary/50">
          Masuk untuk melanjutkan ke dashboard kamu
        </p>

        <LoginForm :loading="isLoading" @submit="handleLogin" />
        <p v-if="errorMessage" class="mt-3 text-xs text-red-500">{{ errorMessage }}</p>

        <p class="mt-7 text-center text-sm text-secondary/50">
          Belum punya akun?
          <RouterLink to="/register" class="font-semibold text-primary-dark hover:text-primary">
            Daftar sekarang
          </RouterLink>
        </p>
      </div>
    </div>
  </main>
</template>
