<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getMerchantInvoices } from '@/services/merchantService'
import Skeleton from '@/components/animations/Skeleton.vue'

const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const invoices = ref([])
const statusFilter = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

const STATUS_LABEL = {
  unpaid: 'Belum Lunas',
  paid: 'Lunas',
  cancelled: 'Dibatalkan',
}

const STATUS_CLASS = {
  unpaid: 'bg-primary/10 text-primary-dark',
  paid: 'bg-green-100 text-green-700',
  cancelled: 'bg-gray-100 text-gray-500',
}

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

async function loadInvoices(page = 1) {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const params = new URLSearchParams()
    params.set('page', page)
    if (statusFilter.value) params.set('status', statusFilter.value)

    const res = await getMerchantInvoices(`?${params.toString()}`)
    invoices.value = res.data ?? []
    currentPage.value = res.current_page ?? 1
    lastPage.value = res.last_page ?? 1
    total.value = res.total ?? 0
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleFilterChange() {
  loadInvoices(1)
}

function goToDetail(invoice) {
  router.push(`/merchant/invoices/${invoice.id}`)
}

onMounted(() => loadInvoices(1))
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Merchant</p>
        <h1 class="text-lg font-bold text-primary">Invoice</h1>
      </div>
      <button
        @click="router.push('/merchant/dashboard')"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Kembali
      </button>
    </header>

    <main class="p-6">
      <div class="mb-4 flex items-center gap-3">
        <label class="text-sm text-gray-600">Filter Status:</label>
        <select
          v-model="statusFilter"
          @change="handleFilterChange"
          class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        >
          <option value="">Semua</option>
          <option value="unpaid">Belum Lunas</option>
          <option value="paid">Lunas</option>
          <option value="cancelled">Dibatalkan</option>
        </select>
      </div>

      <div
        v-if="isLoading"
        class="flex flex-col gap-3 rounded-xl border border-gray-200 bg-white p-5"
      >
        <div v-for="i in 6" :key="i" class="flex items-center gap-4">
          <Skeleton width="25%" height="0.875rem" />
          <Skeleton width="20%" height="0.875rem" />
          <Skeleton width="20%" height="0.875rem" />
          <Skeleton width="15%" height="1.25rem" rounded="9999px" />
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <p v-else-if="invoices.length === 0" class="text-sm text-gray-400">Belum ada invoice.</p>

      <div v-else class="rounded-xl border border-gray-200 bg-white p-5">
        <table class="w-full text-left text-sm">
          <thead>
            <tr class="border-b border-gray-200 text-gray-500">
              <th class="py-2 pr-4">No. Invoice</th>
              <th class="py-2 pr-4">Kantor</th>
              <th class="py-2 pr-4">Total</th>
              <th class="py-2 pr-4">Jatuh Tempo</th>
              <th class="py-2">Status</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="invoice in invoices"
              :key="invoice.id"
              @click="goToDetail(invoice)"
              class="cursor-pointer border-b border-gray-100 transition last:border-0 hover:bg-gray-50"
            >
              <td class="py-3 pr-4 font-medium text-gray-800">{{ invoice.invoice_number }}</td>
              <td class="py-3 pr-4">{{ invoice.order?.customer?.office_name ?? '-' }}</td>
              <td class="py-3 pr-4">{{ formatRupiah(invoice.total_amount) }}</td>
              <td class="py-3 pr-4">{{ formatDate(invoice.due_date) }}</td>
              <td class="py-3">
                <span
                  class="rounded-full px-2 py-1 text-xs font-medium"
                  :class="STATUS_CLASS[invoice.status]"
                >
                  {{ STATUS_LABEL[invoice.status] ?? invoice.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>

        <div class="mt-4 flex items-center justify-between text-sm text-gray-500">
          <p>Total {{ total }} invoice</p>
          <div class="flex gap-2">
            <button
              :disabled="currentPage <= 1"
              @click="loadInvoices(currentPage - 1)"
              class="rounded-lg border border-gray-300 px-3 py-1 transition hover:border-primary disabled:opacity-40"
            >
              Sebelumnya
            </button>
            <span class="px-2 py-1">{{ currentPage }} / {{ lastPage }}</span>
            <button
              :disabled="currentPage >= lastPage"
              @click="loadInvoices(currentPage + 1)"
              class="rounded-lg border border-gray-300 px-3 py-1 transition hover:border-primary disabled:opacity-40"
            >
              Berikutnya
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
