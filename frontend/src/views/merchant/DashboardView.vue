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

const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')

const merchant = ref(null)
const totalMenu = ref(0)
const pendingOrders = ref(0)
const unpaidInvoices = ref(0)
const recentOrders = ref([])

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

const STATUS_LABEL = {
  pending: 'Menunggu',
  confirmed: 'Dikonfirmasi',
  delivered: 'Dikirim',
  completed: 'Selesai',
  cancelled: 'Dibatalkan',
}

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
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Merchant</p>
        <h1 class="text-lg font-bold text-primary">
          {{ merchant?.company_name ?? 'Memuat...' }}
        </h1>
      </div>
      <nav class="flex items-center gap-3">
        <RouterLink
          to="/merchant/orders"
          class="text-sm font-medium text-gray-300 transition hover:text-primary"
        >
          Order
        </RouterLink>
        <RouterLink
          to="/merchant/menus"
          class="text-sm font-medium text-gray-300 transition hover:text-primary"
        >
          Menu
        </RouterLink>
        <RouterLink
          to="/merchant/profile"
          class="text-sm font-medium text-gray-300 transition hover:text-primary"
        >
          Profil
        </RouterLink>
        <RouterLink
          to="/merchant/invoices"
          class="text-sm font-medium text-gray-300 transition hover:text-primary"
        >
          Invoice
        </RouterLink>
        <button
          @click="handleLogout"
          class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
        >
          Logout
        </button>
      </nav>
    </header>

    <main class="p-6">
      <div v-if="isLoading" class="flex flex-col gap-6">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div v-for="i in 3" :key="i" class="rounded-xl border border-gray-200 bg-white p-5">
            <Skeleton width="60%" height="0.75rem" />
            <Skeleton width="40%" height="1.75rem" rounded="0.375rem" class="mt-3" />
          </div>
        </div>

        <div class="rounded-xl border border-gray-200 bg-white p-5">
          <Skeleton width="30%" height="0.875rem" class="mb-4" />
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

      <p v-else-if="errorMessage" class="text-sm text-red-500">
        {{ errorMessage }}
      </p>

      <div v-else class="flex flex-col gap-6">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div class="rounded-xl border border-gray-200 bg-white p-5">
            <p class="text-xs text-gray-500">Total Menu</p>
            <p class="mt-1 text-2xl font-bold text-secondary">{{ totalMenu }}</p>
          </div>
          <div class="rounded-xl border border-gray-200 bg-white p-5">
            <p class="text-xs text-gray-500">Order Menunggu Konfirmasi</p>
            <p class="mt-1 text-2xl font-bold text-secondary">{{ pendingOrders }}</p>
          </div>
          <div class="rounded-xl border border-gray-200 bg-white p-5">
            <p class="text-xs text-gray-500">Invoice Belum Lunas</p>
            <p class="mt-1 text-2xl font-bold text-secondary">{{ unpaidInvoices }}</p>
          </div>
        </div>

        <div class="rounded-xl border border-gray-200 bg-white p-5">
          <h2 class="mb-4 text-sm font-semibold text-gray-700">Order Terbaru</h2>

          <p v-if="recentOrders.length === 0" class="text-sm text-gray-400">
            Belum ada order masuk.
          </p>

          <table v-else class="w-full text-left text-sm">
            <thead>
              <tr class="border-b border-gray-200 text-gray-500">
                <th class="py-2 pr-4">Kantor</th>
                <th class="py-2 pr-4">Tanggal Kirim</th>
                <th class="py-2 pr-4">Total</th>
                <th class="py-2">Status</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="order in recentOrders"
                :key="order.id"
                class="border-b border-gray-100 last:border-0"
              >
                <td class="py-2 pr-4">{{ order.customer?.office_name ?? '-' }}</td>
                <td class="py-2 pr-4">{{ formatDate(order.delivery_date) }}</td>
                <td class="py-2 pr-4">{{ formatRupiah(order.total_amount) }}</td>
                <td class="py-2">
                  <span
                    class="rounded-full bg-primary/10 px-2 py-1 text-xs font-medium text-primary-dark"
                  >
                    {{ STATUS_LABEL[order.status] ?? order.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</template>
