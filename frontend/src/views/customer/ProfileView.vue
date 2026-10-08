<script setup>
import { ref, onMounted } from 'vue'
import { getCustomerProfile, updateCustomerProfile } from '@/services/customerService'
import Skeleton from '@/components/animations/Skeleton.vue'
import LatticeLoader from '@/components/animations/LatticeLoader.vue'
import CartButton from '@/components/customer/CartButton.vue'
import PageBackground from '@/components/ui/PageBackground.vue'
import PageHeader from '@/components/ui/PageHeader.vue'
import BackButton from '@/components/ui/BackButton.vue'
import DoubleBezelCard from '@/components/ui/DoubleBezelCard.vue'


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
      <CartButton />
      <BackButton to="/customer/home" />
    </PageHeader>

    <main class="relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-6 sm:py-16">
      <DoubleBezelCard v-if="isLoading" :animate="false">
        <div class="flex flex-col gap-5">
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
            class="w-max rounded-full bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-primary-dark"
          >
            Identitas Kantor
          </span>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
              Nama Kantor
            </label>
            <input
              v-model="officeName"
              type="text"
              class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <p v-if="errors.office_name" class="text-xs text-red-600 dark:text-red-400">{{ errors.office_name[0] }}</p>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
              Alamat Pengiriman
            </label>
            <textarea
              v-model="address"
              rows="3"
              class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
            ></textarea>
            <p v-if="errors.address" class="text-xs text-red-600 dark:text-red-400">{{ errors.address[0] }}</p>
          </div>

          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Kota
              </label>
              <input
                v-model="city"
                type="text"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p v-if="errors.city" class="text-xs text-red-600 dark:text-red-400">{{ errors.city[0] }}</p>
            </div>

            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
                Nomor Kontak
              </label>
              <input
                v-model="contactPhone"
                type="text"
                class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <p v-if="errors.contact_phone" class="text-xs text-red-600 dark:text-red-400">
                {{ errors.contact_phone[0] }}
              </p>
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-xs font-medium uppercase tracking-[0.08em] text-subtle">
              Nama PIC (Penanggung Jawab)
            </label>
            <input
              v-model="picName"
              type="text"
              class="rounded-2xl bg-ink/[0.04] px-4 py-2.5 text-sm text-ink focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <p v-if="errors.pic_name" class="text-xs text-red-600 dark:text-red-400">{{ errors.pic_name[0] }}</p>
          </div>

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
