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
