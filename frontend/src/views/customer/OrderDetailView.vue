<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getCustomerOrder, cancelCustomerOrder, submitOrderReview } from '@/services/customerService'
import { formatRupiah, formatDate } from '@/utils/format'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import CancelOrderModal from '@/components/ui/CancelOrderModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const route = useRoute()

const isLoading = ref(true)
const isCancelling = ref(false)
const errorMessage = ref('')
const order = ref(null)
const showCancelModal = ref(false)

const reviewRating = ref(0)
const reviewHoverRating = ref(0)
const reviewComment = ref('')
const isSubmittingReview = ref(false)
const reviewError = ref('')

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
  cancelled: 'bg-ink/10 text-subtle',
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
      <CartButton />
      <BackButton to="/customer/orders" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-5">
        <Skeleton width="100%" height="9rem" rounded="2rem" />
        <Skeleton width="100%" height="11rem" rounded="2rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

      <div v-else-if="order" class="flex flex-col gap-5">
        <DoubleBezelCard>
          <div class="mb-4 flex items-start justify-between gap-3">
            <div>
              <span
                class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
              >
                Order #{{ order.id }}
              </span>
              <h2 class="mt-2 text-xl font-bold text-ink">
                {{ order.merchant?.company_name ?? '-' }}
              </h2>
            </div>
            <StatusBadge :status="order.status" :labels="STATUS_LABEL" :classes="STATUS_CLASS" />
          </div>
          <dl class="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Tanggal Kirim
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(order.delivery_date) }}</dd>
            </div>
            <div class="sm:col-span-2">
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Alamat Pengiriman
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ order.delivery_address }}</dd>
            </div>
            <div v-if="order.notes" class="sm:col-span-2">
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Catatan
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ order.notes }}</dd>
            </div>
          </dl>
        </DoubleBezelCard>

        <DoubleBezelCard delay="0.08s">
          <h2 class="mb-4 text-xs font-semibold uppercase tracking-[0.1em] text-subtle">
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
            <span class="text-xl font-extrabold text-ink">{{ formatRupiah(order.total_amount) }}</span>
          </div>
        </DoubleBezelCard>

        <DoubleBezelCard v-if="order.invoice" delay="0.16s" padding="p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">Invoice</p>
              <p class="mt-1 font-semibold text-ink">{{ order.invoice.invoice_number }}</p>
            </div>
            <span
              class="rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-[0.08em]"
              :class="order.invoice.status === 'paid' ? 'bg-accent/10 text-accent' : 'bg-primary/10 text-primary-dark'"
            >
              {{ order.invoice.status }}
            </span>
          </div>
        </DoubleBezelCard>

        <DoubleBezelCard v-if="order.status === 'completed'" delay="0.2s">
          <div v-if="order.review">
            <h2 class="mb-2 text-xs font-semibold uppercase tracking-[0.1em] text-subtle">
              Rating Kamu
            </h2>
            <div class="flex items-center gap-1">
              <svg
                v-for="n in 5"
                :key="n"
                width="18"
                height="18"
                viewBox="0 0 24 24"
                :fill="n <= order.review.rating ? 'currentColor' : 'none'"
                stroke="currentColor"
                stroke-width="1.5"
                class="text-primary"
              >
                <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
              </svg>
            </div>
            <p v-if="order.review.comment" class="mt-2 text-sm text-ink">{{ order.review.comment }}</p>
            <p class="mt-2 text-xs text-subtle">Terima kasih sudah memberi rating untuk katering ini.</p>
          </div>

          <div v-else>
            <h2 class="mb-2 text-xs font-semibold uppercase tracking-[0.1em] text-subtle">
              Beri Rating Katering Ini
            </h2>
            <div class="flex items-center gap-1" @mouseleave="reviewHoverRating = 0">
              <button
                v-for="n in 5"
                :key="n"
                type="button"
                :aria-label="`${n} bintang`"
                class="p-0.5"
                @mouseenter="reviewHoverRating = n"
                @click="reviewRating = n"
              >
                <svg
                  width="22"
                  height="22"
                  viewBox="0 0 24 24"
                  :fill="n <= (reviewHoverRating || reviewRating) ? 'currentColor' : 'none'"
                  stroke="currentColor"
                  stroke-width="1.5"
                  class="text-primary transition-transform duration-150 hover:scale-110"
                >
                  <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
                </svg>
              </button>
            </div>

            <textarea
              v-model="reviewComment"
              rows="3"
              placeholder="Ceritakan pengalaman kamu dengan katering ini (opsional)"
              class="mt-3 w-full rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>

            <p v-if="reviewError" class="mt-2 text-xs text-red-600 dark:text-red-400">{{ reviewError }}</p>

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
