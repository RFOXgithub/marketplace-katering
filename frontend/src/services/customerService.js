import { getToken } from './authService'

const API_URL = import.meta.env.VITE_API_URL

async function authGet(path) {
  const res = await fetch(`${API_URL}${path}`, {
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${getToken()}`,
    },
  })

  const data = await res.json()

  if (!res.ok) {
    throw new Error(data.message || 'Gagal mengambil data')
  }

  return data
}

export function getCustomerProfile() {
  return authGet('/customer/profile')
}

export function searchCaterings(query = '') {
  return authGet(`/caterings${query}`)
}

export function getCategories() {
  return authGet('/categories')
}
