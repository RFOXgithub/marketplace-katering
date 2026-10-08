<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getCateringDetail } from '@/services/customerService'
import { addToCart, cartCount, cartMerchant } from '@/services/cartStore'
import Skeleton from '@/components/animations/Skeleton.vue'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const merchant = ref(null)
const quantities = ref({})

function photoUrl(path) {
  return path ? `${STORAGE_URL}/${path}` : '/logo-mark.svg'
}

function formatRupiah(value) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(value ?? 0)
}

async function loadCatering() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getCateringDetail(route.params.slug)
    merchant.value = res.data
    quantities.value = Object.fromEntries(res.data.menus.map((menu) => [menu.id, 1]))
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleAddToCart(menu) {
  addToCart(
    { id: merchant.value.id, slug: merchant.value.slug, company_name: merchant.value.company_name },
    menu,
    quantities.value[menu.id] ?? 1,
  )
}

onMounted(loadCatering)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Kantor</p>
        <h1 class="text-lg font-bold text-primary">Detail Katering</h1>
      </div>
      <button
        @click="router.push('/customer/home')"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Kembali
      </button>
    </header>

    <main class="p-6">
      <div v-if="isLoading" class="mx-auto flex max-w-4xl flex-col gap-6">
        <Skeleton width="100%" height="8rem" rounded="0.75rem" />
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="rounded-xl border border-gray-200 bg-white p-4">
            <Skeleton width="100%" height="8rem" rounded="0.5rem" />
            <Skeleton width="60%" height="0.875rem" class="mt-3" />
            <Skeleton width="30%" height="0.875rem" class="mt-2" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div v-else-if="merchant" class="mx-auto flex max-w-4xl flex-col gap-6">
        <div class="rounded-xl border border-gray-200 bg-white p-6">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-xl font-bold text-secondary">{{ merchant.company_name }}</h2>
              <p class="text-sm text-gray-500">{{ merchant.city }}</p>
            </div>
            <img
              :src="photoUrl(merchant.logo_path)"
              alt="Logo"
              class="h-16 w-16 rounded-lg border border-gray-200 object-cover"
            />
          </div>
          <p class="mt-3 text-sm text-gray-600">
            {{ merchant.description || 'Belum ada deskripsi.' }}
          </p>
          <dl class="mt-4 grid grid-cols-1 gap-2 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-gray-500">Alamat</dt>
              <dd class="font-medium text-gray-800">{{ merchant.address }}</dd>
            </div>
            <div>
              <dt class="text-gray-500">Kontak</dt>
              <dd class="font-medium text-gray-800">{{ merchant.contact_phone }}</dd>
            </div>
          </dl>
        </div>

        <div>
          <h3 class="mb-3 text-sm font-semibold text-gray-700">Menu Tersedia</h3>

          <p v-if="merchant.menus.length === 0" class="text-sm text-gray-400">
            Katering ini belum memiliki menu tersedia.
          </p>

          <div v-else class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div
              v-for="menu in merchant.menus"
              :key="menu.id"
              class="flex flex-col gap-2 rounded-xl border border-gray-200 bg-white p-4"
            >
              <img
                :src="photoUrl(menu.photo_path)"
                :alt="menu.name"
                class="h-32 w-full rounded-lg object-cover"
              />
              <div>
                <h4 class="font-bold text-secondary">{{ menu.name }}</h4>
                <p class="text-xs text-gray-500">{{ menu.category?.name ?? '-' }}</p>
              </div>
              <p class="line-clamp-2 text-sm text-gray-600">{{ menu.description }}</p>
              <p class="font-bold text-primary-dark">{{ formatRupiah(menu.price) }}</p>

              <div class="mt-2 flex items-center gap-2">
                <input
                  v-model.number="quantities[menu.id]"
                  type="number"
                  min="1"
                  class="w-16 rounded-lg border border-gray-300 px-2 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                />
                <button
                  @click="handleAddToCart(menu)"
                  class="flex-1 rounded-lg bg-primary py-1.5 text-sm font-bold text-secondary transition hover:bg-primary-dark"
                >
                  + Keranjang
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="cartCount > 0 && cartMerchant?.id === merchant?.id"
      class="fixed inset-x-0 bottom-0 flex items-center justify-between bg-secondary px-6 py-4 text-white"
    >
      <p class="text-sm">{{ cartCount }} item di keranjang</p>
      <button
        @click="router.push('/checkout')"
        class="rounded-lg bg-primary px-5 py-2 text-sm font-bold text-secondary transition hover:bg-primary-dark"
      >
        Lihat Keranjang
      </button>
    </div>
  </div>
</template>
