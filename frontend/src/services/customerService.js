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
