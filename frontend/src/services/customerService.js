import { authFetch } from './http'

export function getCustomerProfile() {
  return authFetch('/customer/profile')
}

export function searchCaterings(query = '') {
  return authFetch(`/caterings${query}`)
}

export function getCategories() {
  return authFetch('/categories')
}

export function updateCustomerProfile(payload) {
  return authFetch('/customer/profile', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

export function getCateringDetail(slug) {
  return authFetch(`/caterings/${slug}`)
}

export function createOrder(payload) {
  return authFetch('/customer/orders', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

export function getCustomerOrders(query = '') {
  return authFetch(`/customer/orders${query}`)
}

export function getCustomerOrder(id) {
  return authFetch(`/customer/orders/${id}`)
}

export function cancelCustomerOrder(id) {
  return authFetch(`/customer/orders/${id}/cancel`, {
    method: 'PATCH',
  })
}

export function getCustomerInvoices(query = '') {
  return authFetch(`/customer/invoices${query}`)
}

export function getCustomerInvoice(id) {
  return authFetch(`/customer/invoices/${id}`)
}
