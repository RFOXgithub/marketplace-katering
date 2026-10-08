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
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Kantor</p>
        <h1 class="text-lg font-bold text-primary">
          {{ customer?.office_name ?? 'Memuat...' }}
        </h1>
      </div>
      <button
        @click="handleLogout"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Logout
      </button>
    </header>

    <main class="p-6">
      <div v-if="isLoading" class="flex flex-col gap-6">
        <Skeleton width="100%" height="3rem" rounded="0.75rem" />
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="flex flex-col gap-2 rounded-xl border border-gray-200 bg-white p-5">
            <Skeleton width="60%" height="1rem" />
            <Skeleton width="30%" height="0.75rem" />
            <Skeleton width="100%" height="0.75rem" class="mt-1" />
            <Skeleton width="80%" height="0.75rem" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">
        {{ errorMessage }}
      </p>

      <div v-else class="flex flex-col gap-6">
        <form
          @submit.prevent="handleSearch"
          class="flex flex-col gap-3 rounded-xl border border-gray-200 bg-white p-4 sm:flex-row"
        >
          <input
            v-model="keyword"
            type="text"
            placeholder="Cari nama katering..."
            class="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <input
            v-model="city"
            type="text"
            placeholder="Kota"
            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm sm:w-40 focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <select
            v-model="categoryId"
            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm sm:w-48 focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="">Semua Kategori</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.name }}
            </option>
          </select>
          <button
            type="submit"
            :disabled="isSearching"
            class="rounded-lg bg-primary px-5 py-2 text-sm font-bold text-secondary transition hover:bg-primary-dark disabled:opacity-70"
          >
            Cari
          </button>
        </form>

        <div v-if="isSearching" class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="flex flex-col gap-2 rounded-xl border border-gray-200 bg-white p-5">
            <Skeleton width="60%" height="1rem" />
            <Skeleton width="30%" height="0.75rem" />
            <Skeleton width="100%" height="0.75rem" class="mt-1" />
            <Skeleton width="80%" height="0.75rem" />
          </div>
        </div>

        <p v-else-if="caterings.length === 0" class="text-sm text-gray-400">
          Tidak ada katering yang ditemukan.
        </p>

        <div v-else class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div
            v-for="catering in caterings"
            :key="catering.id"
            class="flex flex-col gap-2 rounded-xl border border-gray-200 bg-white p-5 transition hover:border-primary"
          >
            <h2 class="font-bold text-secondary">{{ catering.company_name }}</h2>
            <p class="text-xs text-gray-500">{{ catering.city }}</p>
            <p class="line-clamp-2 text-sm text-gray-600">
              {{ catering.description || 'Belum ada deskripsi.' }}
            </p>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
