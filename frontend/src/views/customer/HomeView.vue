<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { logout } from '@/services/authService'
import {
  getCustomerProfile,
  searchCaterings,
  getCategories,
  getCities,
  getFavoriteMerchantIds,
  addFavorite,
  removeFavorite,
} from '@/services/customerService'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import Pagination from '@/components/ui/Pagination.vue'
import { titleCase } from '@/utils/format'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

const router = useRouter()

function photoUrl(path) {
  return path ? `${STORAGE_URL}/${path}` : '/logo-mark.svg'
}

const favoriteIds = ref(new Set())

async function loadFavorites() {
  try {
    const res = await getFavoriteMerchantIds()
    favoriteIds.value = new Set(res.data ?? [])
  } catch {
    // favorites are a non-critical enhancement: leave the list empty on failure
  }
}

async function toggleFavorite(id) {
  const isFavorited = favoriteIds.value.has(id)

  // optimistic update, rolled back if the request fails
  const next = new Set(favoriteIds.value)
  isFavorited ? next.delete(id) : next.add(id)
  favoriteIds.value = next

  try {
    await (isFavorited ? removeFavorite(id) : addFavorite(id))
  } catch {
    // revert to the pre-toggle state
    const reverted = new Set(favoriteIds.value)
    isFavorited ? reverted.add(id) : reverted.delete(id)
    favoriteIds.value = reverted
  }
}

const isLoading = ref(true)
const isSearching = ref(false)
const errorMessage = ref('')

const customer = ref(null)
const categories = ref([])
const cities = ref([])
const caterings = ref([])
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

const keyword = ref('')
const city = ref('')
const categoryId = ref('')
const sortBy = ref('popular')

const sortedCaterings = computed(() => {
  if (sortBy.value === 'name') {
    return [...caterings.value].sort((a, b) => a.company_name.localeCompare(b.company_name))
  }
  if (sortBy.value === 'city') {
    return [...caterings.value].sort((a, b) => (a.city ?? '').localeCompare(b.city ?? ''))
  }
  return caterings.value
})

function buildQuery(page = 1) {
  const params = new URLSearchParams()
  params.set('page', page)
  if (keyword.value) params.set('q', keyword.value)
  if (city.value) params.set('city', city.value)
  if (categoryId.value) params.set('category', categoryId.value)
  return `?${params.toString()}`
}

function applyCateringsResult(res) {
  caterings.value = res.data ?? []
  currentPage.value = res.current_page ?? 1
  lastPage.value = res.last_page ?? 1
  total.value = res.total ?? 0
}

async function loadCaterings(page = 1) {
  isSearching.value = true
  errorMessage.value = ''
  try {
    const res = await searchCaterings(buildQuery(page))
    applyCateringsResult(res)
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
    const [profileRes, categoriesRes, citiesRes, cateringsRes] = await Promise.all([
      getCustomerProfile(),
      getCategories(),
      getCities(),
      searchCaterings(buildQuery(1)),
      loadFavorites(),
    ])
    customer.value = profileRes.data
    categories.value = categoriesRes.data ?? []
    cities.value = citiesRes.data ?? []
    applyCateringsResult(cateringsRes)
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleSearch() {
  loadCaterings(1)
}

async function handleLogout() {
  await logout()
  router.push('/login')
}

onMounted(handleInit)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader
      eyebrow="Portal Kantor"
      :title="customer ? titleCase(customer.office_name) : 'Memuat...'"
      max-width="max-w-6xl"
    >
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

      <CartButton />

      <button
        @click="handleLogout"
        class="group ml-1 flex items-center gap-2 rounded-full bg-primary py-1.5 pr-1.5 pl-4 text-sm font-semibold text-secondary transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
      >
        Logout
        <span
          class="flex h-6 w-6 items-center justify-center rounded-full bg-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5 group-hover:-translate-y-[1px] group-hover:scale-105"
        >
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
          </svg>
        </span>
      </button>
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-6">
        <Skeleton width="100%" height="4rem" rounded="1.75rem" />
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-ink/5 p-2">
            <div class="flex flex-col gap-2 rounded-[1.625rem] bg-card p-5">
              <Skeleton width="60%" height="1rem" />
              <Skeleton width="30%" height="0.75rem" />
              <Skeleton width="100%" height="0.75rem" class="mt-1" />
              <Skeleton width="80%" height="0.75rem" />
            </div>
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
        {{ errorMessage }}
      </p>

      <div v-else class="flex flex-col gap-10">
        <div class="flex flex-col gap-8 lg:flex-row lg:items-center lg:justify-between">
          <div class="flex max-w-xl flex-col gap-4">
            <span
              class="animate-fade-up flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
            >
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 2v7c0 1.1.9 2 2 2h1a2 2 0 0 0 2-2V2M7 2v20" />
                <path d="M17 2c-1.5 1.5-2 3.5-2 5.5 0 1.9 1 3.3 2 3.3s2-1.4 2-3.3C19 5.5 18.5 3.5 17 2ZM17 11v11" />
              </svg>
              Cari Katering
            </span>

            <h1
              class="animate-fade-up text-3xl font-extrabold leading-tight text-ink sm:text-4xl"
              style="animation-delay: 0.04s"
            >
              Temukan Katering Terbaik
              <br />
              untuk <span class="text-primary">Kebutuhan Kantor Anda</span>
            </h1>

            <p class="animate-fade-up text-sm text-subtle sm:text-base" style="animation-delay: 0.08s">
              Pilih dari berbagai pilihan katering berkualitas dengan layanan terbaik.
            </p>
          </div>

          <div
            class="animate-fade-up relative hidden shrink-0 items-center gap-5 pr-6 lg:flex"
            style="animation-delay: 0.1s"
            aria-hidden="true"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" class="absolute -top-2 left-2 text-primary">
              <path d="M12 2l1.8 6.2L20 10l-6.2 1.8L12 18l-1.8-6.2L4 10l6.2-1.8z" />
            </svg>
            <svg width="8" height="8" viewBox="0 0 24 24" fill="currentColor" class="absolute top-9 left-10 text-primary/60">
              <path d="M12 2l1.8 6.2L20 10l-6.2 1.8L12 18l-1.8-6.2L4 10l6.2-1.8z" />
            </svg>

            <div
              class="flex h-28 w-28 flex-shrink-0 items-center justify-center rounded-full"
              style="background: radial-gradient(circle, rgba(245, 166, 35, 0.2), transparent 70%)"
            >
              <span class="flex h-[4.5rem] w-[4.5rem] items-center justify-center rounded-full bg-primary/15 text-primary-dark ring-1 ring-primary/20">
                <svg width="30" height="30" viewBox="0 0 24 24" fill="currentColor">
                  <circle cx="12" cy="4" r="1.3" />
                  <rect x="11.1" y="5.3" width="1.8" height="2.2" />
                  <path d="M3 17.2a9 9 0 0 1 18 0 1 1 0 0 1-1 1H4a1 1 0 0 1-1-1Z" />
                  <rect x="1.5" y="18.4" width="21" height="2.2" rx="1.1" />
                </svg>
              </span>
            </div>

            <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" class="absolute right-0 bottom-9 text-primary">
              <path d="M12 2l1.8 6.2L20 10l-6.2 1.8L12 18l-1.8-6.2L4 10l6.2-1.8z" />
            </svg>
            <p class="max-w-[9rem] text-sm leading-snug font-medium text-primary-dark italic">
              Makan enak, kerja makin semangat!
            </p>
          </div>
        </div>

        <form
          @submit.prevent="handleSearch"
          class="animate-fade-up flex flex-col gap-3 rounded-[1.75rem] bg-card p-3 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)] ring-1 ring-ink/5 sm:flex-row"
          style="animation-delay: 0.14s"
        >
          <div class="relative flex-1">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="pointer-events-none absolute top-1/2 left-4 -translate-y-1/2 text-subtle">
              <circle cx="11" cy="11" r="7" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
            <input
              v-model="keyword"
              type="text"
              placeholder="Cari nama katering..."
              class="w-full rounded-2xl bg-ink/[0.04] py-2.5 pr-4 pl-10 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <div class="relative w-full sm:w-44">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="pointer-events-none absolute top-1/2 left-4 -translate-y-1/2 text-subtle">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
              <circle cx="12" cy="10" r="3" />
            </svg>
            <select
              v-model="city"
              class="w-full appearance-none rounded-2xl bg-ink/[0.04] py-2.5 pr-8 pl-10 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">Semua Kota</option>
              <option v-for="c in cities" :key="c.id" :value="c.name">{{ c.name }}</option>
            </select>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="pointer-events-none absolute top-1/2 right-3.5 -translate-y-1/2 text-subtle">
              <polyline points="6 9 12 15 18 9" />
            </svg>
          </div>
          <div class="relative w-full sm:w-48">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="pointer-events-none absolute top-1/2 left-4 -translate-y-1/2 text-subtle">
              <rect x="3" y="3" width="7" height="7" rx="1.5" />
              <rect x="14" y="3" width="7" height="7" rx="1.5" />
              <rect x="3" y="14" width="7" height="7" rx="1.5" />
              <rect x="14" y="14" width="7" height="7" rx="1.5" />
            </svg>
            <select
              v-model="categoryId"
              class="w-full appearance-none rounded-2xl bg-ink/[0.04] py-2.5 pr-8 pl-10 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">Semua Kategori</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                {{ cat.name }}
              </option>
            </select>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="pointer-events-none absolute top-1/2 right-3.5 -translate-y-1/2 text-subtle">
              <polyline points="6 9 12 15 18 9" />
            </svg>
          </div>
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
          <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-ink/5 p-2">
            <div class="flex flex-col gap-2 rounded-[1.625rem] bg-card p-5">
              <Skeleton width="60%" height="1rem" />
              <Skeleton width="30%" height="0.75rem" />
              <Skeleton width="100%" height="0.75rem" class="mt-1" />
              <Skeleton width="80%" height="0.75rem" />
            </div>
          </div>
        </div>

        <div v-else class="flex flex-col gap-5">
          <div class="flex flex-wrap items-center justify-between gap-3">
            <div class="flex items-center gap-2">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-subtle">
                <circle cx="6" cy="6" r="2" />
                <circle cx="18" cy="6" r="2" />
                <circle cx="6" cy="18" r="2" />
                <circle cx="18" cy="18" r="2" />
                <path d="M8 6h8M8 18h8M6 8v8M18 8v8" />
              </svg>
              <h2 class="font-bold text-ink">Hasil Pencarian</h2>
              <span class="rounded-full bg-ink/5 px-2.5 py-1 text-xs font-semibold text-subtle">
                {{ total }} Katering
              </span>
            </div>

            <div class="relative" v-if="caterings.length > 0">
              <select
                v-model="sortBy"
                class="appearance-none rounded-full bg-ink/5 py-2 pr-9 pl-4 text-xs font-semibold text-ink focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="popular">Urutkan: Terpopuler</option>
                <option value="name">Urutkan: Nama A-Z</option>
                <option value="city">Urutkan: Kota</option>
              </select>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="pointer-events-none absolute top-1/2 right-3.5 -translate-y-1/2 text-subtle">
                <polyline points="6 9 12 15 18 9" />
              </svg>
            </div>
          </div>

          <p v-if="caterings.length === 0" class="text-sm text-subtle">
            Tidak ada katering yang ditemukan.
          </p>

          <div v-else class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <div
              v-for="(catering, index) in sortedCaterings"
              :key="catering.id"
              @click="router.push(`/caterings/${catering.slug}`)"
              class="animate-fade-up group flex cursor-pointer flex-col gap-3 rounded-2xl bg-card p-4 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)] ring-1 ring-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
              :style="{ animationDelay: `${Math.min(index, 8) * 0.06}s` }"
            >
              <div class="flex items-center justify-between">
                <span
                  class="flex w-max items-center gap-1 rounded-full bg-primary/10 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-[0.1em] text-primary-dark"
                >
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                    <circle cx="12" cy="10" r="3" />
                  </svg>
                  {{ catering.city }}
                </span>

                <button
                  type="button"
                  :aria-label="favoriteIds.has(catering.id) ? 'Hapus dari favorit' : 'Tandai favorit'"
                  class="flex h-7 w-7 items-center justify-center rounded-full text-subtle transition-colors duration-200 hover:text-primary"
                  @click.stop="toggleFavorite(catering.id)"
                >
                  <svg
                    width="15"
                    height="15"
                    viewBox="0 0 24 24"
                    :fill="favoriteIds.has(catering.id) ? 'currentColor' : 'none'"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    :class="favoriteIds.has(catering.id) ? 'text-primary' : ''"
                  >
                    <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8Z" />
                  </svg>
                </button>
              </div>

              <div class="flex items-center gap-3">
                <img
                  v-if="catering.cover_photo"
                  :src="photoUrl(catering.cover_photo)"
                  :alt="catering.company_name"
                  class="h-14 w-14 flex-shrink-0 rounded-xl object-cover ring-1 ring-ink/10"
                />
                <span
                  v-else
                  class="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary-dark ring-1 ring-ink/10"
                >
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 2a7 7 0 0 0-7 7c0 3.1 2 5.6 5 6.6V18h4v-2.4c3-1 5-3.5 5-6.6a7 7 0 0 0-7-7Z" />
                    <path d="M9 21h6" />
                  </svg>
                </span>
                <div class="min-w-0 flex-1">
                  <h3 class="truncate font-bold text-ink">{{ catering.company_name }}</h3>
                  <p class="line-clamp-2 text-xs text-subtle">
                    {{ catering.description || 'Belum ada deskripsi.' }}
                  </p>
                </div>
              </div>

              <div class="mt-auto flex items-center justify-between gap-2">
                <div class="flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1 text-xs text-subtle">
                  <span v-if="catering.rating_count > 0" class="flex items-center gap-1 whitespace-nowrap font-semibold text-ink">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" class="text-primary">
                      <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
                    </svg>
                    {{ Number(catering.rating_avg).toFixed(1) }}
                  </span>
                  <span v-if="catering.rating_count > 0" class="text-ink/15">|</span>
                  <span class="flex items-center gap-1 whitespace-nowrap">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                      <circle cx="9" cy="7" r="4" />
                      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                    </svg>
                    {{ catering.total_orders > 0 ? `${catering.total_orders}+ pesanan` : 'Katering baru' }}
                  </span>
                  <span class="text-ink/15">|</span>
                  <span class="flex items-center gap-1 whitespace-nowrap">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="12" cy="12" r="10" />
                      <polyline points="12 6 12 12 16 14" />
                    </svg>
                    Min. {{ catering.min_order_pax }} pax
                  </span>
                </div>

                <span
                  class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-full text-ink/60 ring-1 ring-ink/10 transition-colors duration-300 group-hover:bg-primary group-hover:text-secondary group-hover:ring-primary"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5">
                    <line x1="5" y1="12" x2="19" y2="12" />
                    <polyline points="12 5 19 12 12 19" />
                  </svg>
                </span>
              </div>
            </div>
          </div>
        </div>

        <Pagination
          v-if="caterings.length > 0"
          :current-page="currentPage"
          :last-page="lastPage"
          :total="total"
          label="katering"
          @change="loadCaterings"
        />
      </div>
    </main>
  </div>
</template>
