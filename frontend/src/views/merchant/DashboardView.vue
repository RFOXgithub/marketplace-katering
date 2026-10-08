<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { logout } from '@/services/authService'
import {
  getMerchantProfile,
  getMerchantMenus,
  getMerchantOrders,
  getMerchantInvoices,
} from '@/services/merchantService'
import Skeleton from '@/components/animations/Skeleton.vue'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'
import CountUp from '@/components/animations/CountUp.vue'
import AnimatedList from '@/components/animations/AnimatedList.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import { formatRupiah, formatDate, titleCase } from '@/utils/format'

const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')

const merchant = ref(null)
const totalMenu = ref(0)
const pendingOrders = ref(0)
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
  cancelled: 'bg-secondary/10 text-secondary/50',
}

const NAV_LINKS = [
  { to: '/merchant/orders', label: 'Order' },
  { to: '/merchant/menus', label: 'Menu' },
  { to: '/merchant/profile', label: 'Profil' },
  { to: '/merchant/invoices', label: 'Invoice' },
]

async function loadDashboard() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [profileRes, menuRes, allOrdersRes, pendingOrdersRes, unpaidInvoicesRes] =
      await Promise.all([
        getMerchantProfile(),
        getMerchantMenus('?page=1'),
        getMerchantOrders(''),
        getMerchantOrders('?status=pending'),
        getMerchantInvoices('?status=unpaid'),
      ])

    merchant.value = profileRes.data
    totalMenu.value = menuRes.total ?? 0
    pendingOrders.value = pendingOrdersRes.total ?? 0
    unpaidInvoices.value = unpaidInvoicesRes.total ?? 0
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
  <div class="relative min-h-[100dvh] overflow-x-clip bg-[#f7f5f2]">
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
            class="rounded-full px-3 py-1.5 text-sm font-medium text-white/60 transition-[color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
          >
            {{ link.label }}
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
      <!-- loading skeleton -->
      <div v-if="isLoading" class="flex flex-col gap-5">
        <div class="grid grid-cols-1 gap-5 md:grid-cols-4 md:auto-rows-[9rem]">
          <div class="rounded-[2rem] bg-secondary/5 p-2 md:col-span-2 md:row-span-2">
            <div class="h-full rounded-[1.625rem] bg-white p-6">
              <Skeleton width="50%" height="0.75rem" />
              <Skeleton width="35%" height="2.5rem" rounded="0.5rem" class="mt-4" />
            </div>
          </div>
          <div v-for="i in 2" :key="i" class="rounded-[2rem] bg-secondary/5 p-2 md:col-span-2">
            <div class="h-full rounded-[1.625rem] bg-white p-6">
              <Skeleton width="50%" height="0.75rem" />
              <Skeleton width="30%" height="1.75rem" rounded="0.5rem" class="mt-3" />
            </div>
          </div>
        </div>

        <div class="rounded-[2rem] bg-secondary/5 p-2">
          <div class="rounded-[1.625rem] bg-white p-6">
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

      <p v-else-if="errorMessage" class="text-sm text-red-500">
        {{ errorMessage }}
      </p>

      <div v-else class="flex flex-col gap-5">
        <!-- asymmetrical bento stats -->
        <div class="grid grid-cols-1 gap-5 md:grid-cols-4 md:auto-rows-[9rem]">
          <!-- featured tile: double-bezel, dark, spans 2x2 -->
          <div
            class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5 md:col-span-2 md:row-span-2"
          >
            <SpotlightCard
              class="flex h-full flex-col justify-between rounded-[1.625rem] border-0 bg-secondary p-7 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]"
              spotlight-color="rgba(245, 166, 35, 0.25)"
            >
              <span
                class="w-max rounded-full bg-white/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary"
              >
                Perlu Tindakan
              </span>
              <div>
                <p class="text-sm text-white/50">Order Menunggu Konfirmasi</p>
                <p class="mt-2 text-5xl font-extrabold tracking-tight text-primary">
                  <CountUp :to="pendingOrders" :duration="1.1" />
                </p>
              </div>
            </SpotlightCard>
          </div>

          <!-- small tile -->
          <div
            class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5 md:col-span-2"
            style="animation-delay: 0.08s"
          >
            <SpotlightCard
              class="flex h-full items-center justify-between rounded-[1.625rem] border-0 bg-white p-6 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)]"
              spotlight-color="rgba(245, 166, 35, 0.12)"
            >
              <div>
                <p class="text-xs font-medium uppercase tracking-[0.1em] text-secondary/40">
                  Total Menu
                </p>
                <p class="mt-2 text-3xl font-extrabold text-secondary">
                  <CountUp :to="totalMenu" :duration="1" />
                </p>
              </div>
            </SpotlightCard>
          </div>

          <!-- small tile -->
          <div
            class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5 md:col-span-2"
            style="animation-delay: 0.16s"
          >
            <SpotlightCard
              class="flex h-full items-center justify-between rounded-[1.625rem] border-0 bg-white p-6 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)]"
              spotlight-color="rgba(245, 166, 35, 0.12)"
            >
              <div>
                <p class="text-xs font-medium uppercase tracking-[0.1em] text-secondary/40">
                  Invoice Belum Lunas
                </p>
                <p class="mt-2 text-3xl font-extrabold text-secondary">
                  <CountUp :to="unpaidInvoices" :duration="1" />
                </p>
              </div>
            </SpotlightCard>
          </div>
        </div>

        <!-- recent orders -->
        <DoubleBezelCard delay="0.24s">
          <div class="mb-5 flex items-center justify-between">
            <div>
              <span
                class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
              >
                Aktivitas Terbaru
              </span>
              <h2 class="mt-2 text-xl font-bold text-secondary">Order Terbaru</h2>
            </div>
          </div>

          <p v-if="recentOrders.length === 0" class="text-sm text-secondary/40">
            Belum ada order masuk.
          </p>

          <AnimatedList
            v-else
            :items="recentOrders"
            :show-gradients="recentOrders.length > 4"
            :display-scrollbar="false"
            @item-selected="(order) => router.push(`/merchant/orders/${order.id}`)"
          >
            <template #default="{ item: order }">
              <div
                class="group mb-3 flex cursor-pointer items-center justify-between gap-4 rounded-2xl border border-secondary/5 bg-white p-4 text-sm shadow-[0_1px_2px_rgba(18,18,18,0.04)] transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:border-primary/30"
              >
                <span class="flex-1 truncate font-medium text-secondary">
                  {{ order.customer?.office_name ?? '-' }}
                </span>
                <span class="hidden text-secondary/40 sm:block">
                  {{ formatDate(order.delivery_date) }}
                </span>
                <span class="font-semibold text-secondary">{{ formatRupiah(order.total_amount) }}</span>
                <StatusBadge :status="order.status" :labels="STATUS_LABEL" :classes="STATUS_CLASS" />
                <span
                  class="hidden h-7 w-7 shrink-0 items-center justify-center rounded-full bg-secondary/5 text-secondary/40 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5 group-hover:bg-primary/10 group-hover:text-primary-dark sm:flex"
                >
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
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
