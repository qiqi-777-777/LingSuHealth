<template>
  <div class="dashboard-container">
    <!-- 顶部导航栏 -->
    <header class="top-header">
      <div class="header-left">
        <!-- 用户头像菜单 -->
        <div class="user-menu-container">
          <div class="user-avatar" @click.stop="toggleUserMenu">
            <svg class="user-icon" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
            </svg>
          </div>
          
          <!-- 用户菜单弹窗 -->
          <div v-if="showUserMenu" class="user-menu" @click.stop>
            <div class="user-profile">
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
              <div class="menu-item" @click="editProfile">
                <span>编辑资料</span>
              </div>
              <div class="menu-item" @click="changePassword">
                <span>修改密码</span>
              </div>
            </div>
            <div class="menu-divider"></div>
            <div class="menu-item logout-item" @click="logout">
              <span>退出登录</span>
            </div>
          </div>
        </div>
        
        <div class="logo">
          <span class="logo-icon">🌿</span>
          <span class="logo-text">灵素养生平台</span>
        </div>
      </div>
      
      <div class="header-right">
        <div class="header-actions">
          <button class="header-btn" @click="navigateTo('/dashboard-metrics')">仪表盘</button>
        </div>
      </div>
    </header>

    <!-- 主要内容区域 -->
    <div class="main-layout">
      <!-- 左侧功能模块 -->
      <aside class="left-sidebar">
        <div class="modules-container">
          <!-- 节气养生提醒 -->
          <div class="module-card season-card" @click="navigateTo('/season')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M6.76 4.84l-1.8-1.79-1.41 1.41 1.79 1.79 1.42-1.41zM4 10.5H1v2h3v-2zm9-9.95h-2V3.5h2V.55zm7.45 3.91l-1.41-1.41-1.79 1.79 1.41 1.41 1.79-1.79zm-3.21 13.7l1.79 1.8 1.41-1.41-1.8-1.79-1.4 1.4zM20 10.5v2h3v-2h-3zm-8-5c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6-2.69-6-6-6zm-1 16.95h2V19.5h-2v2.95zm-7.45-3.91l1.41 1.41 1.79-1.8-1.41-1.41-1.79 1.8z"/>
              </svg>
            </div>
            <div class="module-content">
              <h3 class="module-title">节气养生提醒</h3>
              <p class="module-description">顺应自然的养生智慧</p>
            </div>
          </div>

          <!-- 个性化方案 -->
          <div class="module-card plan-card" @click="navigateTo('/plan')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
              </svg>
            </div>
            <div class="module-content">
              <h3 class="module-title">个性化方案</h3>
              <p class="module-description">定制您的养生计划</p>
            </div>
          </div>

          <!-- 养生打卡和反馈 -->
          <div class="module-card checkin-card" @click="navigateTo('/checkin')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
            <div class="module-content">
              <h3 class="module-title">养生打卡和反馈</h3>
              <p class="module-description">记录您的养生进度</p>
            </div>
          </div>

          <!-- AI问答助手 -->
          <div class="module-card assistant-card" @click="navigateTo('/assistant')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 12h-2v-2h2v2zm0-4h-2V6h2v4z"/>
              </svg>
            </div>
            <div class="module-content">
              <h3 class="module-title">AI问答助手</h3>
              <p class="module-description">专业健康咨询服务</p>
            </div>
          </div>
        </div>
      </aside>

      <!-- 右侧主要内容区域 -->
      <main class="main-content">
        <!-- 顶部标语区域 -->
        <div class="hero-section">
          <div class="hero-badge">
            <span class="badge-text">中西融合 · AI驱动</span>
          </div>
          
          <h1 class="hero-title">
            发现您的<br>
            <span class="highlight">养生之道</span>
          </h1>
          
          <p class="hero-description">
            融合现代AI技术与健康大数据，打造您的专属健康养生平台。我们提供个性化健康方案、智能健康评估、四季生活指南、专业营养建议，让科学养生融入日常生活，为您的健康保驾护航。立即开启您的智慧养生之旅！
          </p>
          
          <!-- 体质测评按钮 -->
          <div class="cta-section">
            <button class="assessment-btn" @click="navigateTo('/assessment')">
              开始体质测评 →
            </button>
            <button class="secondary-btn" @click="navigateTo('/knowledge')">
              浏览知识库
            </button>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const showUserMenu = ref(false);
const username = ref('');
const userEmail = ref('');

// 获取用户信息
onMounted(() => {
  username.value = localStorage.getItem('username') || '用户';
  userEmail.value = localStorage.getItem('userEmail') || 'user@example.com';
  
  // 添加全局点击事件监听
  document.addEventListener('click', handleClickOutside);
});

// 组件卸载时移除事件监听
onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});

function navigateTo(path: string) {
  router.push(path);
}

function toggleUserMenu() {
  showUserMenu.value = !showUserMenu.value;
}

function editProfile() {
  showUserMenu.value = false;
  router.push('/profile');
}

function changePassword() {
  showUserMenu.value = false;
  router.push('/change-password');
}

function logout() {
  localStorage.removeItem('token');
  localStorage.removeItem('username');
  localStorage.removeItem('userEmail');
  showUserMenu.value = false;
  router.push('/login');
}

// 点击外部关闭菜单
function handleClickOutside(event: Event) {
  const target = event.target as HTMLElement;
  const userMenuContainer = document.querySelector('.user-menu-container');
  
  if (userMenuContainer && !userMenuContainer.contains(target)) {
    showUserMenu.value = false;
  }
}
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  display: flex;
  flex-direction: column;
}

/* 顶部导航栏 */
.top-header {
  background: white;
  padding: 16px 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-left .logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 20px;
  font-weight: 700;
  color: #2c3e50;
}

.logo-icon {
  font-size: 24px;
}

.header-right .header-actions {
  display: flex;
  gap: 16px;
}

.header-btn {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  color: #495057;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
}

.header-btn:hover {
  background: #ff6b6b;
  color: white;
  border-color: #ff6b6b;
}

/* 用户菜单 */
.user-menu-container {
  position: relative;
  margin-right: 16px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  border: 2px solid #e9ecef;
}

.user-avatar:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  background: #f8f9fa;
}

.user-icon {
  width: 20px;
  height: 20px;
  color: #666;
}

.user-menu {
  position: absolute;
  top: 50px;
  left: 0;
  width: 280px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(0, 0, 0, 0.1);
  z-index: 1000;
  overflow: hidden;
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.user-profile {
  padding: 20px;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
}

.avatar-large {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border: 2px solid #e9ecef;
}

.user-icon-large {
  width: 28px;
  height: 28px;
  color: #666;
}

.user-details h3 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.user-email {
  margin: 0;
  font-size: 14px;
  color: #666;
}

.menu-divider {
  height: 1px;
  background: #e9ecef;
  margin: 0;
}

.menu-items {
  padding: 8px 0;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  cursor: pointer;
  transition: background 0.2s ease;
  font-size: 14px;
  color: #2c3e50;
}

.logout-item {
  color: #e74c3c;
  font-weight: 500;
}

.logout-item:hover {
  background: #fdf2f2;
}

/* 主要布局 */
.main-layout {
  display: flex;
  flex: 1;
  gap: 24px;
  padding: 24px;
}

/* 左侧功能模块 */
.left-sidebar {
  width: 380px;
  background: transparent;
  padding: 0;
  height: fit-content;
}

.modules-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.module-card {
  display: flex;
  align-items: center;
  gap: 16px;
  background: linear-gradient(135deg, #ffeaa7, #fab1a0);
  padding: 20px;
  border-radius: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  margin-bottom: 16px;
}

.module-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

/* 不同模块的渐变色 */
.season-card {
  background: linear-gradient(135deg, #ffeaa7, #fab1a0);
}

.plan-card {
  background: linear-gradient(135deg, #fd79a8, #fdcb6e);
}

.checkin-card {
  background: linear-gradient(135deg, #e17055, #f39c12);
}

.assistant-card {
  background: linear-gradient(135deg, #74b9ff, #0984e3);
}

.module-icon {
  width: 60px;
  height: 60px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.module-icon svg {
  width: 28px;
  height: 28px;
  color: rgba(255, 255, 255, 0.9);
}



.module-content {
  flex: 1;
}

.module-title {
  font-size: 18px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 6px 0;
}

.module-description {
  font-size: 14px;
  color: #636e72;
  margin: 0;
  line-height: 1.4;
}

/* 右侧主要内容区域 */
.main-content {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.hero-section {
  max-width: 600px;
  text-align: left;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 24px;
}

.hero-title {
  font-size: 48px;
  font-weight: 700;
  color: #2c3e50;
  line-height: 1.2;
  margin: 0 0 24px 0;
}

.highlight {
  color: #ff6b6b;
}

.hero-description {
  font-size: 18px;
  color: #6c757d;
  line-height: 1.6;
  margin: 0 0 32px 0;
}

.cta-section {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
}

.assessment-btn {
  background: linear-gradient(135deg, #ff6b6b, #ee5a52);
  color: white;
  border: none;
  padding: 16px 32px;
  border-radius: 25px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.assessment-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 107, 107, 0.4);
}

.secondary-btn {
  background: white;
  color: #6c757d;
  border: 2px solid #e9ecef;
  padding: 14px 28px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.secondary-btn:hover {
  border-color: #ff6b6b;
  color: #ff6b6b;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .main-layout {
    flex-direction: column;
  }
  
  .left-sidebar {
    width: 100%;
  }
  
  .modules-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 16px;
  }
  
  .hero-title {
    font-size: 36px;
  }
}

@media (max-width: 768px) {
  .main-layout {
    padding: 16px;
  }
  
  .cta-section {
    flex-direction: column;
  }
  
  .assessment-btn,
  .secondary-btn {
    text-align: center;
    justify-content: center;
  }
  
  .modules-container {
    grid-template-columns: 1fr;
  }
  
  .header-actions {
    flex-direction: column;
    gap: 8px;
  }
}
</style>