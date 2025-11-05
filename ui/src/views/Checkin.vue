<template>
  <div class="checkin-container">
    <!-- 返回首页按钮 -->
    <div class="back-to-home">
      <button @click="goHome" class="back-btn">
        ← 返回首页
      </button>
    </div>

    <!-- 已打卡提示弹窗（样式2） -->
    <div v-if="showAlreadyChecked" class="checked-modal-overlay" @click="closeAlreadyChecked">
      <div class="checked-modal" @click.stop>
        <div class="checked-icon">✔️</div>
        <h3 class="checked-title">今日已打卡</h3>
        <p class="checked-message">今日数据已记录并同步到仪表盘</p>
        <div class="checked-actions">
          <button @click="closeAlreadyChecked" class="btn-primary">查看仪表盘</button>
          <button @click="showAlreadyChecked = false" class="btn-secondary">关闭</button>
        </div>
      </div>
    </div>

    <!-- 成功提示弹窗 -->
    <div v-if="showSuccessModal" class="success-modal-overlay" @click="closeSuccessModal">
      <div class="success-modal" @click.stop>
        <div class="success-animation">
          <div class="success-checkmark">
            <div class="check-icon">
              <span class="icon-line line-tip"></span>
              <span class="icon-line line-long"></span>
            </div>
          </div>
        </div>
        <div class="success-content">
          <h3 class="success-title">打卡成功！</h3>
          <p class="success-message">您的健康数据已成功记录</p>
          <div class="success-details">
            <div class="detail-item">
              <span class="detail-icon">📅</span>
              <span class="detail-text">{{ getCurrentDate() }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-icon">⏰</span>
              <span class="detail-text">{{ formatTime(new Date()) }}</span>
            </div>
          </div>
        </div>
        <div class="success-actions">
          <button @click="continueCheckin" class="btn-continue">继续打卡</button>
          <button @click="goHome" class="btn-home">返回首页</button>
        </div>
      </div>
    </div>

    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <span class="title-icon">✅</span>
          养生打卡
        </h1>
        <p class="page-subtitle">记录每日养生状态，AI智能分析您的健康趋势</p>
      </div>
    </div>

    <!-- 双栏布局：左侧打卡，右侧近7天历史 -->
    <div class="checkin-main" v-if="!showResult">
      <div class="left-panel">
        <div class="checkin-form-card">
          <div class="form-header">
            <h2>今日打卡</h2>
            <div class="date">{{ getCurrentDate() }}</div>
          </div>

          <div class="form-content">
            <!-- 睡眠时长 -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">😴</span>
                睡眠时长
              </label>
              <div class="slider-container">
                <input
                  type="range"
                  v-model="checkinData.sleepHours"
                  min="0"
                  max="12"
                  step="0.5"
                  class="slider"
                >
                <div class="slider-value">{{ checkinData.sleepHours }} 小时</div>
              </div>
            </div>

            <!-- 入睡时间 -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🌙</span>
                入睡时间
              </label>
              <input
                type="time"
                v-model="checkinData.sleepTime"
                class="time-input"
              >
            </div>

            <!-- 今日症状 -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🤒</span>
                今日症状
              </label>
              <div class="multi-select">
                <div
                  v-for="symptom in symptoms"
                  :key="symptom"
                  class="symptom-tag"
                  :class="{ active: checkinData.symptoms.includes(symptom) }"
                  @click="toggleSymptom(symptom)"
                >
                  {{ symptom }}
                </div>
              </div>
            </div>

            <!-- 情绪 -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">😊</span>
                情绪状态
              </label>
              <div class="emoji-options">
                <div
                  v-for="(mood, index) in moods"
                  :key="index"
                  class="emoji-option"
                  :class="{ active: checkinData.mood === index }"
                  @click="checkinData.mood = index"
                >
                  <span class="emoji">{{ mood.emoji }}</span>
                  <span class="mood-text">{{ mood.name }}</span>
                </div>
              </div>
            </div>

            <!-- 运动分钟 -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🏃</span>
                运动时长
              </label>
              <div class="number-input">
                <button @click="adjustExercise(-10)" class="adjust-btn">-</button>
                <input
                  type="number"
                  v-model="checkinData.exerciseMinutes"
                  min="0"
                  max="300"
                  class="number-field"
                >
                <button @click="adjustExercise(10)" class="adjust-btn">+</button>
                <span class="unit">分钟</span>
              </div>
            </div>

            <!-- 饮食简记 -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🍽️</span>
                饮食记录
              </label>
              <textarea
                v-model="checkinData.dietNotes"
                placeholder="简单记录今日饮食，如：早餐小米粥，午餐青菜炒肉..."
                class="diet-textarea"
                rows="3"
              ></textarea>
            </div>

          </div>

          <!-- 提交按钮 -->
          <div class="form-actions">
            <button
              @click="submitCheckin"
              :disabled="loading || !isFormValid"
              class="submit-btn"
              :class="{ loading: loading }"
            >
              <span v-if="!loading">提交打卡</span>
              <span v-else>提交中...</span>
            </button>
          </div>
        </div>
      </div>

      <aside class="right-panel">
        <div class="history-panel">
          <h3 class="history-title">近7天打卡历史</h3>
          <div class="history-list">
            <div
              v-for="record in checkinHistory"
              :key="record.date"
              class="history-item"
            >
              <div class="history-date">{{ record.date }}</div>
              <div class="history-summary">
                <span class="history-score" v-if="record.healthScore !== undefined">健康分 {{ record.healthScore }}</span>
                <span class="history-text" v-else>{{ record.summary }}</span>
              </div>
            </div>
          </div>
        </div>
      </aside>
    </div>

    <!-- AI分析结果 -->
    <div class="result-card" v-if="showResult && analysisResult">
      <div class="result-header">
        <h2>AI健康分析报告</h2>
        <div class="analysis-time">{{ formatTime(new Date()) }}</div>
      </div>

      <div class="result-content">
        <!-- 一句话总结 -->
        <div class="summary-section">
          <h3>
            <span class="section-icon">💡</span>
            今日健康总结
          </h3>
          <div class="summary-text">{{ analysisResult.summary }}</div>
        </div>

        <!-- 健康趋势图表 -->
        <div class="chart-section">
          <h3>
            <span class="section-icon">📊</span>
            近7天健康趋势
          </h3>
          <div class="chart-container">
            <canvas ref="chartCanvas" width="400" height="200"></canvas>
          </div>
        </div>

        <!-- 个性化建议 -->
        <div class="suggestions-section">
          <h3>
            <span class="section-icon">🎯</span>
            个性化建议
          </h3>
          <div class="suggestions-list">
            <div
              v-for="(suggestion, index) in analysisResult.suggestions"
              :key="index"
              class="suggestion-item"
            >
              <span class="suggestion-icon">{{ suggestion.icon }}</span>
              <div class="suggestion-content">
                <h4>{{ suggestion.title }}</h4>
                <p>{{ suggestion.content }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- 明日方案 -->
        <div class="plan-section">
          <h3>
            <span class="section-icon">📅</span>
            明日养生方案
          </h3>
          <div class="plan-content">{{ analysisResult.tomorrowPlan }}</div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="result-actions">
        <button @click="resetForm" class="secondary-btn">重新打卡</button>
        <button @click="goHome" class="primary-btn">返回首页</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { postCheckin, getCheckinSummary, getHealthTrends } from '../services/api';

// 类型定义
interface HealthTrend {
  date: string;
  healthScore: number;
  summary?: string;
}

interface Suggestion {
  icon: string;
  title: string;
  content: string;
}

interface AnalysisResult {
  summary: string;
  suggestions: Suggestion[];
  healthScore?: number;
  tomorrowPlan: string;
}

const router = useRouter();

// 响应式数据
const loading = ref(false);
const showResult = ref(false);
const showSuccessModal = ref(false);
const showAlreadyChecked = ref(false);
const analysisResult = ref<AnalysisResult | null>(null);
const checkinHistory = ref<HealthTrend[]>([]);
const chartCanvas = ref<HTMLCanvasElement>();

// 打卡数据
const checkinData = ref({
  sleepHours: 8,
  sleepTime: '23:00',
  symptoms: [] as string[],
  mood: 2,
  exerciseMinutes: 30,
  dietNotes: ''
});

// 选项数据
const symptoms = [
  '头痛', '疲劳', '失眠', '食欲不振', '腹胀', '便秘', '腹泻',
  '口干', '怕冷', '怕热', '出汗多', '心悸', '无症状'
];

const moods = [
  { emoji: '😢', name: '很差' },
  { emoji: '😕', name: '一般' },
  { emoji: '😊', name: '良好' },
  { emoji: '😄', name: '很好' },
  { emoji: '🤩', name: '极佳' }
];

// 计算属性
const isFormValid = computed(() => {
  return checkinData.value.sleepTime &&
         checkinData.value.sleepHours > 0 &&
         checkinData.value.mood !== null;
});

// 方法
const goHome = () => {
  router.push('/dashboard');
};

const getCurrentDate = () => {
  return new Date().toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  });
};

const formatTime = (date: Date) => {
  return date.toLocaleString('zh-CN');
};

const toggleSymptom = (symptom: string) => {
  const index = checkinData.value.symptoms.indexOf(symptom);
  if (index > -1) {
    checkinData.value.symptoms.splice(index, 1);
  } else {
    checkinData.value.symptoms.push(symptom);
  }
};

const adjustExercise = (amount: number) => {
  const newValue = checkinData.value.exerciseMinutes + amount;
  if (newValue >= 0 && newValue <= 300) {
    checkinData.value.exerciseMinutes = newValue;
  }
};

const submitCheckin = async () => {
  if (!isFormValid.value || loading.value) return;
  loading.value = true;

  try {
    const submitData = {
      ...checkinData.value,
      sleepHours: Number(checkinData.value.sleepHours),
      mood: Number(checkinData.value.mood),
      exerciseMinutes: Number(checkinData.value.exerciseMinutes),
      date: new Date().toISOString().split('T')[0]
    };

    const response = await postCheckin(submitData);

    if (response.success) {
      showSuccessModal.value = true;
    } else {
      const msg = response.message || '未知错误';
      if (msg.includes('今日已打卡')) {
        showAlreadyChecked.value = true;
      } else {
        alert('打卡失败：' + msg);
      }
    }
  } catch (error) {
    console.error('提交打卡失败:', error);
    alert('提交失败，请检查网络连接后重试');
  } finally {
    loading.value = false;
  }
};

const closeSuccessModal = () => {
  showSuccessModal.value = false;
};

const closeAlreadyChecked = () => {
  showAlreadyChecked.value = false;
  // 跳转仪表盘，让用户查看数据
  router.push('/dashboard-metrics');
};

const continueCheckin = () => {
  showSuccessModal.value = false;
  resetForm();
};

const resetForm = () => {
  showResult.value = false;
  analysisResult.value = null;
  // 重置表单数据
  checkinData.value = {
    sleepHours: 8,
    sleepTime: '23:00',
    symptoms: [],
    mood: 2,
    exerciseMinutes: 30,
    dietNotes: ''
  };
};

const drawHealthChart = async () => {
  if (!chartCanvas.value) return;

  const ctx = chartCanvas.value.getContext('2d');
  if (!ctx) return;

  try {
    // 获取真实的健康趋势数据
    const trendsResponse = await getHealthTrends(7);
    const trendsData = trendsResponse.trends || [];

    // 清空画布
    ctx.clearRect(0, 0, 400, 200);

    // 绘制坐标轴
    ctx.strokeStyle = '#e9ecef';
    ctx.lineWidth = 1;

    // Y轴
    ctx.beginPath();
    ctx.moveTo(40, 20);
    ctx.lineTo(40, 180);
    ctx.stroke();

    // X轴
    ctx.beginPath();
    ctx.moveTo(40, 180);
    ctx.lineTo(380, 180);
    ctx.stroke();

    if (trendsData.length > 0) {
      // 绘制真实数据线
      ctx.strokeStyle = '#667eea';
      ctx.lineWidth = 3;
      ctx.beginPath();

      trendsData.forEach((item: HealthTrend, index: number) => {
        const x = 60 + index * (320 / Math.max(trendsData.length - 1, 1));
        const y = 180 - ((item.healthScore || 70) - 50) * 2.6; // 缩放到图表高度

        if (index === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }

        // 绘制数据点
        ctx.fillStyle = '#667eea';
        ctx.beginPath();
        ctx.arc(x, y, 4, 0, Math.PI * 2);
        ctx.fill();

        // 显示数值
        ctx.fillStyle = '#495057';
        ctx.font = '11px Arial';
        ctx.textAlign = 'center';
        ctx.fillText((item.healthScore || 70).toString(), x, y - 8);
      });

      ctx.stroke();

      // 添加日期标签
      ctx.fillStyle = '#6c757d';
      ctx.font = '12px Arial';
      ctx.textAlign = 'center';

      trendsData.forEach((item: HealthTrend, index: number) => {
        const x = 60 + index * (320 / Math.max(trendsData.length - 1, 1));
        const date = new Date(item.date);
        const dayNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
        const dayName = dayNames[date.getDay()];
        ctx.fillText(dayName || '', x, 195);
      });
    } else {
      // 如果没有数据，显示提示信息
      ctx.fillStyle = '#6c757d';
      ctx.font = '14px Arial';
      ctx.textAlign = 'center';
      ctx.fillText('暂无数据，请先进行打卡', 200, 100);
    }
  } catch (error) {
    console.error('绘制图表失败:', error);
    // 显示错误提示
    ctx.fillStyle = '#dc3545';
    ctx.font = '14px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('数据加载失败', 200, 100);
  }
};

const loadCheckinHistory = async () => {
  try {
    // 首选：从趋势接口获取最近 7 天
    const t = await getHealthTrends(7);
    const rows = (t?.trends ?? []) as any[];

    checkinHistory.value = rows.map((r: any) => {
      const date = r.date || r.checkin_date || r.checkinDate || '';
      const score = r.healthScore ?? r.health_score;
      const summary = r.summary ?? (score !== undefined ? `健康分 ${score}` : '已打卡');
      return { date, healthScore: score, summary } as HealthTrend;
    });
  } catch (err) {
    console.warn('getHealthTrends(7) 失败，回退到 summary.history:', err);
    try {
      const summary = await getCheckinSummary();
      const list: any[] = summary?.history ?? [];
      // 只取最近 7 条
      checkinHistory.value = list.slice(-7).map((r: any) => ({
        date: r.date || '',
        healthScore: r.healthScore ?? r.health_score,
        summary: r.summary ?? '已打卡'
      }));
    } catch (e) {
      console.error('加载历史记录失败:', e);
      checkinHistory.value = [];
    }
  }
};

onMounted(() => {
  loadCheckinHistory();
  // 引用一次以消除“未使用”警告，存在画布时绘制
  if (chartCanvas.value) {
    drawHealthChart();
  }
});

// 结果卡片显示后再绘制图表，确保 canvas 已挂载
watch(showResult, async (v) => {
  if (v) {
    await nextTick();
    drawHealthChart();
  }
});
</script>

<style scoped>
.checkin-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  position: relative;
}

.checkin-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="75" cy="75" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="50" cy="10" r="0.5" fill="rgba(255,255,255,0.05)"/><circle cx="20" cy="80" r="0.5" fill="rgba(255,255,255,0.05)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  pointer-events: none;
}

/* 返回首页按钮 */
.back-to-home {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 100;
}

.back-btn {
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: 10px 20px;
  border-radius: 25px;
  color: white;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  backdrop-filter: blur(15px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

/* 页面头部 */
.page-header {
  text-align: center;
  margin-bottom: 40px;
  padding-top: 60px;
  position: relative;
  z-index: 1;
}

.header-content {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(15px);
  border-radius: 25px;
  padding: 40px 30px;
  margin: 0 auto;
  max-width: 600px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  animation: fadeInUp 0.8s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.page-title {
  color: white;
  font-size: 2.8rem;
  margin: 0 0 15px 0;
  font-weight: 700;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.title-icon {
  margin-right: 15px;
  display: inline-block;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

.page-subtitle {
  color: rgba(255, 255, 255, 0.95);
  font-size: 1.2rem;
  margin: 0;
  font-weight: 400;
  text-shadow: 0 1px 5px rgba(0, 0, 0, 0.1);
}

/* 打卡表单卡片 */
.checkin-form-card {
  background: rgba(255, 255, 255, 0.98);
  border-radius: 25px;
  padding: 40px;
  margin: 0 auto 30px;
  max-width: 800px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 1;
  animation: slideInUp 0.6s ease-out;
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(50px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 35px;
  padding-bottom: 25px;
  border-bottom: 3px solid #f0f4f8;
  position: relative;
}

.form-header::after {
  content: '';
  position: absolute;
  bottom: -3px;
  left: 0;
  width: 60px;
  height: 3px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
}

.form-header h2 {
  color: #2d3748;
  margin: 0;
  font-size: 2rem;
  font-weight: 700;
}

.date {
  color: #718096;
  font-weight: 600;
  font-size: 1.1rem;
  background: #f7fafc;
  padding: 8px 16px;
  border-radius: 15px;
}

/* 表单组 */
.form-group {
  margin-bottom: 25px;
}

.form-label {
  display: flex;
  align-items: center;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 12px;
}

.label-icon {
  margin-right: 8px;
  font-size: 1.2rem;
}

/* 滑块 */
.slider-container {
  display: flex;
  align-items: center;
  gap: 15px;
}

.slider {
  flex: 1;
  height: 6px;
  border-radius: 3px;
  background: #e9ecef;
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #667eea;
  cursor: pointer;
}

.slider-value {
  background: #667eea;
  color: white;
  padding: 5px 12px;
  border-radius: 15px;
  font-size: 0.9rem;
  font-weight: 500;
  min-width: 80px;
  text-align: center;
}

/* 时间输入 */
.time-input {
  width: 150px;
  padding: 10px 15px;
  border: 2px solid #e9ecef;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.time-input:focus {
  outline: none;
  border-color: #667eea;
}

/* 文字选项样式 */
.text-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 12px;
  margin-top: 8px;
}

.text-option {
  padding: 12px 16px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: center;
  background: white;
}

.text-option:hover {
  border-color: #667eea;
  background: #f8f9ff;
}

.text-option.active {
  border-color: #667eea;
  background: #667eea;
  color: white;
}

.text-option .option-text {
  font-size: 14px;
  font-weight: 500;
}

/* 多选标签 */
.multi-select {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.symptom-tag {
  padding: 8px 16px;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.symptom-tag:hover {
  border-color: #667eea;
}

.symptom-tag.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

/* 表情选项 */
.emoji-options {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.emoji-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 80px;
}

.emoji-option:hover {
  border-color: #667eea;
  transform: scale(1.05);
}

.emoji-option.active {
  border-color: #667eea;
  background: rgba(102, 126, 234, 0.1);
}

.emoji {
  font-size: 2rem;
  margin-bottom: 5px;
}

.mood-text {
  font-size: 0.9rem;
  color: #6c757d;
}

/* 数字输入 */
.number-input {
  display: flex;
  align-items: center;
  gap: 10px;
}

.adjust-btn {
  width: 40px;
  height: 40px;
  border: 2px solid #667eea;
  background: white;
  color: #667eea;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.2rem;
  font-weight: bold;
  transition: all 0.3s ease;
}

.adjust-btn:hover {
  background: #667eea;
  color: white;
}

.number-field {
  width: 80px;
  padding: 10px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  text-align: center;
  font-size: 1rem;
}

.number-field:focus {
  outline: none;
  border-color: #667eea;
}

.unit {
  color: #6c757d;
  font-weight: 500;
}

/* 文本域 */
.diet-textarea {
  width: 100%;
  padding: 15px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  font-size: 1rem;
  font-family: inherit;
  resize: vertical;
  transition: border-color 0.3s ease;
}

.diet-textarea:focus {
  outline: none;
  border-color: #667eea;
}

/* 单选按钮 */
.radio-options {
  display: flex;
  gap: 20px;
}

.radio-option {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.radio-option input[type="radio"] {
  margin-right: 8px;
  transform: scale(1.2);
}

.radio-text {
  font-size: 1rem;
  color: #2c3e50;
}

/* 提交按钮 */
.form-actions {
  text-align: center;
  margin-top: 30px;
}

.submit-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 15px 40px;
  border-radius: 25px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 200px;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.submit-btn.loading {
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

/* 结果卡片 */
.result-card {
  background: white;
  border-radius: 20px;
  padding: 30px;
  margin: 0 auto;
  max-width: 900px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #f8f9fa;
}

.result-header h2 {
  color: #2c3e50;
  margin: 0;
  font-size: 1.8rem;
}

.analysis-time {
  color: #6c757d;
  font-size: 0.9rem;
}

.result-content {
  margin-bottom: 30px;
}

/* 各个结果部分 */
.summary-section,
.chart-section,
.suggestions-section,
.plan-section {
  margin-bottom: 30px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 15px;
}

.summary-section h3,
.chart-section h3,
.suggestions-section h3,
.plan-section h3 {
  display: flex;
  align-items: center;
  color: #2c3e50;
  margin: 0 0 15px 0;
  font-size: 1.3rem;
}

.section-icon {
  margin-right: 10px;
  font-size: 1.4rem;
}

.summary-text,
.plan-content {
  font-size: 1.1rem;
  line-height: 1.6;
  color: #495057;
}

/* 图表容器 */
.chart-container {
  background: white;
  border-radius: 10px;
  padding: 20px;
  text-align: center;
}

/* 建议列表 */
.suggestions-list {
  display: grid;
  gap: 15px;
}

.suggestion-item {
  display: flex;
  align-items: flex-start;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.suggestion-icon {
  font-size: 1.5rem;
  margin-right: 15px;
  margin-top: 2px;
}

.suggestion-content h4 {
  margin: 0 0 8px 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.suggestion-content p {
  margin: 0;
  color: #6c757d;
  line-height: 1.5;
}

/* 操作按钮 */
.result-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.secondary-btn,
.primary-btn {
  padding: 12px 30px;
  border-radius: 20px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.secondary-btn {
  background: white;
  color: #667eea;
  border: 2px solid #667eea;
}

.secondary-btn:hover {
  background: #667eea;
  color: white;
}

.primary-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
}

.primary-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

/* 历史记录（旧块样式保留用于通用类，但不再使用该块） */
.history-section {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 25px;
  margin: 0 auto;
  max-width: 800px;
}

.history-section h3 {
  color: white;
  margin: 0 0 20px 0;
  font-size: 1.5rem;
}

.history-list {
  display: grid;
  gap: 10px;
}

.history-item {
  background: rgba(255, 255, 255, 0.1);
  padding: 15px 20px;
  border-radius: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* 已打卡样式2 */
.checked-modal-overlay {
  position: fixed; inset: 0;
  background: rgba(17, 24, 39, 0.4);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000;
}
.checked-modal {
  background: #ffffff;
  border-radius: 16px;
  box-shadow: 0 10px 25px rgba(16, 24, 40, 0.2);
  width: 420px;
  padding: 24px 20px;
  text-align: center;
  animation: slideIn 260ms ease-out;
}
.checked-icon {
  font-size: 36px;
  margin-bottom: 8px;
}
.checked-title {
  font-size: 20px;
  font-weight: 700;
  color: #101828;
  margin: 0 0 8px 0;
}
.checked-message {
  font-size: 14px;
  color: #475467;
  margin-bottom: 16px;
}
.checked-actions {
  display: flex; gap: 12px; justify-content: center;
}
.btn-primary {
  background: #4f73ff; color: #fff; border: none;
  padding: 10px 16px; border-radius: 10px; cursor: pointer;
}
.btn-secondary {
  background: #e7eaf6; color: #344054; border: none;
  padding: 10px 16px; border-radius: 10px; cursor: pointer;
}
@keyframes slideIn {
  from { transform: translateY(16px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

/* 成功提示弹窗样式 */
.success-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

.success-modal {
  background: white;
  border-radius: 20px;
  padding: 40px;
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.4s ease;
}

.success-animation {
  margin-bottom: 30px;
}

.success-checkmark {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: block;
  stroke-width: 2;
  stroke: #4CAF50;
  stroke-miterlimit: 10;
  margin: 0 auto 20px;
  box-shadow: inset 0px 0px 0px #4CAF50;
  animation: fill 0.4s ease-in-out 0.4s forwards, scale 0.3s ease-in-out 0.9s both;
  position: relative;
}

.success-checkmark .check-icon {
  width: 80px;
  height: 80px;
  position: relative;
  border-radius: 50%;
  box-sizing: content-box;
  border: 4px solid #4CAF50;
}

.success-checkmark .check-icon::before {
  top: 3px;
  left: -2px;
  width: 30px;
  transform-origin: 100% 50%;
  border-radius: 100px 0 0 100px;
}

.success-checkmark .check-icon::after {
  top: 0;
  left: 30px;
  width: 60px;
  transform-origin: 0 50%;
  border-radius: 0 100px 100px 0;
  animation: rotate-circle 4.25s ease-in;
}

.success-checkmark .check-icon::before,
.success-checkmark .check-icon::after {
  content: '';
  height: 100px;
  position: absolute;
  background: white;
  transform: rotate(-45deg);
}

.success-checkmark .icon-line {
  height: 5px;
  background-color: #4CAF50;
  display: block;
  border-radius: 2px;
  position: absolute;
  z-index: 10;
}

.success-checkmark .icon-line.line-tip {
  top: 46px;
  left: 14px;
  width: 25px;
  transform: rotate(45deg);
  animation: icon-line-tip 0.75s;
}

.success-checkmark .icon-line.line-long {
  top: 38px;
  right: 8px;
  width: 47px;
  transform: rotate(-45deg);
  animation: icon-line-long 0.75s;
}

.success-content {
  margin-bottom: 30px;
}

.success-title {
  color: #2c3e50;
  font-size: 1.8rem;
  margin: 0 0 10px 0;
  font-weight: 600;
}

.success-message {
  color: #6c757d;
  font-size: 1rem;
  margin: 0 0 20px 0;
  line-height: 1.5;
}

.success-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
  background: #f8f9fa;
  padding: 15px;
  border-radius: 10px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 0.9rem;
  color: #495057;
}

.detail-icon {
  font-size: 1.1rem;
}

.success-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.btn-continue,
.btn-home {
  padding: 12px 24px;
  border-radius: 25px;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
}

.btn-continue {
  background: #f8f9fa;
  color: #6c757d;
  border: 2px solid #e9ecef;
}

.btn-continue:hover {
  background: #e9ecef;
  color: #495057;
  transform: translateY(-1px);
}

/* 双栏布局与右侧历史卡片样式 */
.checkin-main {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 24px;
  align-items: start;
  margin-top: 12px;
}

.left-panel {
  min-width: 0;
}

.right-panel {
  position: sticky;
  top: 84px; /* 保持在视口内 */
  align-self: start;
}

/* 右侧历史卡片 */
.history-panel {
  background: rgba(255, 255, 255, 0.82);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 18px 16px;
  box-shadow: 0 14px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.history-title {
  margin: 0 0 12px 0;
  color: #2c3e50;
  font-size: 16px;
  font-weight: 700;
}

.history-list {
  display: grid;
  gap: 10px;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8f9fa;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid #e9ecef;
}

.history-date {
  color: #495057;
  font-weight: 600;
  font-size: 13px;
}

.history-summary {
  display: flex;
  gap: 8px;
  align-items: center;
}

.history-score {
  background: #e9f5ff;
  color: #0b6dbe;
  border: 1px solid #cfe8ff;
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 600;
}

.history-text {
  color: #6c757d;
  font-size: 12px;
}

/* 移动端：自动回到单列 */
@media (max-width: 768px) {
  .checkin-main {
    grid-template-columns: 1fr;
  }
  .right-panel {
    position: static;
  }
}
</style>
