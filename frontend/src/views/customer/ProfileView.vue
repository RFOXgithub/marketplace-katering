<script setup>
import { ref, computed, onMounted } from 'vue'
import { getCustomerProfile, updateCustomerProfile } from '@/services/customerService'
import { getCities } from '@/services/referenceService'
import { useCurrentLocation } from '@/composables/useCurrentLocation'
import { matchCityFromAddress } from '@/utils/city'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import CartButton from '@/components/customer/CartButton.vue'
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

const officeName = ref('')
const address = ref('')
const city = ref('')
const contactPhone = ref('')
const picName = ref('')

const cityOptions = computed(() => {
  if (city.value && !cities.value.some((c) => c.name === city.value)) {
    return [{ id: 'current', name: city.value }, ...cities.value]
  }
  return cities.value
})

function populateForm(customer) {
  officeName.value = customer.office_name ?? ''
  address.value = customer.address ?? ''
  city.value = customer.city ?? ''
  contactPhone.value = customer.contact_phone ?? ''
  picName.value = customer.pic_name ?? ''
}

async function loadProfile() {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [profileRes, citiesRes] = await Promise.all([getCustomerProfile(), getCities()])
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

async function handleSubmit() {
  errors.value = {}
  errorMessage.value = ''
  successMessage.value = ''
  isSaving.value = true

  try {
    const res = await updateCustomerProfile({
      office_name: officeName.value,
      address: address.value,
      city: city.value,
      contact_phone: contactPhone.value,
      pic_name: picName.value,
    })
    populateForm(res.data)
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

    <PageHeader :sticky="false" eyebrow="Portal Kantor" title="Profil Kantor">
      <template #title-icon>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 text-primary"><path d="M3 21h18"/><path d="M5 21V7l8-4v18"/><path d="M19 21V11l-6-4"/><path d="M9 9v.01M9 12v.01M9 15v.01M9 18v.01"/></svg>
      </template>
      <CartButton />
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-6 sm:py-16">
      <DoubleBezelCard v-if="isLoading" :animate="false">
        <div class="flex flex-col gap-5">
          <div class="flex items-center gap-4">
            <Skeleton width="4rem" height="4rem" rounded="1.25rem" />
            <div class="flex flex-1 flex-col gap-2">
              <Skeleton width="40%" height="0.875rem" />
              <Skeleton width="60%" height="0.75rem" />
            </div>
          </div>
          <div v-for="i in 5" :key="i" class="flex flex-col gap-1.5">
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
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M5 21V7l8-4v18"/><path d="M19 21V11l-6-4"/></svg>
            Identitas Kantor
          </span>

          <!-- ringkasan identitas -->
          <div class="flex items-center gap-4 rounded-2xl border border-ink/5 bg-card p-4">
            <span
              class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-primary/10 text-primary-dark"
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M5 21V7l8-4v18"/><path d="M19 21V11l-6-4"/><path d="M9 9v.01M9 12v.01M9 15v.01M9 18v.01"/></svg>
            </span>
            <div class="min-w-0 flex-1">
              <p class="truncate font-bold text-ink">{{ officeName || 'Kantor belum diberi nama' }}</p>
              <div class="mt-1 flex flex-wrap items-center gap-x-3 gap-y-0.5 text-xs text-subtle">
                <span v-if="city" class="flex items-center gap-1">
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z"/><circle cx="12" cy="10" r="3"/></svg>
                  {{ city }}
                </span>
                <template v-if="picName">
                  <span class="text-ink/15">|</span>
                  <span class="flex items-center gap-1">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    {{ picName }}
                  </span>
                </template>
              </div>
            </div>
          </div>

          <FormField label="Nama Kantor" :error="errors.office_name?.[0]">
            <template #icon>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M5 21V7l8-4v18"/><path d="M19 21V11l-6-4"/></svg>
            </template>
            <input
              v-model="officeName"
              type="text"
              placeholder="Contoh: PT Maju Jaya"
              class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
            />
          </FormField>

          <FormField label="Alamat Pengiriman" :error="errors.address?.[0]">
            <template #icon>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z"/><circle cx="12" cy="10" r="3"/></svg>
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
              <p v-if="locationError" class="text-xs text-red-600 dark:text-red-400">{{ locationError }}</p>
            </template>
          </FormField>

          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <FormField label="Kota" :error="errors.city?.[0]">
              <template #icon>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z"/><circle cx="12" cy="10" r="3"/></svg>
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
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
              </template>
              <input
                v-model="contactPhone"
                type="text"
                placeholder="08xxxxxxxxxx"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
              />
            </FormField>
          </div>

          <FormField label="Nama PIC (Penanggung Jawab)" :error="errors.pic_name?.[0]">
            <template #icon>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            </template>
            <input
              v-model="picName"
              type="text"
              placeholder="Nama lengkap penanggung jawab"
              class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink placeholder-subtle focus:outline-none focus:ring-2 focus:ring-primary-dark"
            />
          </FormField>

          <p v-if="errorMessage" class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>
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
