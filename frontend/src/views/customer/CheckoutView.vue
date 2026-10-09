<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCustomerProfile, createOrder } from '@/services/customerService'
import { useCurrentLocation } from '@/composables/useCurrentLocation'
import {
  cartItems,
  cartMerchant,
  cartTotal,
  cartCount,
  updateQuantity,
  removeFromCart,
  clearCart,
} from '@/services/cartStore'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import PaymentSuccessModal from '@/components/ui/PaymentSuccessModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import FormField from '@/components/ui/FormField.vue'
import { formatRupiah } from '@/utils/format'

const router = useRouter()

const isLoading = ref(true)
const isSubmitting = ref(false)
const errorMessage = ref('')
const isSuccess = ref(false)
const successSummary = ref(null)

const deliveryDate = ref('')
const deliveryAddress = ref('')
const notes = ref('')

const minDate = (() => {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return tomorrow.toISOString().split('T')[0]
})()

const { isLocating, locationError, locate } = useCurrentLocation({
  permissionDenied: 'Izin lokasi ditolak. Kamu masih bisa mengetik alamat secara manual.',
  locateFailed: 'Gagal mendapatkan lokasi. Coba lagi atau ketik alamat secara manual.',
})

async function loadProfile() {
  isLoading.value = true
  try {
    const res = await getCustomerProfile()
    deliveryAddress.value = res.data?.address ?? ''
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleQuantityChange(menuId, value) {
  updateQuantity(menuId, Number(value))
}

function useCurrentLocationForAddress() {
  locate({
    onResolved: (address) => {
      deliveryAddress.value = address
    },
    onFallback: (coords) => {
      deliveryAddress.value = coords
    },
  })
}

async function handleSubmit() {
  errorMessage.value = ''
  isSubmitting.value = true

  try {
    await createOrder({
      merchant_id: cartMerchant.value.id,
      delivery_date: deliveryDate.value,
      delivery_address: deliveryAddress.value,
      notes: notes.value,
      items: cartItems.value.map((item) => ({
        menu_id: item.menu_id,
        quantity: item.quantity,
      })),
    })

    successSummary.value = {
      items: cartItems.value.map((item) => ({
        menu_id: item.menu_id,
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      })),
      totalQuantity: cartCount.value,
      total: cartTotal.value,
      date: deliveryDate.value,
      address: deliveryAddress.value,
    }
    clearCart()
    isSuccess.value = true
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  if (cartItems.value.length === 0 && !isSuccess.value) {
    router.replace('/customer/home')
    return
  }
  loadProfile()
})
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Checkout">
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
          <circle cx="9" cy="21" r="1" />
          <circle cx="20" cy="21" r="1" />
          <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
        </svg>
      </template>
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 pb-24 sm:px-6 sm:py-16 sm:pb-16">
      <div class="flex flex-col gap-5">
        <DoubleBezelCard>
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
              <circle cx="9" cy="21" r="1" />
              <circle cx="20" cy="21" r="1" />
              <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
            </svg>
            Keranjang
          </span>
          <h2 class="mt-2 mb-4 text-xl font-bold text-ink">
            {{ cartMerchant?.company_name }}
          </h2>

          <div class="flex flex-col gap-2">
            <div
              v-for="item in cartItems"
              :key="item.menu_id"
              class="flex items-center justify-between gap-3 rounded-xl bg-ink/[0.03] px-4 py-3"
            >
              <div class="min-w-0 flex-1">
                <p class="truncate text-sm font-medium text-ink">{{ item.name }}</p>
                <p class="text-xs text-subtle">{{ formatRupiah(item.price) }} / porsi</p>
              </div>
              <input
                type="number"
                min="1"
                :value="item.quantity"
                @change="handleQuantityChange(item.menu_id, $event.target.value)"
                class="w-16 rounded-xl bg-card px-2 py-1.5 text-center text-sm text-ink ring-1 ring-ink/10 focus:outline-none focus:ring-2 focus:ring-primary-dark"
              />
              <p class="w-24 shrink-0 text-right text-sm font-semibold text-ink">
                {{ formatRupiah(item.price * item.quantity) }}
              </p>
              <button
                @click="removeFromCart(item.menu_id)"
                class="shrink-0 text-xs font-medium text-red-600 dark:text-red-400 hover:underline"
              >
                Hapus
              </button>
            </div>
          </div>

          <div class="mt-4 flex items-center justify-between border-t border-ink/5 pt-4">
            <span class="text-sm font-medium text-subtle">Total</span>
            <span class="text-xl font-extrabold text-ink">{{ formatRupiah(cartTotal) }}</span>
          </div>
        </DoubleBezelCard>

        <form v-if="!isLoading" @submit.prevent="handleSubmit">
          <DoubleBezelCard delay="0.08s">
            <div class="flex flex-col gap-4">
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
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
                  <line x1="16" y1="2" x2="16" y2="6" />
                  <line x1="8" y1="2" x2="8" y2="6" />
                  <line x1="3" y1="10" x2="21" y2="10" />
                </svg>
                Detail Pengiriman
              </span>

              <FormField label="Tanggal Pengiriman">
                <template #icon>
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
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
                    <line x1="16" y1="2" x2="16" y2="6" />
                    <line x1="8" y1="2" x2="8" y2="6" />
                    <line x1="3" y1="10" x2="21" y2="10" />
                  </svg>
                </template>
                <input
                  v-model="deliveryDate"
                  type="date"
                  :min="minDate"
                  required
                  class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary-dark"
                />
              </FormField>

              <FormField label="Alamat Pengiriman">
                <template #icon>
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
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z" />
                    <circle cx="12" cy="10" r="3" />
                  </svg>
                </template>
                <template #label-action>
                  <button
                    type="button"
                    :disabled="isLocating"
                    @click="useCurrentLocationForAddress"
                    class="group flex items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-xs font-semibold text-primary-dark transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-60"
                  >
                    <svg
                      v-if="!isLocating"
                      width="12"
                      height="12"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:scale-110"
                    >
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z" />
                      <circle cx="12" cy="10" r="3" />
                    </svg>
                    <span v-if="isLocating">Mencari lokasi...</span>
                    <span v-else>Gunakan Lokasi Saat Ini</span>
                  </button>
                </template>
                <textarea
                  v-model="deliveryAddress"
                  rows="3"
                  required
                  placeholder="Ketik alamat, atau pakai tombol lokasi di atas"
                  class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
                ></textarea>
                <template #footer>
                  <p v-if="locationError" class="text-xs text-red-600 dark:text-red-400">
                    {{ locationError }}
                  </p>
                </template>
              </FormField>

              <FormField label="Catatan (opsional)">
                <template #icon>
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
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                    <polyline points="14 2 14 8 20 8" />
                    <line x1="8" y1="13" x2="16" y2="13" />
                    <line x1="8" y1="17" x2="13" y2="17" />
                  </svg>
                </template>
                <textarea
                  v-model="notes"
                  rows="2"
                  placeholder="Ada permintaan khusus untuk pesanan ini?"
                  class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
                ></textarea>
              </FormField>

              <p v-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
                {{ errorMessage }}
              </p>

              <button
                type="submit"
                :disabled="isSubmitting || cartItems.length === 0"
                class="flex items-center justify-center rounded-full bg-primary py-3 font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-70"
              >
                <LatticeLoader
                  v-if="isSubmitting"
                  label="Memproses"
                  status="working"
                  :show-timer="false"
                  color="currentColor"
                  :cell-size="5"
                  font-size="13"
                />
                <span v-else>Buat Pesanan</span>
              </button>
            </div>
          </DoubleBezelCard>
        </form>
      </div>
    </main>
    <PaymentSuccessModal
      :model-value="isSuccess"
      :summary="successSummary"
      title="Pesanan"
      highlight="Berhasil Dibuat!"
      message="Pesanan Anda sudah dikirim ke katering. Invoice akan muncul setelah dikonfirmasi."
      note="Terima kasih! Pesanan Anda akan segera diproses."
      secondary-label="Kembali ke Beranda"
      @primary="router.push('/customer/orders')"
      @secondary="router.push('/customer/home')"
      @update:model-value="router.push('/customer/orders')"
    />
  </div>
</template>
