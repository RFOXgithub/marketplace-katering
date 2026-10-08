<script setup>
import { ref, computed, onMounted } from 'vue'
import { getMenus, getCategories, createMenu, updateMenu, deleteMenu } from '@/services/menuService'
import { resolveStorageUrl } from '@/services/http'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import FileUploadButton from '@/components/ui/FileUploadButton.vue'
import DeleteMenuModal from '@/components/ui/DeleteMenuModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import FilterPills from '@/components/ui/FilterPills.vue'
import FormField from '@/components/ui/FormField.vue'
import Pagination from '@/components/ui/Pagination.vue'
import { formatRupiah } from '@/utils/format'

const isLoading = ref(true)
const errorMessage = ref('')
const menus = ref([])
const categoryCounts = ref({ total: 0, categories: [] })
const categories = ref([])
const categoryFilter = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)

const categoryFilters = computed(() => {
  return [
    { value: '', label: 'Semua', count: categoryCounts.value.total },
    ...categoryCounts.value.categories.map((c) => ({ value: c.id, label: c.name, count: c.count })),
  ]
})

const showDeleteModal = ref(false)
const isDeleting = ref(false)
const menuToDelete = ref(null)

const showModal = ref(false)
const isEditing = ref(false)
const editingId = ref(null)
const isSaving = ref(false)
const formErrors = ref({})
const formError = ref('')

const categoryId = ref('')
const name = ref('')
const description = ref('')
const price = ref('')
const priceDisplay = computed({
  get() {
    if (!price.value) return ''
    return Number(price.value).toLocaleString('id-ID')
  },
  set(value) {
    price.value = value.replace(/\D/g, '')
  },
})
const isAvailable = ref(true)
const photoFile = ref(null)
const photoPreview = ref('')
const currentPhotoPath = ref('')

function photoUrl(path) {
  return resolveStorageUrl(path, '/logo-mark.svg')
}

async function loadData(page = 1) {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const params = new URLSearchParams()
    params.set('page', page)
    if (categoryFilter.value) params.set('category_id', categoryFilter.value)

    const [menuRes, categoryRes] = await Promise.all([
      getMenus(`?${params.toString()}`),
      categories.value.length ? Promise.resolve({ data: categories.value }) : getCategories(),
    ])
    menus.value = menuRes.data ?? []
    currentPage.value = menuRes.current_page ?? 1
    lastPage.value = menuRes.last_page ?? 1
    total.value = menuRes.total ?? 0
    categoryCounts.value = menuRes.counts ?? { total: 0, categories: [] }
    categories.value = categoryRes.data ?? []
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function selectCategoryFilter(value) {
  categoryFilter.value = value
  loadData(1)
}

function resetForm() {
  categoryId.value = ''
  name.value = ''
  description.value = ''
  price.value = ''
  isAvailable.value = true
  photoFile.value = null
  photoPreview.value = ''
  currentPhotoPath.value = ''
  formErrors.value = {}
  formError.value = ''
}

function openCreateModal() {
  resetForm()
  isEditing.value = false
  editingId.value = null
  showModal.value = true
}

function openEditModal(menu) {
  resetForm()
  isEditing.value = true
  editingId.value = menu.id
  categoryId.value = menu.category_id
  name.value = menu.name
  description.value = menu.description
  price.value = String(Math.round(Number(menu.price)))
  isAvailable.value = Boolean(menu.is_available)
  currentPhotoPath.value = menu.photo_path
  showModal.value = true
}

function closeModal() {
  showModal.value = false
}

function handlePhotoChange(event) {
  const file = event.target.files[0]
  if (!file) return
  photoFile.value = file
  photoPreview.value = URL.createObjectURL(file)
}

async function handleSubmit() {
  formErrors.value = {}
  formError.value = ''
  isSaving.value = true

  try {
    const formData = new FormData()
    formData.append('category_id', categoryId.value)
    formData.append('name', name.value)
    formData.append('description', description.value)
    formData.append('price', price.value)
    formData.append('is_available', isAvailable.value ? '1' : '0')
    if (photoFile.value) {
      formData.append('photo', photoFile.value)
    }

    if (isEditing.value) {
      await updateMenu(editingId.value, formData)
    } else {
      await createMenu(formData)
    }

    showModal.value = false
    await loadData(currentPage.value)
  } catch (e) {
    formError.value = e.message
    formErrors.value = e.errors ?? {}
  } finally {
    isSaving.value = false
  }
}

function handleDelete(menu) {
  menuToDelete.value = menu
  showDeleteModal.value = true
}

async function confirmDelete() {
  isDeleting.value = true
  errorMessage.value = ''
  try {
    await deleteMenu(menuToDelete.value.id)
    showDeleteModal.value = false
    await loadData(currentPage.value)
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isDeleting.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Kelola Menu" max-width="max-w-6xl">
      <template #title-icon>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 text-primary"><path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2"/><path d="M5 2v20"/><path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z"/><path d="M19 13v9"/></svg>
      </template>
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <div class="animate-fade-up mb-6 flex flex-wrap items-center justify-between gap-3">
        <span
          class="flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
        >
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2"/><path d="M5 2v20"/><path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z"/><path d="M19 13v9"/></svg>
          {{ total }} Menu Terdaftar
        </span>

        <button
          @click="openCreateModal"
          class="group flex items-center gap-2 rounded-full bg-primary py-2 pr-2 pl-5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
        >
          Tambah Menu
          <span
            class="flex h-7 w-7 items-center justify-center rounded-full bg-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:rotate-90"
          >
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19" />
              <line x1="5" y1="12" x2="19" y2="12" />
            </svg>
          </span>
        </button>
      </div>

      <!-- Filter kategori dengan count -->
      <FilterPills
        v-if="categoryFilters.length > 1"
        :filters="categoryFilters"
        :model-value="categoryFilter"
        @update:model-value="selectCategoryFilter"
      />

      <div v-if="isLoading" class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-ink/5 p-2">
          <div class="rounded-[1.625rem] bg-card p-4">
            <Skeleton width="100%" height="8rem" rounded="1.125rem" />
            <Skeleton width="60%" height="0.875rem" class="mt-3" />
            <Skeleton width="30%" height="0.875rem" class="mt-2" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>

      <div
        v-else-if="menus.length === 0"
        class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5"
      >
        <p class="rounded-[1.625rem] bg-card p-10 text-center text-sm text-subtle">
          {{ categoryFilter ? 'Belum ada menu di kategori ini.' : 'Belum ada menu. Tambahkan menu pertama kamu.' }}
        </p>
      </div>

      <template v-else>
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="(menu, index) in menus"
          :key="menu.id"
          class="animate-fade-up rounded-[2rem] bg-ink/5 p-2 ring-1 ring-ink/5"
          :style="{ animationDelay: `${Math.min(index, 8) * 0.06}s` }"
        >
          <div
            class="flex h-full flex-col gap-3 rounded-[1.625rem] bg-card p-4 shadow-[inset_0_1px_1px_rgba(255,255,255,0.08)]"
          >
            <div class="relative overflow-hidden rounded-[1.125rem]">
              <img
                :src="photoUrl(menu.photo_path)"
                :alt="menu.name"
                class="h-36 w-full object-cover"
              />
              <span
                v-if="!menu.is_available"
                class="absolute top-2 right-2 rounded-full bg-secondary/80 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-[0.1em] text-white backdrop-blur-sm"
              >
                Nonaktif
              </span>
            </div>
            <div class="flex items-start justify-between gap-2">
              <div class="min-w-0">
                <h2 class="truncate font-bold text-ink">{{ menu.name }}</h2>
                <p class="text-xs text-subtle">{{ menu.category?.name ?? '-' }}</p>
              </div>
            </div>
            <p class="line-clamp-2 text-sm text-muted">{{ menu.description }}</p>
            <p class="text-lg font-extrabold text-primary-dark">{{ formatRupiah(menu.price) }}</p>

            <div class="mt-auto flex gap-2 pt-1">
              <button
                @click="openEditModal(menu)"
                class="flex-1 rounded-full py-2 text-sm font-semibold text-ink ring-1 ring-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
              >
                Edit
              </button>
              <button
                @click="handleDelete(menu)"
                class="flex-1 rounded-full bg-red-500/10 py-2 text-sm font-semibold text-red-600 dark:text-red-400 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
              >
                Hapus
              </button>
            </div>
          </div>
        </div>
      </div>

      <Pagination
        class="mt-6"
        :current-page="currentPage"
        :last-page="lastPage"
        :total="total"
        label="menu"
        @change="loadData"
      />
      </template>
    </main>

    <div
      v-if="showModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-secondary/60 p-4 backdrop-blur-sm"
    >
      <form
        @submit.prevent="handleSubmit"
        class="relative flex max-h-[90vh] w-full max-w-md flex-col gap-4 overflow-y-auto rounded-[2rem] bg-card p-7 shadow-[0_40px_80px_-30px_rgba(18,18,18,0.5)]"
      >
        <button
          type="button"
          @click="closeModal"
          class="absolute top-5 right-5 flex h-8 w-8 items-center justify-center rounded-full bg-ink/5 text-subtle transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:bg-ink/10"
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        <div class="pr-10">
          <span
            class="flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
          >
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2"/><path d="M5 2v20"/><path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z"/><path d="M19 13v9"/></svg>
            {{ isEditing ? 'Edit' : 'Baru' }}
          </span>
          <h2 class="mt-2 text-xl font-bold text-ink">
            {{ isEditing ? 'Edit Menu' : 'Tambah Menu' }}
          </h2>
        </div>

        <div class="flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4">
          <img
            :src="photoPreview || photoUrl(currentPhotoPath)"
            alt="Preview"
            class="h-16 w-16 shrink-0 rounded-2xl object-cover ring-1 ring-ink/10"
          />
          <div class="flex min-w-0 flex-1">
            <FormField label="Foto Menu" :error="formErrors.photo?.[0]">
              <template #icon>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5L5 21"/></svg>
              </template>
              <FileUploadButton label="Pilih Foto" accept="image/*" @change="handlePhotoChange" />
            </FormField>
          </div>
        </div>

        <FormField label="Kategori" :error="formErrors.category_id?.[0]">
          <template #icon>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.59 13.41 13.42 20.6a2 2 0 0 1-2.83 0L2.83 12.83a2 2 0 0 1 0-2.83l7.17-7.17A2 2 0 0 1 11.42 2h6.58a2 2 0 0 1 2 2v6.59a2 2 0 0 1-.58 1.41z"/><circle cx="7.5" cy="7.5" r="1.5"/></svg>
          </template>
          <select
            v-model="categoryId"
            class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary-dark"
          >
            <option value="" disabled>Pilih kategori</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </FormField>

        <FormField label="Nama Menu" :error="formErrors.name?.[0]">
          <template #icon>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7a2 2 0 0 0 2 2h0a2 2 0 0 0 2-2V2"/><path d="M5 2v20"/><path d="M19 2c-1.5 0-3 1.5-3 4v5c0 1.5 1 2 2 2h1V2z"/><path d="M19 13v9"/></svg>
          </template>
          <input
            v-model="name"
            type="text"
            placeholder="Contoh: Nasi Box Ayam Bakar"
            class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
          />
        </FormField>

        <FormField label="Deskripsi" :error="formErrors.description?.[0]">
          <template #icon>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="13" y2="17"/></svg>
          </template>
          <textarea
            v-model="description"
            rows="3"
            placeholder="Jelaskan isi dan keunggulan menu ini"
            class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
          ></textarea>
        </FormField>

        <FormField label="Harga per Porsi" :error="formErrors.price?.[0]">
          <template #icon>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/></svg>
          </template>
          <div class="flex items-center gap-2 rounded-2xl bg-ink/[0.04] px-4 py-2.5 focus-within:ring-2 focus-within:ring-primary-dark">
            <span class="text-sm text-subtle">Rp</span>
            <input
              v-model="priceDisplay"
              type="text"
              inputmode="numeric"
              placeholder="0"
              class="w-full bg-transparent text-sm text-ink focus:outline-none"
            />
          </div>
        </FormField>

        <label class="flex items-center gap-3 rounded-2xl bg-ink/[0.04] px-4 py-3 text-sm text-muted">
          <input v-model="isAvailable" type="checkbox" class="h-4 w-4 accent-primary" />
          Menu tersedia
        </label>

        <p v-if="formError" class="text-sm text-red-600 dark:text-red-400">{{ formError }}</p>

        <div class="flex gap-2 pt-1">
          <button
            type="button"
            @click="closeModal"
            class="flex-1 rounded-full py-2.5 text-sm font-semibold text-muted ring-1 ring-ink/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="isSaving"
            class="flex flex-1 items-center justify-center rounded-full bg-primary py-2.5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97] disabled:opacity-70"
          >
            <LatticeLoader
              v-if="isSaving"
              label="Menyimpan"
              status="working"
              :show-timer="false"
              color="currentColor"
              :cell-size="5"
              font-size="13"
            />
            <span v-else>Simpan</span>
          </button>
        </div>
      </form>
    </div>

    <DeleteMenuModal
      v-model="showDeleteModal"
      :menu="menuToDelete"
      :photo-url="photoUrl"
      :loading="isDeleting"
      @confirm="confirmDelete"
    />
  </div>
</template>
