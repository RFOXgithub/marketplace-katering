import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '@/views/auth/LoginView.vue'
import RegisterView from '@/views/auth/RegisterView.vue'
import MerchantDashboardView from '@/views/merchant/DashboardView.vue'
import ProfileView from '@/views/merchant/ProfileView.vue'
import MenuView from '@/views/merchant/MenuView.vue'
import OrderListView from '@/views/merchant/OrderListView.vue'
import OrderDetailView from '@/views/merchant/OrderDetailView.vue'
import InvoiceListView from '@/views/merchant/InvoiceListView.vue'
import InvoiceDetailView from '@/views/merchant/InvoiceDetailView.vue'
import CustomerHomeView from '@/views/customer/HomeView.vue'
import CustomerProfileView from '@/views/customer/ProfileView.vue'
import CateringDetailView from '@/views/customer/CateringDetailView.vue'
import CheckoutView from '@/views/customer/CheckoutView.vue'
import CustomerOrderListView from '@/views/customer/OrderListView.vue'
import CustomerOrderDetailView from '@/views/customer/OrderDetailView.vue'
import CustomerInvoiceListView from '@/views/customer/InvoiceListView.vue'
import CustomerInvoiceDetailView from '@/views/customer/InvoiceDetailView.vue'

import { getToken, getUser } from '@/services/authService'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/login',
    },
    {
      path: '/login',
      component: LoginView,
      meta: { order: 1 },
    },
    {
      path: '/register',
      component: RegisterView,
      meta: { order: 2 },
    },
    {
      path: '/merchant/dashboard',
      component: MerchantDashboardView,
      meta: { order: 3, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/merchant/profile',
      component: ProfileView,
      meta: { order: 4, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/merchant/menus',
      component: MenuView,
      meta: { order: 5, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/merchant/orders',
      component: OrderListView,
      meta: { order: 6, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/merchant/orders/:id',
      component: OrderDetailView,
      meta: { order: 7, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/merchant/invoices',
      component: InvoiceListView,
      meta: { order: 8, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/merchant/invoices/:id',
      component: InvoiceDetailView,
      meta: { order: 9, requiresAuth: true, role: 'merchant' },
    },
    {
      path: '/customer/home',
      component: CustomerHomeView,
      meta: { order: 3, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/customer/profile',
      component: CustomerProfileView,
      meta: { order: 4, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/caterings/:slug',
      component: CateringDetailView,
      meta: { order: 5, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/checkout',
      component: CheckoutView,
      meta: { order: 6, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/customer/orders',
      component: CustomerOrderListView,
      meta: { order: 7, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/customer/orders/:id',
      component: CustomerOrderDetailView,
      meta: { order: 8, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/customer/invoices',
      component: CustomerInvoiceListView,
      meta: { order: 9, requiresAuth: true, role: 'customer' },
    },
    {
      path: '/customer/invoices/:id',
      component: CustomerInvoiceDetailView,
      meta: { order: 10, requiresAuth: true, role: 'customer' },
    },
  ],
})

router.beforeEach((to) => {
  if (!to.meta.requiresAuth) return true

  const token = getToken()
  if (!token) return '/login'

  const user = getUser()
  if (to.meta.role && user?.role !== to.meta.role) return '/login'

  return true
})

export default router
