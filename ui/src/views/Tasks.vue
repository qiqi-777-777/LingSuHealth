<template>
  <div class="tasks-page">
    <!-- 头部 -->
    <header class="page-header">
      <div class="header-content">
        <button class="back-btn" @click="$router.back()">
          <span class="icon">←</span>
        </button>
        <h1>任务中心</h1>
        <div class="header-spacer"></div>
      </div>
    </header>

    <!-- 内容区 -->
    <main class="page-content">
      <!-- 计划状态卡片 -->
      <section class="plan-status-card" v-if="planData">
        <div class="plan-header">
          <div class="plan-info">
            <h2>{{ planData.plan?.planName || '7天养生计划' }}</h2>
            <span class="constitution-badge">{{ planData.plan?.constitution || '平和质' }}</span>
          </div>
          <div class="plan-progress">
            <div class="progress-ring">
              <svg viewBox="0 0 100 100">
                <circle class="bg" cx="50" cy="50" r="40" />
                <circle class="fg" cx="50" cy="50" r="40" 
                  :style="{ strokeDashoffset: 251 - (251 * progressPercent / 100) }" />
              </svg>
              <span class="progress-text">{{ progressPercent }}%</span>
            </div>
          </div>
        </div>
        <div class="plan-dates" v-if="planData.plan">
          <span>{{ planData.plan.startDate }} ~ {{ planData.plan.endDate }}</span>
        </div>
      </section>

      <!-- 无计划提示 -->
      <section class="no-plan-card" v-else-if="!loading && !hasPlan">
        <div class="no-plan-icon">📋</div>
        <h3>暂无进行中的计划</h3>
        <p>根据您的体质生成专属7天养生计划</p>
        <button class="generate-btn" @click="generatePlan" :disabled="generating">
          {{ generating ? '生成中...' : '生成7天计划' }}
        </button>
      </section>

      <!-- 日期选择器 -->
      <section class="date-tabs" v-if="hasPlan && dailyProgress">
        <div class="date-tab" 
             v-for="(day, date) in dailyProgress" 
             :key="date"
             :class="{ active: selectedDate === date, today: day.isToday, past: day.isPast }"
             @click="selectDate(date)">
          <span class="day-num">{{ getDayNum(date) }}</span>
          <span class="day-name">{{ getDayName(day.dayOfWeek) }}</span>
          <div class="day-progress" :style="{ width: day.progress + '%' }"></div>
        </div>
      </section>

      <!-- 今日任务列表 -->
      <section class="tasks-section" v-if="hasPlan">
        <div class="section-header">
          <h3>{{ selectedDate === todayStr ? '今日任务' : formatDate(selectedDate) }}</h3>
          <span class="task-count">{{ completedCount }}/{{ totalCount }}</span>
        </div>

        <div class="task-list" v-if="currentTasks.length > 0">
          <div class="task-item" 
               v-for="task in currentTasks" 
               :key="task.id"
               :class="{ completed: task.isCompleted }">
            <div class="task-checkbox" @click="toggleTask(task)">
              <span class="check-icon" v-if="task.isCompleted">✓</span>
            </div>
            <div class="task-content">
              <div class="task-title">{{ task.title }}</div>
              <div class="task-desc">{{ task.description }}</div>
              <div class="task-meta">
                <span class="task-category">{{ task.category }}</span>
                <span class="task-intensity">{{ task.intensity }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="empty-tasks" v-else>
          <p>该日暂无任务</p>
        </div>
      </section>

      <!-- 快捷操作 -->
      <section class="quick-actions" v-if="hasPlan">
        <button class="action-btn checkin" @click="$router.push('/checkin')">
          <span class="action-icon">📝</span>
          <span>去打卡</span>
        </button>
        <button class="action-btn report" @click="$router.push('/weekly-report')">
          <span class="action-icon">📊</span>
          <span>周报</span>
        </button>
      </section>
    </main>

    <!-- Loading -->
    <div class="loading-overlay" v-if="loading">
      <div class="loader"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { get7DayPlan, generate7DayPlan, completeTask, uncompleteTask } from '../services/api';

interface Task {
  id: number;
  title: string;
  description: string;
  category: string;
  intensity: string;
  isCompleted: boolean;
  targetValue: number;
  actualValue: number;
}

interface DayProgress {
  date: string;
  dayOfWeek: number;
  total: number;
  completed: number;
  progress: number;
  isToday: boolean;
  isPast: boolean;
}

const loading = ref(true);
const generating = ref(false);
const hasPlan = ref(false);
const planData = ref<any>(null);
const dailyProgress = ref<Record<string, DayProgress>>({});
const tasksByDate = ref<Record<string, Task[]>>({});
const selectedDate = ref('');

const todayStr = computed(() => new Date().toISOString().slice(0, 10));

const progressPercent = computed(() => {
  return planData.value?.progressPercent || 0;
});

const currentTasks = computed(() => {
  return tasksByDate.value[selectedDate.value] || [];
});

const completedCount = computed(() => {
  return currentTasks.value.filter(t => t.isCompleted).length;
});

const totalCount = computed(() => {
  return currentTasks.value.length;
});

function getDayNum(dateStr: string): string {
  return dateStr.split('-')[2] ?? '';
}

function getDayName(dayOfWeek: number): string {
  const names = ['', '一', '二', '三', '四', '五', '六', '日'];
  return names[dayOfWeek] || '';
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  return `${date.getMonth() + 1}月${date.getDate()}日`;
}

function selectDate(date: string) {
  selectedDate.value = date;
}

async function loadPlan() {
  loading.value = true;
  try {
    const res = await get7DayPlan();
    if (res.success) {
      hasPlan.value = res.hasPlan;
      if (res.hasPlan) {
        planData.value = res;
        dailyProgress.value = res.dailyProgress || {};
        tasksByDate.value = res.tasksByDate || {};
        
        // 默认选中今天
        const today = todayStr.value;
        if (dailyProgress.value[today]) {
          selectedDate.value = today;
        } else {
          // 选择第一天
          const dates = Object.keys(dailyProgress.value);
          if (dates.length > 0) {
            selectedDate.value = dates[0] ?? '';
          }
        }
      }
    }
  } catch (e) {
    console.error('加载计划失败:', e);
  } finally {
    loading.value = false;
  }
}

async function generatePlan() {
  generating.value = true;
  try {
    const res = await generate7DayPlan();
    if (res.success) {
      await loadPlan();
    } else {
      alert(res.message || '生成计划失败');
    }
  } catch (e) {
    console.error('生成计划失败:', e);
    alert('生成计划失败，请稍后重试');
  } finally {
    generating.value = false;
  }
}

async function toggleTask(task: Task) {
  try {
    if (task.isCompleted) {
      await uncompleteTask(task.id);
      task.isCompleted = false;
    } else {
      await completeTask(task.id);
      task.isCompleted = true;
    }
    // 更新进度
    await loadPlan();
  } catch (e) {
    console.error('更新任务状态失败:', e);
  }
}

onMounted(() => {
  loadPlan();
});
</script>

<style scoped>
.tasks-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding-bottom: 20px;
}

.page-header {
  padding: 20px 16px;
  color: white;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.back-btn {
  background: rgba(255,255,255,0.2);
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 12px;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.3s;
}

.back-btn:hover {
  background: rgba(255,255,255,0.3);
}

.header-content h1 {
  font-size: 20px;
  font-weight: 600;
}

.header-spacer {
  width: 40px;
}

.page-content {
  padding: 0 16px;
}

/* 计划状态卡片 */
.plan-status-card {
  background: white;
  border-radius: 20px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.1);
}

.plan-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.plan-info h2 {
  font-size: 18px;
  margin-bottom: 8px;
  color: #333;
}

.constitution-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
}

.progress-ring {
  position: relative;
  width: 70px;
  height: 70px;
}

.progress-ring svg {
  transform: rotate(-90deg);
}

.progress-ring circle {
  fill: none;
  stroke-width: 8;
  stroke-linecap: round;
}

.progress-ring .bg {
  stroke: #e0e0e0;
}

.progress-ring .fg {
  stroke: #667eea;
  stroke-dasharray: 251;
  transition: stroke-dashoffset 0.5s ease;
}

.progress-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
}

.plan-dates {
  margin-top: 12px;
  font-size: 13px;
  color: #888;
}

/* 无计划提示 */
.no-plan-card {
  background: white;
  border-radius: 20px;
  padding: 40px 20px;
  text-align: center;
  margin-bottom: 16px;
}

.no-plan-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.no-plan-card h3 {
  font-size: 18px;
  color: #333;
  margin-bottom: 8px;
}

.no-plan-card p {
  color: #888;
  font-size: 14px;
  margin-bottom: 20px;
}

.generate-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 25px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.generate-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.generate-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* 日期选择器 */
.date-tabs {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding: 16px 0;
  margin-bottom: 8px;
}

.date-tab {
  flex-shrink: 0;
  background: rgba(255,255,255,0.2);
  border-radius: 16px;
  padding: 12px 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
  overflow: hidden;
  min-width: 50px;
  color: white;
}

.date-tab.active {
  background: white;
  color: #667eea;
}

.date-tab.today {
  border: 2px solid rgba(255,255,255,0.5);
}

.date-tab.past:not(.active) {
  opacity: 0.7;
}

.day-num {
  display: block;
  font-size: 18px;
  font-weight: 600;
}

.day-name {
  font-size: 12px;
  opacity: 0.8;
}

.day-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 3px;
  background: #4CAF50;
  transition: width 0.3s;
}

/* 任务列表 */
.tasks-section {
  background: white;
  border-radius: 20px;
  padding: 20px;
  margin-bottom: 16px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-header h3 {
  font-size: 16px;
  color: #333;
}

.task-count {
  font-size: 14px;
  color: #667eea;
  font-weight: 600;
}

.task-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: all 0.3s;
}

.task-item.completed {
  background: #e8f5e9;
}

.task-item.completed .task-title {
  text-decoration: line-through;
  color: #888;
}

.task-checkbox {
  width: 24px;
  height: 24px;
  border: 2px solid #ddd;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
  transition: all 0.3s;
}

.task-item.completed .task-checkbox {
  background: #4CAF50;
  border-color: #4CAF50;
}

.check-icon {
  color: white;
  font-size: 14px;
}

.task-content {
  flex: 1;
}

.task-title {
  font-size: 15px;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}

.task-desc {
  font-size: 13px;
  color: #666;
  margin-bottom: 8px;
}

.task-meta {
  display: flex;
  gap: 8px;
}

.task-category,
.task-intensity {
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 10px;
  background: #e0e0e0;
  color: #666;
}

.task-category {
  background: #e3f2fd;
  color: #1976d2;
}

.empty-tasks {
  text-align: center;
  padding: 30px;
  color: #888;
}

/* 快捷操作 */
.quick-actions {
  display: flex;
  gap: 12px;
  margin-top: 8px;
}

.action-btn {
  flex: 1;
  background: white;
  border: none;
  border-radius: 16px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.1);
}

.action-icon {
  font-size: 24px;
}

.action-btn span:last-child {
  font-size: 13px;
  color: #666;
}

/* Loading */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255,255,255,0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.loader {
  width: 40px;
  height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
