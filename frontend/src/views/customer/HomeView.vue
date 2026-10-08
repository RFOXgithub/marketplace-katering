<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { logout } from '@/services/authService'
import { getCustomerProfile, searchCaterings, getCategories } from '@/services/customerService'
import Skeleton from '@/components/animations/Skeleton.vue'

const router = useRouter()

const isLoading = ref(true)
const isSearching = ref(false)
const errorMessage = ref('')

const customer = ref(null)
const categories = ref([])
const caterings = ref([])

const keyword = ref('')
const city = ref('')
const categoryId = ref('')

function titleCase(value) {
  if (!value) return value
  return value
    .split(' ')
    .map((word) => (word ? word.charAt(0).toUpperCase() + word.slice(1) : word))
    .join(' ')
}

function buildQuery() {
  const params = new URLSearchParams()
  if (keyword.value) params.set('q', keyword.value)
  if (city.value) params.set('city', city.value)
  if (categoryId.value) params.set('category', categoryId.value)
  const query = params.toString()
  return query ? `?${query}` : ''
}

async function loadCaterings() {
  isSearching.value = true
  errorMessage.value = ''
  try {
    const res = await searchCaterings(buildQuery())
    caterings.value = res.data ?? []
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isSearching.value = false
  }
}

async function handleInit() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [profileRes, categoriesRes, cateringsRes] = await Promise.all([
      getCustomerProfile(),
      getCategories(),
      searchCaterings(''),
    ])
    customer.value = profileRes.data
    categories.value = categoriesRes.data ?? []
    caterings.value = cateringsRes.data ?? []
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleSearch() {
  loadCaterings()
}

async function handleLogout() {
  await logout()
  router.push('/login')
}

onMounted(handleInit)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-hidden bg-[#f7f5f2]">
    <div
      class="pointer-events-none fixed inset-0 z-0"
      style="
        background:
          radial-gradient(60rem 36rem at 85% -10%, rgba(245, 166, 35, 0.14), transparent 60%),
          radial-gradient(40rem 30rem at -10% 20%, rgba(74, 124, 89, 0.08), transparent 55%);
      "
    />

    <header class="sticky top-4 z-40 mx-4 sm:top-6 sm:mx-6">
      <div
        class="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 rounded-[1.75rem] border border-white/10 bg-secondary/90 px-4 py-3 shadow-[0_20px_50px_-20px_rgba(18,18,18,0.45)] backdrop-blur-xl sm:px-6 sm:py-3.5"
      >
        <div class="min-w-0">
          <p class="text-[10px] font-semibold uppercase tracking-[0.2em] text-white/40">
            Portal Kantor
          </p>
          <h1 class="truncate text-base font-bold text-primary sm:text-lg">
            {{ customer ? titleCase(customer.office_name) : 'Memuat...' }}
          </h1>
        </div>

        <nav class="flex flex-wrap items-center gap-1 sm:gap-2">
          <RouterLink
            to="/customer/orders"
            class="rounded-full px-3 py-1.5 text-sm font-medium text-white/60 transition-[color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
          >
            Riwayat Order
          </RouterLink>
          <RouterLink
            to="/customer/invoices"
            class="rounded-full px-3 py-1.5 text-sm font-medium text-white/60 transition-[color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
          >
            Invoice
          </RouterLink>
          <RouterLink
            to="/customer/profile"
            class="rounded-full px-3 py-1.5 text-sm font-medium text-white/60 transition-[color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
          >
            Profil
          </RouterLink>

          <button
            @click="handleLogout"
            class="group ml-1 flex items-center gap-2 rounded-full bg-primary py-1.5 pr-1.5 pl-4 text-sm font-semibold text-secondary transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
          >
            Logout
            <span
              class="flex h-6 w-6 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5 group-hover:-translate-y-[1px] group-hover:scale-105"
            >
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                <polyline points="16 17 21 12 16 7" />
                <line x1="21" y1="12" x2="9" y2="12" />
              </svg>
            </span>
          </button>
        </nav>
      </div>
    </header>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-6">
        <Skeleton width="100%" height="4rem" rounded="1.75rem" />
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-secondary/5 p-2">
            <div class="flex flex-col gap-2 rounded-[1.625rem] bg-white p-5">
              <Skeleton width="60%" height="1rem" />
              <Skeleton width="30%" height="0.75rem" />
              <Skeleton width="100%" height="0.75rem" class="mt-1" />
              <Skeleton width="80%" height="0.75rem" />
            </div>
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">
        {{ errorMessage }}
      </p>

      <div v-else class="flex flex-col gap-6">
        <span
          class="animate-fade-up w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
        >
          Cari Katering
        </span>

        <form
          @submit.prevent="handleSearch"
          class="animate-fade-up flex flex-col gap-3 rounded-[1.75rem] bg-white p-3 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)] ring-1 ring-secondary/5 sm:flex-row"
          style="animation-delay: 0.06s"
        >
          <input
            v-model="keyword"
            type="text"
            placeholder="Cari nama katering..."
            class="flex-1 rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary placeholder-secondary/30 focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <input
            v-model="city"
            type="text"
            placeholder="Kota"
            class="w-full rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary placeholder-secondary/30 focus:outline-none focus:ring-2 focus:ring-primary sm:w-40"
          />
          <select
            v-model="categoryId"
            class="w-full rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary sm:w-48"
          >
            <option value="">Semua Kategori</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.name }}
            </option>
          </select>
          <button
            type="submit"
            :disabled="isSearching"
            class="group flex items-center justify-center gap-2 rounded-2xl bg-primary px-5 py-2.5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97] disabled:opacity-70"
          >
            Cari
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:scale-110">
              <circle cx="11" cy="11" r="7" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
          </button>
        </form>

        <div v-if="isSearching" class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-secondary/5 p-2">
            <div class="flex flex-col gap-2 rounded-[1.625rem] bg-white p-5">
              <Skeleton width="60%" height="1rem" />
              <Skeleton width="30%" height="0.75rem" />
              <Skeleton width="100%" height="0.75rem" class="mt-1" />
              <Skeleton width="80%" height="0.75rem" />
            </div>
          </div>
        </div>

        <p v-else-if="caterings.length === 0" class="text-sm text-secondary/40">
          Tidak ada katering yang ditemukan.
        </p>

        <div v-else class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div
            v-for="(catering, index) in caterings"
            :key="catering.id"
            class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
            :style="{ animationDelay: `${Math.min(index, 8) * 0.06}s` }"
          >
            <div
              @click="router.push(`/caterings/${catering.slug}`)"
              class="group flex h-full cursor-pointer flex-col gap-2 rounded-[1.625rem] bg-white p-5 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)] transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
            >
              <span
                class="w-max rounded-full bg-primary/10 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-[0.1em] text-primary-dark"
              >
                {{ catering.city }}
              </span>
              <h2 class="mt-1 font-bold text-secondary">{{ catering.company_name }}</h2>
              <p class="line-clamp-2 flex-1 text-sm text-secondary/50">
                {{ catering.description || 'Belum ada deskripsi.' }}
              </p>
              <span
                class="flex items-center gap-1 text-xs font-semibold text-primary-dark opacity-0 transition-opacity duration-300 group-hover:opacity-100"
              >
                Lihat menu
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5">
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </span>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
