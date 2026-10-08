<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getMerchantInvoice, markInvoicePaid } from '@/services/merchantService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const isUpdating = ref(false)
const errorMessage = ref('')
const invoice = ref(null)

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

async function loadInvoice() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getMerchantInvoice(route.params.id)
    invoice.value = res.data
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

async function handleMarkPaid() {
  const confirmed = window.confirm('Tandai invoice ini sebagai lunas?')
  if (!confirmed) return

  isUpdating.value = true
  errorMessage.value = ''
  try {
    await markInvoicePaid(invoice.value.id)
    await loadInvoice()
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isUpdating.value = false
  }
}

onMounted(loadInvoice)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Merchant</p>
        <h1 class="text-lg font-bold text-primary">Detail Invoice</h1>
      </div>
      <button
        @click="router.push('/merchant/invoices')"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Kembali
      </button>
    </header>

    <main class="p-6">
      <div v-if="isLoading" class="mx-auto flex max-w-2xl flex-col gap-4">
        <Skeleton width="100%" height="8rem" rounded="0.75rem" />
        <Skeleton width="100%" height="10rem" rounded="0.75rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div v-else-if="invoice" class="mx-auto flex max-w-2xl flex-col gap-4">
        <div class="rounded-xl border border-gray-200 bg-white p-5">
          <div class="mb-3 flex items-center justify-between">
            <h2 class="font-bold text-secondary">{{ invoice.invoice_number }}</h2>
            <span
              class="rounded-full px-3 py-1 text-xs font-medium"
              :class="STATUS_CLASS[invoice.status]"
            >
              {{ STATUS_LABEL[invoice.status] ?? invoice.status }}
            </span>
          </div>
          <dl class="grid grid-cols-1 gap-2 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-gray-500">Kantor</dt>
              <dd class="font-medium text-gray-800">
                {{ invoice.order?.customer?.office_name ?? '-' }}
              </dd>
            </div>
            <div>
              <dt class="text-gray-500">Tanggal Terbit</dt>
              <dd class="font-medium text-gray-800">{{ formatDate(invoice.issued_at) }}</dd>
            </div>
            <div>
              <dt class="text-gray-500">Jatuh Tempo</dt>
              <dd class="font-medium text-gray-800">{{ formatDate(invoice.due_date) }}</dd>
            </div>
            <div v-if="invoice.paid_at">
              <dt class="text-gray-500">Dibayar Pada</dt>
              <dd class="font-medium text-gray-800">{{ formatDate(invoice.paid_at) }}</dd>
            </div>
          </dl>
        </div>

        <div class="rounded-xl border border-gray-200 bg-white p-5">
          <h2 class="mb-3 text-sm font-semibold text-gray-700">Item Pesanan</h2>
          <table class="w-full text-left text-sm">
            <thead>
              <tr class="border-b border-gray-200 text-gray-500">
                <th class="py-2 pr-4">Menu</th>
                <th class="py-2 pr-4">Harga</th>
                <th class="py-2 pr-4">Jumlah</th>
                <th class="py-2">Subtotal</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="item in invoice.order?.items"
                :key="item.id"
                class="border-b border-gray-100 last:border-0"
              >
                <td class="py-2 pr-4">{{ item.menu_name }}</td>
                <td class="py-2 pr-4">{{ formatRupiah(item.price) }}</td>
                <td class="py-2 pr-4">{{ item.quantity }}</td>
                <td class="py-2">{{ formatRupiah(item.subtotal) }}</td>
              </tr>
            </tbody>
          </table>
          <div class="mt-3 flex justify-end text-sm font-bold text-secondary">
            Total: {{ formatRupiah(invoice.total_amount) }}
          </div>
        </div>

        <div
          v-if="invoice.status === 'unpaid'"
          class="rounded-xl border border-gray-200 bg-white p-5"
        >
          <button
            :disabled="isUpdating"
            @click="handleMarkPaid"
            class="flex w-full items-center justify-center rounded-lg bg-primary py-2 text-sm font-bold text-secondary transition hover:bg-primary-dark disabled:opacity-60"
          >
            <LatticeLoader
              v-if="isUpdating"
              label="Memproses"
              status="working"
              :show-timer="false"
              color="currentColor"
              :cell-size="5"
              font-size="13"
            />
            <span v-else>Tandai Lunas</span>
          </button>
        </div>
      </div>
    </main>
  </div>
</template>
