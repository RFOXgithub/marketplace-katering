<script setup>
import { ref, computed, onMounted } from 'vue'
import { getMerchantProfile, updateMerchantProfile } from '@/services/merchantService'
import { getCities } from '@/services/referenceService'
import { useCurrentLocation } from '@/composables/useCurrentLocation'
import { matchCityFromAddress } from '@/utils/city'
import { resolveStorageUrl } from '@/services/http'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import FileUploadButton from '@/components/ui/FileUploadButton.vue'
import Skeleton from '@/components/animations/Skeleton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'
import FormField from '@/components/ui/FormField.vue'

const isLoading = ref(true)
const isSaving = ref(false)
const errorMessage = ref('')
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
const minOrderPax = ref(10)
const totalOrders = ref(0)
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
  minOrderPax.value = merchant.min_order_pax ?? 10
  totalOrders.value = merchant.total_orders ?? 0
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

const { isLocating, locationError, locate } = useCurrentLocation()

function useCurrentLocationForAddress() {
  locate({
    onResolved: (resolvedAddress, addressParts) => {
      address.value = resolvedAddress

      const matchedCity = matchCityFromAddress(addressParts, cities.value)
      if (matchedCity) {
        city.value = matchedCity
      } else {
        locationError.value =
          'Alamat terisi otomatis, tapi kota tidak cocok dengan daftar. Pilih kota secara manual.'
      }
    },
    onFallback: (coords) => {
      address.value = coords
    },
  })
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
    formData.append('min_order_pax', minOrderPax.value)
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
  <div class="relative min-h-[100dvh] overflow-x-clip bg-page">
    <PageBackground />

    <PageHeader eyebrow="Portal Merchant" title="Profil Perusahaan">
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
      <BackButton to="/merchant/dashboard" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 pb-24 sm:px-6 sm:py-16 sm:pb-16">
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
              class="flex w-max items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
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
                <path d="M3 9 12 2l9 7" />
                <path d="M4 10v10a1 1 0 0 0 1 1h3v-6h8v6h3a1 1 0 0 0 1-1V10" />
              </svg>
              Identitas Katering
            </span>

            <!-- ringkasan identitas -->
            <div
              class="flex flex-wrap items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4"
            >
              <div class="rounded-2xl bg-ink/5 p-1.5">
                <img
                  :src="logoPreview || resolveStorageUrl(currentLogoPath, '/logo-mark.svg')"
                  alt="Logo"
                  class="h-16 w-16 rounded-xl object-cover"
                />
              </div>
              <div class="flex min-w-0 flex-1">
                <FormField class="min-w-0 flex-1" label="Logo Perusahaan" :error="errors.logo?.[0]">
                  <FileUploadButton
                    label="Pilih Logo"
                    accept="image/*"
                    @change="handleLogoChange"
                  />
                </FormField>
              </div>
              <div class="flex shrink-0 flex-col items-end gap-1.5 text-xs text-subtle">
                <span class="flex items-center gap-1">
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
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                    <polyline points="14 2 14 8 20 8" />
                  </svg>
                  {{ totalOrders }} pesanan masuk
                </span>
                <span class="flex items-center gap-1.5">
                  <span
                    class="h-1.5 w-1.5 rounded-full"
                    :class="isActive ? 'bg-accent' : 'bg-ink/30'"
                  />
                  {{ isActive ? 'Tampil di pencarian' : 'Disembunyikan' }}
                </span>
              </div>
            </div>

            <FormField label="Nama Perusahaan" :error="errors.company_name?.[0]">
              <template #icon>
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
                  <path d="M3 9 12 2l9 7" />
                  <path d="M4 10v10a1 1 0 0 0 1 1h3v-6h8v6h3a1 1 0 0 0 1-1V10" />
                </svg>
              </template>
              <input
                v-model="companyName"
                type="text"
                placeholder="Contoh: Katering Berkah"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
              />
            </FormField>

            <FormField label="Alamat" :error="errors.address?.[0]">
              <template #icon>
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
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z" />
                  <circle cx="12" cy="10" r="3" />
                </svg>
              </template>
              <template #label-action>
                <button
                  type="button"
                  :disabled="isLocating"
                  @click="useCurrentLocationForAddress"
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
              </template>
              <textarea
                v-model="address"
                rows="3"
                placeholder="Ketik alamat, atau pakai tombol lokasi di atas"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
              ></textarea>
              <template #footer>
                <p v-if="locationError" class="text-xs text-red-600 dark:text-red-400">
                  {{ locationError }}
                </p>
              </template>
            </FormField>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <FormField label="Kota" :error="errors.city?.[0]">
                <template #icon>
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
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z" />
                    <circle cx="12" cy="10" r="3" />
                  </svg>
                </template>
                <select
                  v-model="city"
                  class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary-dark"
                >
                  <option value="" disabled>Pilih kota</option>
                  <option v-for="opt in cityOptions" :key="opt.id" :value="opt.name">
                    {{ opt.name }}
                  </option>
                </select>
              </FormField>

              <FormField label="Nomor Kontak" :error="errors.contact_phone?.[0]">
                <template #icon>
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
                    <path
                      d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"
                    />
                  </svg>
                </template>
                <input
                  v-model="contactPhone"
                  type="text"
                  placeholder="08xxxxxxxxxx"
                  class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
                />
              </FormField>
            </div>

            <FormField label="Email Kontak" :error="errors.contact_email?.[0]">
              <template #icon>
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
                  <path d="M4 4h16v16H4z" />
                  <path d="m4 4 8 9 8-9" />
                </svg>
              </template>
              <input
                v-model="contactEmail"
                type="email"
                placeholder="nama@perusahaan.com"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
              />
            </FormField>

            <FormField label="Deskripsi" :error="errors.description?.[0]">
              <template #icon>
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
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                  <polyline points="14 2 14 8 20 8" />
                  <line x1="8" y1="13" x2="16" y2="13" />
                  <line x1="8" y1="17" x2="13" y2="17" />
                </svg>
              </template>
              <textarea
                v-model="description"
                rows="4"
                placeholder="Ceritakan keunggulan katering kamu"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
              ></textarea>
            </FormField>

            <FormField
              label="Minimal Pesanan (pax)"
              :error="errors.min_order_pax?.[0]"
              hint="Jumlah pax minimum yang kamu layani untuk satu pesanan."
            >
              <template #icon>
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
              </template>
              <input
                v-model.number="minOrderPax"
                type="number"
                min="1"
                max="1000"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary-dark"
              />
            </FormField>

            <label
              class="flex items-center gap-3 rounded-2xl bg-ink/[0.04] px-4 py-3 text-sm text-muted"
            >
              <input v-model="isActive" type="checkbox" class="h-4 w-4 accent-primary" />
              Tampilkan katering saya di pencarian customer
            </label>

            <p v-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">
              {{ errorMessage }}
            </p>
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
