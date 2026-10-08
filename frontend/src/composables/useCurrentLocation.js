import { ref } from 'vue'
import { reverseGeocode } from '@/services/geocodingService'

const DEFAULT_MESSAGES = {
  unsupported: 'Browser kamu tidak mendukung deteksi lokasi.',
  geocodeFailed: 'Gagal mengambil nama alamat. Koordinat tetap disimpan manual.',
  permissionDenied: 'Izin lokasi ditolak. Kamu masih bisa mengisi alamat secara manual.',
  locateFailed: 'Gagal mendapatkan lokasi. Coba lagi atau isi alamat secara manual.',
}

/**
 * Wraps the browser geolocation + reverse-geocoding flow shared by every
 * "Gunakan Lokasi Saat Ini" button in the app (Checkout, customer and
 * merchant profile forms).
 */
export function useCurrentLocation(messageOverrides = {}) {
  const messages = { ...DEFAULT_MESSAGES, ...messageOverrides }
  const isLocating = ref(false)
  const locationError = ref('')

  function locate({ onResolved, onFallback }) {
    locationError.value = ''

    if (!navigator.geolocation) {
      locationError.value = messages.unsupported
      return
    }

    isLocating.value = true

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords
        try {
          const data = await reverseGeocode(latitude, longitude)
          const address = data.display_name ?? `${latitude}, ${longitude}`
          onResolved(address, data.address ?? {})
        } catch {
          locationError.value = messages.geocodeFailed
          onFallback?.(`${latitude}, ${longitude}`)
        } finally {
          isLocating.value = false
        }
      },
      (error) => {
        isLocating.value = false
        locationError.value =
          error.code === error.PERMISSION_DENIED ? messages.permissionDenied : messages.locateFailed
      },
    )
  }

  return { isLocating, locationError, locate }
}
