import { authFetch } from './http'

export function getMenus(query = '') {
  return authFetch(`/merchant/menus${query}`)
}

export function createMenu(formData) {
  return authFetch('/merchant/menus', {
    method: 'POST',
    body: formData,
  })
}

export function updateMenu(id, formData) {
  formData.append('_method', 'PUT')
  return authFetch(`/merchant/menus/${id}`, {
    method: 'POST',
    body: formData,
  })
}

export function deleteMenu(id) {
  return authFetch(`/merchant/menus/${id}`, {
    method: 'DELETE',
  })
}
