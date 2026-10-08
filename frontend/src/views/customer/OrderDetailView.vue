<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getCustomerOrder, cancelCustomerOrder } from '@/services/customerService'
import { formatRupiah, formatDate } from '@/utils/format'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import ConfirmModal from '@/components/ui/ConfirmModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const isCancelling = ref(false)
const errorMessage = ref('')
const order = ref(null)
const showCancelModal = ref(false)

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

async function confirmCancel() {
  isCancelling.value = true
  errorMessage.value = ''
  try {
    await cancelCustomerOrder(order.value.id)
    showCancelModal.value = false
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
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Detail Order">
      <CartButton />
      <BackButton to="/customer/orders" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-5">
        <Skeleton width="100%" height="9rem" rounded="2rem" />
        <Skeleton width="100%" height="11rem" rounded="2rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div v-else-if="order" class="flex flex-col gap-5">
        <DoubleBezelCard>
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
            <StatusBadge :status="order.status" :labels="STATUS_LABEL" :classes="STATUS_CLASS" />
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
        </DoubleBezelCard>

        <DoubleBezelCard delay="0.08s">
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
        </DoubleBezelCard>

        <DoubleBezelCard v-if="order.invoice" delay="0.16s" padding="p-6">
          <div class="flex items-center justify-between">
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
        </DoubleBezelCard>

        <button
          v-if="order.status === 'pending'"
          @click="showCancelModal = true"
          class="animate-fade-up flex items-center justify-center gap-2 rounded-full bg-red-50 py-3.5 text-sm font-bold text-red-500 ring-1 ring-red-100 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98]"
          style="animation-delay: 0.24s"
        >
          Batalkan Order
        </button>
      </div>
    </main>

    <ConfirmModal
      v-model="showCancelModal"
      title="Batalkan Order?"
      message="Order ini akan dibatalkan dan tidak bisa diproses lagi oleh katering."
      confirm-label="Ya, Batalkan"
      danger
      :loading="isCancelling"
      @confirm="confirmCancel"
    />
  </div>
</template>
