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
  <main class="flex min-h-[100dvh]">
    <div class="relative hidden w-2/3 overflow-hidden md:block">
      <img src="/register.png" alt="registerIlustrasi" class="h-full w-full object-cover" />
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
          Satu platform untuk mengelola pesanan katering dan makan siang kantor.
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
          Daftar Akun
        </span>
        <h1 class="mt-3 text-2xl font-extrabold text-secondary">
          <ScrambleText text="Mulai Sekarang" />
        </h1>
        <p class="mt-1.5 mb-7 text-sm text-secondary/50">Isi data berikut untuk membuat akun</p>

        <RegisterForm :loading="isLoading" @submit="handleRegister" />
        <p v-if="errorMessage" class="mt-3 text-xs text-red-500">{{ errorMessage }}</p>

        <p class="mt-7 text-center text-sm text-secondary/50">
          Sudah punya akun?
          <RouterLink to="/login" class="font-semibold text-primary-dark hover:text-primary">
            Masuk di sini
          </RouterLink>
        </p>
      </div>
    </div>
  </main>

  <div
    v-if="showSuccessModal"
    class="fixed inset-0 z-50 flex items-center justify-center bg-secondary/60 p-4 backdrop-blur-sm"
  >
    <SpotlightCard
      class="w-full max-w-sm rounded-[2rem] border-0 bg-secondary p-2 shadow-[0_40px_80px_-30px_rgba(18,18,18,0.5)]"
      spotlight-color="rgba(245, 166, 35, 0.25)"
    >
      <div class="rounded-[1.625rem] p-7 text-center">
        <span
          class="mx-auto w-max rounded-full bg-primary/15 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary"
        >
          Berhasil
        </span>
        <h2 class="mt-3 text-xl font-extrabold text-white">Registrasi Berhasil!</h2>
        <p class="mt-2 mb-6 text-sm text-white/50">
          Akun kamu sudah dibuat. Silakan login untuk melanjutkan.
        </p>
        <button
          @click="goToLogin"
          class="group flex w-full items-center justify-center gap-2 rounded-full bg-primary py-3 pr-2 pl-5 font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98]"
        >
          Lanjut ke Login
          <span
            class="flex h-7 w-7 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
          >
            <svg
              width="11"
              height="11"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </span>
        </button>
      </div>
    </SpotlightCard>
  </div>
</template>
