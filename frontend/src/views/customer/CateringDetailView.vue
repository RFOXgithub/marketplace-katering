<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getCateringDetail, getCateringReviews } from '@/services/customerService'
import { addToCart, cartCount, cartMerchant } from '@/services/cartStore'
import { resolveStorageUrl } from '@/services/http'
import Skeleton from '@/components/animations/Skeleton.vue'
import SpotlightCard from '@/components/animations/SpotlightCard.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import Pagination from '@/components/ui/Pagination.vue'
import StarRating from '@/components/ui/StarRating.vue'
import { formatRupiah, formatDate } from '@/utils/format'

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const merchant = ref(null)
const quantities = ref({})

const isReviewsLoading = ref(true)
const reviews = ref([])
const reviewsPage = ref(1)
const reviewsLastPage = ref(1)
const reviewsTotal = ref(0)

function photoUrl(path) {
  return resolveStorageUrl(path, '/logo-mark.svg')
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

async function loadReviews(page = 1) {
  isReviewsLoading.value = true
  try {
    const res = await getCateringReviews(route.params.slug, `?page=${page}`)
    reviews.value = res.data ?? []
    reviewsPage.value = res.current_page ?? 1
    reviewsLastPage.value = res.last_page ?? 1
    reviewsTotal.value = res.total ?? 0
  } catch {
    // reviews are a non-critical enhancement: leave the list empty on failure
  } finally {
    isReviewsLoading.value = false
  }
}

function handleAddToCart(menu) {
  addToCart(
    { id: merchant.value.id, slug: merchant.value.slug, company_name: merchant.value.company_name },
    menu,
    quantities.value[menu.id] ?? 1,
  )
}

onMounted(() => {
  loadCatering()
  loadReviews(1)
})
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Detail Katering" max-width="max-w-5xl">
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
          <path d="M3 9 12 2l9 7" />
          <path d="M4 10v10a1 1 0 0 0 1 1h3v-6h8v6h3a1 1 0 0 0 1-1V10" />
        </svg>
      </template>
      <CartButton />
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-5xl px-4 py-12 pb-40 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="flex flex-col gap-6">
        <Skeleton width="100%" height="10rem" rounded="2rem" />
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-ink/5 p-2">
            <div class="rounded-[1.625rem] bg-card p-4">
              <Skeleton width="100%" height="8rem" rounded="1.125rem" />
              <Skeleton width="60%" height="0.875rem" class="mt-3" />
              <Skeleton width="30%" height="0.875rem" class="mt-2" />
            </div>
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
        {{ errorMessage }}
      </p>

      <div v-else-if="merchant" class="flex flex-col gap-6">
        <div class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5">
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

            <div class="mt-4 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-white/60">
              <span
                v-if="merchant.rating_count > 0"
                class="flex items-center gap-1 whitespace-nowrap font-semibold text-white"
              >
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  class="text-primary"
                >
                  <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
                </svg>
                {{ Number(merchant.rating_avg).toFixed(1) }}
              </span>
              <span v-if="merchant.rating_count > 0" class="text-white/20">|</span>
              <span class="flex items-center gap-1 whitespace-nowrap">
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
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                  <circle cx="9" cy="7" r="4" />
                  <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                  <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                </svg>
                {{
                  merchant.total_orders > 0 ? `${merchant.total_orders}+ pesanan` : 'Katering baru'
                }}
              </span>
              <span class="text-white/20">|</span>
              <span class="flex items-center gap-1 whitespace-nowrap">
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
                  <circle cx="12" cy="12" r="10" />
                  <polyline points="12 6 12 12 16 14" />
                </svg>
                Min. {{ merchant.min_order_pax }} pax
              </span>
            </div>

            <dl class="mt-5 grid grid-cols-1 gap-4 text-sm sm:grid-cols-2">
              <div>
                <dt
                  class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-white/30"
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
                  Alamat
                </dt>
                <dd class="mt-1 font-medium text-white/80">{{ merchant.address }}</dd>
              </div>
              <div>
                <dt
                  class="flex items-center gap-1.5 text-xs font-medium uppercase tracking-[0.08em] text-white/30"
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
                    <path
                      d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"
                    />
                  </svg>
                  Kontak
                </dt>
                <dd class="mt-1 font-medium text-white/80">{{ merchant.contact_phone }}</dd>
              </div>
            </dl>
          </SpotlightCard>
        </div>

        <div>
          <span
            class="animate-fade-up flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
            style="animation-delay: 0.08s"
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
              <path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2" />
              <path d="M5 2v20" />
              <path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z" />
              <path d="M19 13v9" />
            </svg>
            Menu Tersedia
          </span>

          <p v-if="merchant.menus.length === 0" class="mt-3 text-sm text-subtle">
            Katering ini belum memiliki menu tersedia.
          </p>

          <div v-else class="mt-4 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <div
              v-for="(menu, index) in merchant.menus"
              :key="menu.id"
              class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5"
              :style="{ animationDelay: `${0.1 + Math.min(index, 8) * 0.06}s` }"
            >
              <div
                class="flex h-full flex-col gap-3 rounded-[1.625rem] bg-card p-4 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)]"
              >
                <img
                  :src="photoUrl(menu.photo_path)"
                  :alt="menu.name"
                  loading="lazy"
                  class="h-36 w-full rounded-[1.125rem] object-cover"
                />
                <div>
                  <h4 class="font-bold text-ink">{{ menu.name }}</h4>
                  <p class="text-xs text-subtle">{{ menu.category?.name ?? '-' }}</p>
                </div>
                <p class="line-clamp-2 text-sm text-muted">{{ menu.description }}</p>
                <p class="text-lg font-extrabold text-primary-dark">
                  {{ formatRupiah(menu.price) }}
                </p>

                <div class="mt-auto flex items-center gap-2 pt-1">
                  <input
                    v-model.number="quantities[menu.id]"
                    type="number"
                    min="1"
                    class="w-16 rounded-full bg-ink/[0.04] px-3 py-2 text-center text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary-dark"
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

        <div>
          <span
            class="animate-fade-up flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
            style="animation-delay: 0.16s"
          >
            <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
            </svg>
            Ulasan {{ merchant.rating_count > 0 ? `(${merchant.rating_count})` : '' }}
          </span>

          <div v-if="isReviewsLoading" class="mt-4 flex flex-col gap-3">
            <div
              v-for="i in 2"
              :key="i"
              class="flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4"
            >
              <Skeleton width="2.5rem" height="2.5rem" rounded="9999px" />
              <div class="flex flex-1 flex-col gap-2">
                <Skeleton width="30%" height="0.875rem" />
                <Skeleton width="70%" height="0.75rem" />
              </div>
            </div>
          </div>

          <p v-else-if="reviews.length === 0" class="mt-3 text-sm text-subtle">
            Belum ada ulasan untuk katering ini.
          </p>

          <template v-else>
            <div class="mt-4 flex flex-col gap-3">
              <div
                v-for="review in reviews"
                :key="review.id"
                class="flex items-start gap-4 rounded-2xl border border-ink/5 bg-card p-4"
              >
                <span
                  class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10 text-sm font-bold text-primary-dark"
                >
                  {{ (review.customer?.office_name ?? '?').charAt(0).toUpperCase() }}
                </span>
                <div class="min-w-0 flex-1">
                  <div class="flex flex-wrap items-center justify-between gap-x-3 gap-y-1">
                    <p class="truncate font-semibold text-ink">
                      {{ review.customer?.office_name ?? 'Pelanggan' }}
                    </p>
                    <span class="flex items-center gap-1 text-xs text-subtle">
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
                      {{ formatDate(review.created_at) }}
                    </span>
                  </div>
                  <StarRating :value="review.rating" class="mt-1" />
                  <p v-if="review.comment" class="mt-2 text-sm text-muted">{{ review.comment }}</p>
                </div>
              </div>
            </div>

            <Pagination
              v-if="reviewsTotal > 0"
              class="mt-4"
              :current-page="reviewsPage"
              :last-page="reviewsLastPage"
              :total="reviewsTotal"
              label="ulasan"
              @change="loadReviews"
            />
          </template>
        </div>
      </div>
    </main>

    <div
      v-if="cartCount > 0 && cartMerchant?.id === merchant?.id"
      class="fixed inset-x-4 bottom-20 z-40 sm:inset-x-6 sm:bottom-6"
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
            class="flex h-6 w-6 items-center justify-center rounded-full bg-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5"
          >
            <svg
              width="11"
              height="11"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </span>
        </button>
      </div>
    </div>
  </div>
</template>
