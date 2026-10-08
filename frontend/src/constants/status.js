// Shared order/invoice status vocab — labels, badge/dot colors, and filter
// lists are identical across customer and merchant views, so every list and
// detail page imports from here instead of redefining its own copy.

export const ORDER_STATUS_LABEL = {
  pending: 'Menunggu',
  confirmed: 'Dikonfirmasi',
  delivered: 'Dikirim',
  completed: 'Selesai',
  cancelled: 'Dibatalkan',
}

export const ORDER_STATUS_CLASS = {
  pending: 'bg-primary/10 text-primary-dark',
  confirmed: 'bg-primary/10 text-primary-dark',
  delivered: 'bg-primary/10 text-primary-dark',
  completed: 'bg-accent/10 text-accent',
  cancelled: 'bg-ink/10 text-subtle',
}

export const ORDER_STATUS_DOT_CLASS = {
  pending: 'bg-primary',
  confirmed: 'bg-primary',
  delivered: 'bg-primary',
  completed: 'bg-accent',
  cancelled: 'bg-ink/30',
}

export const ORDER_STATUS_FILTERS = [
  { value: '', label: 'Semua' },
  { value: 'pending', label: 'Menunggu' },
  { value: 'confirmed', label: 'Dikonfirmasi' },
  { value: 'delivered', label: 'Dikirim' },
  { value: 'completed', label: 'Selesai' },
  { value: 'cancelled', label: 'Dibatalkan' },
]

export const INVOICE_STATUS_LABEL = {
  unpaid: 'Belum Lunas',
  paid: 'Lunas',
  cancelled: 'Dibatalkan',
}

export const INVOICE_STATUS_CLASS = {
  unpaid: 'bg-primary/10 text-primary-dark',
  paid: 'bg-accent/10 text-accent',
  cancelled: 'bg-ink/10 text-subtle',
}

export const INVOICE_STATUS_DOT_CLASS = {
  unpaid: 'bg-primary',
  paid: 'bg-accent',
  cancelled: 'bg-ink/30',
}

export const INVOICE_STATUS_FILTERS = [
  { value: '', label: 'Semua' },
  { value: 'unpaid', label: 'Belum Lunas' },
  { value: 'paid', label: 'Lunas' },
  { value: 'cancelled', label: 'Dibatalkan' },
]
