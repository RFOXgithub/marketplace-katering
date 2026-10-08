<script setup>
import { ref, computed, onMounted } from 'vue'
import { getMenus, getCategories, createMenu, updateMenu, deleteMenu } from '@/services/menuService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import FileUploadButton from '@/components/ui/FileUploadButton.vue'
import DeleteMenuModal from '@/components/ui/DeleteMenuModal.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import { formatRupiah } from '@/utils/format'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')


const isLoading = ref(true)
const errorMessage = ref('')
const menus = ref([])
const categories = ref([])

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
  return path ? `${STORAGE_URL}/${path}` : '/logo-mark.svg'
}

async function loadData() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [menuRes, categoryRes] = await Promise.all([getMenus(), getCategories()])
    menus.value = menuRes.data ?? []
    categories.value = categoryRes.data ?? []
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
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
    await loadData()
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
    await loadData()
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isDeleting.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-clip bg-[#f7f5f2]">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Kelola Menu" max-width="max-w-6xl">
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
      <div class="animate-fade-up mb-6 flex items-center justify-between">
        <span
          class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
        >
          {{ menus.length }} Menu Terdaftar
        </span>

        <button
          @click="openCreateModal"
          class="group flex items-center gap-2 rounded-full bg-primary py-2 pr-2 pl-5 text-sm font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.97]"
        >
          Tambah Menu
          <span
            class="flex h-7 w-7 items-center justify-center rounded-full bg-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:rotate-90"
          >
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="5" x2="12" y2="19" />
              <line x1="5" y1="12" x2="19" y2="12" />
            </svg>
          </span>
        </button>
      </div>

      <div v-if="isLoading" class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div v-for="i in 6" :key="i" class="rounded-[2rem] bg-secondary/5 p-2">
          <div class="rounded-[1.625rem] bg-white p-4">
            <Skeleton width="100%" height="8rem" rounded="1.125rem" />
            <Skeleton width="60%" height="0.875rem" class="mt-3" />
            <Skeleton width="30%" height="0.875rem" class="mt-2" />
          </div>
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <div
        v-else-if="menus.length === 0"
        class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
      >
        <p class="rounded-[1.625rem] bg-white p-10 text-center text-sm text-secondary/40">
          Belum ada menu. Tambahkan menu pertama kamu.
        </p>
      </div>

      <div v-else class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="(menu, index) in menus"
          :key="menu.id"
          class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
          :style="{ animationDelay: `${Math.min(index, 8) * 0.06}s` }"
        >
          <div
            class="flex h-full flex-col gap-3 rounded-[1.625rem] bg-white p-4 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)]"
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
                <h2 class="truncate font-bold text-secondary">{{ menu.name }}</h2>
                <p class="text-xs text-secondary/40">{{ menu.category?.name ?? '-' }}</p>
              </div>
            </div>
            <p class="line-clamp-2 text-sm text-secondary/60">{{ menu.description }}</p>
            <p class="text-lg font-extrabold text-primary-dark">{{ formatRupiah(menu.price) }}</p>

            <div class="mt-auto flex gap-2 pt-1">
              <button
                @click="openEditModal(menu)"
                class="flex-1 rounded-full py-2 text-sm font-semibold text-secondary ring-1 ring-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
              >
                Edit
              </button>
              <button
                @click="handleDelete(menu)"
                class="flex-1 rounded-full bg-red-50 py-2 text-sm font-semibold text-red-500 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
              >
                Hapus
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="showModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-secondary/60 p-4 backdrop-blur-sm"
    >
      <form
        @submit.prevent="handleSubmit"
        class="flex max-h-[90vh] w-full max-w-md flex-col gap-4 overflow-y-auto rounded-[2rem] bg-white p-7 shadow-[0_40px_80px_-30px_rgba(18,18,18,0.5)]"
      >
        <div>
          <span
            class="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
          >
            {{ isEditing ? 'Edit' : 'Baru' }}
          </span>
          <h2 class="mt-2 text-xl font-bold text-secondary">
            {{ isEditing ? 'Edit Menu' : 'Tambah Menu' }}
          </h2>
        </div>

        <div class="flex items-center gap-4">
          <img
            :src="photoPreview || photoUrl(currentPhotoPath)"
            alt="Preview"
            class="h-16 w-16 rounded-2xl object-cover ring-1 ring-secondary/10"
          />
          <div class="flex min-w-0 flex-1 flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">Foto Menu</label>
            <FileUploadButton label="Pilih Foto" accept="image/*" @change="handlePhotoChange" />
            <p v-if="formErrors.photo" class="text-xs text-red-500">{{ formErrors.photo[0] }}</p>
          </div>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">Kategori</label>
          <select
            v-model="categoryId"
            class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="" disabled>Pilih kategori</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
          <p v-if="formErrors.category_id" class="text-xs text-red-500">
            {{ formErrors.category_id[0] }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">Nama Menu</label>
          <input
            v-model="name"
            type="text"
            class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="formErrors.name" class="text-xs text-red-500">{{ formErrors.name[0] }}</p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">Deskripsi</label>
          <textarea
            v-model="description"
            rows="3"
            class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
          ></textarea>
          <p v-if="formErrors.description" class="text-xs text-red-500">
            {{ formErrors.description[0] }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">Harga per Porsi</label>
          <div class="flex items-center gap-2 rounded-2xl bg-secondary/[0.04] px-4 py-2.5 focus-within:ring-2 focus-within:ring-primary">
            <span class="text-sm text-secondary/40">Rp</span>
            <input
              v-model="priceDisplay"
              type="text"
              inputmode="numeric"
              placeholder="0"
              class="w-full bg-transparent text-sm text-secondary focus:outline-none"
            />
          </div>
          <p v-if="formErrors.price" class="text-xs text-red-500">{{ formErrors.price[0] }}</p>
        </div>

        <label class="flex items-center gap-2 text-sm text-secondary/70">
          <input v-model="isAvailable" type="checkbox" class="h-4 w-4 accent-primary" />
          Menu tersedia
        </label>

        <p v-if="formError" class="text-sm text-red-500">{{ formError }}</p>

        <div class="flex gap-2 pt-1">
          <button
            type="button"
            @click="closeModal"
            class="flex-1 rounded-full py-2.5 text-sm font-semibold text-secondary/70 ring-1 ring-secondary/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5"
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
