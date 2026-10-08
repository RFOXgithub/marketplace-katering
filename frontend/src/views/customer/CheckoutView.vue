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
import SpotlightCard from '@/components/animations/SpotlightCard.vue'
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
  <div class="relative min-h-[100dvh] overflow-x-hidden bg-[#f7f5f2]">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Checkout">
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isSuccess" class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5">
        <SpotlightCard
          class="rounded-[1.625rem] border-0 bg-secondary p-8 text-center"
          spotlight-color="rgba(245, 166, 35, 0.25)"
        >
          <span
            class="mx-auto w-max rounded-full bg-primary/15 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary"
          >
            Berhasil
          </span>
          <h2 class="mt-3 text-xl font-extrabold text-white">Pesanan Berhasil Dibuat!</h2>
          <p class="mt-2 mb-6 text-sm text-white/50">
            Pesanan kamu sudah dikirim ke katering. Invoice akan muncul setelah dikonfirmasi.
          </p>
          <div class="flex flex-col gap-2">
            <button
              @click="router.push('/customer/orders')"
              class="group flex items-center justify-center gap-2 rounded-full bg-primary py-3 pr-2 pl-5 font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98]"
            >
              Lihat Riwayat Order
              <span
                class="flex h-7 w-7 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
              >
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </span>
            </button>
            <button
              @click="router.push('/customer/home')"
              class="rounded-full py-3 text-sm font-medium text-white/60 ring-1 ring-white/15 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
            >
              Kembali ke Beranda
            </button>
          </div>
        </SpotlightCard>
      </div>

      <div v-else class="flex flex-col gap-5">
        <DoubleBezelCard>
          <span
            class="w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
          >
            Keranjang
          </span>
          <h2 class="mt-2 mb-4 text-xl font-bold text-secondary">
            {{ cartMerchant?.company_name }}
          </h2>

          <div class="flex flex-col gap-2">
            <div
              v-for="item in cartItems"
              :key="item.menu_id"
              class="flex items-center justify-between gap-3 rounded-xl bg-secondary/[0.03] px-4 py-3"
            >
              <div class="min-w-0 flex-1">
                <p class="truncate text-sm font-medium text-secondary">{{ item.name }}</p>
                <p class="text-xs text-secondary/40">{{ formatRupiah(item.price) }} / porsi</p>
              </div>
              <input
                type="number"
                min="1"
                :value="item.quantity"
                @change="handleQuantityChange(item.menu_id, $event.target.value)"
                class="w-16 rounded-xl bg-white px-2 py-1.5 text-center text-sm text-secondary ring-1 ring-secondary/10 focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p class="w-24 shrink-0 text-right text-sm font-semibold text-secondary">
                {{ formatRupiah(item.price * item.quantity) }}
              </p>
              <button
                @click="removeFromCart(item.menu_id)"
                class="shrink-0 text-xs font-medium text-red-500 hover:underline"
              >
                Hapus
              </button>
            </div>
          </div>

          <div class="mt-4 flex items-center justify-between border-t border-secondary/5 pt-4">
            <span class="text-sm font-medium text-secondary/50">Total</span>
            <span class="text-xl font-extrabold text-secondary">{{ formatRupiah(cartTotal) }}</span>
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
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Tanggal Pengiriman
              </label>
              <input
                v-model="deliveryDate"
                type="date"
                :min="minDate"
                required
                class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            <div class="flex flex-col gap-1">
              <div class="flex items-center justify-between">
                <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
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
                class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary placeholder-secondary/30 focus:outline-none focus:ring-2 focus:ring-primary"
              ></textarea>
              <p v-if="locationError" class="text-xs text-red-500">{{ locationError }}</p>
            </div>

            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Catatan (opsional)
              </label>
              <textarea
                v-model="notes"
                rows="2"
                class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
              ></textarea>
            </div>

            <p v-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

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
  </div>
</template>
