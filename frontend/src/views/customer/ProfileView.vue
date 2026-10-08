<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCustomerProfile, updateCustomerProfile } from '@/services/customerService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'

const router = useRouter()

const isLoading = ref(true)
const isSaving = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const errors = ref({})

const officeName = ref('')
const address = ref('')
const city = ref('')
const contactPhone = ref('')
const picName = ref('')

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
    const res = await getCustomerProfile()
    populateForm(res.data)
  } catch (e) {
    errorMessage.value = e.message
  } finally {
    isLoading.value = false
  }
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
        <p class="text-xs text-gray-400">Portal Kantor</p>
        <h1 class="text-lg font-bold text-primary">Profil Kantor</h1>
      </div>
      <button
        @click="router.push('/customer/home')"
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
        <div v-for="i in 5" :key="i" class="flex flex-col gap-1.5">
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
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Nama Kantor</label>
          <input
            v-model="officeName"
            type="text"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="errors.office_name" class="text-xs text-red-500">{{ errors.office_name[0] }}</p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Alamat Pengiriman</label>
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
          <label class="text-sm font-medium text-gray-700">Nama PIC (Penanggung Jawab)</label>
          <input
            v-model="picName"
            type="text"
            class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          <p v-if="errors.pic_name" class="text-xs text-red-500">{{ errors.pic_name[0] }}</p>
        </div>

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
