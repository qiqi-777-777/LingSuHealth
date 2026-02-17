<template>
  <div class="report-page">
    <!-- 头部 -->
    <header class="page-header">
      <div class="header-content">
        <button class="back-btn" @click="$router.back()">
          <span class="icon">←</span>
        </button>
        <h1>健康周报</h1>
        <button class="refresh-btn" @click="generateReport" :disabled="generating">
          <span v-if="generating">...</span>
          <span v-else>🔄</span>
        </button>
      </div>
    </header>

    <!-- 内容区 -->
    <main class="page-content" v-if="hasReport && report">
      <!-- 周报概览 -->
      <section class="overview-card">
        <div class="overview-header">
          <div class="week-info">
            <h2>{{ getReportTitle() }}</h2>
            <span class="trend-badge" :class="report.healthTrend">
              {{ getTrendLabel() }}
            </span>
          </div>
          <div class="health-score">
            <span class="score-value">{{ report.avgHealthScore?.toFixed(0) || '--' }}</span>
            <span class="score-label">平均健康分</span>
          </div>
        </div>
      </section>

      <!-- 数据统计 -->
      <section class="stats-grid">
        <div class="stat-item">
          <span class="stat-icon">📝</span>
          <span class="stat-value">{{ report.checkinDays || 0 }}</span>
          <span class="stat-label">打卡天数</span>
        </div>
        <div class="stat-item">
          <span class="stat-icon">😴</span>
          <span class="stat-value">{{ report.avgSleepHours?.toFixed(1) || '--' }}</span>
          <span class="stat-label">平均睡眠(h)</span>
        </div>
        <div class="stat-item">
          <span class="stat-icon">🏃</span>
          <span class="stat-value">{{ report.totalExerciseMinutes || 0 }}</span>
          <span class="stat-label">运动时长(min)</span>
        </div>
        <div class="stat-item">
          <span class="stat-icon">✅</span>
          <span class="stat-value">{{ report.taskCompletionRate?.toFixed(0) || 0 }}%</span>
          <span class="stat-label">任务完成率</span>
        </div>
      </section>

      <!-- AI总结 -->
      <section class="summary-card" v-if="report.summary">
        <div class="card-header">
          <span class="card-icon">🤖</span>
          <h3>AI 周总结</h3>
        </div>
        <p class="summary-text">{{ report.summary }}</p>
      </section>

      <!-- 本周亮点 -->
      <section class="highlights-card" v-if="highlights.length > 0">
        <div class="card-header">
          <span class="card-icon">⭐</span>
          <h3>本周亮点</h3>
        </div>
        <ul class="highlights-list">
          <li v-for="(item, i) in highlights" :key="i">{{ item }}</li>
        </ul>
      </section>

      <!-- 需改进项 -->
      <section class="improvements-card" v-if="improvements.length > 0">
        <div class="card-header">
          <span class="card-icon">💡</span>
          <h3>改进建议</h3>
        </div>
        <ul class="improvements-list">
          <li v-for="(item, i) in improvements" :key="i">{{ item }}</li>
        </ul>
      </section>

      <!-- 下周建议 -->
      <section class="advice-card" v-if="report.nextWeekAdvice">
        <div class="card-header">
          <span class="card-icon">🎯</span>
          <h3>下周计划</h3>
        </div>
        <p class="advice-text">{{ report.nextWeekAdvice }}</p>
      </section>

      <!-- 健康评分详情 -->
      <section class="scores-card">
        <div class="card-header">
          <span class="card-icon">📊</span>
          <h3>各项评分</h3>
        </div>
        <div class="score-bars">
          <div class="score-row">
            <span class="score-name">睡眠质量</span>
            <div class="score-bar-bg">
              <div class="score-bar" :style="{ width: (report.avgSleepScore || 0) + '%' }"></div>
            </div>
            <span class="score-num">{{ report.avgSleepScore || 0 }}</span>
          </div>
          <div class="score-row">
            <span class="score-name">情绪状态</span>
            <div class="score-bar-bg">
              <div class="score-bar mood" :style="{ width: (report.avgMoodScore || 0) + '%' }"></div>
            </div>
            <span class="score-num">{{ report.avgMoodScore || 0 }}</span>
          </div>
          <div class="score-row">
            <span class="score-name">运动表现</span>
            <div class="score-bar-bg">
              <div class="score-bar exercise" :style="{ width: (report.avgExerciseScore || 0) + '%' }"></div>
            </div>
            <span class="score-num">{{ report.avgExerciseScore || 0 }}</span>
          </div>
        </div>
      </section>
    </main>

    <!-- 无周报 -->
    <main class="page-content" v-else-if="!loading">
      <section class="no-report-card">
        <div class="no-report-icon">📊</div>
        <h3>暂无周报</h3>
        <p>坚持打卡，周末可生成周报</p>
        <button class="generate-btn" @click="generateReport" :disabled="generating">
          {{ generating ? '生成中...' : '立即生成' }}
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
import { getWeeklyReport, generateWeeklyReport } from '../services/api';

interface Report {
  weekStart: string;
  weekEnd: string;
  avgHealthScore: number;
  avgSleepHours: number;
  avgSleepScore: number;
  avgMoodScore: number;
  avgExerciseScore: number;
  totalExerciseMinutes: number;
  taskCompletionRate: number;
  checkinDays: number;
  healthTrend: string;
  summary: string;
  nextWeekAdvice: string;
  highlights: string;
  improvements: string;
}

const loading = ref(true);
const generating = ref(false);
const hasReport = ref(false);
const report = ref<Report | null>(null);

const highlights = computed(() => {
  if (!report.value?.highlights) return [];
  try {
    const data = JSON.parse(report.value.highlights);
    return data.items || [];
  } catch {
    return [];
  }
});

const improvements = computed(() => {
  if (!report.value?.improvements) return [];
  try {
    const data = JSON.parse(report.value.improvements);
    return data.items || [];
  } catch {
    return [];
  }
});

function getReportTitle(): string {
  if (!report.value) return '周报';
  const start = report.value.weekStart;
  const end = report.value.weekEnd;
  if (start && end) {
    return `${formatShortDate(start)} ~ ${formatShortDate(end)}`;
  }
  return '周报';
}

function formatShortDate(dateStr: string): string {
  const date = new Date(dateStr);
  return `${date.getMonth() + 1}/${date.getDate()}`;
}

function getTrendLabel(): string {
  const trend = report.value?.healthTrend;
  if (trend === 'improving') return '📈 持续改善';
  if (trend === 'declining') return '📉 有待提升';
  return '➡️ 保持稳定';
}

async function loadReport() {
  loading.value = true;
  try {
    const res = await getWeeklyReport();
    if (res.success) {
      hasReport.value = res.hasReport;
      if (res.hasReport) {
        report.value = res.report;
      }
    }
  } catch (e) {
    console.error('加载周报失败:', e);
  } finally {
    loading.value = false;
  }
}

async function generateReport() {
  generating.value = true;
  try {
    const res = await generateWeeklyReport();
    if (res.success) {
      report.value = res.report;
      hasReport.value = true;
    } else {
      alert(res.message || '生成周报失败');
    }
  } catch (e) {
    console.error('生成周报失败:', e);
    alert('生成失败，请确保本周有打卡记录');
  } finally {
    generating.value = false;
  }
}

onMounted(() => {
  loadReport();
});
</script>

<style scoped>
.report-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #1a237e 0%, #4a148c 100%);
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

.back-btn,
.refresh-btn {
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

.back-btn:hover,
.refresh-btn:hover:not(:disabled) {
  background: rgba(255,255,255,0.3);
}

.refresh-btn:disabled {
  opacity: 0.5;
}

.header-content h1 {
  font-size: 20px;
  font-weight: 600;
}

.page-content {
  padding: 0 16px;
}

/* 概览卡片 */
.overview-card {
  background: white;
  border-radius: 20px;
  padding: 20px;
  margin-bottom: 16px;
}

.overview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.week-info h2 {
  font-size: 16px;
  color: #333;
  margin-bottom: 8px;
}

.trend-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.trend-badge.improving {
  background: #e8f5e9;
  color: #2e7d32;
}

.trend-badge.declining {
  background: #ffebee;
  color: #c62828;
}

.trend-badge.stable {
  background: #e3f2fd;
  color: #1565c0;
}

.health-score {
  text-align: center;
}

.score-value {
  display: block;
  font-size: 36px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.score-label {
  font-size: 12px;
  color: #888;
}

/* 统计网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.stat-item {
  background: white;
  border-radius: 16px;
  padding: 16px;
  text-align: center;
}

.stat-icon {
  font-size: 24px;
  display: block;
  margin-bottom: 8px;
}

.stat-value {
  display: block;
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

.stat-label {
  font-size: 12px;
  color: #888;
}

/* 卡片通用样式 */
.summary-card,
.highlights-card,
.improvements-card,
.advice-card,
.scores-card {
  background: white;
  border-radius: 20px;
  padding: 20px;
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.card-icon {
  font-size: 20px;
}

.card-header h3 {
  font-size: 16px;
  color: #333;
}

.summary-text,
.advice-text {
  font-size: 14px;
  line-height: 1.6;
  color: #555;
  white-space: pre-line;
}

.highlights-list,
.improvements-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.highlights-list li,
.improvements-list li {
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
  font-size: 14px;
  color: #555;
}

.highlights-list li:last-child,
.improvements-list li:last-child {
  border-bottom: none;
}

.highlights-list li::before {
  content: '✨ ';
}

.improvements-list li::before {
  content: '💡 ';
}

/* 评分条 */
.score-bars {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.score-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.score-name {
  width: 70px;
  font-size: 13px;
  color: #666;
}

.score-bar-bg {
  flex: 1;
  height: 8px;
  background: #e0e0e0;
  border-radius: 4px;
  overflow: hidden;
}

.score-bar {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 4px;
  transition: width 0.5s ease;
}

.score-bar.mood {
  background: linear-gradient(90deg, #ff9800, #ff5722);
}

.score-bar.exercise {
  background: linear-gradient(90deg, #4caf50, #8bc34a);
}

.score-num {
  width: 30px;
  text-align: right;
  font-size: 13px;
  font-weight: 600;
  color: #333;
}

/* 无周报 */
.no-report-card {
  background: white;
  border-radius: 20px;
  padding: 50px 20px;
  text-align: center;
}

.no-report-icon {
  font-size: 60px;
  margin-bottom: 16px;
}

.no-report-card h3 {
  font-size: 18px;
  color: #333;
  margin-bottom: 8px;
}

.no-report-card p {
  color: #888;
  font-size: 14px;
  margin-bottom: 24px;
}

.generate-btn {
  background: linear-gradient(135deg, #1a237e 0%, #4a148c 100%);
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
  box-shadow: 0 8px 25px rgba(26, 35, 126, 0.4);
}

.generate-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
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
  border-top-color: #1a237e;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
