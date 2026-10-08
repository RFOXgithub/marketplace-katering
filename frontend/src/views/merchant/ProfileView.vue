<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getMerchantProfile, updateMerchantProfile } from '@/services/merchantService'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import Skeleton from '@/components/animations/Skeleton.vue'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

const router = useRouter()

const isLoading = ref(true)
const isSaving = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const errors = ref({})

const companyName = ref('')
const address = ref('')
const city = ref('')
const contactPhone = ref('')
const contactEmail = ref('')
const description = ref('')
const isActive = ref(true)
const logoFile = ref(null)
const logoPreview = ref('')
const currentLogoPath = ref('')

function populateForm(merchant) {
  companyName.value = merchant.company_name ?? ''
  address.value = merchant.address ?? ''
  city.value = merchant.city ?? ''
  contactPhone.value = merchant.contact_phone ?? ''
  contactEmail.value = merchant.contact_email ?? ''
  description.value = merchant.description ?? ''
  isActive.value = Boolean(merchant.is_active)
  currentLogoPath.value = merchant.logo_path ?? ''
}

async function loadProfile() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const res = await getMerchantProfile()
    populateForm(res.data)
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function handleLogoChange(event) {
  const file = event.target.files[0]
  if (!file) return
  logoFile.value = file
  logoPreview.value = URL.createObjectURL(file)
}

async function handleSubmit() {
  errors.value = {}
  errorMessage.value = ''
  successMessage.value = ''
  isSaving.value = true

  try {
    const formData = new FormData()
    formData.append('company_name', companyName.value)
    formData.append('address', address.value)
    formData.append('city', city.value)
    formData.append('contact_phone', contactPhone.value)
    formData.append('contact_email', contactEmail.value)
    formData.append('description', description.value)
    formData.append('is_active', isActive.value ? '1' : '0')
    if (logoFile.value) {
      formData.append('logo', logoFile.value)
    }

    const res = await updateMerchantProfile(formData)
    populateForm(res.data)
    logoFile.value = null
    logoPreview.value = ''
    successMessage.value = res.message
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isSaving.value = false
  }
}

onMounted(loadProfile)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <header class="flex items-center justify-between bg-secondary px-6 py-4 text-white">
      <div>
        <p class="text-xs text-gray-400">Portal Merchant</p>
        <h1 class="text-lg font-bold text-primary">Profil Perusahaan</h1>
      </div>
      <button
        @click="router.push('/merchant/dashboard')"
        class="rounded-lg border border-gray-600 px-4 py-2 text-sm font-medium transition hover:border-primary hover:text-primary"
      >
        Kembali
      </button>
    </header>

    <main class="p-6">
      <div
        v-if="isLoading"
        class="mx-auto flex max-w-2xl flex-col gap-5 rounded-xl border border-gray-200 bg-white p-6"
      >
        <div class="flex items-center gap-4">
          <Skeleton width="5rem" height="5rem" rounded="0.5rem" />
          <div class="flex flex-1 flex-col gap-2">
            <Skeleton width="30%" height="0.875rem" />
            <Skeleton width="50%" height="0.875rem" />
          </div>
        </div>

        <div v-for="i in 4" :key="i" class="flex flex-col gap-1.5">
          <Skeleton width="25%" height="0.75rem" />
          <Skeleton width="100%" height="2.25rem" rounded="0.5rem" />
        </div>

        <Skeleton width="100%" height="2.5rem" rounded="0.5rem" />
      </div>

      <form
        v-else
        @submit.prevent="handleSubmit"
        class="mx-auto flex max-w-2xl flex-col gap-5 rounded-xl border border-gray-200 bg-white p-6"
      >
        <div class="flex items-center gap-4">
          <img
            :src="
              logoPreview ||
              (currentLogoPath ? `${STORAGE_URL}/${currentLogoPath}` : '/logo-mark.svg')
            "
            alt="Logo"
            class="h-20 w-20 rounded-lg border border-gray-200 object-cover"
          />
          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Logo Perusahaan</label>
            <input
              type="file"
              accept="image/*"
              @change="handleLogoChange"
              class="text-sm text-gray-600"
            />
            <p v-if="errors.logo" class="text-xs text-red-500">{{ errors.logo[0] }}</p>
          </div>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Nama Perusahaan</label>
          <input
            v-model="companyName"
            type="text"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="errors.company_name" class="text-xs text-red-500">
            {{ errors.company_name[0] }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Alamat</label>
          <textarea
            v-model="address"
            rows="3"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          ></textarea>
          <p v-if="errors.address" class="text-xs text-red-500">{{ errors.address[0] }}</p>
        </div>

        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Kota</label>
            <input
              v-model="city"
              type="text"
              class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <p v-if="errors.city" class="text-xs text-red-500">{{ errors.city[0] }}</p>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Nomor Kontak</label>
            <input
              v-model="contactPhone"
              type="text"
              class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <p v-if="errors.contact_phone" class="text-xs text-red-500">
              {{ errors.contact_phone[0] }}
            </p>
          </div>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Email Kontak</label>
          <input
            v-model="contactEmail"
            type="email"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="errors.contact_email" class="text-xs text-red-500">
            {{ errors.contact_email[0] }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Deskripsi</label>
          <textarea
            v-model="description"
            rows="4"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          ></textarea>
          <p v-if="errors.description" class="text-xs text-red-500">{{ errors.description[0] }}</p>
        </div>

        <label class="flex items-center gap-2 text-sm text-gray-700">
          <input v-model="isActive" type="checkbox" class="h-4 w-4 accent-primary" />
          Tampilkan katering saya di pencarian customer
        </label>

        <p v-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>
        <p v-if="successMessage" class="text-sm text-green-600">{{ successMessage }}</p>

        <button
          type="submit"
          :disabled="isSaving"
          class="flex items-center justify-center rounded-lg bg-primary py-2 font-bold text-secondary transition hover:bg-primary-dark disabled:opacity-70"
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
          <span v-else>Simpan Perubahan</span>
        </button>
      </form>
    </main>
  </div>
</template>
