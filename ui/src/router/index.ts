import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';
import Dashboard from '../views/Dashboard.vue';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: '/dashboard' },
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
    { path: '/products', component: () => import('../views/Products.vue') },
    { path: '/recipes', component: () => import('../views/Recipes.vue') },
  ],
});

// 全局导航守卫 - 检查登录状态
router.beforeEach((to, from, next) => {
  const username = localStorage.getItem('username');
  
  // 如果访问的不是登录页，但没有登录，则跳转到登录页
  if (to.path !== '/login' && !username) {
    next('/login');
  } 
  // 如果已登录且访问登录页，则跳转到首页
  else if (to.path === '/login' && username) {
    next('/dashboard');
  } 
  // 其他情况正常访问
  else {
    next();
  }
});

export default router;
