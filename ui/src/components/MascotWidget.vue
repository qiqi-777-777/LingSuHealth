<template>
  <div class="mascot-widget" ref="widgetRef">
    <!-- 角色主体 -->
    <div
      class="mascot-character"
      :class="{ 'is-active': showMenu }"
      @click="toggleMenu"
      @contextmenu.prevent="toggleMenu"
      role="button"
      tabindex="0"
      @keydown.enter="toggleMenu"
      @keydown.space.prevent="toggleMenu"
    >
      <!-- 灵素小精灵 SVG -->
      <svg viewBox="0 0 200 200" class="character-svg">
        <defs>
          <linearGradient id="bodyGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stop-color="#ffffff" />
            <stop offset="100%" stop-color="#ecfdf5" />
          </linearGradient>
          <linearGradient id="leafGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#34d399" />
            <stop offset="100%" stop-color="#059669" />
          </linearGradient>
          <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="3" result="coloredBlur" />
            <feMerge>
              <feMergeNode in="coloredBlur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        <!-- 阴影 -->
        <ellipse cx="100" cy="185" rx="50" ry="8" fill="rgba(16, 185, 129, 0.1)" class="shadow-pulse" />

        <!-- 身体 (圆润的灵体) -->
        <g class="body-group" transform="translate(0, 5)">
           <!-- 主体 -->
           <path d="M100 40
                    C 150 40, 180 80, 180 130
                    C 180 170, 150 190, 100 190
                    C 50 190, 20 170, 20 130
                    C 20 80, 50 40, 100 40 Z"
                 fill="url(#bodyGradient)"
                 stroke="#e2e8f0"
                 stroke-width="1" />

           <!-- 肚子上的小装饰 (淡绿色) -->
           <ellipse cx="100" cy="150" rx="30" ry="20" fill="#d1fae5" opacity="0.6" />
        </g>

        <!-- 头顶嫩芽 (象征生命/草本) -->
        <g class="sprout" transform="translate(100, 45)">
          <!-- 左叶 -->
          <path d="M0 0 Q -20 -30, -35 -20 Q -40 -5, -15 5 Z" fill="url(#leafGradient)" class="leaf-left" />
          <!-- 右叶 -->
          <path d="M0 0 Q 15 -40, 40 -25 Q 45 -10, 15 5 Z" fill="url(#leafGradient)" class="leaf-right" />
          <!-- 茎 -->
          <path d="M0 0 L 0 5" stroke="#059669" stroke-width="3" stroke-linecap="round" />
        </g>

        <!-- 表情 -->
        <g class="face" transform="translate(0, 10)">
          <!-- 眼睛 -->
          <g class="eyes">
            <!-- 左眼 -->
            <ellipse cx="75" cy="110" rx="8" ry="10" fill="#0f766e" />
            <circle cx="78" cy="106" r="3" fill="white" opacity="0.8" />
            <!-- 右眼 -->
            <ellipse cx="125" cy="110" rx="8" ry="10" fill="#0f766e" />
            <circle cx="128" cy="106" r="3" fill="white" opacity="0.8" />
          </g>

          <!-- 腮红 -->
          <ellipse cx="65" cy="125" rx="8" ry="5" fill="#fecaca" opacity="0.6" class="blush" />
          <ellipse cx="135" cy="125" rx="8" ry="5" fill="#fecaca" opacity="0.6" class="blush" />

          <!-- 嘴巴 (微笑) -->
          <path d="M90 125 Q 100 132, 110 125" fill="none" stroke="#0f766e" stroke-width="2" stroke-linecap="round" />
        </g>

        <!-- 漂浮的小光点 (气/能量) -->
        <circle cx="160" cy="80" r="4" fill="#34d399" opacity="0.6" class="floater f1" />
        <circle cx="40" cy="100" r="3" fill="#34d399" opacity="0.4" class="floater f2" />
        <circle cx="150" cy="160" r="2" fill="#34d399" opacity="0.5" class="floater f3" />
      </svg>

      <!-- 状态气泡 -->
      <Transition name="fade">
        <div class="status-bubble" v-if="!showMenu && currentTip">
          <span class="typing-text">{{ currentTip }}</span>
        </div>
      </Transition>
    </div>

    <!-- 菜单 -->
    <Transition name="pop">
      <div
        v-if="showMenu"
        class="mascot-menu"
        ref="menuRef"
        @click.stop
      >
        <div class="menu-header">
          <span class="menu-title">灵素助手</span>
          <span class="menu-badge">Online</span>
        </div>

        <div class="menu-grid">
          <button class="menu-item" @click="handleAction('assistant')">
            <div class="icon-box assistant">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
              </svg>
            </div>
            <span>AI 资讯</span>
          </button>

          <button class="menu-item" @click="handleAction('checkin')">
            <div class="icon-box checkin">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
            <span>健康打卡</span>
          </button>

          <button class="menu-item" @click="handleAction('assessment')">
            <div class="icon-box assessment">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
              </svg>
            </div>
            <span>体质测评</span>
          </button>

          <button class="menu-item" @click="handleAction('season')">
            <div class="icon-box season">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
              </svg>
            </div>
            <span>节气养生</span>
          </button>
        </div>
      </div>
    </Transition>

    <!-- 节气弹窗 -->
    <Teleport to="body">
      <AIChatModal :visible="showChatModal" @close="showChatModal = false" />
      <Transition name="fade">
        <div v-if="showSeasonModal" class="modal-overlay" @click="showSeasonModal = false">
          <div class="modal-content" @click.stop>
            <button class="close-btn" @click="showSeasonModal = false">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12"></path>
              </svg>
            </button>
            
            <div class="modal-header">
              <div class="season-icon-large">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
                  <path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>
                </svg>
              </div>
              <h2>{{ seasonData?.season }}</h2>
              <p class="date">{{ getCurrentDate() }}</p>
            </div>

            <div class="modal-body">
              <!-- 核心推荐 -->
              <div class="info-group">
                <div class="group-header">
                  <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 20h9M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                  </svg>
                  <h3>养生重点</h3>
                </div>
                <p>{{ seasonData?.principle }}</p>
              </div>

              <!-- 食物推荐 -->
              <div class="info-group">
                <div class="group-header">
                  <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 2a10 10 0 0 0-7.38 16.66c.2.22.42.42.66.6a10 10 0 1 0 13.44 0c.24-.18.46-.38.66-.6A10 10 0 0 0 12 2z"></path>
                    <path d="M8.5 10a3.5 3.5 0 1 0 7 0"></path>
                  </svg>
                  <h3>宜食</h3>
                </div>
                <div class="tags">
                  <span v-for="food in getFoodsList(seasonData?.recommendedFoods)" :key="food" class="tag">
                    {{ food }}
                  </span>
                </div>
              </div>

               <!-- 注意事项 -->
              <div class="info-group warning">
                <div class="group-header">
                  <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                    <line x1="12" y1="9" x2="12" y2="13"></line>
                    <line x1="12" y1="17" x2="12.01" y2="17"></line>
                  </svg>
                  <h3>注意</h3>
                </div>
                <p>{{ seasonData?.taboos }}</p>
              </div>

              <!-- 详细建议（折叠） -->
              <div class="detail-collapse">
                <button class="collapse-btn" @click="toggleSeasonDetail">
                  <span>查看详细养生建议</span>
                  <svg :class="{ 'rotate': showSeasonDetail }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="6 9 12 15 18 9"></polyline>
                  </svg>
                </button>
                <div class="collapse-content" v-show="showSeasonDetail">
                   <p>{{ seasonData?.detailSuggestion }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import AIChatModal from './AIChatModal.vue';

const router = useRouter();
const showMenu = ref(false);
const widgetRef = ref<HTMLElement | null>(null);
const showSeasonModal = ref(false);
const showChatModal = ref(false);
const showSeasonDetail = ref(false);
type SeasonTip = {
  season?: string;
  principle?: string;
  recommendedFoods?: string;
  taboos?: string;
  detailSuggestion?: string;
};
const seasonData = ref<SeasonTip | null>(null);

// 养生提示语
const tips = [
  '多喝温水哦~',
  '注意坐姿挺拔',
  '深呼吸，放松一下',
  '眼睛累了吗？远眺一会',
  '保持心情舒畅',
  '今天也要早点休息',
  '按时吃饭很重要',
  '动一动，更有活力'
];
const currentTip = ref(tips[0]);
let tipInterval: number | null = null;

function toggleMenu() {
  showMenu.value = !showMenu.value;
}

function toggleSeasonDetail() {
  showSeasonDetail.value = !showSeasonDetail.value;
}

function getFoodsList(foods?: string) {
  return foods ? foods.split('、').filter(f => f.trim()) : [];
}

function getCurrentDate() {
  const now = new Date();
  return now.toLocaleDateString('zh-CN', { month: 'long', day: 'numeric' });
}

async function loadSeasonData() {
  try {
    const { getCurrentSeasonTip } = await import('../services/api');
    seasonData.value = await getCurrentSeasonTip();
  } catch (e) {
    console.error('Failed to load season data', e);
  }
}

function handleAction(action: string) {
  showMenu.value = false;
  switch (action) {
    case 'assistant': 
      showChatModal.value = true;
      break;
    case 'checkin': router.push('/checkin'); break;
    case 'assessment': router.push('/assessment'); break;
    case 'season': 
      // 打开节气弹窗
      loadSeasonData();
      showSeasonModal.value = true;
      break;
    case 'knowledge': router.push('/knowledge'); break;
    case 'metrics': router.push('/dashboard-metrics'); break;
  }
}

function handleClickOutside(event: MouseEvent) {
  if (widgetRef.value && !widgetRef.value.contains(event.target as Node)) {
    showMenu.value = false;
  }
}

function startTipRotation() {
  // 每 8 秒更换一次提示
  tipInterval = window.setInterval(() => {
    if (!showMenu.value) {
      const idx = Math.floor(Math.random() * tips.length);
      currentTip.value = tips[idx];
    }
  }, 8000);
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
  startTipRotation();
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
  if (tipInterval) clearInterval(tipInterval);
});
</script>

<style scoped>
.mascot-widget {
  position: fixed;
  left: 20px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 1000;
  width: 120px;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.mascot-character {
  width: 100%;
  height: 100%;
  cursor: pointer;
  position: relative;
  z-index: 1;
  transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  animation: float 6s ease-in-out infinite;
  /* 柔和的脉冲发光效果 - 贴合身体 */
  filter: 
    drop-shadow(0 0 20px rgba(16, 185, 129, 0.3))
    drop-shadow(0 0 40px rgba(16, 185, 129, 0.2))
    drop-shadow(0 10px 15px rgba(16, 185, 129, 0.15));
  animation: float 6s ease-in-out infinite, glow-breathe 4s ease-in-out infinite;
}

/* 呼吸发光动画 */
@keyframes glow-breathe {
  0%, 100% {
    filter: 
      drop-shadow(0 0 15px rgba(16, 185, 129, 0.25))
      drop-shadow(0 0 30px rgba(16, 185, 129, 0.15))
      drop-shadow(0 10px 15px rgba(16, 185, 129, 0.15));
  }
  50% {
    filter: 
      drop-shadow(0 0 25px rgba(16, 185, 129, 0.4))
      drop-shadow(0 0 50px rgba(16, 185, 129, 0.25))
      drop-shadow(0 10px 20px rgba(16, 185, 129, 0.2));
  }
}

.mascot-character:hover {
  transform: scale(1.1) translateY(-5px);
  filter: 
    drop-shadow(0 0 30px rgba(16, 185, 129, 0.5))
    drop-shadow(0 0 60px rgba(16, 185, 129, 0.3))
    drop-shadow(0 15px 25px rgba(16, 185, 129, 0.25));
}

.mascot-character.is-active {
  transform: scale(1.05);
}

.character-svg {
  width: 100%;
  height: 100%;
  overflow: visible;
}

/* 眨眼动画 */
.eyes {
  animation: blink 5s infinite; /* 减慢眨眼频率 */
  transform-origin: center;
}

@keyframes blink {
  0%, 48%, 52%, 100% { transform: scaleY(1); }
  50% { transform: scaleY(0.1); }
}

/* 呼吸浮动 */
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.shadow-pulse {
  animation: shadow-scale 6s ease-in-out infinite;
  transform-origin: center;
}

@keyframes shadow-scale {
  0%, 100% { transform: scaleX(1); opacity: 0.1; }
  50% { transform: scaleX(0.85); opacity: 0.05; }
}

/* 嫩芽摇摆 */
.sprout {
  animation: sway 4s ease-in-out infinite;
  transform-origin: bottom center;
}

@keyframes sway {
  0%, 100% { transform: translate(100px, 45px) rotate(-2deg); }
  50% { transform: translate(100px, 45px) rotate(2deg); }
}

/* 漂浮光点 */
.floater {
  animation: float-particle 4s ease-in-out infinite;
}
.f1 { animation-delay: 0s; }
.f2 { animation-delay: 1.5s; }
.f3 { animation-delay: 3s; }

@keyframes float-particle {
  0%, 100% { transform: translate(0, 0); opacity: 0.6; }
  50% { transform: translate(0, -10px); opacity: 0.3; }
}

/* 状态气泡 */
.status-bubble {
  position: absolute;
  top: 5px; /* 向下移动，压缩顶部空间 */
  left: 100px; /* 固定左边缘位置，从角色右侧120px开始 */
  background: white;
  padding: 8px 16px;
  border-radius: 16px 16px 16px 0;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
  font-size: 13px;
  font-weight: 500;
  color: #0f766e;
  white-space: nowrap; /* 保持单行，让气泡根据文字长度自动调整 */
  border: 1px solid #e0f2fe;
  animation: bubble-float 0.5s cubic-bezier(0.18, 0.89, 0.32, 1.28);
  z-index: 10;
  min-width: 60px; /* 最小宽度 */
  max-width: 300px; /* 最大宽度，防止文字太长 */
}

@keyframes bubble-float {
  from {
    opacity: 0;
    transform: translateY(10px) scale(0.8);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s ease, transform 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

/* 菜单样式 - 保持原样，微调颜色 */
.mascot-menu {
  position: absolute;
  left: 150px; /* 位于角色右侧 */
  top: 50%;
  transform: translateY(-50%);
  width: 280px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 20px;
  box-shadow:
    0 20px 50px rgba(16, 185, 129, 0.15),
    0 0 0 1px rgba(255, 255, 255, 0.8);
  border: 1px solid #f0fdf4;
  transform-origin: left center;
}

.menu-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f1f5f9;
}

.menu-title {
  font-size: 16px;
  font-weight: 700;
  color: #0f766e; /* 深青色 */
}

.menu-badge {
  font-size: 11px;
  padding: 2px 8px;
  background: #d1fae5;
  color: #059669;
  border-radius: 99px;
  font-weight: 600;
}

.menu-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.menu-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: white;
  border: 1px solid #f1f5f9;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.2s;
  color: #64748b;
}

.menu-item:hover {
  background: #f0fdf4;
  border-color: #10b981;
  color: #10b981;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
}

.icon-box {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8fafc;
  color: #94a3b8;
  transition: all 0.2s;
}

.menu-item:hover .icon-box {
  background: #10b981;
  color: white;
}

.menu-item span {
  font-size: 13px;
  font-weight: 500;
}

/* 动画 */
.pop-enter-active,
.pop-leave-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.pop-enter-from,
.pop-leave-to {
  opacity: 0;
  transform: scale(0.8) translate(-20px, 20px);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .mascot-widget {
    left: 10px;
    bottom: 20px;
    width: 90px;
    height: 90px;
  }

  .mascot-menu {
    left: 10px;
    bottom: 100px;
    width: 260px;
  }
}

/* 节气弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal-content {
  background: #ffffff;
  width: 90%;
  max-width: 400px;
  border-radius: 24px;
  padding: 32px 24px;
  position: relative;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
  border: 1px solid #e2e8f0;
  animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes popIn {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

.close-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  color: #94a3b8;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
}

.close-btn:hover {
  background: #f1f5f9;
  color: #64748b;
}

.close-btn svg {
  width: 20px;
  height: 20px;
}

.modal-header {
  text-align: center;
  margin-bottom: 24px;
}

.season-icon-large {
  color: #f59e0b;
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
}

.modal-header h2 {
  font-size: 2rem;
  color: #1e293b;
  margin: 0 0 4px;
}

.modal-header .date {
  color: #64748b;
  font-size: 0.95rem;
  margin: 0;
}

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.info-group {
  background: #f1f5f9;
  padding: 16px;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
}

.info-group.warning {
  background: #fee2e2;
  border: 1px solid #fecaca;
}

.info-group.warning .icon {
  color: #f43f5e;
}

.group-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  color: #334155;
}

.group-header .icon {
  width: 20px;
  height: 20px;
  color: #10b981;
}

.group-header h3 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
}

.info-group p {
  margin: 0;
  font-size: 0.95rem;
  color: #334155;
  line-height: 1.5;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  background: #fff;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  color: #059669;
  border: 1px solid #d1fae5;
}

.detail-collapse {
  margin-top: 8px;
}

.collapse-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: transparent;
  border: 1px solid #e2e8f0;
  padding: 12px 16px;
  border-radius: 12px;
  color: #64748b;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.2s;
}

.collapse-btn:hover {
  background: #f8fafc;
  color: #334155;
  border-color: #cbd5e1;
}

.collapse-btn svg {
  width: 18px;
  height: 18px;
  transition: transform 0.3s;
}

.collapse-btn svg.rotate {
  transform: rotate(180deg);
}

.collapse-content {
  margin-top: 12px;
  padding: 16px;
  background: #f1f5f9;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  font-size: 0.95rem;
  color: #334155;
  line-height: 1.6;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
