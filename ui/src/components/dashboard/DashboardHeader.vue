<template>
  <header class="top-header">
    <div class="header-left">
      <!-- 用户头像菜单 -->
      <div class="user-menu-container">
        <button type="button" class="user-avatar" aria-label="打开用户菜单" @click.stop="toggleUserMenu">
          <svg class="user-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
        </button>

        <!-- 用户菜单弹窗 -->
        <div v-if="showUserMenu" class="user-menu" @click.stop>
          <div class="user-profile" @click="$emit('edit-profile')" role="button" tabindex="0">
            <div class="avatar-large">
              <svg class="user-icon-large" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
            </div>
            <div class="user-details">
              <h3>{{ username }}</h3>
              <p class="user-email">{{ userEmail }}</p>
            </div>
          </div>
          <div class="menu-divider"></div>
          <div class="menu-items">
            <button type="button" class="menu-item" @click="$emit('edit-profile')">
              <span>编辑资料</span>
            </button>
            <button type="button" class="menu-item" @click="$emit('change-password')">
              <span>修改密码</span>
            </button>
          </div>
          <div class="menu-divider"></div>
          <button type="button" class="menu-item logout-item" @click="$emit('logout')">
            <span>退出登录</span>
          </button>
        </div>
      </div>

      <div class="logo">
        <span class="logo-icon">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C7.03 2 3 6.03 3 11c0 4.42 3.13 8.11 7.3 8.86L10 22h4l-.3-2.14C17.87 19.11 21 15.42 21 11c0-4.97-4.03-9-9-9zm-.5 14c-2.76 0-5-2.24-5-5 0-2.24 1.49-4.14 3.54-4.76L9.8 8.6l1.9-.63V6.5h.6c2.76 0 5 2.24 5 5 0 2.24-1.49 4.14-3.54 4.76l.24-2.36-1.9.63v1.47h-.6z"/>
          </svg>
        </span>
        <span class="logo-text">灵素养生平台</span>
      </div>
    </div>

    <div class="header-right">
      <!-- 导航链接 -->
      <nav class="header-nav">
        <a href="#" @click.prevent="$emit('navigate', '/assistant')" class="nav-link">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
          </svg>
          <span>AI助手</span>
        </a>
        <!-- 原有链接保留 -->
        <a href="#" @click.prevent="$emit('navigate', '/products')" class="nav-link">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"/>
          </svg>
          <span>养生商品</span>
        </a>
        <a href="#" @click.prevent="$emit('navigate', '/recipes')" class="nav-link">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2v20M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>
          </svg>
          <span>养生食谱</span>
        </a>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts">
defineOptions({ name: 'DashboardHeader' });

defineProps<{
  username: string;
  userEmail: string;
  showUserMenu: boolean;
}>();

const emit = defineEmits<{
  (e: 'toggle-user-menu'): void;
  (e: 'edit-profile'): void;
  (e: 'change-password'): void;
  (e: 'logout'): void;
  (e: 'navigate', path: string): void;
}>();

function toggleUserMenu() {
  emit('toggle-user-menu');
}
</script>

<style scoped>
/* 顶部导航栏 */
.top-header {
  background: transparent;
  padding: 24px 32px;
  box-shadow: none;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: absolute;
  top: 0;
  width: 100%;
  z-index: 100;
  pointer-events: none;
}

.header-left, .header-right {
  pointer-events: auto;
}

.header-right {
  display: flex;
  align-items: center;
}

.header-nav {
  display: flex;
  gap: 12px;
  align-items: center;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: 99px; /* 胶囊型 -> 大圆角 */
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  color: var(--text-main);
  text-decoration: none;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.nav-link:hover {
  background: white;
  border-color: var(--primary-color);
  color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: var(--shadow-hover);
}

.nav-icon {
  width: 18px;
  height: 18px;
  stroke: var(--primary-color);
}

.header-left {
  display: flex;
  align-items: center;
}

.header-left .logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 22px;
  font-weight: 800;
  color: var(--text-main);
  letter-spacing: -0.5px;
}

.logo-icon {
  width: 32px;
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-dark);
}

.logo-icon svg {
  width: 32px;
  height: 32px;
}

/* 用户菜单 */
.user-menu-container {
  position: relative;
  margin-right: 24px;
}

.user-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 2px solid rgba(255, 255, 255, 0.8);
  padding: 0;
}

.user-avatar:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
  border-color: var(--primary-color);
}

.user-icon {
  width: 20px;
  height: 20px;
  color: var(--text-sub);
}

.user-menu {
  position: absolute;
  top: 56px;
  left: 0;
  width: 280px;
  background: white;
  border-radius: 20px;
  box-shadow: var(--shadow-hover);
  border: 1px solid rgba(0, 0, 0, 0.05);
  z-index: 1000;
  overflow: hidden;
  animation: slideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px) scale(0.98); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.user-profile {
  padding: 24px;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, var(--primary-light) 0%, white 100%);
  cursor: pointer;
  transition: all 0.2s ease;
}

.user-profile:hover {
  filter: brightness(0.98);
}

.avatar-large {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
  border: 2px solid white;
}

.user-icon-large {
  width: 28px;
  height: 28px;
  color: var(--primary-color);
}

.user-details h3 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 700;
  color: var(--text-main);
}

.user-details p.user-email {
  margin: 0;
  font-size: 13px;
  color: var(--text-sub);
}

.menu-divider {
  height: 1px;
  background: #f1f5f9;
  margin: 0;
}

.menu-items {
  padding: 8px;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  margin: 4px;
  border-radius: 12px; /* 圆角菜单项 */
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  color: var(--text-main);
  width: calc(100% - 8px);
  border: 0;
  background: transparent;
  text-align: left;
  font: inherit;
  font-weight: 500;
}

.menu-item:hover {
  background: #f8fafc;
  color: var(--primary-dark);
}

.menu-item:focus-visible,
.user-avatar:focus-visible,
.nav-link:focus-visible {
  outline: 2px solid var(--primary-color);
  outline-offset: 2px;
}

.logout-item {
  color: #ef4444;
}

.logout-item:hover {
  background: #fef2f2;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .top-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
    padding: 16px 20px;
  }

  .header-right {
    width: 100%;
    justify-content: flex-start;
  }
  
  .header-nav {
    width: 100%;
    overflow-x: auto;
    padding-bottom: 4px;
  }
}
</style>
