<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getMerchantInvoice, markInvoicePaid } from '@/services/merchantService'
import { formatRupiah, formatDate } from '@/utils/format'
import { INVOICE_STATUS_LABEL, INVOICE_STATUS_CLASS } from '@/constants/status'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import MarkPaidModal from '@/components/ui/MarkPaidModal.vue'

const route = useRoute()

const isLoading = ref(true)
const isUpdating = ref(false)
const errorMessage = ref('')
const invoice = ref(null)
const showMarkPaidModal = ref(false)

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

function handleMarkPaid() {
  showMarkPaidModal.value = true
}

async function confirmMarkPaid() {
  isUpdating.value = true
  errorMessage.value = ''
  try {
    await markInvoicePaid(invoice.value.id)
    showMarkPaidModal.value = false
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
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader :sticky="false" eyebrow="Portal Merchant" title="Detail Invoice">
      <template #title-icon>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 text-primary"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
      </template>
      <BackButton to="/merchant/invoices" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-5">
        <Skeleton width="100%" height="9rem" rounded="2rem" />
        <Skeleton width="100%" height="11rem" rounded="2rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

      <div v-else-if="invoice" class="flex flex-col gap-5">
        <DoubleBezelCard>
          <div class="mb-4 flex items-start justify-between gap-3">
            <div>
              <span
                class="flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
              >
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                Invoice
              </span>
              <h2 class="mt-2 text-xl font-bold text-ink">{{ invoice.invoice_number }}</h2>
            </div>
            <StatusBadge :status="invoice.status" :labels="INVOICE_STATUS_LABEL" :classes="INVOICE_STATUS_CLASS" />
          </div>
          <dl class="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
            <div>
              <dt class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9 12 2l9 7"/><path d="M4 10v10a1 1 0 0 0 1 1h3v-6h8v6h3a1 1 0 0 0 1-1V10"/></svg>
                Kantor
              </dt>
              <dd class="mt-1 font-medium text-ink">
                {{ invoice.order?.customer?.office_name ?? '-' }}
              </dd>
            </div>
            <div>
              <dt class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Tanggal Terbit
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(invoice.issued_at) }}</dd>
            </div>
            <div>
              <dt class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                Jatuh Tempo
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(invoice.due_date) }}</dd>
            </div>
            <div v-if="invoice.paid_at">
              <dt class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                Dibayar Pada
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(invoice.paid_at) }}</dd>
            </div>
          </dl>
        </DoubleBezelCard>

        <DoubleBezelCard delay="0.08s">
          <h2 class="mb-4 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-[0.1em] text-subtle">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2"/><path d="M5 2v20"/><path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z"/><path d="M19 13v9"/></svg>
            Item Pesanan
          </h2>
          <div class="flex flex-col gap-2">
            <div
              v-for="item in invoice.order?.items"
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
            <span class="text-xl font-extrabold text-ink">{{ formatRupiah(invoice.total_amount) }}</span>
          </div>
        </DoubleBezelCard>

        <button
          v-if="invoice.status === 'unpaid'"
          :disabled="isUpdating"
          @click="handleMarkPaid"
          class="animate-fade-up flex items-center justify-center gap-2 rounded-full bg-primary py-3.5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-60"
          style="animation-delay: 0.16s"
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
    </main>

    <MarkPaidModal
      v-model="showMarkPaidModal"
      :loading="isUpdating"
      @confirm="confirmMarkPaid"
    />
  </div>
</template>
