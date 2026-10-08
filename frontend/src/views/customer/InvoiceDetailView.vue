<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getCustomerInvoice } from '@/services/customerService'
import { formatRupiah, formatDate } from '@/utils/format'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const invoice = ref(null)

const STATUS_LABEL = {
  unpaid: 'Belum Lunas',
  paid: 'Lunas',
  cancelled: 'Dibatalkan',
}

const STATUS_CLASS = {
  unpaid: 'bg-primary/10 text-primary-dark',
  paid: 'bg-accent/10 text-accent',
  cancelled: 'bg-secondary/10 text-secondary/50',
}

async function loadInvoice() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getCustomerInvoice(route.params.id)
    invoice.value = res.data
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

onMounted(loadInvoice)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-hidden bg-[#f7f5f2]">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Detail Invoice">
      <CartButton />
      <BackButton to="/customer/invoices" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-5">
        <Skeleton width="100%" height="9rem" rounded="2rem" />
        <Skeleton width="100%" height="11rem" rounded="2rem" />
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div v-else-if="invoice" class="flex flex-col gap-5">
        <DoubleBezelCard>
          <div class="mb-4 flex items-start justify-between gap-3">
            <div>
              <span
                class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
              >
                Invoice
              </span>
              <h2 class="mt-2 text-xl font-bold text-secondary">{{ invoice.invoice_number }}</h2>
            </div>
            <StatusBadge :status="invoice.status" :labels="STATUS_LABEL" :classes="STATUS_CLASS" />
          </div>
          <dl class="grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Katering
              </dt>
              <dd class="mt-1 font-medium text-secondary">
                {{ invoice.order?.merchant?.company_name ?? '-' }}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Tanggal Terbit
              </dt>
              <dd class="mt-1 font-medium text-secondary">{{ formatDate(invoice.issued_at) }}</dd>
            </div>
            <div>
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Jatuh Tempo
              </dt>
              <dd class="mt-1 font-medium text-secondary">{{ formatDate(invoice.due_date) }}</dd>
            </div>
            <div v-if="invoice.paid_at">
              <dt class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Dibayar Pada
              </dt>
              <dd class="mt-1 font-medium text-secondary">{{ formatDate(invoice.paid_at) }}</dd>
            </div>
          </dl>
        </DoubleBezelCard>

        <DoubleBezelCard delay="0.08s">
          <h2 class="mb-4 text-xs font-semibold uppercase tracking-[0.1em] text-secondary/40">
            Item Pesanan
          </h2>
          <div class="flex flex-col gap-2">
            <div
              v-for="item in invoice.order?.items"
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
            <span class="text-xl font-extrabold text-secondary">{{ formatRupiah(invoice.total_amount) }}</span>
          </div>
        </DoubleBezelCard>
      </div>
    </main>
  </div>
</template>
