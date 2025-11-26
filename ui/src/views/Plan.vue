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

const loading = ref(false);
const aiLoading = ref(false);
const constitution = ref('');
const planItems = ref<PlanItem[]>([]);
const activeTab = ref<'record' | 'ai'>('record');
const aiCategory = ref<'health' | 'season'>('health'); // AI方案分类
const selectedOption = ref('');
const selectedSeason = ref('');
const ingredientInput = ref('');
const aiResponse = ref('');

// AI方案选项
const aiOptions = [
  {
    id: 'sleep',
    title: '改善睡眠质量',
    icon: '😴',
    description: '失眠、多梦、睡眠浅',
    prompt: '我最近睡眠质量不好，经常失眠、多梦、睡眠浅，请给我一套完整的改善睡眠的养生方案，包括饮食、运动、作息调理等方面。'
  },
  {
    id: 'weight',
    title: '健康减重',
    icon: '⚖️',
    description: '科学减肥、控制体重',
    prompt: '我想要健康减重，请为我制定一套科学的减肥养生方案，包括饮食建议、运动计划、生活习惯调整等。'
  },
  {
    id: 'digestion',
    title: '调理肠胃',
    icon: '🍃',
    description: '消化不良、胃胀气',
    prompt: '我经常消化不良、胃胀气、肠胃不适，请给我一套调理肠胃的养生方案，包括饮食禁忌、推荐食物、穴位按摩等。'
  },
  {
    id: 'immunity',
    title: '提高免疫力',
    icon: '💪',
    description: '增强体质、预防感冒',
    prompt: '我想提高免疫力，增强体质，预防感冒，请给我一套提升免疫力的养生方案，包括饮食、运动、生活习惯等。'
  },
  {
    id: 'stress',
    title: '缓解压力焦虑',
    icon: '🧘',
    description: '放松身心、情绪管理',
    prompt: '我最近压力很大，经常焦虑、紧张，请给我一套缓解压力、放松身心的养生方案，包括情绪调节、饮食、运动等。'
  },
  {
    id: 'beauty',
    title: '美容养颜',
    icon: '✨',
    description: '皮肤保养、延缓衰老',
    prompt: '我想要美容养颜，改善皮肤状态，延缓衰老，请给我一套养颜方案，包括饮食推荐、作息调理、护肤建议等。'
  },
  {
    id: 'energy',
    title: '提升精力',
    icon: '⚡',
    description: '消除疲劳、恢复活力',
    prompt: '我经常感到疲劳乏力、精神不振，请给我一套提升精力、恢复活力的养生方案，包括饮食、运动、作息等。'
  },
  {
    id: 'bone',
    title: '骨骼关节保养',
    icon: '🦴',
    description: '强健骨骼、保护关节',
    prompt: '我想保养骨骼和关节，预防骨质疏松和关节问题，请给我一套骨骼关节保养方案，包括饮食、运动、日常护理等。'
  }
];

// 季节选项
const seasonOptions = [
  { id: 'spring', name: '春季', icon: '🌸', color: '#10b981' },
  { id: 'summer', name: '夏季', icon: '☀️', color: '#f59e0b' },
  { id: 'autumn', name: '秋季', icon: '🍂', color: '#ef4444' },
  { id: 'winter', name: '冬季', icon: '❄️', color: '#3b82f6' }
];

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
  await loadRecordBasedPlan();
});

// 加载基于记录的方案
async function loadRecordBasedPlan() {
  try {
    loading.value = true;
    const data = await getDailyPlan();
    
    if (data && data.constitution) {
      constitution.value = data.constitution;
      planItems.value = data.items || [];
    } else {
      // 即使没有测评数据，也显示基于记录的通用建议
      planItems.value = [
        {
          category: '友情提示',
          title: '开始记录健康数据',
          detail: '完成每日健康记录后，系统将根据您的数据生成更精准的养生方案。'
        }
      ];
    }
  } catch (error) {
    console.error('获取个性化方案失败:', error);
    planItems.value = [];
  } finally {
    loading.value = false;
  }
}

// 生成养生需求方案
async function generateAIPlan(optionId: string) {
  const option = aiOptions.find(opt => opt.id === optionId);
  if (!option) return;
  
  selectedOption.value = optionId;
  
  try {
    aiLoading.value = true;
    aiResponse.value = '';
    
    const response = await fetch('/api/assistant/ask', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify({
        q: option.prompt
      })
    });
    
    const data = await response.json();
    
    if (data.answer) {
      aiResponse.value = data.answer;
    } else {
      aiResponse.value = '生成方案失败，请稍后重试';
    }
  } catch (error) {
    console.error('AI方案生成失败:', error);
    aiResponse.value = '生成方案失败，请稍后重试';
  } finally {
    aiLoading.value = false;
  }
}

// 生成季节食材建议
async function generateSeasonAdvice() {
  if (!selectedSeason.value) {
    alert('请选择季节');
    return;
  }
  
  if (!ingredientInput.value.trim()) {
    alert('请输入食材或药材名称');
    return;
  }
  
  const season = seasonOptions.find(s => s.id === selectedSeason.value);
  if (!season) return;
  
  try {
    aiLoading.value = true;
    aiResponse.value = '';
    
    const prompt = `请作为专业的中医养生顾问，针对${season.name}和用户提到的食材药材"${ingredientInput.value.trim()}"，给出详细的食用建议。包括：
1. 该食材/药材在${season.name}的功效和作用
2. 适合的食用方法和搭配
3. 食用时的注意事项和禁忌
4. 推荐的食用量和频率
5. 特别适合哪些体质的人群`;
    
    const response = await fetch('/api/assistant/ask', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify({
        q: prompt
      })
    });
    
    const data = await response.json();
    
    if (data.answer) {
      aiResponse.value = data.answer;
    } else {
      aiResponse.value = '生成建议失败，请稍后重试';
    }
  } catch (error) {
    console.error('季节食材建议生成失败:', error);
    aiResponse.value = '生成建议失败，请稍后重试';
  } finally {
    aiLoading.value = false;
  }
}

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

function formatAIResponse(text: string): string {
  // 将换行符转换为<br>
  return text
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>') // 加粗
    .replace(/\*(.*?)\*/g, '<em>$1</em>'); // 斜体
}
</script>

<template>
  <div class="plan-container">
    <!-- 返回首页按钮 -->
    <button @click="goBack" class="back-btn back-top-left">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>

    <!-- 顶部导航 -->
    <div class="header">
      <h1 class="page-title">个性化养生方案</h1>
    </div>

    <!-- Tab 切换 -->
    <div class="tabs-container">
      <div class="tabs">
        <button 
          class="tab-btn" 
          :class="{ active: activeTab === 'record' }"
          @click="activeTab = 'record'"
        >
          <span class="tab-icon">�</span>
          基于记录的方案
        </button>
        <button 
          class="tab-btn" 
          :class="{ active: activeTab === 'ai' }"
          @click="activeTab = 'ai'"
        >
          <span class="tab-icon">🤖</span>
          AI智能方案
        </button>
      </div>
    </div>

    <!-- 基于记录的方案 -->
    <div v-if="activeTab === 'record'" class="plan-content">
      <!-- 加载状态 -->
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>正在加载方案...</p>
      </div>

      <template v-else>
        <!-- 体质卡片（仅在有体质数据时显示） -->
        <div v-if="constitution" class="constitution-card" :style="{ borderColor: getConstitutionColor() }">
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
      </template>
    </div>

    <!-- AI智能方案 -->
    <div v-if="activeTab === 'ai'" class="ai-content">
      <div class="ai-panel">
        <!-- AI分类切换 -->
        <div class="ai-category-tabs">
          <button 
            class="category-tab" 
            :class="{ active: aiCategory === 'health' }"
            @click="aiCategory = 'health'; aiResponse = ''"
          >
            <span class="category-icon">💊</span>
            养生需求
          </button>
          <button 
            class="category-tab" 
            :class="{ active: aiCategory === 'season' }"
            @click="aiCategory = 'season'; aiResponse = ''"
          >
            <span class="category-icon">🌿</span>
            季节食材建议
          </button>
        </div>

        <!-- 养生需求分类 -->
        <div v-if="aiCategory === 'health'" class="category-content">
          <p class="category-subtitle">选择您的养生需求，AI将为您生成专属方案</p>
          
          <!-- 选项卡片网格 -->
          <div class="ai-options-grid">
          <div
            v-for="option in aiOptions"
            :key="option.id"
            class="option-card"
            :class="{ selected: selectedOption === option.id, loading: aiLoading && selectedOption === option.id }"
            @click="!aiLoading && generateAIPlan(option.id)"
          >
            <div class="option-icon">{{ option.icon }}</div>
            <h3 class="option-title">{{ option.title }}</h3>
            <p class="option-description">{{ option.description }}</p>
            <div v-if="aiLoading && selectedOption === option.id" class="option-loading">
              <div class="mini-spinner"></div>
              <span>生成中...</span>
            </div>
          </div>
          </div>
        </div>

        <!-- 季节食材建议分类 -->
        <div v-if="aiCategory === 'season'" class="category-content">
          <p class="category-subtitle">选择季节，输入食材或药材，获取专业食用建议</p>
          
          <div class="season-input-section">
            <!-- 季节选择 -->
            <div class="season-selector">
              <label class="input-label">选择季节</label>
              <div class="season-options">
                <button
                  v-for="season in seasonOptions"
                  :key="season.id"
                  class="season-btn"
                  :class="{ selected: selectedSeason === season.id }"
                  :style="{ borderColor: selectedSeason === season.id ? season.color : '' }"
                  @click="selectedSeason = season.id"
                >
                  <span class="season-icon">{{ season.icon }}</span>
                  <span>{{ season.name }}</span>
                </button>
              </div>
            </div>

            <!-- 食材药材输入 -->
            <div class="ingredient-input">
              <label class="input-label">输入食材或药材</label>
              <input
                v-model="ingredientInput"
                type="text"
                class="ingredient-field"
                placeholder="例如：枸杞、山药、红枣、菊花..."
                @keyup.enter="generateSeasonAdvice"
              />
            </div>

            <!-- 提交按钮 -->
            <button 
              @click="generateSeasonAdvice" 
              class="season-submit-btn"
              :disabled="aiLoading || !selectedSeason || !ingredientInput.trim()"
              :class="{ loading: aiLoading }"
            >
              <template v-if="!aiLoading">
                <span>✨ 生成建议</span>
              </template>
              <template v-else>
                <div class="mini-spinner"></div>
                <span>生成中...</span>
              </template>
            </button>
          </div>
        </div>

        <div v-if="aiResponse" class="ai-response-section">
          <div class="ai-response-header">
            <h3>
              <span class="response-icon">📋</span>
              {{ aiCategory === 'health' ? 'AI生成的养生方案' : '食材食用建议' }}
            </h3>
          </div>
          <div class="ai-response-content" v-html="formatAIResponse(aiResponse)"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.plan-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
  padding: 80px 20px 20px 20px; /* 增加顶部padding给按钮留空间 */
  position: relative;
}

/* 左上角返回按钮 */
.back-top-left {
  position: fixed;
  top: 10px;
  left: 20px;
  z-index: 9999;
}

/* 按钮样式 - 现代毛玻璃效果 */
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

/* 顶部导航 */
.header {
  display: flex;
  align-items: center;
  justify-content: center;
  max-width: 900px;
  margin: 0 auto 30px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

/* Tab切换 */
.tabs-container {
  max-width: 900px;
  margin: 0 auto 30px;
}

.tabs {
  display: flex;
  gap: 15px;
  background: white;
  border-radius: 16px;
  padding: 8px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.tab-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 20px;
  border: none;
  background: transparent;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab-btn:hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.tab-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.tab-icon {
  font-size: 20px;
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
    padding: 80px 15px 15px 15px; /* 保持顶部padding给按钮留空间 */
  }

  .header {
    margin-bottom: 20px;
  }

  .page-title {
    font-size: 22px;
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
}

/* AI方案样式 */
.ai-content {
  max-width: 900px;
  margin: 0 auto;
}

.ai-panel {
  background: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

/* AI分类切换 */
.ai-category-tabs {
  display: flex;
  gap: 12px;
  margin-bottom: 25px;
  background: #f3f4f6;
  padding: 6px;
  border-radius: 12px;
}

.category-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 20px;
  border: none;
  background: transparent;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.3s ease;
}

.category-tab:hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.category-tab.active {
  background: white;
  color: #667eea;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.category-icon {
  font-size: 18px;
}

.category-content {
  margin-top: 20px;
}

.category-subtitle {
  text-align: center;
  color: #6b7280;
  font-size: 15px;
  margin: 0 0 25px 0;
}

/* 选项卡片网格 */
.ai-options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.option-card {
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 16px;
  padding: 24px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.option-card:hover {
  border-color: #667eea;
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.2);
}

.option-card.selected {
  border-color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.option-card.loading {
  pointer-events: none;
  opacity: 0.8;
}

.option-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.option-title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 8px 0;
}

.option-description {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
  line-height: 1.5;
}

.option-loading {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 14px;
  color: #667eea;
  font-weight: 600;
}

.mini-spinner {
  width: 24px;
  height: 24px;
  border: 3px solid #e9ecef;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.ai-response-section {
  margin-top: 30px;
  padding-top: 30px;
  border-top: 2px solid #f3f4f6;
}

.ai-response-header h3 {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 20px 0;
}

.response-icon {
  font-size: 24px;
}

.ai-response-content {
  background: #f9fafb;
  border-left: 4px solid #667eea;
  border-radius: 12px;
  padding: 20px;
  color: #374151;
  font-size: 15px;
  line-height: 1.8;
  white-space: pre-wrap;
}

/* 季节食材建议 */
.season-input-section {
  max-width: 600px;
  margin: 0 auto;
}

.input-label {
  display: block;
  font-size: 15px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 12px;
}

.season-selector {
  margin-bottom: 25px;
}

.season-options {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.season-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 12px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  font-weight: 500;
  color: #374151;
}

.season-btn:hover {
  border-color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.season-btn.selected {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.season-icon {
  font-size: 28px;
}

.ingredient-input {
  margin-bottom: 20px;
}

.ingredient-field {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  font-size: 15px;
  color: #2c3e50;
  transition: border-color 0.3s ease;
}

.ingredient-field:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.ingredient-field::placeholder {
  color: #9ca3af;
}

.season-submit-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
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

.season-submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

.season-submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.season-submit-btn.loading {
  background: #9ca3af;
  cursor: wait;
}

/* 响应式设计 - 选项卡片 */
@media (max-width: 768px) {
  .ai-options-grid {
    grid-template-columns: 1fr;
    gap: 15px;
  }
  
  .option-card {
    padding: 20px;
  }
  
  .option-icon {
    font-size: 40px;
  }
  
  .option-title {
    font-size: 16px;
  }
  
  .ai-panel {
    padding: 25px;
  }

  .season-options {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .category-tab {
    padding: 10px 12px;
    font-size: 14px;
  }
}
</style>
