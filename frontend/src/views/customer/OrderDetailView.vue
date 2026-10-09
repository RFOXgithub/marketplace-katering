<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import {
  getCustomerOrder,
  cancelCustomerOrder,
  submitOrderReview,
} from '@/services/customerService'
import { formatRupiah, formatDate } from '@/utils/format'
import {
  ORDER_STATUS_LABEL,
  ORDER_STATUS_CLASS,
  INVOICE_STATUS_LABEL,
  INVOICE_STATUS_CLASS,
} from '@/constants/status'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import CancelOrderModal from '@/components/ui/CancelOrderModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import StarRating from '@/components/ui/StarRating.vue'
import PeekRating from '@/components/animations/PeekRating.vue'

const route = useRoute()

const isLoading = ref(true)
const isCancelling = ref(false)
const errorMessage = ref('')
const order = ref(null)
const showCancelModal = ref(false)

const reviewRating = ref(0)
const reviewComment = ref('')
const isSubmittingReview = ref(false)
const reviewError = ref('')

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

async function submitReview() {
  if (reviewRating.value < 1) {
    reviewError.value = 'Pilih jumlah bintang dulu ya.'
    return
  }

  isSubmittingReview.value = true
  reviewError.value = ''
  try {
    await submitOrderReview(order.value.id, {
      rating: reviewRating.value,
      comment: reviewComment.value || null,
    })
    await loadOrder()
  } catch (e) {
    reviewError.value = e.message
  } finally {
    isSubmittingReview.value = false
  }
}

onMounted(loadOrder)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader :sticky="false" eyebrow="Portal Kantor" title="Detail Order">
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
      <CartButton />
      <BackButton to="/customer/orders" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-3xl px-4 py-12 pb-24 sm:px-6 sm:py-16 sm:pb-16">
      <div v-if="isLoading" class="flex flex-col gap-5">
        <Skeleton width="100%" height="9rem" rounded="2rem" />
        <Skeleton width="100%" height="11rem" rounded="2rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
        {{ errorMessage }}
      </p>

      <div v-else-if="order" class="flex flex-col gap-5">
        <DoubleBezelCard>
          <div class="mb-4 flex items-start justify-between gap-3">
            <div>
              <span
                class="flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
              >
                <svg
                  width="10"
                  height="10"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M3 3h18v4H3z" />
                  <path d="M5 7v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7" />
                  <path d="M10 12h4" />
                </svg>
                Order #{{ order.id }}
              </span>
              <h2 class="mt-2 text-xl font-bold text-ink">
                {{ order.merchant?.company_name ?? '-' }}
              </h2>
            </div>
            <StatusBadge
              :status="order.status"
              :labels="ORDER_STATUS_LABEL"
              :classes="ORDER_STATUS_CLASS"
            />
          </div>
          <dl class="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
            <div>
              <dt
                class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle"
              >
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
                Tanggal Kirim
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(order.delivery_date) }}</dd>
            </div>
            <div class="sm:col-span-2">
              <dt
                class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle"
              >
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
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z" />
                  <circle cx="12" cy="10" r="3" />
                </svg>
                Alamat Pengiriman
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ order.delivery_address }}</dd>
            </div>
            <div v-if="order.notes" class="sm:col-span-2">
              <dt
                class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle"
              >
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
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                  <polyline points="14 2 14 8 20 8" />
                  <line x1="8" y1="13" x2="16" y2="13" />
                  <line x1="8" y1="17" x2="13" y2="17" />
                </svg>
                Catatan
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ order.notes }}</dd>
            </div>
          </dl>
        </DoubleBezelCard>

        <DoubleBezelCard delay="0.08s">
          <h2
            class="mb-4 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-[0.1em] text-subtle"
          >
            <svg
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2" />
              <path d="M5 2v20" />
              <path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z" />
              <path d="M19 13v9" />
            </svg>
            Item Pesanan
          </h2>
          <div class="flex flex-col gap-2">
            <div
              v-for="item in order.items"
              :key="item.id"
              class="flex items-center justify-between gap-4 rounded-xl bg-ink/[0.03] px-4 py-3 text-sm"
            >
              <span class="flex-1 font-medium text-ink">{{ item.menu_name }}</span>
              <span class="text-subtle">{{ formatRupiah(item.price) }} × {{ item.quantity }}</span>
              <span class="font-semibold text-ink">{{ formatRupiah(item.subtotal) }}</span>
            </div>
          </div>
          <div class="mt-4 flex items-center justify-between border-t border-ink/5 pt-4">
            <span class="text-sm font-medium text-subtle">Total</span>
            <span class="text-xl font-extrabold text-ink">{{
              formatRupiah(order.total_amount)
            }}</span>
          </div>
        </DoubleBezelCard>

        <DoubleBezelCard v-if="order.invoice" delay="0.16s" padding="p-6">
          <div class="flex items-center justify-between">
            <div>
              <p
                class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle"
              >
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
                  <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                  <line x1="3" y1="6" x2="21" y2="6" />
                  <path d="M16 10a4 4 0 0 1-8 0" />
                </svg>
                Invoice
              </p>
              <p class="mt-1 font-semibold text-ink">{{ order.invoice.invoice_number }}</p>
            </div>
            <StatusBadge
              :status="order.invoice.status"
              :labels="INVOICE_STATUS_LABEL"
              :classes="INVOICE_STATUS_CLASS"
            />
          </div>
        </DoubleBezelCard>

        <DoubleBezelCard v-if="order.status === 'completed'" delay="0.2s">
          <div v-if="order.review">
            <h2
              class="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-[0.1em] text-subtle"
            >
              <svg
                width="12"
                height="12"
                viewBox="0 0 24 24"
                fill="currentColor"
                class="text-primary-dark"
              >
                <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
              </svg>
              Rating Kamu
            </h2>
            <StarRating :value="order.review.rating" :size="18" />
            <p v-if="order.review.comment" class="mt-2 text-sm text-ink">
              {{ order.review.comment }}
            </p>
            <p class="mt-2 text-xs text-subtle">
              Terima kasih sudah memberi rating untuk katering ini.
            </p>
          </div>

          <div v-else>
            <h2
              class="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-[0.1em] text-subtle"
            >
              <svg
                width="12"
                height="12"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
              </svg>
              Beri Rating Katering Ini
            </h2>
            <PeekRating
              :value="reviewRating"
              :size="26"
              :allow-clear="false"
              active-color="var(--color-primary-dark)"
              idle-color="var(--color-subtle)"
              aria-label="Rating katering"
              @change="reviewRating = $event"
            />

            <textarea
              v-model="reviewComment"
              rows="3"
              placeholder="Ceritakan pengalaman kamu dengan katering ini (opsional)"
              class="mt-3 w-full rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
            ></textarea>

            <p v-if="reviewError" class="mt-2 text-xs text-red-600 dark:text-red-400">
              {{ reviewError }}
            </p>

            <button
              type="button"
              :disabled="isSubmittingReview"
              @click="submitReview"
              class="mt-3 flex items-center justify-center rounded-full bg-primary px-5 py-2.5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-70"
            >
              {{ isSubmittingReview ? 'Mengirim...' : 'Kirim Rating' }}
            </button>
          </div>
        </DoubleBezelCard>

        <button
          v-if="order.status === 'pending'"
          @click="showCancelModal = true"
          class="animate-fade-up flex items-center justify-center gap-2 rounded-full bg-red-500/10 py-3.5 text-sm font-bold text-red-600 dark:text-red-400 ring-1 ring-red-500/20 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98]"
          style="animation-delay: 0.24s"
        >
          Batalkan Order
        </button>
      </div>
    </main>

    <CancelOrderModal
      v-model="showCancelModal"
      :order="order"
      :loading="isCancelling"
      @confirm="confirmCancel"
    />
  </div>
</template>
