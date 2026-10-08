<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getMerchantOrders } from '@/services/merchantService'
import Skeleton from '@/components/animations/Skeleton.vue'
import AnimatedList from '@/components/animations/AnimatedList.vue'

const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const orders = ref([])
const statusFilter = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

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

const STATUS_FILTERS = [
  { value: '', label: 'Semua' },
  { value: 'pending', label: 'Menunggu' },
  { value: 'confirmed', label: 'Dikonfirmasi' },
  { value: 'delivered', label: 'Dikirim' },
  { value: 'completed', label: 'Selesai' },
  { value: 'cancelled', label: 'Dibatalkan' },
]

function formatRupiah(value) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(value ?? 0)
}

function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

async function loadOrders(page = 1) {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const params = new URLSearchParams()
    params.set('page', page)
    if (statusFilter.value) params.set('status', statusFilter.value)

    const res = await getMerchantOrders(`?${params.toString()}`)
    orders.value = res.data ?? []
    currentPage.value = res.current_page ?? 1
    lastPage.value = res.last_page ?? 1
    total.value = res.total ?? 0
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function selectFilter(value) {
  statusFilter.value = value
  loadOrders(1)
}

function goToDetail(order) {
  router.push(`/merchant/orders/${order.id}`)
}

onMounted(() => loadOrders(1))
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
            Portal Merchant
          </p>
          <h1 class="truncate text-base font-bold text-primary sm:text-lg">Order Masuk</h1>
        </div>

        <button
          @click="router.push('/merchant/dashboard')"
          class="group flex items-center gap-2 rounded-full border border-white/15 py-1.5 pr-4 pl-1.5 text-sm font-medium text-white/70 transition-[transform,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
        >
          <span
            class="flex h-6 w-6 items-center justify-center rounded-full bg-white/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:-translate-x-0.5"
          >
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="19" y1="12" x2="5" y2="12" />
              <polyline points="12 19 5 12 12 5" />
            </svg>
          </span>
          Kembali
        </button>
      </div>
    </header>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <div class="animate-fade-up mb-6 flex flex-wrap gap-2">
        <button
          v-for="filter in STATUS_FILTERS"
          :key="filter.value"
          @click="selectFilter(filter.value)"
          class="rounded-full px-4 py-2 text-sm font-medium transition-[transform,background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
          :class="
            statusFilter === filter.value
              ? 'bg-secondary text-white'
              : 'bg-white text-secondary/60 ring-1 ring-secondary/10'
          "
        >
          {{ filter.label }}
        </button>
      </div>

      <div v-if="isLoading" class="rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5">
        <div class="flex flex-col gap-3 rounded-[1.625rem] bg-white p-6">
          <div v-for="i in 6" :key="i" class="flex items-center gap-4">
            <Skeleton width="25%" height="0.875rem" />
            <Skeleton width="20%" height="0.875rem" />
            <Skeleton width="20%" height="0.875rem" />
            <Skeleton width="15%" height="1.25rem" rounded="9999px" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <p v-else-if="orders.length === 0" class="text-sm text-secondary/40">Belum ada order.</p>

      <div
        v-else
        class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
        style="animation-delay: 0.08s"
      >
        <div class="rounded-[1.625rem] bg-white p-6 sm:p-7">
          <AnimatedList
            :items="orders"
            :show-gradients="orders.length > 4"
            :display-scrollbar="false"
            @item-selected="goToDetail"
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
                <span
                  class="rounded-full px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.1em]"
                  :class="STATUS_CLASS[order.status] ?? STATUS_CLASS.pending"
                >
                  {{ STATUS_LABEL[order.status] ?? order.status }}
                </span>
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

          <div class="mt-4 flex items-center justify-between text-sm text-secondary/50">
            <p>Total {{ total }} order</p>
            <div class="flex items-center gap-2">
              <button
                :disabled="currentPage <= 1"
                @click="loadOrders(currentPage - 1)"
                class="rounded-full px-4 py-1.5 font-medium ring-1 ring-secondary/10 transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-30 disabled:hover:translate-y-0"
              >
                Sebelumnya
              </button>
              <span class="px-2 font-medium text-secondary">{{ currentPage }} / {{ lastPage }}</span>
              <button
                :disabled="currentPage >= lastPage"
                @click="loadOrders(currentPage + 1)"
                class="rounded-full px-4 py-1.5 font-medium ring-1 ring-secondary/10 transition-[transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-30 disabled:hover:translate-y-0"
              >
                Berikutnya
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
