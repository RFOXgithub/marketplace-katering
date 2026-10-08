import { getToken } from './authService'

const API_URL = import.meta.env.VITE_API_URL

async function authRequest(path, options = {}) {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${getToken()}`,
      ...options.headers,
    },
  })

  const data = await res.json()

  if (!res.ok) {
    throw new Error(data.message || 'Terjadi kesalahan')
  }

  return data
}

export function getMenus(query = '') {
  return authRequest(`/merchant/menus${query}`)
}

export function getCategories() {
  return authRequest('/categories')
}

export function createMenu(formData) {
  return authRequest('/merchant/menus', {
    method: 'POST',
    body: formData,
  })
}

export function updateMenu(id, formData) {
  formData.append('_method', 'PUT')
  return authRequest(`/merchant/menus/${id}`, {
    method: 'POST',
    body: formData,
  })
}

export function deleteMenu(id) {
  return authRequest(`/merchant/menus/${id}`, {
    method: 'DELETE',
  })
}
