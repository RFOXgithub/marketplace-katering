import { authFetch } from './http'

// Public reference data used by both the customer and merchant sides of the
// app (city list, menu categories) — kept in one place instead of being
// redefined per role-specific service.

export function getCities() {
  return authFetch('/cities')
}

export function getCategories() {
  return authFetch('/categories')
}
