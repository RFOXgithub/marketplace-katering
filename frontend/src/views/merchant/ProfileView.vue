<script setup>
import { ref, computed, onMounted } from 'vue'
import { getMerchantProfile, updateMerchantProfile, getCities } from '@/services/merchantService'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import FileUploadButton from '@/components/ui/FileUploadButton.vue'
import Skeleton from '@/components/animations/Skeleton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'

const API_URL = import.meta.env.VITE_API_URL
const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')


const isLoading = ref(true)
const isSaving = ref(false)
const isLocating = ref(false)
const errorMessage = ref('')
const locationError = ref('')
const successMessage = ref('')
const errors = ref({})
const cities = ref([])

const companyName = ref('')
const address = ref('')
const city = ref('')

const cityOptions = computed(() => {
  if (city.value && !cities.value.some((c) => c.name === city.value)) {
    return [{ id: 'current', name: city.value }, ...cities.value]
  }
  return cities.value
})
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
    const [profileRes, citiesRes] = await Promise.all([getMerchantProfile(), getCities()])
    populateForm(profileRes.data)
    cities.value = citiesRes.data ?? []
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
}

function matchCityFromAddress(addressParts) {
  const candidates = [
    addressParts.city,
    addressParts.town,
    addressParts.municipality,
    addressParts.county,
    addressParts.city_district,
    addressParts.suburb,
  ].filter(Boolean)

  for (const candidate of candidates) {
    const normalized = candidate.replace(/^(Kota|Kabupaten)\s+/i, '').trim().toLowerCase()
    const match = cities.value.find(
      (c) =>
        c.name.toLowerCase() === normalized ||
        c.name.toLowerCase().replace(/^(kota|kabupaten)\s+/i, '') === normalized,
    )
    if (match) return match.name
  }

  return null
}

function useCurrentLocation() {
  locationError.value = ''

  if (!navigator.geolocation) {
    locationError.value = 'Browser kamu tidak mendukung deteksi lokasi.'
    return
  }

  isLocating.value = true

  navigator.geolocation.getCurrentPosition(
    async (position) => {
      const { latitude, longitude } = position.coords
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`,
          { headers: { Accept: 'application/json' } },
        )
        const data = await res.json()
        address.value = data.display_name ?? `${latitude}, ${longitude}`

        const matchedCity = matchCityFromAddress(data.address ?? {})
        if (matchedCity) {
          city.value = matchedCity
        } else {
          locationError.value =
            'Alamat terisi otomatis, tapi kota tidak cocok dengan daftar. Pilih kota secara manual.'
        }
      } catch {
        locationError.value = 'Gagal mengambil nama alamat. Koordinat tetap disimpan manual.'
        address.value = `${latitude}, ${longitude}`
      } finally {
        isLocating.value = false
      }
    },
    (error) => {
      isLocating.value = false
      if (error.code === error.PERMISSION_DENIED) {
        locationError.value = 'Izin lokasi ditolak. Kamu masih bisa mengisi alamat secara manual.'
      } else {
        locationError.value = 'Gagal mendapatkan lokasi. Coba lagi atau isi alamat secara manual.'
      }
    },
  )
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
  <div class="relative min-h-[100dvh] overflow-x-clip bg-[#f7f5f2]">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Profil Perusahaan">
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-6 sm:py-16">
      <DoubleBezelCard v-if="isLoading" :animate="false">
        <div class="flex flex-col gap-5">
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
      </DoubleBezelCard>

      <form v-else @submit.prevent="handleSubmit">
        <DoubleBezelCard>
          <div class="flex flex-col gap-5">
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
            <div class="flex min-w-0 flex-1 flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Logo Perusahaan
              </label>
              <FileUploadButton label="Pilih Logo" accept="image/*" @change="handleLogoChange" />
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
            <div class="flex items-center justify-between">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Alamat
              </label>
              <button
                type="button"
                :disabled="isLocating"
                @click="useCurrentLocation"
                class="group flex items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-xs font-semibold text-primary-dark transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 disabled:opacity-60"
              >
                <svg
                  v-if="!isLocating"
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:scale-110"
                >
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z" />
                  <circle cx="12" cy="10" r="3" />
                </svg>
                <span v-if="isLocating">Mencari lokasi...</span>
                <span v-else>Gunakan Lokasi Saat Ini</span>
              </button>
            </div>
            <textarea
              v-model="address"
              rows="3"
              placeholder="Ketik alamat, atau pakai tombol lokasi di atas"
              class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary placeholder-secondary/30 focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>
            <p v-if="locationError" class="text-xs text-red-500">{{ locationError }}</p>
            <p v-if="errors.address" class="text-xs text-red-500">{{ errors.address[0] }}</p>
          </div>

          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-secondary/40">
                Kota
              </label>
              <select
                v-model="city"
                class="rounded-2xl bg-secondary/[0.04] px-4 py-2.5 text-sm text-secondary focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="" disabled>Pilih kota</option>
                <option v-for="opt in cityOptions" :key="opt.id" :value="opt.name">
                  {{ opt.name }}
                </option>
              </select>
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
        </DoubleBezelCard>
      </form>
    </main>
  </div>
</template>
