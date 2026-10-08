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

const STATUS_CLASS = {
  pending: 'bg-primary/10 text-primary-dark',
  confirmed: 'bg-primary/10 text-primary-dark',
  delivered: 'bg-primary/10 text-primary-dark',
  completed: 'bg-accent/10 text-accent',
  cancelled: 'bg-secondary/10 text-secondary/50',
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
        class="mx-auto flex max-w-3xl flex-wrap items-center justify-between gap-3 rounded-[1.75rem] border border-white/10 bg-secondary/90 px-4 py-3 shadow-[0_20px_50px_-20px_rgba(18,18,18,0.45)] backdrop-blur-xl sm:px-6 sm:py-3.5"
      >
        <div class="min-w-0">
          <p class="text-[10px] font-semibold uppercase tracking-[0.2em] text-white/40">
            Portal Kantor
          </p>
          <h1 class="truncate text-base font-bold text-primary sm:text-lg">Detail Order</h1>
        </div>

        <button
          @click="router.push('/customer/orders')"
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

    <main class="relative z-10 mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-5">
        <Skeleton width="100%" height="9rem" rounded="2rem" />
        <Skeleton width="100%" height="11rem" rounded="2rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div v-else-if="order" class="flex flex-col gap-5">
        <div class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5">
          <div class="rounded-[1.625rem] bg-white p-6 sm:p-7">
            <div class="mb-4 flex items-start justify-between gap-3">
              <div>
                <span
                  class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
                >
                  Order #{{ order.id }}
                </span>
                <h2 class="mt-2 text-xl font-bold text-secondary">
                  {{ order.merchant?.company_name ?? '-' }}
                </h2>
              </div>
              <span
                class="rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-[0.08em]"
                :class="STATUS_CLASS[order.status] ?? STATUS_CLASS.pending"
              >
                {{ STATUS_LABEL[order.status] ?? order.status }}
              </span>
            </div>
            <dl class="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
              <div>
                <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                  Tanggal Kirim
                </dt>
                <dd class="mt-1 font-medium text-secondary">{{ formatDate(order.delivery_date) }}</dd>
              </div>
              <div class="sm:col-span-2">
                <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                  Alamat Pengiriman
                </dt>
                <dd class="mt-1 font-medium text-secondary">{{ order.delivery_address }}</dd>
              </div>
              <div v-if="order.notes" class="sm:col-span-2">
                <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                  Catatan
                </dt>
                <dd class="mt-1 font-medium text-secondary">{{ order.notes }}</dd>
              </div>
            </dl>
          </div>
        </div>

        <div
          class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
          style="animation-delay: 0.08s"
        >
          <div class="rounded-[1.625rem] bg-white p-6 sm:p-7">
            <h2 class="mb-4 text-xs font-semibold uppercase tracking-[0.1em] text-secondary/40">
              Item Pesanan
            </h2>
            <div class="flex flex-col gap-2">
              <div
                v-for="item in order.items"
                :key="item.id"
                class="flex items-center justify-between gap-4 rounded-xl bg-secondary/[0.03] px-4 py-3 text-sm"
              >
                <span class="flex-1 font-medium text-secondary">{{ item.menu_name }}</span>
                <span class="text-secondary/50">{{ formatRupiah(item.price) }} × {{ item.quantity }}</span>
                <span class="font-semibold text-secondary">{{ formatRupiah(item.subtotal) }}</span>
              </div>
            </div>
            <div class="mt-4 flex items-center justify-between border-t border-secondary/5 pt-4">
              <span class="text-sm font-medium text-secondary/50">Total</span>
              <span class="text-xl font-extrabold text-secondary">{{ formatRupiah(order.total_amount) }}</span>
            </div>
          </div>
        </div>

        <div
          v-if="order.invoice"
          class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
          style="animation-delay: 0.16s"
        >
          <div class="flex items-center justify-between rounded-[1.625rem] bg-white p-6">
            <div>
              <p class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">Invoice</p>
              <p class="mt-1 font-semibold text-secondary">{{ order.invoice.invoice_number }}</p>
            </div>
            <span
              class="rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-[0.08em]"
              :class="order.invoice.status === 'paid' ? 'bg-accent/10 text-accent' : 'bg-primary/10 text-primary-dark'"
            >
              {{ order.invoice.status }}
            </span>
          </div>
        </div>

        <button
          v-if="order.status === 'pending'"
          :disabled="isCancelling"
          @click="handleCancel"
          class="animate-fade-up flex items-center justify-center gap-2 rounded-full bg-red-50 py-3.5 text-sm font-bold text-red-500 ring-1 ring-red-100 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-60"
          style="animation-delay: 0.24s"
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
    </main>
  </div>
</template>
