<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { logout } from '@/services/authService'
import {
  getMerchantProfile,
  getMerchantOrders,
  getMerchantDashboardStats,
} from '@/services/merchantService'
import Skeleton from '@/components/animations/Skeleton.vue'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'
import CountUp from '@/components/animations/CountUp.vue'
import AnimatedList from '@/components/animations/AnimatedList.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import { formatRupiah, formatDate, formatTime, titleCase } from '@/utils/format'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

function photoUrl(path) {
  return path ? `${STORAGE_URL}/${path}` : null
}

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')

const merchant = ref(null)
const pendingOrders = ref(0)
const totalMenu = ref(0)
const menuGrowthPercent = ref(0)
const monthlyMenuCounts = ref([0, 0, 0, 0, 0, 0])
const totalInvoices = ref(0)
const unpaidInvoices = ref(0)
const recentOrders = ref([])

const STATUS_LABEL = {
  pending: 'Menunggu',
  confirmed: 'Dikonfirmasi',
  delivered: 'Dikirim',
  completed: 'Selesai',
  cancelled: 'Dibatalkan',
}

const STATUS_CLASS = {
  pending: 'bg-primary/10 text-primary-dark',
  confirmed: 'bg-primary/10 text-primary-dark',
  delivered: 'bg-primary/10 text-primary-dark',
  completed: 'bg-accent/10 text-accent',
  cancelled: 'bg-ink/10 text-subtle',
}

const NAV_LINKS = [
  { to: '/merchant/orders', label: 'Order' },
  { to: '/merchant/menus', label: 'Menu' },
  { to: '/merchant/profile', label: 'Profil' },
  { to: '/merchant/invoices', label: 'Invoice' },
]

function isActiveLink(link) {
  return route.path.startsWith(link.to)
}

async function loadDashboard() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [profileRes, statsRes, allOrdersRes] = await Promise.all([
      getMerchantProfile(),
      getMerchantDashboardStats(),
      getMerchantOrders(''),
    ])

    merchant.value = profileRes.data
    pendingOrders.value = statsRes.data.pending_orders ?? 0
    totalMenu.value = statsRes.data.total_menu ?? 0
    menuGrowthPercent.value = statsRes.data.menu_growth_percent ?? 0
    monthlyMenuCounts.value = statsRes.data.monthly_menu_counts ?? [0, 0, 0, 0, 0, 0]
    totalInvoices.value = statsRes.data.total_invoices ?? 0
    unpaidInvoices.value = statsRes.data.unpaid_invoices ?? 0
    recentOrders.value = (allOrdersRes.data ?? []).slice(0, 5)
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

async function handleLogout() {
  await logout()
  router.push('/login')
}

onMounted(loadDashboard)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <!-- floating island nav -->
    <header class="sticky top-4 z-40 mx-4 sm:top-6 sm:mx-6">
      <div
        class="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 rounded-[1.75rem] border border-white/10 bg-secondary/90 px-4 py-3 shadow-[0_20px_50px_-20px_rgba(18,18,18,0.45)] backdrop-blur-xl sm:px-6 sm:py-3.5"
      >
        <div class="min-w-0">
          <p class="text-[10px] font-semibold uppercase tracking-[0.2em] text-white/40">
            Portal Merchant
          </p>
          <h1 class="truncate text-base font-bold text-primary sm:text-lg">
            {{ merchant ? titleCase(merchant.company_name) : 'Memuat...' }}
          </h1>
        </div>

        <nav class="flex flex-wrap items-center gap-1 sm:gap-2">
          <RouterLink
            v-for="link in NAV_LINKS"
            :key="link.to"
            :to="link.to"
            class="relative rounded-full px-3 py-1.5 text-sm font-medium transition-[color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
            :class="isActiveLink(link) ? 'text-primary' : 'text-white/60 hover:text-primary'"
          >
            {{ link.label }}
            <span
              v-if="isActiveLink(link)"
              class="absolute -bottom-1 left-1/2 h-0.5 w-4 -translate-x-1/2 rounded-full bg-primary"
            />
          </RouterLink>

          <button
            @click="handleLogout"
            class="group ml-1 flex items-center gap-2 rounded-full bg-primary py-1.5 pr-1.5 pl-4 text-sm font-semibold text-secondary transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
          >
            Logout
            <span
              class="flex h-6 w-6 items-center justify-center rounded-full bg-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5 group-hover:-translate-y-[1px] group-hover:scale-105"
            >
              <svg
                width="11"
                height="11"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
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
      <!-- loading skeleton -->
      <div v-if="isLoading" class="flex flex-col gap-5">
        <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
          <div class="rounded-[2rem] bg-ink/5 p-2">
            <div class="h-full rounded-[1.625rem] bg-card p-6">
              <Skeleton width="50%" height="0.75rem" />
              <Skeleton width="35%" height="2.5rem" rounded="0.5rem" class="mt-4" />
              <Skeleton width="80%" height="0.875rem" class="mt-3" />
            </div>
          </div>
          <div class="flex flex-col gap-5">
            <div v-for="i in 2" :key="i" class="rounded-[2rem] bg-ink/5 p-2">
              <div class="h-full rounded-[1.625rem] bg-card p-6">
                <Skeleton width="50%" height="0.75rem" />
                <Skeleton width="30%" height="1.75rem" rounded="0.5rem" class="mt-3" />
              </div>
            </div>
          </div>
        </div>

        <div class="rounded-[2rem] bg-ink/5 p-2">
          <div class="rounded-[1.625rem] bg-card p-6">
            <Skeleton width="25%" height="0.875rem" class="mb-4" />
            <div class="flex flex-col gap-3">
              <div v-for="i in 5" :key="i" class="flex items-center gap-4">
                <Skeleton width="25%" height="0.875rem" />
                <Skeleton width="20%" height="0.875rem" />
                <Skeleton width="20%" height="0.875rem" />
                <Skeleton width="15%" height="1.25rem" rounded="9999px" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
        {{ errorMessage }}
      </p>

      <div v-else class="flex flex-col gap-5">
        <div class="grid grid-cols-1 items-stretch gap-5 md:grid-cols-2">
          <!-- featured tile: pending orders -->
          <div class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5">
            <SpotlightCard
              class="relative flex h-full flex-col overflow-hidden rounded-[1.625rem] border-0 bg-secondary p-7 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]"
              spotlight-color="rgba(245, 166, 35, 0.25)"
            >
              <span
                class="flex w-max items-center gap-1.5 rounded-full bg-white/10 px-3 py-1 text-[10px] font-semibold tracking-[0.2em] text-primary uppercase"
              >
                <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M13 2 3 14h7l-1 8 11-14h-7l0-6z" />
                </svg>
                Perlu Tindakan
              </span>

              <div class="relative mt-5 max-w-[65%]">
                <p class="text-sm text-white/50">Order Menunggu Konfirmasi</p>
                <p class="mt-2 text-5xl font-extrabold tracking-tight text-primary">
                  <CountUp :to="pendingOrders" :duration="1.1" />
                </p>
                <p class="mt-2 text-sm text-white/50">
                  {{
                    pendingOrders > 0
                      ? `${pendingOrders} pesanan menunggu dikonfirmasi.`
                      : 'Tidak ada pesanan yang perlu dikonfirmasi saat ini.'
                  }}
                </p>
              </div>

              <!-- decorative illustration -->
              <div
                class="pointer-events-none absolute top-2 right-2 flex h-32 w-32 items-center justify-center rounded-full"
                style="
                  background: radial-gradient(circle, rgba(245, 166, 35, 0.18), transparent 70%);
                "
                aria-hidden="true"
              >
                <span
                  class="flex h-16 w-16 items-center justify-center rounded-2xl bg-white/5 text-primary ring-1 ring-primary/20"
                >
                  <svg
                    width="28"
                    height="28"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.8"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <rect x="5" y="4" width="14" height="17" rx="2" />
                    <path d="M9 3.5h6a1 1 0 0 1 1 1V6H8V4.5a1 1 0 0 1 1-1Z" />
                    <line x1="8.5" y1="10.5" x2="15.5" y2="10.5" />
                    <line x1="8.5" y1="14" x2="15.5" y2="14" />
                  </svg>
                </span>
                <span
                  class="absolute right-0 -bottom-1 flex h-7 w-7 items-center justify-center rounded-full bg-primary text-secondary ring-2 ring-secondary"
                >
                  <svg
                    width="12"
                    height="12"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="3"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <polyline points="20 6 9 17 4 12" />
                  </svg>
                </span>
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  class="absolute -top-1 right-6 text-primary"
                >
                  <path d="M12 2l1.8 6.2L20 10l-6.2 1.8L12 18l-1.8-6.2L4 10l6.2-1.8z" />
                </svg>
              </div>

              <RouterLink
                :to="pendingOrders > 0 ? '/merchant/orders?status=pending' : '/merchant/orders'"
                class="group relative mt-auto flex items-center gap-3 rounded-2xl px-4 py-3 text-left text-xs transition-colors duration-300"
                :class="
                  pendingOrders > 0
                    ? 'bg-primary/15 text-primary ring-1 ring-primary/30 hover:bg-primary/20'
                    : 'bg-white/5 text-white/60 ring-1 ring-white/10 hover:bg-white/10'
                "
              >
                <span
                  class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-white/10"
                >
                  <svg
                    v-if="pendingOrders > 0"
                    width="13"
                    height="13"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2.2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <path
                      d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z"
                    />
                    <line x1="12" y1="9" x2="12" y2="13" />
                    <line x1="12" y1="17" x2="12.01" y2="17" />
                  </svg>
                  <svg
                    v-else
                    width="13"
                    height="13"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2.2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <path
                      d="M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c.6.5 1 1.3 1 2.1v.4h6v-.4c0-.8.4-1.6 1-2.1A6 6 0 0 0 12 3Z"
                    />
                  </svg>
                </span>
                <span class="flex-1">
                  <span class="block font-bold">
                    {{
                      pendingOrders > 0
                        ? 'Ada pesanan menunggu diproses!'
                        : 'Semua pesanan sudah dikonfirmasi!'
                    }}
                  </span>
                  <span class="mt-0.5 block text-white/50">
                    {{
                      pendingOrders > 0
                        ? 'Segera konfirmasi agar customer tidak menunggu lama.'
                        : 'Terima kasih telah menjaga performa toko Anda dengan baik.'
                    }}
                  </span>
                </span>
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="shrink-0 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
                >
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </RouterLink>
            </SpotlightCard>
          </div>

          <!-- right stack -->
          <div class="flex flex-col gap-5">
            <div
              class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5"
              style="animation-delay: 0.08s"
            >
              <SpotlightCard
                class="relative h-full overflow-hidden rounded-[1.625rem] border-0 bg-card p-6 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)]"
                spotlight-color="rgba(245, 166, 35, 0.12)"
              >
                <div class="flex items-start justify-between gap-3">
                  <div class="flex items-center gap-3">
                    <span
                      class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-primary/10 text-primary-dark"
                    >
                      <svg
                        width="18"
                        height="18"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                        <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                        <line x1="3" y1="6" x2="21" y2="6" />
                        <path d="M16 10a4 4 0 0 1-8 0" />
                      </svg>
                    </span>
                    <p class="text-xs font-semibold tracking-[0.1em] text-subtle uppercase">
                      Total Menu
                    </p>
                  </div>
                  <RouterLink
                    to="/merchant/menus"
                    class="group flex shrink-0 items-center gap-1 rounded-full px-3 py-1.5 text-xs font-semibold text-ink ring-1 ring-ink/10 transition-colors duration-300 hover:bg-ink/5"
                  >
                    Kelola Menu
                    <svg
                      width="10"
                      height="10"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
                    >
                      <line x1="5" y1="12" x2="19" y2="12" />
                      <polyline points="12 5 19 12 12 19" />
                    </svg>
                  </RouterLink>
                </div>

                <p class="mt-4 text-3xl font-extrabold text-ink">
                  <CountUp :to="totalMenu" :duration="1" />
                </p>

                <p class="mt-2 flex items-center gap-1 text-xs text-subtle">
                  <template v-if="menuGrowthPercent !== 0">
                    <svg
                      width="11"
                      height="11"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      :class="menuGrowthPercent > 0 ? 'text-accent' : 'text-red-500'"
                    >
                      <polyline v-if="menuGrowthPercent > 0" points="18 15 12 9 6 15" />
                      <polyline v-else points="6 9 12 15 18 9" />
                    </svg>
                    <span
                      class="font-semibold"
                      :class="menuGrowthPercent > 0 ? 'text-accent' : 'text-red-500'"
                    >
                      {{ menuGrowthPercent > 0 ? '+' : '' }}{{ menuGrowthPercent }}%
                    </span>
                    dari bulan lalu
                  </template>
                  <template v-else>Tidak ada perubahan dari bulan lalu</template>
                </p>

                <div class="absolute right-6 bottom-6 flex h-10 items-end gap-1" aria-hidden="true">
                  <span
                    v-for="(count, i) in monthlyMenuCounts"
                    :key="i"
                    class="w-2 rounded-full bg-primary/25"
                    :class="{ '!bg-primary': i === monthlyMenuCounts.length - 1 }"
                    :style="{
                      height: `${Math.max((count / Math.max(...monthlyMenuCounts, 1)) * 100, 12)}%`,
                    }"
                  />
                </div>
              </SpotlightCard>
            </div>

            <div
              class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5"
              style="animation-delay: 0.16s"
            >
              <SpotlightCard
                class="h-full rounded-[1.625rem] border-0 bg-card p-6 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)]"
                spotlight-color="rgba(245, 166, 35, 0.12)"
              >
                <div class="flex items-start justify-between gap-3">
                  <div class="flex items-center gap-3">
                    <span
                      class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-primary/10 text-primary-dark"
                    >
                      <svg
                        width="18"
                        height="18"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                        <polyline points="14 2 14 8 20 8" />
                        <line x1="8" y1="13" x2="16" y2="13" />
                        <line x1="8" y1="17" x2="13" y2="17" />
                      </svg>
                    </span>
                    <p class="text-xs font-semibold tracking-[0.1em] text-subtle uppercase">
                      Invoice Belum Lunas
                    </p>
                  </div>
                  <RouterLink
                    to="/merchant/invoices?status=unpaid"
                    class="group flex shrink-0 items-center gap-1 rounded-full px-3 py-1.5 text-xs font-semibold text-ink ring-1 ring-ink/10 transition-colors duration-300 hover:bg-ink/5"
                  >
                    Lihat Invoice
                    <svg
                      width="10"
                      height="10"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
                    >
                      <line x1="5" y1="12" x2="19" y2="12" />
                      <polyline points="12 5 19 12 12 19" />
                    </svg>
                  </RouterLink>
                </div>

                <p class="mt-4 text-3xl font-extrabold text-ink">
                  <CountUp :to="unpaidInvoices" :duration="1" />
                </p>

                <p class="mt-1 text-xs text-subtle">
                  {{
                    totalInvoices > 0
                      ? `${unpaidInvoices} dari ${totalInvoices} invoice belum lunas`
                      : 'Belum ada invoice yang terbit'
                  }}
                </p>

                <div
                  v-if="totalInvoices > 0"
                  class="mt-4 h-1.5 w-full overflow-hidden rounded-full bg-ink/10"
                >
                  <div
                    class="h-full rounded-full bg-primary"
                    :style="{ width: `${Math.round((unpaidInvoices / totalInvoices) * 100)}%` }"
                  />
                </div>
              </SpotlightCard>
            </div>
          </div>
        </div>

        <!-- recent orders -->
        <DoubleBezelCard delay="0.24s">
          <div class="mb-5 flex items-center justify-between">
            <div>
              <span
                class="flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold tracking-[0.2em] text-primary-dark uppercase"
              >
                <svg
                  width="10"
                  height="10"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                  <polyline points="14 2 14 8 20 8" />
                </svg>
                Aktivitas Terbaru
              </span>
              <h2 class="mt-2 text-xl font-bold text-ink">Order Terbaru</h2>
            </div>
            <RouterLink
              to="/merchant/orders"
              class="group flex shrink-0 items-center gap-1 rounded-full px-3 py-1.5 text-xs font-semibold text-ink ring-1 ring-ink/10 transition-colors duration-300 hover:bg-ink/5"
            >
              Lihat Semua
              <svg
                width="10"
                height="10"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.5"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
              >
                <line x1="5" y1="12" x2="19" y2="12" />
                <polyline points="12 5 19 12 12 19" />
              </svg>
            </RouterLink>
          </div>

          <p v-if="recentOrders.length === 0" class="text-sm text-subtle">Belum ada order masuk.</p>

          <AnimatedList
            v-else
            :items="recentOrders"
            :show-gradients="recentOrders.length > 4"
            :display-scrollbar="false"
            @item-selected="(order) => router.push(`/merchant/orders/${order.id}`)"
          >
            <template #default="{ item: order }">
              <div
                class="group mb-3 flex cursor-pointer items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4 text-sm shadow-[0_1px_2px_rgba(18,18,18,0.04)] transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:border-primary/30"
              >
                <img
                  v-if="photoUrl(order.items?.[0]?.menu?.photo_path)"
                  :src="photoUrl(order.items[0].menu.photo_path)"
                  alt=""
                  class="h-11 w-11 shrink-0 rounded-full object-cover ring-1 ring-ink/10"
                />
                <span
                  v-else
                  class="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary-dark"
                >
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.8"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <path
                      d="M12 2a7 7 0 0 0-7 7c0 3.1 2 5.6 5 6.6V18h4v-2.4c3-1 5-3.5 5-6.6a7 7 0 0 0-7-7Z"
                    />
                    <path d="M9 21h6" />
                  </svg>
                </span>

                <div class="min-w-0 max-w-[9rem] sm:max-w-[11rem]">
                  <p class="truncate font-bold text-ink">
                    {{ order.customer?.office_name ?? '-' }}
                  </p>
                  <p class="truncate text-xs text-subtle">
                    {{ order.items?.[0]?.menu_name ?? 'Pesanan katering' }}
                  </p>
                </div>

                <span class="hidden items-center gap-3 text-xs text-subtle md:flex">
                  <span class="flex items-center gap-1">
                    <svg
                      width="12"
                      height="12"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    >
                      <rect x="3" y="4" width="18" height="18" rx="2" />
                      <line x1="16" y1="2" x2="16" y2="6" />
                      <line x1="8" y1="2" x2="8" y2="6" />
                      <line x1="3" y1="10" x2="21" y2="10" />
                    </svg>
                    {{ formatDate(order.delivery_date) }}
                  </span>
                  <span class="flex items-center gap-1">
                    <svg
                      width="12"
                      height="12"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    >
                      <circle cx="12" cy="12" r="10" />
                      <polyline points="12 6 12 12 16 14" />
                    </svg>
                    {{ formatTime(order.created_at) }}
                  </span>
                </span>

                <span class="flex-1" />

                <span class="font-semibold text-ink">{{ formatRupiah(order.total_amount) }}</span>

                <StatusBadge
                  :status="order.status"
                  :labels="STATUS_LABEL"
                  :classes="STATUS_CLASS"
                />

                <span
                  class="hidden h-7 w-7 shrink-0 items-center justify-center rounded-full bg-ink/5 text-subtle transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5 group-hover:bg-primary/10 group-hover:text-primary-dark sm:flex"
                >
                  <svg
                    width="10"
                    height="10"
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
              </div>
            </template>
          </AnimatedList>
        </DoubleBezelCard>
      </div>
    </main>
  </div>
</template>
