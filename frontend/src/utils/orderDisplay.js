import { resolveStorageUrl } from '@/services/http'

/**
 * Shared presentation helpers for order list rows, used identically by the
 * customer and merchant order lists.
 */

export function getOrderMenuSummary(order) {
  const items = order.items ?? []
  if (!items.length) return order.notes ?? ''
  const names = items.map((i) => i.menu_name).filter(Boolean)
  if (!names.length) return order.notes ?? ''
  const joined = names.join(', ')
  return joined.charAt(0).toUpperCase() + joined.slice(1) + '.'
}

export function getOrderThumbnail(order) {
  const items = order.items ?? []
  for (const item of items) {
    if (item.menu?.photo_path) return resolveStorageUrl(item.menu.photo_path)
  }
  return null
}

export function getOrderTotalPax(order) {
  const items = order.items ?? []
  if (!items.length) return order.pax_count ?? null
  return items.reduce((sum, i) => sum + (i.quantity ?? 0), 0) || null
}
