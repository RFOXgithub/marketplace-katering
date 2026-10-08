<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getMerchantOrder, updateMerchantOrderStatus } from '@/services/merchantService'
import { formatRupiah, formatDate } from '@/utils/format'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import CancelOrderModal from '@/components/ui/CancelOrderModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const route = useRoute()

const isLoading = ref(true)
const isUpdating = ref(false)
const errorMessage = ref('')
const order = ref(null)
const showCancelModal = ref(false)

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

const STATUS_CLASS = {
  pending: 'bg-primary/10 text-primary-dark',
  confirmed: 'bg-primary/10 text-primary-dark',
  delivered: 'bg-primary/10 text-primary-dark',
  completed: 'bg-accent/10 text-accent',
  cancelled: 'bg-secondary/10 text-secondary/50',
}

const ACTION_LABEL = {
  confirmed: 'Konfirmasi Order',
  delivered: 'Tandai Dikirim',
  completed: 'Tandai Selesai',
  cancelled: 'Batalkan Order',
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
    showCancelModal.value = true
    return
  }

  await submitStatusChange(status)
}

async function submitStatusChange(status) {
  isUpdating.value = true
  errorMessage.value = ''
  try {
    await updateMerchantOrderStatus(order.value.id, status)
    showCancelModal.value = false
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
  <div class="relative min-h-[100dvh] overflow-x-hidden bg-[#f7f5f2]">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Detail Order">
      <BackButton to="/merchant/orders" />
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
                {{ order.customer?.office_name ?? '-' }}
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

        <div
          v-if="ALLOWED_TRANSITIONS[order.status]?.length"
          class="animate-fade-up flex flex-wrap gap-3"
          style="animation-delay: 0.24s"
        >
          <button
            v-for="status in ALLOWED_TRANSITIONS[order.status]"
            :key="status"
            :disabled="isUpdating"
            @click="handleStatusChange(status)"
            class="flex items-center justify-center gap-2 rounded-full px-6 py-3 text-sm font-bold transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-60"
            :class="
              status === 'cancelled'
                ? 'bg-red-50 text-red-500 ring-1 ring-red-100'
                : 'bg-primary text-secondary'
            "
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
            <span v-else>{{ ACTION_LABEL[status] }}</span>
          </button>
        </div>
      </div>
    </main>

    <CancelOrderModal
      v-model="showCancelModal"
      :order="order"
      note="Customer akan diberi tahu bahwa pesanan ini dibatalkan."
      :loading="isUpdating"
      @confirm="submitStatusChange('cancelled')"
    />
  </div>
</template>
