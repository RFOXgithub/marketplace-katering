<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getCustomerOrder, cancelCustomerOrder } from '@/services/customerService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const isCancelling = ref(false)
const errorMessage = ref('')
const order = ref(null)

const STATUS_LABEL = {
  pending: 'Menunggu',
  confirmed: 'Dikonfirmasi',
  delivered: 'Dikirim',
  completed: 'Selesai',
  cancelled: 'Dibatalkan',
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

async function loadOrder() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getCustomerOrder(route.params.id)
    order.value = res.data
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

async function handleCancel() {
  const confirmed = window.confirm('Yakin batalkan order ini?')
  if (!confirmed) return

  isCancelling.value = true
  errorMessage.value = ''
  try {
    await cancelCustomerOrder(order.value.id)
    await loadOrder()
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isCancelling.value = false
  }
}

onMounted(loadOrder)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Kantor</p>
        <h1 class="text-lg font-bold text-primary">Detail Order</h1>
      </div>
      <button
        @click="router.push('/customer/orders')"
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

      <div v-else-if="order" class="mx-auto flex max-w-2xl flex-col gap-4">
        <div class="rounded-xl border border-gray-200 bg-white p-5">
          <div class="mb-3 flex items-center justify-between">
            <h2 class="font-bold text-secondary">Order #{{ order.id }}</h2>
            <span class="rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary-dark">
              {{ STATUS_LABEL[order.status] ?? order.status }}
            </span>
          </div>
          <dl class="grid grid-cols-1 gap-2 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-gray-500">Katering</dt>
              <dd class="font-medium text-gray-800">{{ order.merchant?.company_name ?? '-' }}</dd>
            </div>
            <div>
              <dt class="text-gray-500">Tanggal Kirim</dt>
              <dd class="font-medium text-gray-800">{{ formatDate(order.delivery_date) }}</dd>
            </div>
            <div class="sm:col-span-2">
              <dt class="text-gray-500">Alamat Pengiriman</dt>
              <dd class="font-medium text-gray-800">{{ order.delivery_address }}</dd>
            </div>
            <div v-if="order.notes" class="sm:col-span-2">
              <dt class="text-gray-500">Catatan</dt>
              <dd class="font-medium text-gray-800">{{ order.notes }}</dd>
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
              <tr v-for="item in order.items" :key="item.id" class="border-b border-gray-100 last:border-0">
                <td class="py-2 pr-4">{{ item.menu_name }}</td>
                <td class="py-2 pr-4">{{ formatRupiah(item.price) }}</td>
                <td class="py-2 pr-4">{{ item.quantity }}</td>
                <td class="py-2">{{ formatRupiah(item.subtotal) }}</td>
              </tr>
            </tbody>
          </table>
          <div class="mt-3 flex justify-end text-sm font-bold text-secondary">
            Total: {{ formatRupiah(order.total_amount) }}
          </div>
        </div>

        <div v-if="order.invoice" class="rounded-xl border border-gray-200 bg-white p-5">
          <h2 class="mb-2 text-sm font-semibold text-gray-700">Invoice</h2>
          <p class="text-sm text-gray-600">
            {{ order.invoice.invoice_number }} —
            <span class="font-medium">{{ order.invoice.status }}</span>
          </p>
        </div>

        <div v-if="order.status === 'pending'" class="rounded-xl border border-gray-200 bg-white p-5">
          <button
            :disabled="isCancelling"
            @click="handleCancel"
            class="flex w-full items-center justify-center rounded-lg border border-red-200 py-2 text-sm font-bold text-red-500 transition hover:bg-red-50 disabled:opacity-60"
          >
            <LatticeLoader
              v-if="isCancelling"
              label="Memproses"
              status="working"
              :show-timer="false"
              color="currentColor"
              :cell-size="5"
              font-size="13"
            />
            <span v-else>Batalkan Order</span>
          </button>
        </div>
      </div>
    </main>
  </div>
</template>
