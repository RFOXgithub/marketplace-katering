<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCustomerInvoices } from '@/services/customerService'
import { resolveStorageUrl } from '@/services/http'
import { formatRupiah, formatDate } from '@/utils/format'
import { INVOICE_STATUS_LABEL, INVOICE_STATUS_CLASS, INVOICE_STATUS_DOT_CLASS, INVOICE_STATUS_FILTERS } from '@/constants/status'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import FilterPills from '@/components/ui/FilterPills.vue'
import EntityListRow from '@/components/ui/EntityListRow.vue'
import Pagination from '@/components/ui/Pagination.vue'

const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const invoices = ref([])
const statusCounts = ref({})
const brokenLogoIds = ref(new Set())
const statusFilter = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

const filtersWithCount = computed(() => {
  return INVOICE_STATUS_FILTERS.map((filter) => ({
    ...filter,
    count: statusCounts.value[filter.value] ?? 0,
  }))
})

function getThumbnail(invoice) {
  if (brokenLogoIds.value.has(invoice.id)) return null
  return resolveStorageUrl(invoice.order?.merchant?.logo_path)
}

function markLogoBroken(invoiceId) {
  brokenLogoIds.value = new Set(brokenLogoIds.value).add(invoiceId)
}

async function loadInvoices(page = 1) {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const params = new URLSearchParams()
    params.set('page', page)
    if (statusFilter.value) params.set('status', statusFilter.value)

    const res = await getCustomerInvoices(`?${params.toString()}`)
    invoices.value = res.data ?? []
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
  loadInvoices(1)
}

function goToDetail(invoice) {
  router.push(`/customer/invoices/${invoice.id}`)
}

onMounted(() => loadInvoices(1))
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Invoice" max-width="max-w-6xl">
      <template #title-icon>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 text-primary"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
      </template>
      <CartButton />
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">

      <FilterPills :filters="filtersWithCount" :model-value="statusFilter" @update:model-value="selectFilter">
        <template #icon="{ filter }">
          <svg v-if="filter.value === ''" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
          <svg v-else-if="filter.value === 'unpaid'" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
          <svg v-else-if="filter.value === 'paid'" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
          <svg v-else-if="filter.value === 'cancelled'" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        </template>
      </FilterPills>

      <!-- Loading skeleton -->
      <div v-if="isLoading" class="flex flex-col gap-3">
        <div v-for="i in 3" :key="i" class="flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4">
          <Skeleton width="4.5rem" height="4.5rem" rounded="0.75rem" />
          <div class="flex flex-1 flex-col gap-2">
            <Skeleton width="40%" height="0.875rem" />
            <Skeleton width="60%" height="0.75rem" />
          </div>
          <div class="flex flex-col items-end gap-2">
            <Skeleton width="5rem" height="1rem" />
            <Skeleton width="4rem" height="1.5rem" rounded="9999px" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

      <p v-else-if="invoices.length === 0" class="text-sm text-subtle">
        Belum ada invoice.
      </p>

      <template v-else>
        <div class="flex flex-col gap-3">
          <EntityListRow
            v-for="invoice in invoices"
            :key="invoice.id"
            :thumbnail="getThumbnail(invoice)"
            :alt="invoice.order?.merchant?.company_name"
            :dot-class="INVOICE_STATUS_DOT_CLASS[invoice.status] ?? 'bg-ink/30'"
            @click="goToDetail(invoice)"
            @thumbnail-error="markLogoBroken(invoice.id)"
          >
            <template #fallback-icon>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="text-subtle opacity-40" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
            </template>

            <template #info>
              <p class="truncate font-semibold text-ink">
                {{ invoice.order?.merchant?.company_name ?? '-' }}
              </p>
              <div class="mt-1 flex flex-wrap items-center gap-x-3 gap-y-0.5 text-xs text-subtle">
                <span class="flex items-center gap-1">
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                  {{ invoice.invoice_number }}
                </span>
                <span class="text-ink/15">|</span>
                <span class="flex items-center gap-1">
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                  Jatuh tempo {{ formatDate(invoice.due_date) }}
                </span>
              </div>
            </template>

            <template #trailing>
              <span class="hidden h-8 w-px bg-ink/10 sm:inline-block"></span>
              <span class="font-bold text-ink">{{ formatRupiah(invoice.total_amount) }}</span>
              <StatusBadge :status="invoice.status" :labels="INVOICE_STATUS_LABEL" :classes="INVOICE_STATUS_CLASS" />
              <span
                class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-secondary text-white transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
              >
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
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
          label="invoice"
          @change="loadInvoices"
        />
      </template>
    </main>
  </div>
</template>
