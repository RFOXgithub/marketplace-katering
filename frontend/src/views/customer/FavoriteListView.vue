<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getFavoriteMerchants, removeFavorite } from '@/services/customerService'
import { resolveStorageUrl } from '@/services/http'
import Skeleton from '@/components/animations/Skeleton.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import Pagination from '@/components/ui/Pagination.vue'

const router = useRouter()

function photoUrl(path) {
  return resolveStorageUrl(path, '/logo-mark.svg')
}

const isLoading = ref(true)
const errorMessage = ref('')
const caterings = ref([])
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

async function loadFavorites(page = 1) {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getFavoriteMerchants(`?page=${page}`)
    caterings.value = res.data ?? []
    currentPage.value = res.current_page ?? 1
    lastPage.value = res.last_page ?? 1
    total.value = res.total ?? 0
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

async function handleUnfavorite(catering) {
  // optimistic: this page only ever lists favorited merchants, so removing
  // one here should drop it from view immediately rather than just flip a heart
  const previous = caterings.value
  caterings.value = caterings.value.filter((c) => c.id !== catering.id)
  total.value = Math.max(total.value - 1, 0)

  try {
    await removeFavorite(catering.id)
  } catch {
    caterings.value = previous
    total.value += 1
  }
}

onMounted(() => loadFavorites(1))
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Kantor" title="Katering Favorit" max-width="max-w-6xl">
      <template #title-icon>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" class="shrink-0 text-primary"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8Z"/></svg>
      </template>
      <CartButton />
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <div v-if="isLoading" class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div v-for="i in 6" :key="i" class="rounded-2xl bg-card p-4 ring-1 ring-ink/10">
          <div class="flex items-center gap-3">
            <Skeleton width="3.5rem" height="3.5rem" rounded="0.75rem" />
            <div class="flex flex-1 flex-col gap-2">
              <Skeleton width="60%" height="0.875rem" />
              <Skeleton width="80%" height="0.75rem" />
            </div>
          </div>
          <Skeleton width="100%" height="0.75rem" class="mt-4" />
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

      <div v-else-if="caterings.length === 0" class="flex flex-col items-center gap-3 py-16 text-center">
        <span class="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10 text-primary-dark">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8Z"/></svg>
        </span>
        <p class="text-sm text-subtle">
          Belum ada katering favorit. Tandai katering yang kamu suka dari halaman Beranda.
        </p>
        <RouterLink
          to="/customer/home"
          class="mt-1 rounded-full bg-primary px-5 py-2 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
        >
          Cari Katering
        </RouterLink>
      </div>

      <template v-else>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div
            v-for="(catering, index) in caterings"
            :key="catering.id"
            @click="router.push(`/caterings/${catering.slug}`)"
            class="animate-fade-up group flex cursor-pointer flex-col gap-3 rounded-2xl bg-card p-4 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)] ring-1 ring-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
            :style="{ animationDelay: `${Math.min(index, 8) * 0.06}s` }"
          >
            <div class="flex items-center justify-between">
              <span
                class="flex w-max items-center gap-1 rounded-full bg-primary/10 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-[0.1em] text-primary-dark"
              >
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                  <circle cx="12" cy="10" r="3" />
                </svg>
                {{ catering.city }}
              </span>

              <button
                type="button"
                aria-label="Hapus dari favorit"
                class="flex h-7 w-7 items-center justify-center rounded-full text-primary-dark transition-colors duration-200 hover:text-red-500 dark:hover:text-red-400"
                @click.stop="handleUnfavorite(catering)"
              >
                <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8Z" />
                </svg>
              </button>
            </div>

            <div class="flex items-center gap-3">
              <img
                v-if="catering.cover_photo"
                :src="photoUrl(catering.cover_photo)"
                :alt="catering.company_name"
                class="h-14 w-14 flex-shrink-0 rounded-xl object-cover ring-1 ring-ink/10"
              />
              <span
                v-else
                class="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary-dark ring-1 ring-ink/10"
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M12 2a7 7 0 0 0-7 7c0 3.1 2 5.6 5 6.6V18h4v-2.4c3-1 5-3.5 5-6.6a7 7 0 0 0-7-7Z" />
                  <path d="M9 21h6" />
                </svg>
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate font-bold text-ink">{{ catering.company_name }}</h3>
                <p class="line-clamp-2 text-xs text-subtle">
                  {{ catering.description || 'Belum ada deskripsi.' }}
                </p>
              </div>
            </div>

            <div class="mt-auto flex items-center justify-between gap-2">
              <div class="flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1 text-xs text-subtle">
                <span v-if="catering.rating_count > 0" class="flex items-center gap-1 whitespace-nowrap font-semibold text-ink">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" class="text-primary-dark">
                    <path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z" />
                  </svg>
                  {{ Number(catering.rating_avg).toFixed(1) }}
                </span>
                <span v-if="catering.rating_count > 0" class="text-ink/15">|</span>
                <span class="flex items-center gap-1 whitespace-nowrap">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                    <circle cx="9" cy="7" r="4" />
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                  </svg>
                  {{ catering.total_orders > 0 ? `${catering.total_orders}+ pesanan` : 'Katering baru' }}
                </span>
                <span class="text-ink/15">|</span>
                <span class="flex items-center gap-1 whitespace-nowrap">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10" />
                    <polyline points="12 6 12 12 16 14" />
                  </svg>
                  Min. {{ catering.min_order_pax }} pax
                </span>
              </div>

              <span
                class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-full text-ink/60 ring-1 ring-ink/10 transition-colors duration-300 group-hover:bg-primary group-hover:text-secondary group-hover:ring-primary"
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:translate-x-0.5">
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </span>
            </div>
          </div>
        </div>

        <Pagination
          class="mt-6"
          :current-page="currentPage"
          :last-page="lastPage"
          :total="total"
          label="katering"
          @change="loadFavorites"
        />
      </template>
    </main>
  </div>
</template>
