<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getMenus, getCategories, createMenu, updateMenu, deleteMenu } from '@/services/menuService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

const router = useRouter()

const isLoading = ref(true)
const errorMessage = ref('')
const menus = ref([])
const categories = ref([])

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
const isAvailable = ref(true)
const photoFile = ref(null)
const photoPreview = ref('')
const currentPhotoPath = ref('')

function formatRupiah(value) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(value ?? 0)
}

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
  price.value = menu.price
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

async function handleDelete(menu) {
  const confirmed = window.confirm(`Hapus menu "${menu.name}"?`)
  if (!confirmed) return

  try {
    await deleteMenu(menu.id)
    await loadData()
  } catch (e) {
    errorMessage.value = e.message
  }
}

onMounted(loadData)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Merchant</p>
        <h1 class="text-lg font-bold text-primary">Kelola Menu</h1>
      </div>
      <button
        @click="router.push('/merchant/dashboard')"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Kembali
      </button>
    </header>

    <main class="p-6">
      <div class="mb-4 flex justify-end">
        <button
          @click="openCreateModal"
          class="rounded-lg bg-primary px-4 py-2 text-sm font-bold text-secondary transition hover:bg-primary-dark"
        >
          + Tambah Menu
        </button>
      </div>

      <div v-if="isLoading" class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div v-for="i in 6" :key="i" class="rounded-xl border border-gray-200 bg-white p-4">
          <Skeleton width="100%" height="8rem" rounded="0.5rem" />
          <Skeleton width="60%" height="0.875rem" class="mt-3" />
          <Skeleton width="30%" height="0.875rem" class="mt-2" />
        </div>
      </div>

      <p v-else-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>

      <p v-else-if="menus.length === 0" class="text-sm text-gray-400">
        Belum ada menu. Tambahkan menu pertama kamu.
      </p>

      <div v-else class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="menu in menus"
          :key="menu.id"
          class="flex flex-col gap-2 rounded-xl border border-gray-200 bg-white p-4"
        >
          <img
            :src="photoUrl(menu.photo_path)"
            :alt="menu.name"
            class="h-32 w-full rounded-lg object-cover"
          />
          <div class="flex items-start justify-between gap-2">
            <div>
              <h2 class="font-bold text-secondary">{{ menu.name }}</h2>
              <p class="text-xs text-gray-500">{{ menu.category?.name ?? '-' }}</p>
            </div>
            <span
              v-if="!menu.is_available"
              class="shrink-0 rounded-full bg-gray-100 px-2 py-1 text-xs font-medium text-gray-500"
            >
              Nonaktif
            </span>
          </div>
          <p class="line-clamp-2 text-sm text-gray-600">{{ menu.description }}</p>
          <p class="font-bold text-primary-dark">{{ formatRupiah(menu.price) }}</p>

          <div class="mt-2 flex gap-2">
            <button
              @click="openEditModal(menu)"
              class="flex-1 rounded-lg border border-gray-300 py-1.5 text-sm font-medium text-gray-700 transition hover:border-primary hover:text-primary"
            >
              Edit
            </button>
            <button
              @click="handleDelete(menu)"
              class="flex-1 rounded-lg border border-red-200 py-1.5 text-sm font-medium text-red-500 transition hover:bg-red-50"
            >
              Hapus
            </button>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="showModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
    >
      <form
        @submit.prevent="handleSubmit"
        class="flex max-h-[90vh] w-full max-w-md flex-col gap-4 overflow-y-auto rounded-xl bg-white p-6"
      >
        <h2 class="text-lg font-bold text-secondary">
          {{ isEditing ? 'Edit Menu' : 'Tambah Menu' }}
        </h2>

        <div class="flex items-center gap-4">
          <img
            :src="photoPreview || photoUrl(currentPhotoPath)"
            alt="Preview"
            class="h-16 w-16 rounded-lg border border-gray-200 object-cover"
          />
          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Foto Menu</label>
            <input
              type="file"
              accept="image/*"
              @change="handlePhotoChange"
              class="text-sm text-gray-600"
            />
            <p v-if="formErrors.photo" class="text-xs text-red-500">{{ formErrors.photo[0] }}</p>
          </div>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Kategori</label>
          <select
            v-model="categoryId"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="" disabled>Pilih kategori</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
          <p v-if="formErrors.category_id" class="text-xs text-red-500">
            {{ formErrors.category_id[0] }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Nama Menu</label>
          <input
            v-model="name"
            type="text"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="formErrors.name" class="text-xs text-red-500">{{ formErrors.name[0] }}</p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Deskripsi</label>
          <textarea
            v-model="description"
            rows="3"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          ></textarea>
          <p v-if="formErrors.description" class="text-xs text-red-500">
            {{ formErrors.description[0] }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Harga per Porsi</label>
          <input
            v-model="price"
            type="number"
            min="0"
            step="500"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="formErrors.price" class="text-xs text-red-500">{{ formErrors.price[0] }}</p>
        </div>

        <label class="flex items-center gap-2 text-sm text-gray-700">
          <input v-model="isAvailable" type="checkbox" class="h-4 w-4 accent-primary" />
          Menu tersedia
        </label>

        <p v-if="formError" class="text-sm text-red-500">{{ formError }}</p>

        <div class="flex gap-2">
          <button
            type="button"
            @click="closeModal"
            class="flex-1 rounded-lg border border-gray-300 py-2 text-sm font-medium text-gray-700 transition hover:border-gray-400"
          >
            Batal
          </button>
          <button
            type="submit"
            :disabled="isSaving"
            class="flex flex-1 items-center justify-center rounded-lg bg-primary py-2 text-sm font-bold text-secondary transition hover:bg-primary-dark disabled:opacity-70"
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
  </div>
</template>
