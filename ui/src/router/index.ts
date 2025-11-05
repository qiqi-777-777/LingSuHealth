import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';
import Dashboard from '../views/Dashboard.vue';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: '/login' },
    { path: '/login', name: 'Login', component: Login },
    { path: '/dashboard', name: 'Dashboard', component: Dashboard },
    { path: '/dashboard-metrics', component: () => import('../views/DashboardMetrics.vue') },
    { path: '/assessment', component: () => import('../views/Assessment.vue') },
    { path: '/plan', component: () => import('../views/Plan.vue') },
    { path: '/checkin', component: () => import('../views/Checkin.vue') },
    { path: '/knowledge', component: () => import('../views/Knowledge.vue') },
    { path: '/assistant', component: () => import('../views/Assistant.vue') },
    { path: '/season', component: () => import('../views/Season.vue') },
    { path: '/profile', component: () => import('../views/Profile.vue') },
    { path: '/change-password', component: () => import('../views/ChangePassword.vue') },
  ],
});

export default router;
