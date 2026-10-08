import { ref, computed } from 'vue'

const merchant = ref(null)
const items = ref([])
const pendingItem = ref(null)

function commitAddToCart(merchantInfo, menu, quantity) {
  merchant.value = merchantInfo

  const existing = items.value.find((item) => item.menu_id === menu.id)
  if (existing) {
    existing.quantity += quantity
  } else {
    items.value.push({
      menu_id: menu.id,
      name: menu.name,
      price: Number(menu.price),
      quantity,
    })
  }
}

export function addToCart(merchantInfo, menu, quantity = 1) {
  if (merchant.value && merchant.value.id !== merchantInfo.id) {
    pendingItem.value = { merchantInfo, menu, quantity }
    return
  }

  commitAddToCart(merchantInfo, menu, quantity)
}

export function confirmReplaceCart() {
  if (!pendingItem.value) return
  const { merchantInfo, menu, quantity } = pendingItem.value
  items.value = []
  commitAddToCart(merchantInfo, menu, quantity)
  pendingItem.value = null
}

export function cancelReplaceCart() {
  pendingItem.value = null
}

export function updateQuantity(menuId, quantity) {
  const item = items.value.find((i) => i.menu_id === menuId)
  if (!item) return
  if (quantity <= 0) {
    removeFromCart(menuId)
    return
  }
  item.quantity = quantity
}

export function removeFromCart(menuId) {
  items.value = items.value.filter((i) => i.menu_id !== menuId)
  if (items.value.length === 0) merchant.value = null
}

export function clearCart() {
  items.value = []
  merchant.value = null
}

export const cartItems = items
export const cartMerchant = merchant
export const cartPendingItem = pendingItem

export const cartCount = computed(() =>
  items.value.reduce((sum, item) => sum + item.quantity, 0),
)

export const cartTotal = computed(() =>
  items.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
)
