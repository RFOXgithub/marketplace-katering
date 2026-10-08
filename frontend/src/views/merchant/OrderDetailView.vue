<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getMerchantOrder, updateMerchantOrderStatus } from '@/services/merchantService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const isUpdating = ref(false)
const errorMessage = ref('')
const order = ref(null)

const ALLOWED_TRANSITIONS = {
  pending: ['confirmed', 'cancelled'],
  confirmed: ['delivered', 'cancelled'],
  delivered: ['completed'],
  completed: [],
  cancelled: [],
}

const STATUS_LABEL = {
  pending: 'Menunggu',
  confirmed: 'Dikonfirmasi',
  delivered: 'Dikirim',
  completed: 'Selesai',
  cancelled: 'Dibatalkan',
}

const ACTION_LABEL = {
  confirmed: 'Konfirmasi Order',
  delivered: 'Tandai Dikirim',
  completed: 'Tandai Selesai',
  cancelled: 'Batalkan Order',
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
    const res = await getMerchantOrder(route.params.id)
    order.value = res.data
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

async function handleStatusChange(status) {
  if (status === 'cancelled') {
    const confirmed = window.confirm('Yakin batalkan order ini?')
    if (!confirmed) return
  }

  isUpdating.value = true
  errorMessage.value = ''
  try {
    await updateMerchantOrderStatus(order.value.id, status)
    await loadOrder()
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isUpdating.value = false
  }
}

onMounted(loadOrder)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Merchant</p>
        <h1 class="text-lg font-bold text-primary">Detail Order</h1>
      </div>
      <button
        @click="router.push('/merchant/orders')"
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
            <span
              class="rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary-dark"
            >
              {{ STATUS_LABEL[order.status] ?? order.status }}
            </span>
          </div>
          <dl class="grid grid-cols-1 gap-2 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-gray-500">Kantor</dt>
              <dd class="font-medium text-gray-800">{{ order.customer?.office_name ?? '-' }}</dd>
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
              <tr
                v-for="item in order.items"
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

        <div
          v-if="ALLOWED_TRANSITIONS[order.status]?.length"
          class="flex flex-wrap gap-2 rounded-xl border border-gray-200 bg-white p-5"
        >
          <button
            v-for="status in ALLOWED_TRANSITIONS[order.status]"
            :key="status"
            :disabled="isUpdating"
            @click="handleStatusChange(status)"
            class="rounded-lg px-4 py-2 text-sm font-bold transition disabled:opacity-60"
            :class="
              status === 'cancelled'
                ? 'border border-red-200 text-red-500 hover:bg-red-50'
                : 'bg-primary text-secondary hover:bg-primary-dark'
            "
          >
            {{ ACTION_LABEL[status] }}
          </button>
        </div>
      </div>
    </main>
  </div>
</template>
