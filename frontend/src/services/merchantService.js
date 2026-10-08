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

export function getMerchantProfile() {
  return authGet('/merchant/profile')
}

export function getMerchantMenus(query = '') {
  return authGet(`/merchant/menus${query}`)
}

export function getMerchantOrders(query = '') {
  return authGet(`/merchant/orders${query}`)
}

export function getMerchantInvoices(query = '') {
  return authGet(`/merchant/invoices${query}`)
}

export async function updateMerchantProfile(formData) {
  formData.append('_method', 'PUT')

  const res = await fetch(`${API_URL}/merchant/profile`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${getToken()}`,
    },
    body: formData,
  })

  const data = await res.json()

  if (!res.ok) {
    throw new Error(data.message || 'Gagal memperbarui profil')
  }

  return data
}

export async function getMerchantOrder(id) {
  return authGet(`/merchant/orders/${id}`)
}

export async function updateMerchantOrderStatus(id, status) {
  const res = await fetch(`${API_URL}/merchant/orders/${id}/status`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      Authorization: `Bearer ${getToken()}`,
    },
    body: JSON.stringify({ status }),
  })

  const data = await res.json()

  if (!res.ok) {
    throw new Error(data.message || 'Gagal memperbarui status')
  }

  return data
}

export async function getMerchantInvoice(id) {
  return authGet(`/merchant/invoices/${id}`)
}

export async function markInvoicePaid(id) {
  const res = await fetch(`${API_URL}/merchant/invoices/${id}/paid`, {
    method: 'PATCH',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${getToken()}`,
    },
  })

  const data = await res.json()

  if (!res.ok) {
    throw new Error(data.message || 'Gagal menandai lunas')
  }

  return data
}
