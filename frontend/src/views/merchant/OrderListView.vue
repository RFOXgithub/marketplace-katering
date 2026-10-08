<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getMerchantOrders } from '@/services/merchantService'
import { formatRupiah, formatDate } from '@/utils/format'
import Skeleton from '@/components/animations/Skeleton.vue'
import AnimatedList from '@/components/animations/AnimatedList.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import StatusFilterPills from '@/components/ui/StatusFilterPills.vue'
import Pagination from '@/components/ui/Pagination.vue'

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
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Order Masuk" max-width="max-w-6xl">
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <StatusFilterPills
        :filters="STATUS_FILTERS"
        :model-value="statusFilter"
        @update:model-value="selectFilter"
      />

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

      <DoubleBezelCard v-else delay="0.08s">
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

        <Pagination
          class="mt-4"
          :current-page="currentPage"
          :last-page="lastPage"
          :total="total"
          label="order"
          @change="loadOrders"
        />
      </DoubleBezelCard>
    </main>
  </div>
</template>
