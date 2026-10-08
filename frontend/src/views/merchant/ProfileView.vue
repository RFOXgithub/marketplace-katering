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
    errors.value = e.errors ?? {}
  } finally {
    isSaving.value = false
  }
}

onMounted(loadProfile)
</script>

<template>
  <div class="relative min-h-[100dvh] overflow-x-hidden bg-[#f7f5f2]">
    <div
      class="pointer-events-none fixed inset-0 z-0"
      style="
        background:
          radial-gradient(60rem 36rem at 85% -10%, rgba(245, 166, 35, 0.14), transparent 60%),
          radial-gradient(40rem 30rem at -10% 20%, rgba(74, 124, 89, 0.08), transparent 55%);
      "
    />

    <header class="sticky top-4 z-40 mx-4 sm:top-6 sm:mx-6">
      <div
        class="mx-auto flex max-w-2xl flex-wrap items-center justify-between gap-3 rounded-[1.75rem] border border-white/10 bg-secondary/90 px-4 py-3 shadow-[0_20px_50px_-20px_rgba(18,18,18,0.45)] backdrop-blur-xl sm:px-6 sm:py-3.5"
      >
        <div class="min-w-0">
          <p class="text-[10px] font-semibold uppercase tracking-[0.2em] text-white/40">
            Portal Merchant
          </p>
          <h1 class="truncate text-base font-bold text-primary sm:text-lg">Profil Perusahaan</h1>
        </div>

        <button
          @click="router.push('/merchant/dashboard')"
          class="group flex items-center gap-2 rounded-full border border-white/15 py-1.5 pr-4 pl-1.5 text-sm font-medium text-white/70 transition-[transform,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 hover:text-primary"
        >
          <span
            class="flex h-6 w-6 items-center justify-center rounded-full bg-white/10 transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:-translate-x-0.5"
          >
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="19" y1="12" x2="5" y2="12" />
              <polyline points="12 19 5 12 12 5" />
            </svg>
          </span>
          Kembali
        </button>
      </div>
    </header>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-6 sm:py-16">
      <div
        v-if="isLoading"
        class="rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
      >
        <div class="flex flex-col gap-5 rounded-[1.625rem] bg-white p-6 sm:p-7">
          <div class="flex items-center gap-4">
            <Skeleton width="5rem" height="5rem" rounded="1.25rem" />
            <div class="flex flex-1 flex-col gap-2">
              <Skeleton width="30%" height="0.875rem" />
              <Skeleton width="50%" height="0.875rem" />
            </div>
          </div>

          <div v-for="i in 4" :key="i" class="flex flex-col gap-1.5">
            <Skeleton width="25%" height="0.75rem" />
            <Skeleton width="100%" height="2.5rem" rounded="1rem" />
          </div>

          <Skeleton width="100%" height="2.75rem" rounded="9999px" />
        </div>
      </div>

      <form
        v-else
        @submit.prevent="handleSubmit"
        class="animate-fade-up rounded-[2rem] bg-secondary/5 p-2 ring-1 ring-secondary/5"
      >
        <div class="flex flex-col gap-5 rounded-[1.625rem] bg-white p-6 sm:p-7">
          <span
            class="w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
          >
            Identitas Katering
          </span>

          <div class="flex items-center gap-4">
            <div class="rounded-2xl bg-secondary/5 p-1.5">
              <img
                :src="
                  logoPreview ||
                  (currentLogoPath ? `${STORAGE_URL}/${currentLogoPath}` : '/logo-mark.svg')
                "
                alt="Logo"
                class="h-16 w-16 rounded-xl object-cover"
              />
            </div>
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Logo Perusahaan
              </label>
              <input
                type="file"
                accept="image/*"
                @change="handleLogoChange"
                class="text-sm text-secondary/60"
              />
              <p v-if="errors.logo" class="text-xs text-red-500">{{ errors.logo[0] }}</p>
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
              Nama Perusahaan
            </label>
            <input
              v-model="companyName"
              type="text"
              class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <p v-if="errors.company_name" class="text-xs text-red-500">
              {{ errors.company_name[0] }}
            </p>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
              Alamat
            </label>
            <textarea
              v-model="address"
              rows="3"
              class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>
            <p v-if="errors.address" class="text-xs text-red-500">{{ errors.address[0] }}</p>
          </div>

          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Kota
              </label>
              <input
                v-model="city"
                type="text"
                class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p v-if="errors.city" class="text-xs text-red-500">{{ errors.city[0] }}</p>
            </div>

            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Nomor Kontak
              </label>
              <input
                v-model="contactPhone"
                type="text"
                class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p v-if="errors.contact_phone" class="text-xs text-red-500">
                {{ errors.contact_phone[0] }}
              </p>
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
              Email Kontak
            </label>
            <input
              v-model="contactEmail"
              type="email"
              class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <p v-if="errors.contact_email" class="text-xs text-red-500">
              {{ errors.contact_email[0] }}
            </p>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
              Deskripsi
            </label>
            <textarea
              v-model="description"
              rows="4"
              class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>
            <p v-if="errors.description" class="text-xs text-red-500">{{ errors.description[0] }}</p>
          </div>

          <label
            class="flex items-center gap-3 rounded-2xl bg-secondary/[0.04] px-4 py-3 text-sm text-secondary/70"
          >
            <input v-model="isActive" type="checkbox" class="h-4 w-4 accent-primary" />
            Tampilkan katering saya di pencarian customer
          </label>

          <p v-if="errorMessage" class="text-sm text-red-500">{{ errorMessage }}</p>
          <p
            v-if="successMessage"
            class="rounded-2xl bg-accent/10 px-4 py-2.5 text-sm font-medium text-accent"
          >
            {{ successMessage }}
          </p>

          <button
            type="submit"
            :disabled="isSaving"
            class="flex items-center justify-center rounded-full bg-primary py-3 font-bold text-secondary transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-[0.98] disabled:opacity-70"
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
        </div>
      </form>
    </main>
  </div>
</template>
