<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getCateringDetail } from '@/services/customerService'
import { addToCart, cartCount, cartMerchant } from '@/services/cartStore'
import Skeleton from '@/components/animations/Skeleton.vue'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import { formatRupiah } from '@/utils/format'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const merchant = ref(null)
const quantities = ref({})

function photoUrl(path) {
  return path ? `${STORAGE_URL}/${path}` : '/logo-mark.svg'
}

async function loadCatering() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getCateringDetail(route.params.slug)
    merchant.value = res.data
    quantities.value = Object.fromEntries(res.data.menus.map((menu) => [menu.id, 1]))
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleAddToCart(menu) {
  addToCart(
    { id: merchant.value.id, slug: merchant.value.slug, company_name: merchant.value.company_name },
    menu,
    quantities.value[menu.id] ?? 1,
  )
}

onMounted(loadCatering)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-[#f7f5f2]">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Detail Katering" max-width="max-w-5xl">
      <CartButton />
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-5xl px-4 py-12 pb-28 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-6">
        <Skeleton width="100%" height="10rem" rounded="2rem" />
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-secondary/5 p-2">
            <div class="rounded-[1.625rem] bg-white p-4">
              <Skeleton width="100%" height="8rem" rounded="1.125rem" />
              <Skeleton width="60%" height="0.875rem" class="mt-3" />
              <Skeleton width="30%" height="0.875rem" class="mt-2" />
            </div>
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div v-else-if="merchant" class="flex flex-col gap-6">
        <div class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5">
          <SpotlightCard
            class="rounded-[1.625rem] border-0 bg-secondary p-7 text-white"
            spotlight-color="rgba(245, 166, 35, 0.2)"
          >
            <div class="flex items-start justify-between gap-4">
              <div>
                <span
                  class="w-max rounded-full bg-primary/15 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary"
                >
                  {{ merchant.city }}
                </span>
                <h2 class="mt-3 text-2xl font-extrabold">{{ merchant.company_name }}</h2>
              </div>
              <div class="rounded-2xl bg-white/10 p-1.5">
                <img
                  :src="photoUrl(merchant.logo_path)"
                  alt="Logo"
                  class="h-14 w-14 rounded-xl object-cover"
                />
              </div>
            </div>
            <p class="mt-3 max-w-2xl text-sm text-white/60">
              {{ merchant.description || 'Belum ada deskripsi.' }}
            </p>
            <dl class="mt-5 grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
              <div>
                <dt class="text-xs font-medium uppercase tracking-[0.08em] text-white/30">Alamat</dt>
                <dd class="mt-1 font-medium text-white/80">{{ merchant.address }}</dd>
              </div>
              <div>
                <dt class="text-xs font-medium uppercase tracking-[0.08em] text-white/30">Kontak</dt>
                <dd class="mt-1 font-medium text-white/80">{{ merchant.contact_phone }}</dd>
              </div>
            </dl>
          </SpotlightCard>
        </div>

        <div>
          <span
            class="animate-fade-up w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
            style="animation-delay: 0.08s"
          >
            Menu Tersedia
          </span>

          <p v-if="merchant.menus.length === 0" class="mt-3 text-sm text-secondary/40">
            Katering ini belum memiliki menu tersedia.
          </p>

          <div v-else class="mt-4 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <div
              v-for="(menu, index) in merchant.menus"
              :key="menu.id"
              class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
              :style="{ animationDelay: `${0.1 + Math.min(index, 8) * 0.06}s` }"
            >
              <div class="flex h-full flex-col gap-3 rounded-[1.625rem] bg-white p-4 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)]">
                <img
                  :src="photoUrl(menu.photo_path)"
                  :alt="menu.name"
                  class="h-36 w-full rounded-[1.125rem] object-cover"
                />
                <div>
                  <h4 class="font-bold text-secondary">{{ menu.name }}</h4>
                  <p class="text-xs text-secondary/40">{{ menu.category?.name ?? '-' }}</p>
                </div>
                <p class="line-clamp-2 text-sm text-secondary/60">{{ menu.description }}</p>
                <p class="text-lg font-extrabold text-primary-dark">{{ formatRupiah(menu.price) }}</p>

                <div class="mt-auto flex items-center gap-2 pt-1">
                  <input
                    v-model.number="quantities[menu.id]"
                    type="number"
                    min="1"
                    class="w-16 rounded-full bg-secondary/[0.04] px-3 py-2 text-center text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                  <button
                    @click="handleAddToCart(menu)"
                    class="flex-1 rounded-full bg-primary py-2 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
                  >
                    + Keranjang
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="cartCount > 0 && cartMerchant?.id === merchant?.id"
      class="fixed inset-x-4 bottom-4 z-40 sm:inset-x-6 sm:bottom-6"
    >
      <div
        class="mx-auto flex max-w-5xl items-center justify-between gap-3 rounded-[1.75rem] border border-white/10 bg-secondary/95 px-5 py-3.5 shadow-[0_20px_50px_-20px_rgba(18,18,18,0.5)] backdrop-blur-xl"
      >
        <p class="text-sm text-white/70">
          <span class="font-bold text-primary">{{ cartCount }}</span> item di keranjang
        </p>
        <button
          @click="router.push('/checkout')"
          class="group flex items-center gap-2 rounded-full bg-primary py-2 pr-2 pl-5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
        >
          Lihat Keranjang
          <span
            class="flex h-6 w-6 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
          >
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </span>
        </button>
      </div>
    </div>
  </div>
</template>
