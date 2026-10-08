<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCustomerProfile, createOrder } from '@/services/customerService'
import { cartItems, cartMerchant, cartTotal, updateQuantity, removeFromCart, clearCart } from '@/services/cartStore'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const router = useRouter()

const isLoading = ref(true)
const isSubmitting = ref(false)
const errorMessage = ref('')
const isSuccess = ref(false)

const deliveryDate = ref('')
const deliveryAddress = ref('')
const notes = ref('')

const minDate = (() => {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return tomorrow.toISOString().split('T')[0]
})()

function formatRupiah(value) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(value ?? 0)
}

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
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Kantor</p>
        <h1 class="text-lg font-bold text-primary">Checkout</h1>
      </div>
      <button
        @click="router.push('/customer/home')"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Kembali
      </button>
    </header>

    <main class="p-6">
      <div v-if="isSuccess" class="mx-auto flex max-w-md flex-col items-center gap-3 rounded-xl border border-gray-200 bg-white p-8 text-center">
        <h2 class="text-lg font-bold text-primary">Pesanan Berhasil Dibuat!</h2>
        <p class="text-sm text-gray-600">
          Pesanan kamu sudah dikirim ke katering. Invoice akan muncul setelah dikonfirmasi.
        </p>
        <button
          @click="router.push('/customer/orders')"
          class="w-full rounded-lg bg-primary py-2 text-sm font-bold text-secondary transition hover:bg-primary-dark"
        >
          Lihat Riwayat Order
        </button>
        <button
          @click="router.push('/customer/home')"
          class="w-full rounded-lg border border-gray-300 py-2 text-sm font-medium text-gray-700 transition hover:border-gray-400"
        >
          Kembali ke Beranda
        </button>
      </div>

      <div v-else class="mx-auto flex max-w-2xl flex-col gap-6">
        <div class="rounded-xl border border-gray-200 bg-white p-5">
          <h2 class="mb-3 text-sm font-semibold text-gray-700">
            Keranjang — {{ cartMerchant?.company_name }}
          </h2>

          <div class="flex flex-col gap-3">
            <div
              v-for="item in cartItems"
              :key="item.menu_id"
              class="flex items-center justify-between gap-3 border-b border-gray-100 pb-3 last:border-0"
            >
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-800">{{ item.name }}</p>
                <p class="text-xs text-gray-500">{{ formatRupiah(item.price) }} / porsi</p>
              </div>
              <input
                type="number"
                min="1"
                :value="item.quantity"
                @change="handleQuantityChange(item.menu_id, $event.target.value)"
                class="w-16 rounded-lg border border-gray-300 px-2 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p class="w-24 text-right text-sm font-medium text-gray-800">
                {{ formatRupiah(item.price * item.quantity) }}
              </p>
              <button
                @click="removeFromCart(item.menu_id)"
                class="text-sm text-red-500 hover:underline"
              >
                Hapus
              </button>
            </div>
          </div>

          <div class="mt-3 flex justify-end text-sm font-bold text-secondary">
            Total: {{ formatRupiah(cartTotal) }}
          </div>
        </div>

        <form
          v-if="!isLoading"
          @submit.prevent="handleSubmit"
          class="flex flex-col gap-4 rounded-xl border border-gray-200 bg-white p-5"
        >
          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Tanggal Pengiriman</label>
            <input
              v-model="deliveryDate"
              type="date"
              :min="minDate"
              required
              class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Alamat Pengiriman</label>
            <textarea
              v-model="deliveryAddress"
              rows="3"
              required
              class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Catatan (opsional)</label>
            <textarea
              v-model="notes"
              rows="2"
              class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>
          </div>

          <p v-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

          <button
            type="submit"
            :disabled="isSubmitting || cartItems.length === 0"
            class="flex items-center justify-center rounded-lg bg-primary py-2 font-bold text-secondary transition hover:bg-primary-dark disabled:opacity-70"
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
        </form>
      </div>
    </main>
  </div>
</template>
