import { authFetch } from './http'

export function getMerchantProfile() {
  return authFetch('/merchant/profile')
}

export function getCities() {
  return authFetch('/cities')
}

export function getMerchantMenus(query = '') {
  return authFetch(`/merchant/menus${query}`)
}

export function getMerchantOrders(query = '') {
  return authFetch(`/merchant/orders${query}`)
}

export function getMerchantInvoices(query = '') {
  return authFetch(`/merchant/invoices${query}`)
}

export function updateMerchantProfile(formData) {
  formData.append('_method', 'PUT')
  return authFetch('/merchant/profile', {
    method: 'POST',
    body: formData,
  })
}

export function getMerchantOrder(id) {
  return authFetch(`/merchant/orders/${id}`)
}

export function updateMerchantOrderStatus(id, status) {
  return authFetch(`/merchant/orders/${id}/status`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status }),
  })
}

export function getMerchantInvoice(id) {
  return authFetch(`/merchant/invoices/${id}`)
}

export function markInvoicePaid(id) {
  return authFetch(`/merchant/invoices/${id}/paid`, {
    method: 'PATCH',
  })
}
