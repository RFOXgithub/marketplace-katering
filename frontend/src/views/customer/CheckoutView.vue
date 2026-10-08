<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCustomerProfile, createOrder } from '@/services/customerService'
import {
  cartItems,
  cartMerchant,
  cartTotal,
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
import { formatRupiah } from '@/utils/format'

const router = useRouter()

const isLoading = ref(true)
const isSubmitting = ref(false)
const isLocating = ref(false)
const errorMessage = ref('')
const locationError = ref('')
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

function useCurrentLocation() {
  locationError.value = ''

  if (!navigator.geolocation) {
    locationError.value = 'Browser kamu tidak mendukung deteksi lokasi.'
    return
  }

  isLocating.value = true

  navigator.geolocation.getCurrentPosition(
    async (position) => {
      const { latitude, longitude } = position.coords
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`,
          { headers: { Accept: 'application/json' } },
        )
        const data = await res.json()
        deliveryAddress.value = data.display_name ?? `${latitude}, ${longitude}`
      } catch {
        locationError.value = 'Gagal mengambil nama alamat. Koordinat tetap disimpan manual.'
        deliveryAddress.value = `${latitude}, ${longitude}`
      } finally {
        isLocating.value = false
      }
    },
    (error) => {
      isLocating.value = false
      if (error.code === error.PERMISSION_DENIED) {
        locationError.value = 'Izin lokasi ditolak. Kamu masih bisa mengetik alamat secara manual.'
      } else {
        locationError.value = 'Gagal mendapatkan lokasi. Coba lagi atau ketik alamat secara manual.'
      }
    },
  )
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

    const [first] = cartItems.value
    successSummary.value = {
      name: first.name,
      quantity: first.quantity,
      price: first.price,
      extra: cartItems.value.length - 1,
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
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-6 sm:py-16">
      <div class="flex flex-col gap-5">
        <DoubleBezelCard>
          <span
            class="w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
          >
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
                class="w-16 rounded-xl bg-card px-2 py-1.5 text-center text-sm text-ink ring-1 ring-ink/10 focus:outline-none focus:ring-2 focus:ring-primary"
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
              class="w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
            >
              Detail Pengiriman
            </span>

            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Tanggal Pengiriman
              </label>
              <input
                v-model="deliveryDate"
                type="date"
                :min="minDate"
                required
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            <div class="flex flex-col gap-1">
              <div class="flex items-center justify-between">
                <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                  Alamat Pengiriman
                </label>
                <button
                  type="button"
                  :disabled="isLocating"
                  @click="useCurrentLocation"
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
              </div>
              <textarea
                v-model="deliveryAddress"
                rows="3"
                required
                placeholder="Ketik alamat, atau pakai tombol lokasi di atas"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary"
              ></textarea>
              <p v-if="locationError" class="text-xs text-red-600 dark:text-red-400">{{ locationError }}</p>
            </div>

            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Catatan (opsional)
              </label>
              <textarea
                v-model="notes"
                rows="2"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
              ></textarea>
            </div>

            <p v-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

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
