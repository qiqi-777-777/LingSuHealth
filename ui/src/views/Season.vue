<template>
  <div class="season-container">
    <!-- 返回首页按钮 -->
    <button @click="goHome" class="back-btn back-top-left">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>
    
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <span class="title-icon">🌸</span>
          节气养生提醒
        </h1>
        <p class="page-subtitle">顺应自然节律，享受健康生活</p>
      </div>
    </div>

    <!-- 当前节气卡片 -->
    <div class="current-season-card" v-if="currentTip">
      <div class="season-badge">
        <span class="badge-text">当前节气</span>
      </div>
      <div class="season-header">
        <h2 class="season-name">{{ currentTip.season }}</h2>
        <div class="season-date">{{ getCurrentDate() }}</div>
      </div>
      <div class="season-content">
        <div class="quick-tip">
          <span class="tip-icon">💡</span>
          <span class="tip-text">{{ currentTip.suggestion }}</span>
        </div>
      </div>
    </div>

    <!-- 详细信息区域 -->
    <div class="detail-section" v-if="selectedTip">
      <div class="section-header">
        <h3 class="section-title">{{ selectedTip.season }} 养生指南</h3>
        <div class="season-selector">
          <select v-model="selectedSeason" @change="loadSeasonTip" class="season-select">
            <option value="立春">立春</option>
            <option value="雨水">雨水</option>
            <option value="惊蛰">惊蛰</option>
            <option value="春分">春分</option>
            <option value="立夏">立夏</option>
            <option value="小满">小满</option>
            <option value="立秋">立秋</option>
            <option value="处暑">处暑</option>
            <option value="白露">白露</option>
            <option value="秋分">秋分</option>
            <option value="寒露">寒露</option>
            <option value="霜降">霜降</option>
            <option value="立冬">立冬</option>
            <option value="小雪">小雪</option>
          </select>
        </div>
      </div>

      <div class="detail-grid">
        <!-- 养生原则 -->
        <div class="detail-card principle-card">
          <div class="card-header">
            <span class="card-icon">🎯</span>
            <h4 class="card-title">养生原则</h4>
          </div>
          <div class="card-content">
            <p class="principle-text">{{ selectedTip.principle }}</p>
          </div>
        </div>

        <!-- 详细建议 -->
        <div class="detail-card suggestion-card">
          <div class="card-header">
            <span class="card-icon">📋</span>
            <h4 class="card-title">详细建议</h4>
          </div>
          <div class="card-content">
            <p class="suggestion-text">{{ selectedTip.detailSuggestion }}</p>
          </div>
        </div>

        <!-- 推荐食物 -->
        <div class="detail-card foods-card">
          <div class="card-header">
            <span class="card-icon">🥗</span>
            <h4 class="card-title">推荐食物</h4>
          </div>
          <div class="card-content">
            <div class="foods-list">
              <span v-for="food in getFoodsList(selectedTip.recommendedFoods)" 
                    :key="food" 
                    class="food-tag">{{ food }}</span>
            </div>
          </div>
        </div>

        <!-- 注意事项 -->
        <div class="detail-card taboos-card">
          <div class="card-header">
            <span class="card-icon">⚠️</span>
            <h4 class="card-title">注意事项</h4>
          </div>
          <div class="card-content">
            <p class="taboos-text">{{ selectedTip.taboos }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p class="loading-text">正在加载节气信息...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getSeasonTips, getCurrentSeasonTip } from '../services/api';

defineOptions({ name: 'SeasonView' });

const router = useRouter();
interface SeasonTip {
  season: string;
  suggestion: string;
  principle: string;
  detailSuggestion: string;
  recommendedFoods: string;
  taboos: string;
}

const currentTip = ref<SeasonTip | null>(null);
const selectedTip = ref<SeasonTip | null>(null);
const selectedSeason = ref('立冬');
const loading = ref(false);

const goHome = () => {
  router.push('/dashboard');
};

const getCurrentDate = () => {
  const now = new Date();
  return now.toLocaleDateString('zh-CN', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });
};

const getFoodsList = (foods: string) => {
  return foods ? foods.split('、').filter(f => f.trim()) : [];
};

const loadCurrentSeason = async () => {
  try {
    loading.value = true;
    currentTip.value = await getCurrentSeasonTip();
    if (currentTip.value) {
      selectedSeason.value = currentTip.value.season;
      selectedTip.value = currentTip.value;
    }
  } catch (error) {
    console.error('加载当前节气失败:', error);
  } finally {
    loading.value = false;
  }
};

const loadSeasonTip = async () => {
  try {
    loading.value = true;
    selectedTip.value = await getSeasonTips(selectedSeason.value);
  } catch (error) {
    console.error('加载节气信息失败:', error);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadCurrentSeason();
});
</script>

<style scoped>
.season-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #ffd89b 0%, #ffc3a0 100%);
  padding: 60px 20px 20px 20px; /* 减少顶部padding */
  position: relative;
}

/* 左上角返回按钮 */
.back-top-left {
  position: fixed;
  top: 10px;
  left: 20px;
  z-index: 9999;
}

/* 按钮样式 - 黑色风格 */
.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 12px 24px;
  border-radius: 30px;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3),
              0 0 0 1px rgba(255, 255, 255, 0.1) inset;
  position: relative;
  overflow: hidden;
}

.back-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.back-btn:hover::before {
  opacity: 1;
}

.back-btn:hover {
  transform: translateY(-2px) translateX(-2px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.4),
              0 0 0 1px rgba(255, 255, 255, 0.2) inset;
  border-color: rgba(255, 255, 255, 0.2);
  background: rgba(0, 0, 0, 0.95);
}

.back-btn:active {
  transform: translateY(0) translateX(0);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.back-icon {
  width: 18px;
  height: 18px;
  transition: transform 0.3s ease;
  position: relative;
  z-index: 1;
}

.back-btn:hover .back-icon {
  transform: translateX(-3px);
}

.back-btn span {
  position: relative;
  z-index: 1;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.header-content {
  background: rgba(255, 255, 255, 0.95);
  padding: 30px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 10px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
}

.title-icon {
  font-size: 2.2rem;
}

.page-subtitle {
  font-size: 1.1rem;
  color: #6c757d;
  margin: 0;
}

.current-season-card {
  background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 50%, #fecfef 100%);
  border-radius: 20px;
  padding: 30px;
  margin-bottom: 30px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.current-season-card::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
  pointer-events: none;
}

.season-badge {
  display: inline-block;
  background: rgba(255, 255, 255, 0.9);
  padding: 8px 16px;
  border-radius: 20px;
  margin-bottom: 20px;
}

.badge-text {
  font-size: 0.9rem;
  font-weight: 600;
  color: #e91e63;
}

.season-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.season-name {
  font-size: 2.2rem;
  font-weight: 700;
  color: white;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.season-date {
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.quick-tip {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.2);
  padding: 15px 20px;
  border-radius: 15px;
  backdrop-filter: blur(10px);
}

.tip-icon {
  font-size: 1.3rem;
}

.tip-text {
  font-size: 1.1rem;
  color: white;
  font-weight: 500;
}

.detail-section {
  background: white;
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 20px;
}

.section-title {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.season-selector {
  position: relative;
}

.season-select {
  padding: 12px 20px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 500;
  color: #495057;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 150px;
}

.season-select:hover {
  border-color: #667eea;
}

.season-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 25px;
}

.detail-card {
  background: #f8f9fa;
  border-radius: 15px;
  padding: 25px;
  transition: all 0.3s ease;
  border: 1px solid #e9ecef;
}

.detail-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 15px;
}

.card-icon {
  font-size: 1.5rem;
}

.card-title {
  font-size: 1.2rem;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
}

.card-content {
  line-height: 1.6;
}

.principle-text,
.suggestion-text,
.taboos-text {
  color: #495057;
  font-size: 1rem;
  margin: 0;
}

.foods-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.food-tag {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 15px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.loading-container {
  text-align: center;
  padding: 50px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  color: white;
  font-size: 1.1rem;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .season-container {
    padding: 80px 15px 15px 15px; /* 保持顶部padding给按钮留空间 */
  }
  
  .page-title {
    font-size: 2rem;
  }
  
  .season-name {
    font-size: 1.8rem;
  }
  
  .section-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .detail-grid {
    grid-template-columns: 1fr;
  }
  
  .season-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
}

/* 特殊卡片样式 */
.principle-card {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
  border: none;
}

.suggestion-card {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  border: none;
}

.foods-card {
  background: linear-gradient(135deg, #d299c2 0%, #fef9d7 100%);
  border: none;
}

.taboos-card {
  background: linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%);
  border: none;
}

.taboos-card .card-title,
.taboos-card .taboos-text {
  color: white;
}
</style>
