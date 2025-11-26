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
        <!-- 顶部导航模块 -->
        <nav class="top-nav-modules">
          <button class="nav-module-btn" @click="navigateTo('/assistant')">
            <span>AI助手</span>
          </button>
          <button class="nav-module-btn" @click="navigateTo('/assessment')">
            <span>测评</span>
          </button>
          <button class="nav-module-btn" @click="navigateTo('/season')">
            <span>节气养生</span>
          </button>
          <button class="nav-module-btn" @click="navigateTo('/dashboard-metrics')">
            <span>仪表盘</span>
          </button>
        </nav>
      </div>
    </header>

    <!-- 主要内容区域 -->
    <main class="main-content">
      <!-- 大标题区域 -->
      <section class="hero-section">
        <h1 class="hero-main-title">
          DISCOVER YOUR WELLNESS
        </h1>
        <h2 class="hero-sub-title">
          发现你的养生之道
        </h2>
      </section>

      <!-- 滚动提示 -->
      <div class="scroll-hint">
        <p>往下滑，了解平台介绍</p>
      </div>

      <!-- 功能卡片 -->
      <section class="cards-section">
        <div class="cards-grid">
          <!-- 知识库 -->
          <div class="module-card season-card" @click="navigateTo('/knowledge')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 6.253v13m0-13C6.5 6.253 2 10.753 2 16.253s4.5 10 10 10 10-4.5 10-10-4.5-10-10-10z"/>
              </svg>
            </div>
            <h3 class="module-title">知识库</h3>
            <p class="module-description">食材药材知识库</p>
          </div>

          <!-- 个性化方案 -->
          <div class="module-card plan-card" @click="navigateTo('/plan')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
              </svg>
            </div>
            <h3 class="module-title">个性化方案</h3>
            <p class="module-description">定制您的养生计划</p>
          </div>

          <!-- 养生记录和反馈 -->
          <div class="module-card checkin-card" @click="navigateTo('/checkin')">
            <div class="module-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
            <h3 class="module-title">养生记录和反馈</h3>
            <p class="module-description">记录您的养生进度</p>
          </div>
        </div>

        <!-- 左下角介绍文字 -->
        <div class="bottom-description">
          <h3 class="description-title">开启智能养生新时代</h3>
          <p class="description-text">
            融合<span class="highlight">现代AI技术</span>与<span class="highlight">传统中医智慧</span>，
            基于<span class="highlight">海量健康数据</span>与<span class="highlight">专业医学知识</span>，
            为您量身定制专属养生方案。
          </p>
          <p class="description-text">
            从<span class="highlight">体质评估</span>到<span class="highlight">个性化建议</span>，
            从<span class="highlight">节气养生</span>到<span class="highlight">日常记录</span>，
            让科学养生真正融入您的生活。
          </p>
        </div>
      </section>

      <!-- 黑色框框区域 -->
      <section class="dark-section">
        <div class="dark-content">
          <div class="dark-left">
            <h2 class="dark-title">开启您的养生之旅</h2>
            <p class="dark-description">
              科学的养生方法不仅能改善身体状况，更能提升生活质量。通过我们的平台，您将获得：
            </p>
            <ul class="dark-features">
              <li>个性化的健康方案定制</li>
              <li>AI驱动的智能健康评估</li>
              <li>四季养生生活指南</li>
              <li>专业的营养建议支持</li>
            </ul>
          </div>
          <div class="dark-right">
            <div class="platform-intro">
              <h3 class="intro-title">为什么选择灵素？</h3>
              <div class="intro-reasons">
                <div class="reason-item">
                  <div class="reason-content">
                    <h4>传统与科技的完美融合</h4>
                    <p>结合千年中医养生智慧与现代AI技术，为您量身定制健康方案</p>
                  </div>
                </div>
                <div class="reason-item">
                  <div class="reason-content">
                    <h4>精准的个性化服务</h4>
                    <p>根据您的体质、生活习惯和健康目标，提供专属的养生建议</p>
                  </div>
                </div>
                <div class="reason-item">
                  <div class="reason-content">
                    <h4>简单易行的养生方式</h4>
                    <p>不需要复杂的操作，让健康养生融入您的日常生活</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="dark-footer">
          <div class="footer-line"></div>
          <div class="mission-statement">
            <p class="mission-text-cn">我们不是要帮你活到120岁，只是让你在40岁时，依然拥有25岁的身体自主权。</p>
            <p class="mission-text-en">We're not here to help you live to 120, just to keep you feeling 25 when you're 40.</p>
          </div>
        </div>
      </section>

      <!-- 欢迎区域 - 空白区域 -->
      <section class="welcome-section">
        <div class="welcome-content">
          <h2 class="welcome-title">欢迎使用灵素健康养生平台</h2>
          <p class="welcome-subtitle">请点击卡片开始体验</p>
        </div>
      </section>
    </main>

    <!-- 浮动笑脸挂件 -->
    <div class="floating-widget">
      <div class="smile-face" @click="showContextMenu" @contextmenu.prevent="showContextMenu">
        <div class="eye-container left-eye-container">
          <div class="eye-white"></div>
          <div class="eyelid top-eyelid"></div>
        </div>
        <div class="eye-container right-eye-container">
          <div class="eye-white"></div>
          <div class="eyelid top-eyelid"></div>
        </div>
      </div>

      <!-- 右键菜单 -->
      <div v-if="showMenu" class="context-menu" :style="{ top: menuPosition.y + 'px', left: menuPosition.x + 'px' }">
        <div class="menu-item" @click="handleMenuAction('assistant')">
          <svg class="menu-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
          </svg>
          <span>询问灵素小助手</span>
        </div>
        <div class="menu-item" @click="handleMenuAction('season')">
          <svg class="menu-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
          </svg>
          <span>开启节气提醒</span>
        </div>
        <div class="menu-item" @click="handleMenuAction('assessment')">
          <svg class="menu-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
          </svg>
          <span>进入健康测评</span>
        </div>
        <div class="menu-item" @click="handleMenuAction('knowledge')">
          <svg class="menu-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 4h5v8l-2.5-1.5L6 12V4z"/>
          </svg>
          <span>知识库</span>
        </div>
        <div class="menu-item" @click="handleMenuAction('metrics')">
          <svg class="menu-icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zM9 17H7v-7h2v7zm4 0h-2V7h2v10zm4 0h-2v-4h2v4z"/>
          </svg>
          <span>仪表盘</span>
        </div>
      </div>
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

// 右键菜单相关
const showMenu = ref(false);
const menuPosition = ref({ x: 0, y: 0 });

// 显示右键菜单
function showContextMenu(event: MouseEvent) {
  event.preventDefault();
  showMenu.value = true;
  
  // 计算菜单位置（相对于笑脸挂件）
  const widget = document.querySelector('.floating-widget') as HTMLElement;
  if (widget) {
    const widgetRect = widget.getBoundingClientRect();
    menuPosition.value = {
      x: -180, // 菜单显示在笑脸左侧
      y: -100  // 稍微向上偏移
    };
  }
}

// 处理菜单项点击
function handleMenuAction(action: string) {
  showMenu.value = false;
  
  switch(action) {
    case 'assistant':
      router.push('/assistant');
      break;
    case 'season':
      router.push('/season');
      break;
    case 'assessment':
      router.push('/assessment');
      break;
    case 'knowledge':
      router.push('/knowledge');
      break;
    case 'metrics':
      router.push('/dashboard-metrics');
      break;
  }
}

// 点击外部关闭菜单
function handleClickOutsideMenu(event: MouseEvent) {
  const menu = document.querySelector('.context-menu');
  const smileFace = document.querySelector('.smile-face');
  
  if (menu && !menu.contains(event.target as Node) && 
      smileFace && !smileFace.contains(event.target as Node)) {
    showMenu.value = false;
  }
}

// 滚动效果 - 卡片连续动画：下滑、聚拢、再分开（黑色区域遮挡中间部分）
let animationFrameId: any;
function handleScroll() {
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }

  animationFrameId = requestAnimationFrame(() => {
    const cards = document.querySelectorAll('.module-card');
    const modulesSection = document.querySelector('.cards-section');
    const darkSection = document.querySelector('.dark-section');

    if (!darkSection || !modulesSection || cards.length === 0) return;

    const darkRect = darkSection.getBoundingClientRect();
    const modulesRect = modulesSection.getBoundingClientRect();
    const windowHeight = window.innerHeight;

    // 只有在页面完全在顶部时（scrollY = 0）才强制恢复卡片状态
    if (window.scrollY === 0) {
      cards.forEach((card) => {
        const element = card as HTMLElement;
        // 完全移除style属性，让卡片恢复到CSS定义的初始状态
        element.removeAttribute('style');
      });
      return;
    }

    // 计算滚动进度：提前触发动画，从用户开始滚动就开始
    // 动画起点：黑色区域距离视口底部还有一定距离时就开始
    const animationStart = windowHeight + 100; // 黑色区域距离视口底部100px时开始（减少提前量）
    const animationEnd = -darkRect.height;      // 黑色区域完全离开视口

    let progress = 0;
    if (darkRect.top < animationStart) {
      progress = (animationStart - darkRect.top) / (animationStart - animationEnd);
      progress = Math.max(0, Math.min(1, progress));
    }

    cards.forEach((card, index) => {
      const element = card as HTMLElement;

      // === 连续动画分三段 ===
      // 0-0.3: 向下滑动并聚拢
      // 0.3-0.6: 保持聚拢继续向下（被黑色区域遮挡）
      // 0.6-1.0: 从底部出现并分开

      // 水平偏移：聚拢和分开
      const mergeOffset = 80; // 从140减少到80，让聚拢距离更短
      let offsetX = 0;

      if (index !== 1) { // 左右卡片
        if (progress < 0.3) {
          // 阶段1：逐渐聚拢 (0 -> mergeOffset)
          const mergeProgress = progress / 0.3;
          offsetX = index === 0 ? mergeOffset * mergeProgress : -mergeOffset * mergeProgress;
        } else if (progress < 0.6) {
          // 阶段2：保持聚拢
          offsetX = index === 0 ? mergeOffset : -mergeOffset;
        } else {
          // 阶段3：逐渐分开 (mergeOffset -> 0)
          const separateProgress = (progress - 0.6) / 0.4;
          const easeProgress = separateProgress * (2 - separateProgress); // easeOutQuad
          offsetX = index === 0 ? mergeOffset * (1 - easeProgress) : -mergeOffset * (1 - easeProgress);
        }
      }

      // 缩放：先缩小再恢复
      let scale = 1;
      if (progress < 0.5) {
        scale = 1 - 0.2 * (progress / 0.5);
      } else {
        scale = 0.8 + 0.2 * ((progress - 0.5) / 0.5);
      }

      // 垂直偏移：连续向下滑动
      // 计算滑动距离：从卡片原位置到欢迎区域中间
      const welcomeSection = document.querySelector('.welcome-section');
      if (welcomeSection) {
        const welcomeRect = welcomeSection.getBoundingClientRect();
        const distanceToWelcome = welcomeRect.top - modulesSection.getBoundingClientRect().top;
        const totalSlideDistance = distanceToWelcome + 150; // 减少到150px，让滑动距离更短
        const offsetY = totalSlideDistance * progress;
        element.style.transform = `translateX(${offsetX}px) translateY(${offsetY}px) scale(${scale})`;
      } else {
        const distanceToDarkBottom = darkRect.bottom - modulesSection.getBoundingClientRect().top;
        const totalSlideDistance = distanceToDarkBottom + windowHeight * 0.2; // 减少到0.2，让滑动距离更短
        const offsetY = totalSlideDistance * progress;
        element.style.transform = `translateX(${offsetX}px) translateY(${offsetY}px) scale(${scale})`;
      }

      // 透明度：聚拢时变浅，分开时恢复
      let opacity = 1;
      if (progress < 0.3) {
        // 阶段1：逐渐变浅 (1 -> 0.3)
        opacity = 1 - 0.7 * (progress / 0.3);
      } else if (progress < 0.6) {
        // 阶段2：保持半透明
        opacity = 0.3;
      } else {
        // 阶段3：逐渐恢复 (0.3 -> 1)
        const recoverProgress = (progress - 0.6) / 0.4;
        opacity = 0.3 + 0.7 * recoverProgress;
      }

      element.style.opacity = opacity.toString();
      element.style.zIndex = '5'; // 低于黑色区域(z-index:10)，会被遮挡

      // 点击控制：只有透明度为1时才允许点击
      if (opacity >= 0.99) {
        element.style.pointerEvents = 'auto';
        element.style.cursor = 'pointer';
      } else {
        element.style.pointerEvents = 'none';
        element.style.cursor = 'default';
      }
    });
  });
}

// 眼球动画相关
let eyeAnimationTimer: any = null;

// 眼球运动函数
function moveEyes(direction: string) {
  const eyes = document.querySelectorAll('.eye-white');
  
  eyes.forEach((eye) => {
    const element = eye as HTMLElement;
    
    switch(direction) {
      case 'up':
        element.style.transform = 'translate(0, -7px)';
        break;
      case 'right-up':
        element.style.transform = 'translate(6px, -7px)';
        break;
      case 'left-up':
        element.style.transform = 'translate(-6px, -7px)';
        break;
      case 'right':
        element.style.transform = 'translate(6px, 0)';
        break;
      case 'left':
        element.style.transform = 'translate(-6px, 0)';
        break;
      case 'down':
        element.style.transform = 'translate(0, 3px)';
        break;
      case 'center':
      default:
        element.style.transform = 'translate(0, 0)';
        break;
    }
  });
}

// 眨眼函数
function blink() {
  const eyelids = document.querySelectorAll('.eyelid');
  
  eyelids.forEach((eyelid) => {
    const element = eyelid as HTMLElement;
    // 闭眼
    element.style.height = '100%';
  });
  
  // 150ms后睁眼
  setTimeout(() => {
    eyelids.forEach((eyelid) => {
      const element = eyelid as HTMLElement;
      element.style.height = '0';
    });
  }, 150);
}

// 随机眼球动画
function randomEyeAnimation() {
  const actions = [
    () => {
      // 回到中心并眨眼
      moveEyes('center');
      setTimeout(() => blink(), 300);
    },
    () => {
      // 看上
      moveEyes('up');
      setTimeout(() => moveEyes('center'), 1200);
    },
    () => {
      // 看右上
      moveEyes('right-up');
      setTimeout(() => moveEyes('center'), 1200);
    },
    () => {
      // 看左上
      moveEyes('left-up');
      setTimeout(() => moveEyes('center'), 1200);
    },
    () => {
      // 看右
      moveEyes('right');
      setTimeout(() => moveEyes('center'), 1000);
    },
    () => {
      // 看左
      moveEyes('left');
      setTimeout(() => moveEyes('center'), 1000);
    },
    () => {
      // 看某个方向，回到中心，然后眨眼
      const directions = ['up', 'right-up', 'left-up', 'right', 'left'] as const;
      const dir = directions[Math.floor(Math.random() * directions.length)] as string;
      moveEyes(dir);
      setTimeout(() => moveEyes('center'), 800);
      setTimeout(() => blink(), 1200);
    }
  ];
  
  // 随机选择一个动作
  const randomAction = actions[Math.floor(Math.random() * actions.length)];
  if (randomAction) {
    randomAction();
  }
  
  // 设置下一次动画（2-5秒后）
  const nextDelay = 2000 + Math.random() * 3000;
  eyeAnimationTimer = setTimeout(randomEyeAnimation, nextDelay);
}

// 获取用户信息
onMounted(() => {
  username.value = localStorage.getItem('username') || '用户';
  userEmail.value = localStorage.getItem('userEmail') || 'user@example.com';

  // 添加全局点击事件监听
  document.addEventListener('click', handleClickOutside);
  document.addEventListener('click', handleClickOutsideMenu);
  // 添加滚动事件监听
  window.addEventListener('scroll', handleScroll);
  
  // 立即执行一次，初始化卡片状态
  setTimeout(() => {
    handleScroll();
  }, 100);
  
  // 启动眼球动画（1秒后开始）
  setTimeout(() => {
    randomEyeAnimation();
  }, 1000);
});

// 组件卸载时移除事件监听
onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
  document.removeEventListener('click', handleClickOutsideMenu);
  window.removeEventListener('scroll', handleScroll);
  
  // 清除眼球动画定时器
  if (eyeAnimationTimer) {
    clearTimeout(eyeAnimationTimer);
  }
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
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
  display: flex;
  flex-direction: column;
}

/* 顶部导航栏 */
.top-header {
  background: linear-gradient(135deg, #fff9f0 0%, #fff5e8 100%);
  padding: 16px 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
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

/* 主要内容 */
.main-content {
  flex: 1;
  padding: 60px 40px 40px 40px;
  max-width: 1600px;
  margin: 0 auto;
  width: 100%;
  position: relative;
  min-height: 100vh;
}

/* 顶部导航模块 */
.top-nav-modules {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
}

.nav-module-btn {
  background: #000;
  color: #fff;
  border: none;
  border-radius: 25px;
  padding: 10px 24px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
}

.nav-module-btn:hover {
  background: #333;
  transform: translateY(-2px);
}

/* 滚动提示 */
.scroll-hint {
  text-align: center;
  margin-bottom: 30px;
}

.scroll-hint p {
  font-size: 20px;
  color: #666;
  margin: 0;
  font-weight: 500;
  letter-spacing: 1px;
}

/* 英雄区域 - 大标题 */
.hero-section {
  text-align: center;
  margin-bottom: 40px;
}

.hero-main-title {
  font-size: 120px;
  font-weight: 900;
  color: #000;
  margin: 0;
  line-height: 1;
  letter-spacing: -2px;
  text-transform: uppercase;
}

.hero-sub-title {
  font-size: 36px;
  font-weight: 600;
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 24px 0 0 0;
  letter-spacing: 4px;
  text-shadow: 0 2px 10px rgba(46, 204, 113, 0.2);
  position: relative;
}

/* 卡片区域 */
.cards-section {
  position: relative;
  display: flex;
  justify-content: center;
  margin-bottom: 200px;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

.cards-grid {
  display: flex;
  gap: 30px;
  justify-content: center;
}

.module-card {
  width: 220px;
  height: 280px;
  border-radius: 20px;
  padding: 30px 20px;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  position: relative;
  border: none;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  backdrop-filter: blur(10px);
}

.module-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.2);
}

.module-icon {
  width: 70px;
  height: 70px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 32px;
  background: rgba(0, 0, 0, 0.85);
  margin-bottom: 16px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.module-card:hover .module-icon {
  transform: scale(1.1) rotate(5deg);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25);
}

.module-icon svg {
  width: 36px;
  height: 36px;
  color: #fff;
}

.module-title {
  font-size: 15px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 6px 0;
  letter-spacing: 0.3px;
}

.module-description {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.65);
  margin: 0;
  line-height: 1.4;
}

.season-card {
  background: linear-gradient(135deg, #ffccbc 0%, #ffab91 100%);
  border: 2px solid rgba(255, 171, 145, 0.5);
}

.plan-card {
  background: linear-gradient(135deg, #ffe0b2 0%, #ffcc80 100%);
  border: 2px solid rgba(255, 204, 128, 0.5);
}

.checkin-card {
  background: linear-gradient(135deg, #fff9c4 0%, #fff59d 100%);
  border: 2px solid rgba(255, 245, 157, 0.5);
}

/* 底部描述文字 */
.bottom-description {
  position: absolute;
  bottom: -20px;
  left: -220px;
  max-width: 450px;
}

.description-title {
  font-size: 28px;
  font-weight: 800;
  color: #000;
  margin: 0 0 24px 0;
  letter-spacing: -0.5px;
  line-height: 1.3;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
}

.description-text {
  font-size: 16px;
  line-height: 2;
  color: #555;
  margin: 0 0 14px 0;
  font-weight: 400;
  letter-spacing: 0.3px;
}

.description-text:last-child {
  margin-bottom: 0;
}

.description-text .highlight {
  color: #000;
  font-weight: 700;
  position: relative;
  display: inline-block;
}

/* 黑色框框区域 */
.dark-section {
  position: relative;
  z-index: 10; /* 确保黑色区域在卡片之上，用来遮挡卡片 */
  background: linear-gradient(135deg, #3e2723 0%, #4e342e 100%);
  margin: -100px -40px -60px -40px; /* 负margin让黑色区域向上移，覆盖卡片区域 */
  padding: 60px 40px 160px 40px; /* 增加底部padding，为卡片滑出留出空间 */
  border-radius: 0;
}

.dark-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 60px;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
}

.dark-left {
  color: white;
}

.dark-title {
  font-size: 36px;
  font-weight: 800;
  color: white;
  margin: 0 0 24px 0;
  line-height: 1.3;
}

.dark-description {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.7);
  margin: 0 0 24px 0;
  line-height: 1.8;
}

.dark-features {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.dark-features li {
  font-size: 15px;
  color: rgba(255, 255, 255, 0.8);
  padding-left: 24px;
  position: relative;
}

.dark-features li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #4CAF50;
  font-weight: bold;
  font-size: 18px;
}

.mission-statement {
  margin-top: 40px;
  padding: 0 40px 40px 40px;
  text-align: center;
}

.mission-text-cn {
  font-size: 20px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.95);
  line-height: 1.8;
  margin: 0 0 12px 0;
  letter-spacing: 0.5px;
}

.mission-text-en {
  font-size: 15px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.65);
  line-height: 1.6;
  margin: 0;
  font-style: italic;
  letter-spacing: 0.3px;
}

.dark-right {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 平台介绍 */
.platform-intro {
  padding: 20px;
}

.intro-title {
  font-size: 28px;
  font-weight: 700;
  color: #fff;
  margin: 0 0 32px 0;
  letter-spacing: 2px;
  text-align: center;
}

.intro-reasons {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.reason-item {
  padding-left: 0;
}

.reason-content h4 {
  font-size: 18px;
  font-weight: 600;
  color: #fff;
  margin: 0 0 8px 0;
}

.reason-content p {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.8);
  line-height: 1.6;
  margin: 0;
}

.dark-footer {
  margin-top: 60px;
  padding-top: 40px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.footer-line {
  height: 2px;
  background: linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.3) 50%, transparent 100%);
  width: 100%;
}

/* 服务展示区域 */
.service-section {
  padding: 80px 40px;
  background: linear-gradient(135deg, #fff8f0 0%, #ffe8d6 100%);
}

.service-header {
  text-align: center;
  margin-bottom: 60px;
}

.service-title {
  font-size: 40px;
  font-weight: 800;
  color: #1a1a1a;
  margin: 0 0 16px 0;
}

.service-subtitle {
  font-size: 18px;
  color: #666;
  margin: 0;
}

.service-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 80px;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
}

.service-left {
  color: #333;
}

.service-heading {
  font-size: 32px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 20px 0;
}

.service-text {
  font-size: 16px;
  color: #666;
  line-height: 1.8;
  margin: 0;
}

.service-right {
  display: flex;
  justify-content: center;
  align-items: center;
}

.service-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  perspective: 1000px;
}

.service-card {
  background: white;
  border-radius: 16px;
  padding: 40px 24px;
  text-align: center;
  cursor: default;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
  position: relative;
  transform-style: preserve-3d;
}

.service-card:hover {
  transform: translateY(-8px) rotateX(5deg);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.15);
}

.card-1 {
  background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
  border-left: 4px solid #ff9800;
}

.card-2 {
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  border-left: 4px solid #ef5350;
}

.card-3 {
  background: linear-gradient(135deg, #fff8e1 0%, #ffecb3 100%);
  border-left: 4px solid #ffa726;
}

.card-label {
  font-size: 14px;
  font-weight: 700;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 16px;
}

.card-icon {
  font-size: 48px;
  margin-bottom: 12px;
  display: inline-block;
}

/* 浮动笑脸挂件 */
.floating-widget {
  position: fixed;
  right: 40px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 100;
  transition: top 0.3s ease;
}

.smile-face {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, #4a9ff5 0%, #1e88e5 100%);
  box-shadow: 0 8px 32px rgba(74, 159, 245, 0.4),
              inset 0 -8px 16px rgba(0, 0, 0, 0.1),
              inset 0 2px 8px rgba(255, 255, 255, 0.3);
  position: relative;
  animation: float 3s ease-in-out infinite;
  overflow: hidden;
  cursor: pointer;
  user-select: none;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
}

/* 右键菜单 */
.context-menu {
  position: absolute;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2),
              0 0 0 1px rgba(0, 0, 0, 0.05);
  padding: 8px;
  min-width: 200px;
  z-index: 1000;
  animation: menuFadeIn 0.2s ease;
}

@keyframes menuFadeIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.context-menu .menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #333;
  font-size: 14px;
  font-weight: 500;
  user-select: none;
}

.context-menu .menu-item:hover {
  background: rgba(74, 159, 245, 0.1);
  color: #1e88e5;
}

.context-menu .menu-item .menu-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.context-menu .menu-item span {
  flex: 1;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

/* 眼睛容器 */
.eye-container {
  position: absolute;
  width: 14px;
  height: 28px;
  top: 15px;
  overflow: visible;
}

.left-eye-container {
  left: 22px;
}

.right-eye-container {
  right: 22px;
}

/* 眼白 */
.eye-white {
  width: 12px;
  height: 18px;
  background: white;
  border-radius: 50%;
  position: absolute;
  top: 5px;
  left: 1px;
  transition: transform 0.3s ease;
}

/* 眼睑（用于眨眼） */
.eyelid {
  position: absolute;
  width: 100%;
  height: 0;
  background: #1e88e5;
  top: 0;
  left: 0;
  border-radius: 0 0 50% 50%;
  transition: height 0.15s ease;
  z-index: 3;
  pointer-events: none;
}

/* 笑脸在鼠标悬停时有反应 */
.smile-face:hover {
  animation: bounce 0.5s ease;
}

@keyframes bounce {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .floating-widget {
    right: 15px;
  }
  
  .smile-face {
    width: 60px;
    height: 60px;
  }
  
  .eye-container {
    width: 11px;
    height: 22px;
    top: 12px;
  }
  
  .left-eye-container {
    left: 17px;
  }
  
  .right-eye-container {
    right: 17px;
  }
  
  .eye-white {
    width: 9px;
    height: 14px;
    top: 4px;
    left: 1px;
  }

  .context-menu {
    min-width: 180px;
    font-size: 13px;
  }
  
  .context-menu .menu-item {
    padding: 10px 12px;
  }
  
  .context-menu .menu-item .menu-icon {
    width: 18px;
    height: 18px;
  }

  .top-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }

  .header-right {
    width: 100%;
  }

  .main-content {
    padding: 20px;
  }

  .top-nav-modules {
    gap: 8px;
    flex-wrap: wrap;
    width: 100%;
    justify-content: flex-start;
  }

  .nav-module-btn {
    font-size: 11px;
    padding: 8px 16px;
  }

  .hero-main-title {
    font-size: 48px;
    letter-spacing: -1px;
  }

  .hero-sub-title {
    font-size: 24px;
    letter-spacing: 2px;
  }

  .scroll-hint p {
    font-size: 16px;
  }

  .cards-section {
    max-width: 100%;
    padding: 0 20px;
  }

  .cards-grid {
    flex-direction: column;
    gap: 20px;
  }

  .module-card {
    width: 100%;
    max-width: 280px;
    height: 260px;
    margin: 0 auto;
  }

  .bottom-description {
    position: static;
    margin: 30px 0;
    max-width: 100%;
  }

  .dark-section {
    margin: 60px -20px -40px -20px;
    padding: 40px 20px;
  }

  .dark-content {
    grid-template-columns: 1fr;
    gap: 40px;
  }

  .dark-title {
    font-size: 28px;
  }

  .intro-title {
    font-size: 22px;
    margin-bottom: 24px;
  }

  .intro-reasons {
    gap: 20px;
  }

  .reason-content h4 {
    font-size: 16px;
  }

  .reason-content p {
    font-size: 13px;
  }
}

/* 欢迎区域 - 空白区域 */
.welcome-section {
  padding: 60px 40px;
  background: transparent;
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 200px;
}

.welcome-content {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  height: 100%;
  gap: 0;
}

.welcome-title {
  font-size: 28px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 600px 0; /* 减少底部间距，让第二句话向上移动 */
  text-align: center;
}

.welcome-subtitle {
  font-size: 16px;
  color: #666;
  margin: 0;
  text-align: center;
}

@media (max-width: 768px) {
  .welcome-section {
    padding: 40px 20px;
    min-height: 150px;
  }

  .welcome-title {
    font-size: 20px;
  }
}
</style>
