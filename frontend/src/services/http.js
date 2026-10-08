import router from '@/router'
import { getToken } from './authService'

export const API_URL = import.meta.env.VITE_API_URL
export const STORAGE_URL = API_URL.replace(/\/api\/?$/, '/storage')

export function resolveStorageUrl(path, fallback = null) {
  return path ? `${STORAGE_URL}/${path}` : fallback
}

function handleUnauthorized() {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  if (router.currentRoute.value.path !== '/login') {
    router.push('/login')
  }
}

export async function authFetch(path, options = {}) {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${getToken()}`,
      ...options.headers,
    },
  })

  if (res.status === 401) {
    handleUnauthorized()
    throw new Error('Sesi kamu telah berakhir, silakan login kembali.')
  }

  const data = await res.json()

  if (!res.ok) {
    const error = new Error(data.message || 'Terjadi kesalahan')
    error.errors = data.errors ?? null
    throw error
  }

  return data
}
