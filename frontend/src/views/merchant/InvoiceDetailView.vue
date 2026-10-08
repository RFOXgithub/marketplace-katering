<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getMerchantInvoice, markInvoicePaid } from '@/services/merchantService'
import { formatRupiah, formatDate } from '@/utils/format'
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

const STATUS_LABEL = {
  unpaid: 'Belum Lunas',
  paid: 'Lunas',
  cancelled: 'Dibatalkan',
}

const STATUS_CLASS = {
  unpaid: 'bg-primary/10 text-primary-dark',
  paid: 'bg-accent/10 text-accent',
  cancelled: 'bg-ink/10 text-subtle',
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
                class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
              >
                Invoice
              </span>
              <h2 class="mt-2 text-xl font-bold text-ink">{{ invoice.invoice_number }}</h2>
            </div>
            <StatusBadge :status="invoice.status" :labels="STATUS_LABEL" :classes="STATUS_CLASS" />
          </div>
          <dl class="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">Kantor</dt>
              <dd class="mt-1 font-medium text-ink">
                {{ invoice.order?.customer?.office_name ?? '-' }}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Tanggal Terbit
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(invoice.issued_at) }}</dd>
            </div>
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Jatuh Tempo
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(invoice.due_date) }}</dd>
            </div>
            <div v-if="invoice.paid_at">
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Dibayar Pada
              </dt>
              <dd class="mt-1 font-medium text-ink">{{ formatDate(invoice.paid_at) }}</dd>
            </div>
          </dl>
        </DoubleBezelCard>

        <DoubleBezelCard delay="0.08s">
          <h2 class="mb-4 text-xs font-semibold uppercase tracking-[0.1em] text-subtle">
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
