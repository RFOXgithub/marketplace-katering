<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getMerchantOrders } from '@/services/merchantService'
import {
  getOrderMenuSummary as getMenuSummary,
  getOrderThumbnail as getThumbnail,
  getOrderTotalPax as getTotalPax,
} from '@/utils/orderDisplay'
import { formatRupiah, formatDate } from '@/utils/format'
import {
  ORDER_STATUS_LABEL,
  ORDER_STATUS_CLASS,
  ORDER_STATUS_DOT_CLASS,
  ORDER_STATUS_FILTERS,
} from '@/constants/status'
import Skeleton from '@/components/animations/Skeleton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import FilterPills from '@/components/ui/FilterPills.vue'
import EntityListRow from '@/components/ui/EntityListRow.vue'
import Pagination from '@/components/ui/Pagination.vue'

const route = useRoute()
const router = useRouter()

const VALID_STATUSES = ['pending', 'confirmed', 'delivered', 'completed', 'cancelled']

const isLoading = ref(true)
const errorMessage = ref('')
const orders = ref([])
const statusCounts = ref({})
const statusFilter = ref(VALID_STATUSES.includes(route.query.status) ? route.query.status : '')
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

const filtersWithCount = computed(() => {
  return ORDER_STATUS_FILTERS.map((filter) => ({
    ...filter,
    count: statusCounts.value[filter.value] ?? 0,
  }))
})

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
    statusCounts.value = res.counts ?? {}
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
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Order Masuk" max-width="max-w-6xl">
      <template #title-icon>
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="shrink-0 text-primary"
        >
          <path d="M3 3h18v4H3z" />
          <path d="M5 7v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7" />
          <path d="M10 12h4" />
        </svg>
      </template>
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 pb-24 sm:px-6 sm:py-16 sm:pb-16">
      <FilterPills
        :filters="filtersWithCount"
        :model-value="statusFilter"
        @update:model-value="selectFilter"
      >
        <template #icon="{ filter }">
          <svg
            v-if="filter.value === ''"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <rect x="3" y="3" width="7" height="7" />
            <rect x="14" y="3" width="7" height="7" />
            <rect x="14" y="14" width="7" height="7" />
            <rect x="3" y="14" width="7" height="7" />
          </svg>
          <svg
            v-else-if="filter.value === 'pending'"
            width="14"
            height="14"
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
          <svg
            v-else-if="filter.value === 'confirmed'"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
            <polyline points="22 4 12 14.01 9 11.01" />
          </svg>
          <svg
            v-else-if="filter.value === 'delivered'"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <rect x="1" y="3" width="15" height="13" />
            <polygon points="16 8 20 8 23 11 23 16 16 16 16 8" />
            <circle cx="5.5" cy="18.5" r="2.5" />
            <circle cx="18.5" cy="18.5" r="2.5" />
          </svg>
          <svg
            v-else-if="filter.value === 'completed'"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
            <polyline points="22 4 12 14.01 9 11.01" />
          </svg>
          <svg
            v-else-if="filter.value === 'cancelled'"
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <circle cx="12" cy="12" r="10" />
            <line x1="15" y1="9" x2="9" y2="15" />
            <line x1="9" y1="9" x2="15" y2="15" />
          </svg>
        </template>
      </FilterPills>

      <!-- Loading skeleton -->
      <div v-if="isLoading" class="flex flex-col gap-3">
        <div
          v-for="i in 3"
          :key="i"
          class="flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4"
        >
          <Skeleton width="4.5rem" height="4.5rem" rounded="0.75rem" />
          <div class="flex flex-1 flex-col gap-2">
            <Skeleton width="40%" height="0.875rem" />
            <Skeleton width="60%" height="0.75rem" />
            <Skeleton width="80%" height="0.75rem" />
          </div>
          <div class="flex flex-col items-end gap-2">
            <Skeleton width="5rem" height="1rem" />
            <Skeleton width="4rem" height="1.5rem" rounded="9999px" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
        {{ errorMessage }}
      </p>

      <p v-else-if="orders.length === 0" class="text-sm text-subtle">Belum ada order masuk.</p>

      <template v-else>
        <div class="flex flex-col gap-3">
          <EntityListRow
            v-for="order in orders"
            :key="order.id"
            :thumbnail="getThumbnail(order)"
            :alt="order.customer?.office_name"
            :dot-class="ORDER_STATUS_DOT_CLASS[order.status] ?? 'bg-ink/30'"
            :aria-label="`Lihat detail order ${order.customer?.office_name ?? ''}`"
            @click="goToDetail(order)"
          >
            <template #fallback-icon>
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
                class="text-subtle opacity-40"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2" />
                <path d="M5 2v20" />
                <path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z" />
                <path d="M19 13v9" />
              </svg>
            </template>

            <template #info>
              <p class="truncate font-semibold text-ink">
                {{ order.customer?.office_name ?? '-' }}
              </p>
              <div class="mt-1 flex flex-wrap items-center gap-x-3 gap-y-0.5 text-xs text-subtle">
                <span class="flex items-center gap-1">
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
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
                    <line x1="16" y1="2" x2="16" y2="6" />
                    <line x1="8" y1="2" x2="8" y2="6" />
                    <line x1="3" y1="10" x2="21" y2="10" />
                  </svg>
                  {{ formatDate(order.delivery_date) }}
                </span>
                <template v-if="getTotalPax(order)">
                  <span class="text-ink/15">|</span>
                  <span class="flex items-center gap-1">
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
                      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                      <circle cx="9" cy="7" r="4" />
                      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                    </svg>
                    {{ getTotalPax(order) }} pax
                  </span>
                </template>
              </div>
              <p v-if="getMenuSummary(order)" class="mt-1 truncate text-xs text-subtle">
                {{ getMenuSummary(order) }}
              </p>
            </template>

            <template #trailing>
              <span class="hidden h-8 w-px bg-ink/10 sm:inline-block"></span>
              <span class="font-bold text-ink">{{ formatRupiah(order.total_amount) }}</span>
              <StatusBadge
                :status="order.status"
                :labels="ORDER_STATUS_LABEL"
                :classes="ORDER_STATUS_CLASS"
              />
              <span
                class="hidden h-8 w-8 shrink-0 items-center justify-center rounded-full bg-secondary text-white transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5 sm:flex"
              >
                <svg
                  width="12"
                  height="12"
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
            </template>
          </EntityListRow>
        </div>

        <Pagination
          class="mt-4"
          :current-page="currentPage"
          :last-page="lastPage"
          :total="total"
          label="order"
          @change="loadOrders"
        />
      </template>
    </main>
  </div>
</template>
