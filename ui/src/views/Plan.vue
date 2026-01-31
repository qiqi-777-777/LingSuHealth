<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { getDailyPlan, generateAIDynamicPlan } from '../services/api';

defineOptions({ name: 'PlanView' });

const router = useRouter();

const loading = ref(false);
const aiLoading = ref(false);
const aiDynamicLoading = ref(false);
const constitution = ref('');
const planItems = ref<PlanItem[]>([]);
const activeTab = ref<'record' | 'ai'>('record');
const aiCategory = ref<'health' | 'season'>('health'); // AI方案分类
const selectedOption = ref('');
const selectedSeason = ref('');
const ingredientInput = ref('');
const aiResponse = ref('');
const recordKeyword = ref('');
const recordCategory = ref('');
const copyStatus = ref('');

// AI方案选项
type IconKey = keyof typeof iconPaths;

interface PlanItem {
  category: string;
  title: string;
  detail: string;
  icon?: IconKey;
}

const aiOptions: Array<{
  id: string;
  title: string;
  icon: IconKey;
  description: string;
  prompt: string;
}> = [
  {
    id: 'sleep',
    title: '改善睡眠质量',
    icon: 'sleep',
    description: '失眠、多梦、睡眠浅',
    prompt: '我最近睡眠质量不好，经常失眠、多梦、睡眠浅，请给我一套完整的改善睡眠的养生方案，包括饮食、运动、作息调理等方面。'
  },
  {
    id: 'weight',
    title: '健康减重',
    icon: 'weight',
    description: '科学减肥、控制体重',
    prompt: '我想要健康减重，请为我制定一套科学的减肥养生方案，包括饮食建议、运动计划、生活习惯调整等。'
  },
  {
    id: 'digestion',
    title: '调理肠胃',
    icon: 'digestion',
    description: '消化不良、胃胀气',
    prompt: '我经常消化不良、胃胀气、肠胃不适，请给我一套调理肠胃的养生方案，包括饮食禁忌、推荐食物、穴位按摩等。'
  },
  {
    id: 'immunity',
    title: '提高免疫力',
    icon: 'immunity',
    description: '增强体质、预防感冒',
    prompt: '我想提高免疫力，增强体质，预防感冒，请给我一套提升免疫力的养生方案，包括饮食、运动、生活习惯等。'
  },
  {
    id: 'stress',
    title: '缓解压力焦虑',
    icon: 'mood',
    description: '放松身心、情绪管理',
    prompt: '我最近压力很大，经常焦虑、紧张，请给我一套缓解压力、放松身心的养生方案，包括情绪调节、饮食、运动等。'
  },
  {
    id: 'beauty',
    title: '美容养颜',
    icon: 'beauty',
    description: '皮肤保养、延缓衰老',
    prompt: '我想要美容养颜，改善皮肤状态，延缓衰老，请给我一套养颜方案，包括饮食推荐、作息调理、护肤建议等。'
  },
  {
    id: 'energy',
    title: '提升精力',
    icon: 'energy',
    description: '消除疲劳、恢复活力',
    prompt: '我经常感到疲劳乏力、精神不振，请给我一套提升精力、恢复活力的养生方案，包括饮食、运动、作息等。'
  },
  {
    id: 'bone',
    title: '骨骼关节保养',
    icon: 'bone',
    description: '强健骨骼、保护关节',
    prompt: '我想保养骨骼和关节，预防骨质疏松和关节问题，请给我一套骨骼关节保养方案，包括饮食、运动、日常护理等。'
  }
];

// 季节选项
const seasonOptions: Array<{ id: string; name: string; icon: IconKey; color: string }> = [
  { id: 'spring', name: '春季', icon: 'spring', color: '#10b981' },
  { id: 'summer', name: '夏季', icon: 'summer', color: '#f59e0b' },
  { id: 'autumn', name: '秋季', icon: 'autumn', color: '#ef4444' },
  { id: 'winter', name: '冬季', icon: 'winter', color: '#3b82f6' }
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

// 图标路径定义
const iconPaths = {
  back: "M19 12H5M12 19l-7-7 7-7",
  recordTab: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253",
  aiTab: "M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
  health: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z",
  season: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z",
  diet: "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z M12 7v10 M12 12h-5 M12 12h5",
  exercise: "M13 10V3L4 14h7v7l9-11h-7z", // reusing lightning/activity for exercise
  sleep: "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z",
  mood: "M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 018 0z",
  tea: "M18 8h1a4 4 0 0 1 0 8h-1M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z M6 1v3 M10 1v3 M14 1v3",
  massage: "M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3",
  warning: "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
  leaf: "M12 19l9 2-9-18-9 18 9-2zm0 0v-8",
  clipboard: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2",
  default: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
  weight: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z", // same as season/scale-ish
  digestion: "M4 6h16M4 12h16M4 18h16",
  immunity: "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z",
  beauty: "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z",
  energy: "M13 2L3 14h9l-1 8 10-12h-9l1-8z",
  bone: "M18 8a3 3 0 1 0-4.243-4.243 6 6 0 0 0-5.657 0A3 3 0 1 0 3.858 8c0 1.258.653 2.381 1.666 3.033l.476.315.476-.315C7.497 10.381 8.15 9.258 8.15 8a3 3 0 0 1 5.7 0c0 1.258.653 2.381 1.666 3.033l.476.315.476-.315C17.347 10.381 18 9.258 18 8z",
  spring: "M12 19l9 2-9-18-9 18 9-2zm0 0v-8",
  summer: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z",
  autumn: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z", // reuse sun/season
  winter: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z", // reuse sun/season
  idea: "M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
};

// 图标映射
const categoryIcons: Record<string, IconKey> = {
  '饮食建议': 'diet',
  '运动方案': 'exercise',
  '作息调理': 'sleep',
  '情绪管理': 'mood',
  '茶饮推荐': 'tea',
  '穴位按摩': 'massage',
  '注意事项': 'warning',
  '季节养生': 'leaf'
};

onMounted(async () => {
  await loadRecordBasedPlan();
});

const recordCategories = computed(() => {
  return Array.from(new Set(planItems.value.map((item) => item.category).filter(Boolean)));
});

const filteredPlanItems = computed(() => {
  const keyword = recordKeyword.value.trim().toLowerCase();
  return planItems.value.filter((item) => {
    if (recordCategory.value && item.category !== recordCategory.value) {
      return false;
    }
    if (!keyword) {
      return true;
    }
    return [item.category, item.title, item.detail]
      .filter(Boolean)
      .some((text) => text.toLowerCase().includes(keyword));
  });
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

function getCategoryIcon(category: string): IconKey {
  return categoryIcons[category] || 'default';
}

function formatAIResponse(text: string): string {
  // 将换行符转换为<br>
  return text
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>') // 加粗
    .replace(/\*(.*?)\*/g, '<em>$1</em>'); // 斜体
}

async function copyAIResponse() {
  if (!aiResponse.value) return;
  try {
    await navigator.clipboard.writeText(aiResponse.value);
    copyStatus.value = '已复制';
  } catch {
    const textarea = document.createElement('textarea');
    textarea.value = aiResponse.value;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
    copyStatus.value = '已复制';
  } finally {
    setTimeout(() => {
      copyStatus.value = '';
    }, 2000);
  }
}

// AI动态生成方案
async function generateAIDynamic() {
  try {
    aiDynamicLoading.value = true;
    const result = await generateAIDynamicPlan();
    
    if (result.success) {
      // 更新方案列表
      planItems.value = result.items || [];
      constitution.value = result.constitution || constitution.value;
      
      // 显示成功提示
      alert(`AI已根据您最近${result.checkinDays}天的打卡记录生成个性化方案！`);
    } else {
      alert(result.message || 'AI方案生成失败，请稍后重试');
    }
  } catch (error) {
    console.error('AI动态生成失败:', error);
    alert('AI方案生成失败，请确保已完成每日健康打卡');
  } finally {
    aiDynamicLoading.value = false;
  }
}
</script>

<template>
  <div class="plan-container">
    <!-- 动态背景元素 -->
    <div class="bg-blob b1"></div>
    <div class="bg-blob b2"></div>
    
    <!-- 返回首页按钮 -->
    <button @click="goBack" class="back-top-left glass-btn">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>

    <div class="content-wrapper glass-panel">
      <!-- 顶部导航 -->
      <div class="header">
        <h1 class="page-title">个性化养生方案</h1>
        <p class="page-subtitle">AI 驱动的健康生活指南</p>
      </div>

      <!-- Tab 切换 -->
      <div class="tabs-container">
        <div class="tabs">
          <button 
            class="tab-btn" 
            :class="{ active: activeTab === 'record' }"
            @click="activeTab = 'record'"
          >
            <div class="tab-content">
              <svg class="tab-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path :d="iconPaths.recordTab" />
              </svg>
              <span>基于记录</span>
            </div>
          </button>
          <button 
            class="tab-btn" 
            :class="{ active: activeTab === 'ai' }"
            @click="activeTab = 'ai'"
          >
            <div class="tab-content">
              <svg class="tab-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path :d="iconPaths.aiTab" />
              </svg>
              <span>AI 智能生成</span>
            </div>
          </button>
        </div>
      </div>

      <!-- 基于记录的方案 -->
      <transition name="fade-slide" mode="out-in">
        <div v-if="activeTab === 'record'" key="record" class="plan-content">
          <!-- 加载状态 -->
          <div v-if="loading" class="loading-container">
            <div class="loading-spinner"></div>
            <p>正在为您生成专属方案...</p>
          </div>

          <template v-else>
            <!-- 体质卡片 -->
            <div v-if="constitution" class="constitution-card floating-card" :style="{ '--accent': getConstitutionColor() }">
              <div class="constitution-badge">
                {{ constitution }}
              </div>
              <div class="constitution-desc">
                <h3>您的体质类型</h3>
                <p>根据您的测评结果，为您定制专属养生方案</p>
              </div>
              <div class="card-decoration">
                <svg viewBox="0 0 200 200" fill="none">
                  <circle cx="100" cy="100" r="80" stroke="currentColor" stroke-width="20" opacity="0.1"/>
                </svg>
              </div>
            </div>

            <!-- AI动态生成按钮 -->
            <div class="ai-dynamic-section glass-card">
              <div class="ai-dynamic-header">
                <div class="ai-icon-box">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
                  </svg>
                </div>
                <div class="ai-dynamic-text">
                  <h3>AI 实时动态调整</h3>
                  <p>根据您的每日打卡记录，AI 实时生成个性化养生方案</p>
                </div>
                <button 
                  class="ai-generate-btn" 
                  @click="generateAIDynamic"
                  :disabled="aiDynamicLoading"
                >
                  <template v-if="!aiDynamicLoading">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
                    </svg>
                    <span>生成方案</span>
                  </template>
                  <template v-else>
                    <div class="mini-spinner"></div>
                    <span>生成中...</span>
                  </template>
                </button>
              </div>
            </div>

            <div class="plan-toolbar glass-card">
              <div class="plan-search">
                <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="11" cy="11" r="8"/>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                <input v-model="recordKeyword" type="text" placeholder="搜索方案关键词...">
              </div>
              <div class="plan-filter">
                <select v-model="recordCategory" class="custom-select">
                  <option value="">全部分类</option>
                  <option v-for="cat in recordCategories" :key="cat" :value="cat">{{ cat }}</option>
                </select>
              </div>
            </div>

            <div v-if="filteredPlanItems.length === 0" class="plan-empty">
              <div class="empty-icon-box">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                  <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                </svg>
              </div>
              <p>暂无匹配的方案内容</p>
              <button class="reassess-btn" @click="goToAssessment">去测评生成方案</button>
            </div>

            <div v-else class="plan-list">
              <div
                v-for="(item, index) in filteredPlanItems"
                :key="index"
                class="plan-item glass-card"
                :style="{ animationDelay: `${index * 50}ms` }"
              >
                <div class="plan-icon-wrapper">
                  <div class="plan-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path :d="iconPaths[getCategoryIcon(item.category)]" />
                    </svg>
                  </div>
                </div>
                <div class="plan-content-wrapper">
                  <div class="plan-header">
                    <span class="plan-category">{{ item.category }}</span>
                  </div>
                  <h3 class="plan-title">{{ item.title }}</h3>
                  <p class="plan-detail">{{ item.detail }}</p>
                </div>
              </div>
            </div>

            <div class="plan-footer glass-card">
              <div class="footer-tip">
                <div class="tip-icon-box">
                  <svg class="tip-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.idea" />
                  </svg>
                </div>
                <p>养生贵在坚持，建议您每天查看并执行养生方案，保持健康生活方式。</p>
              </div>
              <button class="reassess-btn primary" @click="goToAssessment">
                重新测评
              </button>
            </div>
          </template>
        </div>
      </transition>

      <!-- AI智能方案 -->
      <transition name="fade-slide" mode="out-in">
        <div v-if="activeTab === 'ai'" key="ai" class="ai-content">
          <div class="ai-panel">
            <div class="ai-category-tabs">
              <button 
                class="category-tab" 
                :class="{ active: aiCategory === 'health' }"
                @click="aiCategory = 'health'; aiResponse = ''"
              >
                <svg class="category-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.health" />
                </svg>
                养生需求
              </button>
              <button 
                class="category-tab" 
                :class="{ active: aiCategory === 'season' }"
                @click="aiCategory = 'season'; aiResponse = ''"
              >
                <svg class="category-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.leaf" />
                </svg>
                季节食材建议
              </button>
            </div>

            <transition name="fade" mode="out-in">
              <div v-if="aiCategory === 'health'" key="health" class="category-content">
                <p class="category-subtitle">选择您的养生需求，AI将为您生成专属方案</p>
                <div class="ai-options-grid">
                  <div
                    v-for="option in aiOptions"
                    :key="option.id"
                    class="option-card glass-card"
                    :class="{ selected: selectedOption === option.id, loading: aiLoading && selectedOption === option.id }"
                    @click="!aiLoading && generateAIPlan(option.id)"
                  >
                    <div class="option-icon-box">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path :d="iconPaths[option.icon]" />
                      </svg>
                    </div>
                    <h3 class="option-title">{{ option.title }}</h3>
                    <p class="option-description">{{ option.description }}</p>
                    <div v-if="aiLoading && selectedOption === option.id" class="option-loading-overlay">
                      <div class="mini-spinner"></div>
                    </div>
                  </div>
                </div>
              </div>

              <div v-else key="season" class="category-content">
                <p class="category-subtitle">选择季节，输入食材或药材，获取专业食用建议</p>
                <div class="season-input-section glass-card">
                  <div class="season-selector">
                    <label class="input-label">选择季节</label>
                    <div class="season-options">
                      <button
                        v-for="season in seasonOptions"
                        :key="season.id"
                        class="season-btn"
                        :class="{ selected: selectedSeason === season.id }"
                        :style="{ '--season-color': season.color }"
                        @click="selectedSeason = season.id"
                      >
                        <span class="season-icon">
                          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path :d="iconPaths[season.icon]" />
                          </svg>
                        </span>
                        <span>{{ season.name }}</span>
                      </button>
                    </div>
                  </div>

                  <div class="ingredient-input">
                    <label class="input-label">输入食材或药材</label>
                    <div class="input-with-icon">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="8"/>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                      </svg>
                      <input
                        v-model="ingredientInput"
                        type="text"
                        class="ingredient-field"
                        placeholder="例如：枸杞、山药、红枣、菊花..."
                        @keyup.enter="generateSeasonAdvice"
                      />
                    </div>
                  </div>

                  <button 
                    @click="generateSeasonAdvice" 
                    class="season-submit-btn primary"
                    :disabled="aiLoading || !selectedSeason || !ingredientInput.trim()"
                  >
                    <template v-if="!aiLoading">
                      <span>生成建议</span>
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="5" y1="12" x2="19" y2="12"/>
                        <polyline points="12 5 19 12 12 19"/>
                      </svg>
                    </template>
                    <template v-else>
                      <div class="mini-spinner"></div>
                      <span>思考中...</span>
                    </template>
                  </button>
                </div>
              </div>
            </transition>

            <transition name="slide-up">
              <div v-if="aiResponse" class="ai-response-section glass-card">
                <div class="ai-response-header">
                  <div class="response-title-group">
                    <div class="response-icon-box">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path :d="iconPaths.clipboard" />
                      </svg>
                    </div>
                    <h3>{{ aiCategory === 'health' ? 'AI生成的养生方案' : '食材食用建议' }}</h3>
                  </div>
                  <div class="ai-response-actions">
                    <button class="ai-copy-btn glass-btn small" @click="copyAIResponse">
                      <span v-if="!copyStatus">复制内容</span>
                      <span v-else class="success-text">{{ copyStatus }}</span>
                    </button>
                  </div>
                </div>
                <div class="ai-response-content markdown-body" v-html="formatAIResponse(aiResponse)"></div>
              </div>
            </transition>
          </div>
        </div>
      </transition>
    </div>
  </div>
</template>

<style scoped>
.plan-container {
  --primary-color: #10b981;
  --primary-dark: #059669;
  --primary-light: #d1fae5;
  --accent-color: #3b82f6;
  --text-main: #0f172a;
  --text-sub: #475569;
  --bg-page: #f0fdf4;
  
  min-height: 100vh;
  padding: 40px 20px;
  background: var(--bg-page);
  position: relative;
  overflow: hidden;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  color: var(--text-main);
}

/* 背景装饰 */
.bg-blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  z-index: 0;
  opacity: 0.6;
}
.b1 { top: -10%; left: -10%; width: 50vw; height: 50vw; background: rgba(16, 185, 129, 0.15); animation: float 10s infinite; }
.b2 { bottom: -10%; right: -10%; width: 40vw; height: 40vw; background: rgba(59, 130, 246, 0.15); animation: float 12s infinite reverse; }

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(20px, 20px); }
}

.content-wrapper {
  max-width: 1000px;
  margin: 0 auto;
  position: relative;
  z-index: 1;
}

/* 玻璃拟态面板 */
.glass-panel {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  border-radius: 32px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.05);
}

.glass-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 20px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.glass-card:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.glass-btn {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  padding: 8px 16px;
  font-weight: 600;
  color: var(--text-sub);
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.glass-btn:hover {
  background: white;
  color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.glass-btn.small {
  padding: 6px 12px;
  font-size: 13px;
}

/* 返回按钮 */
.back-top-left {
  position: fixed !important;
  top: 24px !important;
  left: 24px !important;
  z-index: 100;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.page-title {
  font-size: 32px;
  font-weight: 800;
  margin: 0 0 8px;
  background: linear-gradient(135deg, var(--text-main) 0%, var(--text-sub) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.page-subtitle {
  color: var(--text-sub);
  font-size: 16px;
  margin: 0;
}

/* Tabs */
.tabs-container {
  display: flex;
  justify-content: center;
  margin-bottom: 40px;
}

.tabs {
  display: flex;
  background: rgba(255, 255, 255, 0.5);
  padding: 6px;
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.tab-btn {
  padding: 10px 32px;
  border: none;
  background: transparent;
  border-radius: 12px;
  cursor: pointer;
  color: var(--text-sub);
  transition: all 0.3s;
  position: relative;
}

.tab-content {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  font-size: 15px;
  position: relative;
  z-index: 1;
}

.tab-btn.active {
  background: white;
  color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.tab-icon {
  width: 18px;
  height: 18px;
}

/* 体质卡片 */
.constitution-card {
  background: white;
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 24px;
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(0,0,0,0.05);
  box-shadow: 0 10px 30px -10px rgba(0,0,0,0.1);
}

/* AI动态生成区域 */
.ai-dynamic-section {
  padding: 24px;
  margin-bottom: 24px;
}

.ai-dynamic-header {
  display: flex;
  align-items: center;
  gap: 20px;
}

.ai-icon-box {
  width: 56px;
  height: 56px;
  border-radius: 16px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
  box-shadow: 0 8px 20px -6px rgba(16, 185, 129, 0.4);
}

.ai-icon-box svg {
  width: 28px;
  height: 28px;
}

.ai-dynamic-text {
  flex: 1;
}

.ai-dynamic-text h3 {
  margin: 0 0 6px 0;
  font-size: 18px;
  font-weight: 700;
  color: var(--text-main);
}

.ai-dynamic-text p {
  margin: 0;
  font-size: 14px;
  color: var(--text-sub);
}

.ai-generate-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 28px;
  border-radius: 100px;
  border: none;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}

.ai-generate-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.4);
}

.ai-generate-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.ai-generate-btn svg {
  width: 20px;
  height: 20px;
}

.constitution-badge {
  background: var(--accent);
  color: white;
  padding: 12px 24px;
  border-radius: 16px;
  font-size: 20px;
  font-weight: 800;
  box-shadow: 0 8px 20px -6px var(--accent);
  position: relative;
  z-index: 1;
}

.constitution-desc h3 {
  margin: 0 0 6px;
  font-size: 18px;
  color: var(--text-main);
}

.constitution-desc p {
  margin: 0;
  color: var(--text-sub);
  font-size: 14px;
}

.card-decoration {
  position: absolute;
  right: -20px;
  bottom: -40px;
  color: var(--accent);
  opacity: 0.1;
  transform: rotate(-15deg);
}

/* Toolbar */
.plan-toolbar {
  display: flex;
  gap: 16px;
  padding: 16px;
  margin-bottom: 24px;
}

.plan-search {
  flex: 1;
  position: relative;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  color: var(--text-sub);
}

.plan-search input {
  width: 100%;
  padding: 12px 12px 12px 40px;
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: 12px;
  background: rgba(255,255,255,0.5);
  outline: none;
  transition: all 0.3s;
}

.plan-search input:focus {
  background: white;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.custom-select {
  padding: 12px 32px 12px 16px;
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,0.1);
  background: white;
  outline: none;
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='%23475569' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 8px center;
  background-size: 16px;
}

/* Plan List */
.plan-list {
  display: grid;
  gap: 20px;
}

.plan-item {
  display: flex;
  gap: 24px;
  padding: 24px;
  animation: slideUp 0.5s ease-out backwards;
}

.plan-icon-wrapper {
  flex-shrink: 0;
}

.plan-icon {
  width: 56px;
  height: 56px;
  border-radius: 16px;
  background: linear-gradient(135deg, #ecfdf5 0%, #ffffff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(255,255,255,0.8);
}

.plan-icon svg { width: 28px; height: 28px; }

.plan-header { margin-bottom: 8px; }

.plan-category {
  font-size: 12px;
  font-weight: 700;
  color: var(--primary-dark);
  background: rgba(16, 185, 129, 0.1);
  padding: 4px 10px;
  border-radius: 8px;
}

.plan-title {
  margin: 0 0 8px;
  font-size: 18px;
  color: var(--text-main);
}

.plan-detail {
  margin: 0;
  font-size: 14px;
  color: var(--text-sub);
  line-height: 1.6;
}

/* Footer */
.plan-footer {
  margin-top: 40px;
  padding: 24px;
  text-align: center;
}

.footer-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 24px;
  color: #b45309;
}

.tip-icon-box {
  width: 32px;
  height: 32px;
  background: #fef3c7;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #d97706;
}

.tip-icon { width: 18px; height: 18px; }

.reassess-btn {
  padding: 12px 32px;
  border-radius: 100px;
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.reassess-btn.primary {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  color: white;
  box-shadow: 0 8px 20px -6px rgba(16, 185, 129, 0.4);
}

.reassess-btn.primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 24px -8px rgba(16, 185, 129, 0.5);
}

/* AI Options */
.ai-category-tabs {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: 32px;
}

.category-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: 1px solid transparent;
  background: transparent;
  border-radius: 12px;
  color: var(--text-sub);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.category-tab.active {
  background: white;
  color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.category-icon { width: 20px; height: 20px; }

.ai-options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

.option-card {
  padding: 24px;
  text-align: center;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.option-card.selected {
  border-color: var(--primary-color);
  background: rgba(236, 253, 245, 0.6);
}

.option-icon-box {
  width: 48px;
  height: 48px;
  margin: 0 auto 16px;
  background: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}

.option-icon-box svg { width: 24px; height: 24px; }

.option-title { font-size: 16px; margin: 0 0 8px; color: var(--text-main); }
.option-description { font-size: 13px; margin: 0; color: var(--text-sub); }

.option-loading-overlay {
  position: absolute;
  inset: 0;
  background: rgba(255,255,255,0.8);
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Season Input */
.season-options {
  display: flex;
  gap: 12px;
  margin-top: 12px;
  flex-wrap: wrap;
}

.season-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: 1px solid rgba(0,0,0,0.1);
  background: white;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  color: var(--text-sub);
}

.season-btn.selected {
  border-color: var(--season-color);
  color: var(--season-color);
  background: rgba(255,255,255,0.9);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.season-icon { width: 18px; height: 18px; display: flex; }

.ingredient-input { margin: 24px 0; }
.input-label { display: block; font-size: 14px; font-weight: 600; margin-bottom: 8px; }

.input-with-icon {
  position: relative;
}

.input-with-icon svg {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  color: var(--text-sub);
}

.ingredient-field {
  width: 100%;
  padding: 14px 14px 14px 48px;
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: 12px;
  outline: none;
  font-size: 15px;
  transition: all 0.2s;
}

.ingredient-field:focus {
  border-color: var(--primary-color);
  background: white;
}

.season-submit-btn {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 12px;
  background: var(--primary-color);
  color: white;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
}

.season-submit-btn:hover:not(:disabled) {
  background: var(--primary-dark);
}

.season-submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* AI Response */
.ai-response-section {
  margin-top: 32px;
  padding: 32px;
}

.ai-response-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(0,0,0,0.05);
}

.response-title-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.response-icon-box {
  width: 36px;
  height: 36px;
  background: var(--primary-light);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-dark);
}

.response-icon-box svg { width: 20px; height: 20px; }

.ai-response-content {
  font-size: 15px;
  line-height: 1.8;
  color: var(--text-main);
}

/* Animations */
.fade-slide-enter-active, .fade-slide-leave-active {
  transition: all 0.3s ease;
}
.fade-slide-enter-from { opacity: 0; transform: translateX(20px); }
.fade-slide-leave-to { opacity: 0; transform: translateX(-20px); }

.slide-up-enter-active { transition: all 0.4s ease-out; }
.slide-up-enter-from { opacity: 0; transform: translateY(20px); }

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.mini-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(0,0,0,0.1);
  border-top-color: currentColor;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

/* Responsive */
@media (max-width: 768px) {
  .glass-panel { padding: 24px; }
  .plan-item { flex-direction: column; }
  .header { margin-bottom: 24px; }
  .page-title { font-size: 24px; }
  
  .plan-icon {
    margin: 0 auto;
  }

  .plan-toolbar {
    align-items: stretch;
  }

  .plan-filter {
    width: 100%;
    justify-content: space-between;
  }
}

/* AI方案样式 */
.ai-content {
  max-width: 900px;
  margin: 0 auto;
}

.ai-panel {
  background: var(--card-bg);
  border-radius: 24px;
  padding: 40px;
  box-shadow: var(--shadow-card);
  border: 1px solid rgba(255, 255, 255, 0.5);
}

/* AI分类切换 */
.ai-category-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 32px;
  background: var(--option-bg);
  padding: 6px;
  border-radius: 16px;
}

.category-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 14px 24px;
  border: none;
  background: transparent;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-sub);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.category-tab:hover {
  background: rgba(255, 255, 255, 0.5);
  color: var(--primary-color);
}

.category-tab.active {
  background: white;
  color: var(--primary-color);
  box-shadow: var(--shadow-card);
}

.category-icon {
  width: 20px;
  height: 20px;
}

.category-content {
  margin-top: 24px;
}

.category-subtitle {
  text-align: center;
  color: var(--text-sub);
  font-size: 16px;
  margin: 0 0 32px 0;
}

/* 选项卡片网格 */
.ai-options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.option-card {
  background: var(--card-bg);
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 32px 24px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  box-shadow: var(--shadow-card);
}

.option-card:hover {
  border-color: var(--primary-color);
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
}

.option-card.selected {
  border-color: var(--primary-color);
  background: var(--primary-light);
  box-shadow: var(--shadow-card);
}

.option-card.loading {
  pointer-events: none;
  opacity: 0.8;
}

.option-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
  color: var(--primary-color);
  background: rgba(16, 185, 129, 0.1);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px;
}

.option-title {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-main);
  margin: 0 0 8px 0;
}

.option-description {
  font-size: 14px;
  color: var(--text-sub);
  margin: 0;
  line-height: 1.6;
}

.option-loading {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  font-size: 14px;
  color: var(--primary-color);
  font-weight: 600;
}

.mini-spinner {
  width: 24px;
  height: 24px;
  border: 3px solid #e9ecef;
  border-top-color: var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.ai-response-section {
  margin-top: 40px;
  padding-top: 40px;
  border-top: 1px solid #e2e8f0;
}

.ai-response-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 24px;
}

.ai-response-header h3 {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 20px;
  font-weight: 700;
  color: var(--text-main);
  margin: 0;
}

.ai-response-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ai-copy-btn {
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 8px 16px;
  background: white;
  color: var(--text-sub);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.ai-copy-btn:hover {
  background: var(--primary-light);
  color: var(--text-main);
}

.ai-copy-status {
  font-size: 13px;
  color: var(--primary-color);
  font-weight: 600;
}

.response-icon {
  width: 24px;
  height: 24px;
  color: var(--primary-color);
}

.ai-response-content {
  background: var(--option-bg);
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 32px;
  color: var(--text-main);
  font-size: 16px;
  line-height: 1.8;
  white-space: pre-wrap;
}

/* 季节食材建议 */
.season-input-section {
  max-width: 800px;
  margin: 0 auto;
}

.input-label {
  display: block;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 16px;
}

.season-selector {
  margin-bottom: 32px;
}

.season-options {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.season-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 20px;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  background: white;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 15px;
  font-weight: 600;
  color: var(--text-sub);
}

.season-btn:hover {
  border-color: var(--primary-color);
  transform: translateY(-2px);
  box-shadow: var(--shadow-hover);
}

.season-btn.selected {
  background: var(--primary-light);
  border-color: var(--primary-color) !important;
  color: var(--primary-color);
  box-shadow: var(--shadow-card);
}

.season-icon {
  width: 32px;
  height: 32px;
}

.ingredient-input {
  margin-bottom: 32px;
}

.ingredient-field {
  width: 100%;
  padding: 16px 20px;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  font-size: 16px;
  color: var(--text-main);
  transition: all 0.3s;
  background: var(--option-bg);
}

.ingredient-field:focus {
  outline: none;
  border-color: var(--primary-color);
  background: white;
  box-shadow: 0 0 0 4px var(--primary-light);
}

.ingredient-field::placeholder {
  color: #94a3b8;
}

.season-submit-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  background: var(--primary-color);
  color: white;
  border: none;
  border-radius: 16px;
  padding: 16px 32px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}

.season-submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  background: var(--primary-dark);
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.4);
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
