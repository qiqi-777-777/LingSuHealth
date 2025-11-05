<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getDailyPlan } from '../services/api';

const router = useRouter();

interface PlanItem {
  category: string;
  title: string;
  detail: string;
  icon?: string;
}

const loading = ref(true);
const constitution = ref('');
const planItems = ref<PlanItem[]>([]);
const hasAssessment = ref(true);

// 体质对应的颜色主题
const constitutionColors: Record<string, string> = {
  '平和质': '#4CAF50',
  '气虚质': '#FF9800',
  '阳虚质': '#2196F3',
  '阴虚质': '#E91E63',
  '痰湿质': '#9C27B0',
  '湿热质': '#F44336',
  '血瘀质': '#673AB7',
  '气郁质': '#00BCD4',
  '特禀质': '#795548'
};

// 图标映射
const categoryIcons: Record<string, string> = {
  '饮食建议': '🍽️',
  '运动方案': '🏃',
  '作息调理': '😴',
  '情绪管理': '😊',
  '茶饮推荐': '🍵',
  '穴位按摩': '👐',
  '注意事项': '⚠️',
  '季节养生': '🌱'
};

onMounted(async () => {
  try {
    loading.value = true;
    const data = await getDailyPlan();
    
    if (data && data.constitution) {
      hasAssessment.value = true;
      constitution.value = data.constitution;
      planItems.value = data.items || [];
    } else {
      hasAssessment.value = false;
    }
  } catch (error) {
    console.error('获取个性化方案失败:', error);
    hasAssessment.value = false;
  } finally {
    loading.value = false;
  }
});

function goToAssessment() {
  router.push('/assessment');
}

function goBack() {
  router.push('/dashboard');
}

function getConstitutionColor() {
  return constitutionColors[constitution.value] || '#4CAF50';
}

function getCategoryIcon(category: string) {
  return categoryIcons[category] || '📋';
}
</script>

<template>
  <div class="plan-container">
    <!-- 顶部导航 -->
    <div class="header">
      <button class="back-btn" @click="goBack">← 返回</button>
      <h1 class="page-title">个性化养生方案</h1>
      <div class="spacer"></div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>正在生成您的专属方案...</p>
    </div>

    <!-- 未完成测评提示 -->
    <div v-else-if="!hasAssessment" class="no-assessment">
      <div class="no-assessment-card">
        <div class="no-assessment-icon">📋</div>
        <h2>还未完成体质测评</h2>
        <p>完成体质测评后，系统将为您生成专属的个性化养生方案</p>
        <button class="assessment-btn" @click="goToAssessment">
          立即测评
        </button>
      </div>
    </div>

    <!-- 方案内容 -->
    <div v-else class="plan-content">
      <!-- 体质卡片 -->
      <div class="constitution-card" :style="{ borderColor: getConstitutionColor() }">
        <div class="constitution-badge" :style="{ background: getConstitutionColor() }">
          {{ constitution }}
        </div>
        <div class="constitution-desc">
          <h3>您的体质类型</h3>
          <p>根据您的测评结果，为您定制专属养生方案</p>
        </div>
      </div>

      <!-- 方案列表 -->
      <div class="plan-list">
        <div
          v-for="(item, index) in planItems"
          :key="index"
          class="plan-item"
        >
          <div class="plan-icon">{{ getCategoryIcon(item.category) }}</div>
          <div class="plan-content-wrapper">
            <div class="plan-header">
              <h4 class="plan-category">{{ item.category }}</h4>
            </div>
            <h3 class="plan-title">{{ item.title }}</h3>
            <p class="plan-detail">{{ item.detail }}</p>
          </div>
        </div>
      </div>

      <!-- 底部提示 -->
      <div class="plan-footer">
        <div class="footer-tip">
          <span class="tip-icon">💡</span>
          <p>养生贵在坚持，建议您每天查看并执行养生方案，保持健康生活方式。</p>
        </div>
        <button class="reassess-btn" @click="goToAssessment">
          重新测评
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.plan-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e6edf7 100%);
  padding: 20px;
}

/* 顶部导航 */
.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 900px;
  margin: 0 auto 30px;
}

.back-btn {
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 10px;
  padding: 10px 20px;
  color: #6b7280;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.back-btn:hover {
  border-color: #7c3aed;
  color: #7c3aed;
  transform: translateY(-1px);
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.spacer {
  width: 100px;
}

/* 加载状态 */
.loading-container {
  text-align: center;
  padding: 60px 20px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e9ecef;
  border-top-color: #7c3aed;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-container p {
  color: #6b7280;
  font-size: 16px;
}

/* 未完成测评提示 */
.no-assessment {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
}

.no-assessment-card {
  background: white;
  border-radius: 16px;
  padding: 60px 40px;
  text-align: center;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
  max-width: 500px;
}

.no-assessment-icon {
  font-size: 80px;
  margin-bottom: 20px;
}

.no-assessment-card h2 {
  font-size: 24px;
  color: #2c3e50;
  margin: 0 0 15px 0;
}

.no-assessment-card p {
  color: #6b7280;
  font-size: 16px;
  margin: 0 0 30px 0;
  line-height: 1.6;
}

.assessment-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 14px 32px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.assessment-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

/* 方案内容 */
.plan-content {
  max-width: 900px;
  margin: 0 auto;
}

/* 体质卡片 */
.constitution-card {
  background: white;
  border-radius: 16px;
  padding: 30px;
  margin-bottom: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  display: flex;
  align-items: center;
  gap: 25px;
  border-left: 6px solid;
}

.constitution-badge {
  padding: 15px 25px;
  border-radius: 12px;
  color: white;
  font-size: 22px;
  font-weight: 700;
  white-space: nowrap;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
}

.constitution-desc h3 {
  margin: 0 0 8px 0;
  color: #2c3e50;
  font-size: 20px;
  font-weight: 600;
}

.constitution-desc p {
  margin: 0;
  color: #6b7280;
  font-size: 15px;
}

/* 方案列表 */
.plan-list {
  display: grid;
  gap: 20px;
  margin-bottom: 30px;
}

.plan-item {
  background: white;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.06);
  display: flex;
  gap: 20px;
  transition: all 0.3s ease;
}

.plan-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
}

.plan-icon {
  font-size: 40px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e6edf7 100%);
  border-radius: 12px;
}

.plan-content-wrapper {
  flex: 1;
}

.plan-header {
  margin-bottom: 8px;
}

.plan-category {
  display: inline-block;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  margin: 0;
}

.plan-title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 10px 0;
}

.plan-detail {
  color: #495057;
  font-size: 15px;
  line-height: 1.7;
  margin: 0;
}

/* 底部 */
.plan-footer {
  background: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.06);
}

.footer-tip {
  display: flex;
  gap: 15px;
  margin-bottom: 25px;
  padding: 20px;
  background: #fff9e6;
  border: 1px solid #ffe58f;
  border-left: 4px solid #faad14;
  border-radius: 12px;
}

.tip-icon {
  font-size: 24px;
  flex-shrink: 0;
}

.footer-tip p {
  color: #6b5f3b;
  font-size: 14px;
  line-height: 1.6;
  margin: 0;
}

.reassess-btn {
  width: 100%;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 14px 28px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(245, 87, 108, 0.3);
}

.reassess-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(245, 87, 108, 0.4);
}

/* 响应式 */
@media (max-width: 768px) {
  .plan-container {
    padding: 15px;
  }

  .header {
    margin-bottom: 20px;
  }

  .page-title {
    font-size: 22px;
  }

  .spacer {
    display: none;
  }

  .constitution-card {
    flex-direction: column;
    text-align: center;
    padding: 25px;
  }

  .plan-item {
    flex-direction: column;
    padding: 20px;
  }

  .plan-icon {
    margin: 0 auto;
  }

  .no-assessment-card {
    padding: 40px 25px;
  }
}
</style>
