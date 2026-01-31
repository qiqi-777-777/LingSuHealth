<template>
  <div class="solar-term-widget-container">
    <!-- 加载骨架屏 -->
    <div class="widget-card skeleton" v-if="loading">
      <div class="skeleton-icon"></div>
      <div class="skeleton-text"></div>
    </div>

    <!-- 桌面小挂件 - 改进版水墨风格 -->
    <div 
      class="widget-card ink-style" 
      @click="openModal" 
      v-else-if="currentTip"
      :style="{
        '--season-accent': getSeasonColors.textColor
      }"
    >
      <!-- 动态水墨背景 -->
      <div class="ink-bg">
        <div class="ink-blotch i1"></div>
        <div class="ink-blotch i2"></div>
      </div>
      
      <!-- 风吹竹叶动画 -->
      <div class="bamboo-leaves">
        <svg class="leaf l1" viewBox="0 0 24 24"><path d="M12,2 C12,2 8,10 8,16 C8,22 12,22 12,22 C12,22 16,22 16,16 C16,10 12,2 12,2 Z" fill="#88b04b"/></svg>
        <svg class="leaf l2" viewBox="0 0 24 24"><path d="M12,2 C12,2 8,10 8,16 C8,22 12,22 12,22 C12,22 16,22 16,16 C16,10 12,2 12,2 Z" fill="#6a8a3a"/></svg>
      </div>

      <div class="card-content centered">
        <div class="term-header">
          <span class="term-date">{{ getCurrentDateSimple() }}</span>
        </div>
        
        <h2 class="term-title font-serif">{{ currentTip.season }}</h2>
        <p class="term-subtitle font-serif">万物闭藏，冬季养生</p>
      </div>
    </div>

    <!-- 弹窗 (保持原有逻辑，优化样式) -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="isOpen" class="modal-overlay" @click="closeModal">
          <div class="modal-content" @click.stop>
            <button class="close-btn" @click="closeModal">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12"></path>
              </svg>
            </button>
            
            <div class="modal-header" :style="{ background: getSeasonColors.background }">
              <h2 :style="{ color: getSeasonColors.textColor }">{{ currentTip?.season }}</h2>
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
                <p>{{ currentTip?.principle }}</p>
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
                  <span v-for="food in getFoodsList(currentTip?.recommendedFoods)" :key="food" class="tag">
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
                <p>{{ currentTip?.taboos }}</p>
              </div>

              <!-- 详细建议（折叠） -->
              <div class="detail-collapse">
                <button class="collapse-btn" @click="toggleDetail">
                  <span>查看详细养生建议</span>
                  <svg :class="{ 'rotate': showDetail }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="6 9 12 15 18 9"></polyline>
                  </svg>
                </button>
                <div class="collapse-content" v-show="showDetail">
                   <p>{{ currentTip?.detailSuggestion }}</p>
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
import { ref, onMounted, computed, watch } from 'vue';
import { getCurrentSeasonTip } from '../services/api';

interface SeasonTip {
  season?: string;
  detailSuggestion?: string;
  principle?: string;
  recommendedFoods?: string;
  taboos?: string;
}

// 接收外部控制的弹窗状态
const props = defineProps<{
  isModalOpen?: boolean;
}>();

// 发出关闭事件
const emit = defineEmits<{
  close: [];
}>();

const isOpen = ref(false);
const showDetail = ref(false);
const currentTip = ref<SeasonTip | null>(null);
const loading = ref(true);

// 监听外部传入的弹窗状态
watch(() => props.isModalOpen, (newVal) => {
  if (newVal !== undefined) {
    isOpen.value = newVal;
  }
});

const openModal = () => isOpen.value = true;
const closeModal = () => {
  isOpen.value = false;
  showDetail.value = false;
  // 通知父组件关闭
  emit('close');
};
const toggleDetail = () => showDetail.value = !showDetail.value;

const getFoodsList = (foods?: string) => {
  return foods ? foods.split('、').filter(f => f.trim()) : [];
};

const getCurrentDate = () => {
  const now = new Date();
  return now.toLocaleDateString('zh-CN', { month: 'long', day: 'numeric' });
};

const getCurrentDateSimple = () => {
  const now = new Date();
  return `${now.getMonth() + 1}月${now.getDate()}日`;
};

// 根据节气获取季节颜色
const getSeasonColors = computed(() => {
  const season = currentTip.value?.season || '';
  
  // 春季节气
  const springTerms = ['立春', '雨水', '惊蛰', '春分', '清明', '谷雨'];
  // 夏季节气
  const summerTerms = ['立夏', '小满', '芒种', '夏至', '小暑', '大暑'];
  // 秋季节气
  const autumnTerms = ['立秋', '处暑', '白露', '秋分', '寒露', '霜降'];
  // 冬季节气
  const winterTerms = ['立冬', '小雪', '大雪', '冬至', '小寒', '大寒'];
  
  if (springTerms.includes(season)) {
    return {
      background: 'linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%)',
      textColor: '#166534',
      shadow: 'rgba(22, 101, 52, 0.1)',
      glow: 'rgba(34, 197, 94, 0.4)'
    };
  } else if (summerTerms.includes(season)) {
    return {
      background: 'linear-gradient(135deg, #fef9c3 0%, #fde047 100%)',
      textColor: '#854d0e',
      shadow: 'rgba(133, 77, 14, 0.1)',
      glow: 'rgba(234, 179, 8, 0.4)'
    };
  } else if (autumnTerms.includes(season)) {
    return {
      background: 'linear-gradient(135deg, #ffedd5 0%, #fdba74 100%)',
      textColor: '#9a3412',
      shadow: 'rgba(154, 52, 18, 0.1)',
      glow: 'rgba(249, 115, 22, 0.4)'
    };
  } else if (winterTerms.includes(season)) {
    return {
      background: 'linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%)',
      textColor: '#1e40af',
      shadow: 'rgba(30, 64, 175, 0.1)',
      glow: 'rgba(59, 130, 246, 0.4)'
    };
  }
  
  // 默认颜色
  return {
    background: 'linear-gradient(135deg, #f3f4f6 0%, #e2e8f0 100%)',
    textColor: '#475569',
    shadow: 'rgba(71, 85, 105, 0.1)',
    glow: 'rgba(148, 163, 184, 0.4)'
  };
});

onMounted(async () => {
  try {
    currentTip.value = await getCurrentSeasonTip();
  } catch (e) {
    console.error('Failed to load season tip', e);
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
/* 引入字体 */
@import url('https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;700&display=swap');

.font-serif {
  font-family: 'Noto Serif SC', serif;
}

.solar-term-widget-container {
  width: 100%;
  height: 100%;
  min-height: 180px;
}

.widget-card {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 24px;
  background: white;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.widget-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

/* Ink Style */
.ink-style {
  background: linear-gradient(135deg, #f0fdf4 0%, #ffffff 100%);
}

.ink-bg {
  position: absolute;
  inset: 0;
  opacity: 0.1;
  pointer-events: none;
}

.ink-blotch {
  position: absolute;
  background: #000;
  border-radius: 50%;
  filter: blur(40px);
}

.i1 { width: 300px; height: 300px; top: -100px; left: -100px; opacity: 0.3; }
.i2 { width: 200px; height: 200px; bottom: -50px; right: -50px; opacity: 0.2; }

.bamboo-leaves {
  position: absolute;
  top: 0;
  right: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  overflow: hidden;
}

.leaf {
  position: absolute;
  width: 40px;
  height: 40px;
  opacity: 0.6;
  animation: floatLeaf 6s infinite ease-in-out;
}

.l1 { top: 20%; right: 10%; animation-delay: 0s; transform: rotate(45deg); }
.l2 { top: 40%; right: 20%; width: 30px; height: 30px; animation-delay: -2s; transform: rotate(30deg); }

@keyframes floatLeaf {
  0%, 100% { transform: translate(0, 0) rotate(45deg); }
  50% { transform: translate(10px, 10px) rotate(50deg); }
}

.centered {
  z-index: 2;
  text-align: center;
  padding-top: 20px;
}

.term-header {
  margin-bottom: 8px;
}

.term-date {
  font-size: 13px;
  color: #64748b;
  letter-spacing: 2px;
  display: block;
}

.term-title {
  font-size: 32px;
  color: #14532d;
  margin: 0 0 4px 0;
  font-weight: 400;
}

.term-subtitle {
  font-size: 13px;
  color: #166534;
  opacity: 0.8;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Modal Styles - Reuse existing */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-content {
  background: white;
  width: 100%;
  max-width: 500px;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 20px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.3s ease-out;
  position: relative;
}

.modal-header {
  padding: 32px 24px;
  text-align: center;
}

.modal-header h2 {
  font-size: 32px;
  margin: 0 0 8px 0;
  font-weight: 800;
}

.modal-header .date {
  margin: 0;
  opacity: 0.8;
  font-size: 14px;
}

.modal-body {
  padding: 24px;
  max-height: 60vh;
  overflow-y: auto;
}

.close-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.1);
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  z-index: 10;
  transition: background 0.2s;
}

.close-btn:hover {
  background: rgba(0, 0, 0, 0.2);
}

.info-group {
  margin-bottom: 24px;
}

.group-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  color: #1e293b;
}

.group-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
}

.icon {
  width: 20px;
  height: 20px;
  color: #10b981;
}

.warning .icon {
  color: #f59e0b;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  background: #f1f5f9;
  color: #475569;
  padding: 4px 12px;
  border-radius: 100px;
  font-size: 13px;
}

.detail-collapse {
  margin-top: 20px;
  border-top: 1px solid #f1f5f9;
  padding-top: 20px;
}

.collapse-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: none;
  border: none;
  color: #64748b;
  font-size: 14px;
  cursor: pointer;
  padding: 8px 0;
}

.collapse-btn svg {
  width: 16px;
  height: 16px;
  transition: transform 0.3s;
}

.collapse-btn svg.rotate {
  transform: rotate(180deg);
}

.collapse-content {
  margin-top: 12px;
  color: #475569;
  font-size: 14px;
  line-height: 1.6;
}

/* Animations */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

@keyframes slideUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

/* Skeleton */
.skeleton {
  background: #f1f5f9;
  animation: pulse 2s infinite;
}

.skeleton-icon, .skeleton-text {
  background: rgba(0,0,0,0.05);
  border-radius: 4px;
}

.skeleton-icon { width: 40px; height: 40px; border-radius: 50%; margin-bottom: 20px; }
.skeleton-text { width: 60%; height: 20px; }

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.6; }
  100% { opacity: 1; }
}
</style>
