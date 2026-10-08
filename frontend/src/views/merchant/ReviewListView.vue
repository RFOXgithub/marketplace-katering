<script setup>
import { ref, computed, onMounted } from 'vue'
import { getMerchantReviews } from '@/services/merchantService'
import { formatDate } from '@/utils/format'
import Skeleton from '@/components/animations/Skeleton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import FilterPills from '@/components/ui/FilterPills.vue'
import StarRating from '@/components/ui/StarRating.vue'
import Pagination from '@/components/ui/Pagination.vue'

const isLoading = ref(true)
const errorMessage = ref('')
const reviews = ref([])
const ratingCounts = ref({})
const averageRating = ref(0)
const ratingFilter = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

const RATING_FILTERS = [
  { value: '', label: 'Semua' },
  { value: '5', label: '5' },
  { value: '4', label: '4' },
  { value: '3', label: '3' },
  { value: '2', label: '2' },
  { value: '1', label: '1' },
]

const filtersWithCount = computed(() => {
  return RATING_FILTERS.map((filter) => ({
    ...filter,
    count: ratingCounts.value[filter.value] ?? 0,
  }))
})

async function loadReviews(page = 1) {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const params = new URLSearchParams()
    params.set('page', page)
    if (ratingFilter.value) params.set('rating', ratingFilter.value)

    const res = await getMerchantReviews(`?${params.toString()}`)
    reviews.value = res.data ?? []
    currentPage.value = res.current_page ?? 1
    lastPage.value = res.last_page ?? 1
    total.value = res.total ?? 0
    ratingCounts.value = res.counts ?? {}
    averageRating.value = res.average_rating ?? 0
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function selectFilter(value) {
  ratingFilter.value = value
  loadReviews(1)
}

onMounted(() => loadReviews(1))
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Ulasan Pelanggan" max-width="max-w-6xl">
      <template #title-icon>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" class="shrink-0 text-primary"><path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z"/></svg>
      </template>
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">

      <!-- ringkasan rating -->
      <div class="animate-fade-up mb-6 flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4">
        <span class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-primary/10 text-2xl font-extrabold text-primary-dark">
          {{ averageRating.toFixed(1) }}
        </span>
        <div class="min-w-0 flex-1">
          <StarRating :value="Math.round(averageRating)" :size="14" />
          <p class="mt-1 text-xs text-subtle">Dari {{ total }} ulasan pelanggan</p>
        </div>
      </div>

      <!-- Filter pills dengan count -->
      <FilterPills :filters="filtersWithCount" :model-value="ratingFilter" @update:model-value="selectFilter">
        <template #icon="{ filter }">
          <svg v-if="filter.value" width="13" height="13" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z"/></svg>
          <svg v-else width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
        </template>
      </FilterPills>

      <!-- Loading skeleton -->
      <div v-if="isLoading" class="flex flex-col gap-3">
        <div v-for="i in 3" :key="i" class="flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4">
          <Skeleton width="2.5rem" height="2.5rem" rounded="9999px" />
          <div class="flex flex-1 flex-col gap-2">
            <Skeleton width="30%" height="0.875rem" />
            <Skeleton width="70%" height="0.75rem" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

      <p v-else-if="reviews.length === 0" class="text-sm text-subtle">
        Belum ada ulasan masuk.
      </p>

      <template v-else>
        <div class="flex flex-col gap-3">
          <div
            v-for="review in reviews"
            :key="review.id"
            class="flex items-start gap-4 rounded-2xl border border-ink/5 bg-card p-4 shadow-[0_1px_2px_rgba(18,18,18,0.04)]"
          >
            <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10 text-sm font-bold text-primary-dark">
              {{ (review.customer?.office_name ?? '?').charAt(0).toUpperCase() }}
            </span>
            <div class="min-w-0 flex-1">
              <div class="flex flex-wrap items-center justify-between gap-x-3 gap-y-1">
                <p class="truncate font-semibold text-ink">{{ review.customer?.office_name ?? 'Pelanggan' }}</p>
                <span class="flex items-center gap-1 text-xs text-subtle">
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                  {{ formatDate(review.created_at) }}
                </span>
              </div>
              <StarRating :value="review.rating" class="mt-1" />
              <p v-if="review.comment" class="mt-2 text-sm text-muted">{{ review.comment }}</p>
            </div>
          </div>
        </div>

        <Pagination
          class="mt-4"
          :current-page="currentPage"
          :last-page="lastPage"
          :total="total"
          label="ulasan"
          @change="loadReviews"
        />
      </template>
    </main>
  </div>
</template>
