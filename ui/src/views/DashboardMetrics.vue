<template>
  <div class="dashboard-metrics">
    <!-- 动态背景元素 -->
    <div class="bg-blob b1"></div>
    <div class="bg-blob b2"></div>

    <button class="glass-btn back-top-left" @click="goBack">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span class="back-text">返回首页</span>
    </button>

    <div class="content-wrapper">
      <div class="metrics-header">
        <h1>健康仪表盘</h1>
        <p>实时监控您的健康数据</p>
      </div>

      <div class="metrics-grid">
        <div v-for="card in metricCards" :key="card.id" class="metric-card glass-card">
          <div class="metric-icon-wrapper">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path :d="card.iconPath"/>
            </svg>
          </div>
          <div class="metric-content">
            <div class="metric-header-row">
              <h3>{{ card.title }}</h3>
              <div
                v-if="card.anomaly"
                class="anomaly-badge"
                :title="card.anomaly.tooltip"
              >
                <svg viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2 1 21h22L12 2zm0 6a1 1 0 0 1 1 1v5a1 1 0 1 1-2 0V9a1 1 0 0 1 1-1zm0 11a1.2 1.2 0 1 1 0-2.4 1.2 1.2 0 0 1 0 2.4z"/>
                </svg>
              </div>
            </div>
            <div class="metric-value">{{ card.valueText }}</div>
            <div class="metric-status" :class="card.statusClass">{{ card.status }}</div>
            <div class="metric-compare">
              <div v-for="cmp in card.comparisons" :key="cmp.label" class="compare-item">
                <span class="compare-label">{{ cmp.label }}</span>
                <span class="compare-value" :class="cmp.direction">
                  <svg v-if="cmp.direction !== 'flat'" viewBox="0 0 24 24" fill="currentColor">
                    <path v-if="cmp.direction === 'up'" d="M12 5l7 7h-4v7h-6v-7H5l7-7z"/>
                    <path v-else d="M12 19l-7-7h4V5h6v7h4l-7 7z"/>
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="currentColor">
                    <path d="M5 12h14v2H5z"/>
                  </svg>
                  <span>{{ cmp.percentText }}</span>
                </span>
                <span class="compare-diff">{{ cmp.diffText }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 图表区域 -->
      <div class="charts-row">
        <div class="chart-card glass-card trend-card">
          <div class="card-header">
            <h3>
              <div class="icon-box-small">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                  <polyline points="22 4 12 14.01 9 11.01"/>
                </svg>
              </div>
              健康趋势
            </h3>
          </div>
          <div v-if="trendChartState === 'loading'" class="chart-loading">
            <div class="loading-spinner"></div>
            <p>数据加载中...</p>
          </div>
          <div v-else-if="trendChartState === 'error'" class="chart-empty">
            <p>趋势图加载失败</p>
            <span class="chart-error">{{ errorMessage }}</span>
            <button type="button" class="retry-btn" @click="retryLoad">重试</button>
          </div>
          <div v-else-if="trendChartState === 'empty'" class="chart-empty">
            <p>暂无趋势数据</p>
            <button type="button" class="retry-btn" @click="retryLoad">重新获取</button>
          </div>
          <div v-else class="chart-body">
             <canvas id="trendLineCanvas"></canvas>
          </div>
        </div>
        
        <div class="chart-card glass-card mood-card">
          <div class="card-header">
            <h3>
              <div class="icon-box-small">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <path d="M8 14s1.5 2 4 2 4-2 4-2"/>
                  <line x1="9" y1="9" x2="9.01" y2="9"/>
                  <line x1="15" y1="9" x2="15.01" y2="9"/>
                </svg>
              </div>
              心情分布
            </h3>
          </div>
          <div v-if="moodChartState === 'loading'" class="chart-loading">
            <div class="loading-spinner"></div>
            <p>数据加载中...</p>
          </div>
          <div v-else-if="moodChartState === 'error'" class="chart-empty">
            <p>情绪图加载失败</p>
            <span class="chart-error">{{ errorMessage }}</span>
            <button type="button" class="retry-btn" @click="retryLoad">重试</button>
          </div>
          <div v-else-if="moodChartState === 'empty'" class="chart-empty">
            <p>暂无情绪数据</p>
            <button type="button" class="retry-btn" @click="retryLoad">重新获取</button>
          </div>
          <div v-else class="chart-body">
             <canvas id="moodDonutCanvas"></canvas>
          </div>
          
          <transition name="fade">
            <div v-if="moodChartState === 'ready' && moodTooltip.show" class="mood-tooltip" :style="{
              left: moodTooltip.x + 'px',
              top: moodTooltip.y + 'px'
            }">
              <div class="tooltip-header">{{ moodTooltip.label }}</div>
              <div class="tooltip-content">
                <div class="tooltip-item">
                  <span class="tooltip-icon">
                     <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                        <line x1="8" y1="21" x2="16" y2="21"/>
                        <line x1="12" y1="17" x2="12" y2="21"/>
                     </svg>
                  </span>
                  <span>共 {{ moodTooltip.count }} 天</span>
                </div>
                <div class="tooltip-divider"></div>
                <div v-for="(item, index) in moodTooltip.moodStates" :key="index" class="tooltip-item mood-detail">
                  <svg class="mood-icon-small" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                     <path :d="moodIcons[item.iconIndex]" />
                  </svg>
                  <span>{{ item.label }} ({{ item.count }}天)</span>
                </div>
              </div>
            </div>
          </transition>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { getCheckinSummary, getHealthTrends } from '../services/api';
import {
  buildComparisons,
  evaluateAnomaly,
  formatSigned,
  type ComparisonResult,
  type MetricAnomalyRule
} from '../utils/dashboardMetrics';

// 类型定义
type TrendItem = { date: string; sleepHours: number | null; exerciseMinutes: number };
type MoodCounts = { 
  positive: number; 
  neutral: number; 
  negative: number; 
  sampleDays: number;
  moodDetails: { [key: number]: number }; // 记录每种具体情绪的数量
};
type RawTrendRow = {
  date?: string;
  checkin_date?: string;
  checkinDate?: string;
  sleepHours?: number;
  sleep_hours?: number;
  exerciseMinutes?: number;
  exercise_minutes?: number;
  symptoms?: string[] | string;
  mood?: number;
  mood_score?: number;
};

// 路由
const router = useRouter();

// 状态
const summary = ref({
  totalCheckins: 0,
  consecutiveDays: 0,
  weeklyGoal: 7,
  completionRate: 0
});
const trends = ref<Array<{
  date?: string;
  sleepHours?: number | null;
  exerciseMinutes?: number;
  symptoms?: string[] | string;
  mood?: number;
}>>([]);
const loadState = ref<'loading' | 'ready' | 'empty' | 'error'>('loading');
const errorMessage = ref('');
const lastUpdated = ref('');
const trendAggregated = ref<TrendItem[]>([]);
const moodCounts = ref<MoodCounts>({ positive: 0, neutral: 0, negative: 0, sampleDays: 0, moodDetails: {} });
const dailyCounts = ref<Record<string, number>>({});
const chartDrawn = ref({ trend: false, mood: false });

// 情绪状态映射（与Checkin.vue保持一致）
const moodLabels = ['很差', '一般', '良好', '很好', '极佳'];

// 情绪图标SVG路径
const moodIcons = [
  'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-5-9c.83 0 1.5-.67 1.5-1.5S7.83 8 7 8s-1.5.67-1.5 1.5S6.17 11 7 11zm10 0c.83 0 1.5-.67 1.5-1.5S17.83 8 17 8s-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm-5 7.5c-2.33 0-4.31-1.46-5.11-3.5h10.22c-.8 2.04-2.78 3.5-5.11 3.5z', // 很差
  'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zM7 10c.83 0 1.5-.67 1.5-1.5S7.83 7 7 7s-1.5.67-1.5 1.5S6.17 10 7 10zm10 0c.83 0 1.5-.67 1.5-1.5S17.83 7 17 7s-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm-5 6c-2.33 0-4.32-1.45-5.12-3.5h1.67c.69 1.19 1.97 2 3.45 2s2.75-.81 3.45-2h1.67c-.8 2.05-2.79 3.5-5.12 3.5z', // 一般
  'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zM7 10c.83 0 1.5-.67 1.5-1.5S7.83 7 7 7s-1.5.67-1.5 1.5S6.17 10 7 10zm10 0c.83 0 1.5-.67 1.5-1.5S17.83 7 17 7s-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm-5 3c2.33 0 4.31 1.46 5.11 3.5H6.89c.8-2.04 2.78-3.5 5.11-3.5z', // 良好
  'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zM7 10c.83 0 1.5-.67 1.5-1.5S7.83 7 7 7s-1.5.67-1.5 1.5S6.17 10 7 10zm10 0c.83 0 1.5-.67 1.5-1.5S17.83 7 17 7s-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm-5 3c2.33 0 4.31 1.46 5.11 3.5H6.89c.8-2.04 2.78-3.5 5.11-3.5z', // 很好
  'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zM7 10c.83 0 1.5-.67 1.5-1.5S7.83 7 7 7s-1.5.67-1.5 1.5S6.17 10 7 10zm10 0c.83 0 1.5-.67 1.5-1.5S17.83 7 17 7s-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm-5 3c2.33 0 4.31 1.46 5.11 3.5H6.89c.8-2.04 2.78-3.5 5.11-3.5z'  // 极佳
];

// Tooltip状态
const moodTooltip = ref({
  show: false,
  x: 0,
  y: 0,
  label: '',
  count: 0,
  moodStates: [] as Array<{ iconIndex: number; label: string; count: number }>
});

type MetricId = 'checkins' | 'streak' | 'goal' | 'completion';
type ChartState = 'loading' | 'ready' | 'empty' | 'error';
type MetricCard = {
  id: MetricId;
  title: string;
  valueText: string;
  status: string;
  statusClass: 'excellent' | 'good' | 'normal';
  iconClass: string;
  iconPath: string;
  comparisons: Array<{
    label: string;
    percentText: string;
    diffText: string;
    direction: 'up' | 'down' | 'flat';
  }>;
  anomaly?: { tooltip: string };
};

// 异常检测规则，可根据业务进行调整
const anomalyRules: Record<MetricId, MetricAnomalyRule> = {
  checkins: { min: 2, max: 7, percentChangeThreshold: 40, diffThreshold: 3 },
  streak: { min: 1, max: 30, percentChangeThreshold: 60, diffThreshold: 3 },
  goal: { min: 3, max: 7, percentChangeThreshold: 20, diffThreshold: 2 },
  completion: { min: 40, max: 100, percentChangeThreshold: 30, diffThreshold: 20 }
};

const metricIcons: Record<MetricId, { iconClass: string; path: string }> = {
  checkins: {
    iconClass: 'sleep',
    path: 'M12 3a6 6 0 0 0 9 5.2A9 9 0 1 1 8.2 3a6 6 0 0 0 3.8 0z'
  },
  streak: {
    iconClass: 'activity',
    path: 'M13 3h-2v10h2V3zm4 4h-2v6h2V7zM7 9H5v4h2V9z'
  },
  goal: {
    iconClass: 'constitution',
    path: 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5a5.5 5.5 0 0 1 10.7-1.8A5.5 5.5 0 1 1 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z'
  },
  completion: {
    iconClass: 'constitution',
    path: 'M12 2a10 10 0 100 20 10 10 0 000-20z'
  }
};

// 解析症状（兼容 string[] 或 JSON 字符串）
function normalizeSymptoms(sym: unknown): string[] {
  if (Array.isArray(sym)) return sym as string[];
  if (typeof sym === 'string') {
    try {
      const parsed = JSON.parse(sym);
      if (Array.isArray(parsed)) return parsed as string[];
      return [sym];
    } catch {
      return [sym];
    }
  }
  return [];
}

// 日期工具
function formatDate(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}
function getLastNDates(n: number): string[] {
  const arr: string[] = [];
  const today = new Date();
  for (let i = n - 1; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(today.getDate() - i);
    arr.push(formatDate(d));
  }
  return arr;
}

// 按日期聚合（睡眠平均、运动量求和、症状去重、收集心情）
function aggregateByDate(rows: RawTrendRow[]) {
  const map: Record<string, {
    date: string;
    sleepHours: number[];
    exerciseMinutes: number;
    symptoms: Set<string>;
    moods: number[];
  }> = {};

  for (const r of rows) {
    const date: string = r.date || r.checkin_date || r.checkinDate || '';
    if (!date) continue;
    if (!map[date]) {
      map[date] = { date, sleepHours: [], exerciseMinutes: 0, symptoms: new Set<string>(), moods: [] };
    }
    const bucket = map[date];
    const sh = Number(r.sleepHours ?? r.sleep_hours ?? 0);
    if (!Number.isNaN(sh) && sh > 0) bucket.sleepHours.push(sh);

    const ex = Number(r.exerciseMinutes ?? r.exercise_minutes ?? 0);
    if (!Number.isNaN(ex)) bucket.exerciseMinutes += ex;

    normalizeSymptoms(r.symptoms).forEach((s: string) => bucket.symptoms.add(s));

    const moodVal = Number(r.mood ?? r.mood_score ?? NaN);
    if (!Number.isNaN(moodVal)) bucket.moods.push(moodVal);
  }

  const obj: Record<string, {
    date: string;
    sleepHours: number | null;
    exerciseMinutes: number;
    symptoms: string[];
    moods: number[];
  }> = {};

  Object.values(map).forEach((b) => {
    const avgSleep = b.sleepHours.length
      ? b.sleepHours.reduce((a: number, c: number) => a + c, 0) / b.sleepHours.length
      : null;
    obj[b.date] = {
      date: b.date,
      sleepHours: avgSleep,
      exerciseMinutes: b.exerciseMinutes,
      symptoms: Array.from(b.symptoms),
      moods: b.moods
    };
  });

  return obj;
}

// 计算指定日期截止的连续记录天数
function calculateStreak(countMap: Record<string, number>, days: string[], endIndex: number) {
  let streak = 0;
  for (let i = endIndex; i >= 0; i--) {
    const day = days[i];
    if (!day || countMap[day] !== 1) break;
    streak += 1;
  }
  return streak;
}

// 格式化对比数据展示文本
function formatComparisonRows(comparisons: ComparisonResult[]) {
  return comparisons.map((cmp) => ({
    label: cmp.type === 'week' ? '较上周' : '较昨日',
    percentText: `${formatSigned(cmp.percent, 1)}%`,
    diffText: `差值 ${formatSigned(cmp.diff)}`,
    direction: cmp.direction
  }));
}

// 图表状态用于兜底展示与重试
const trendChartState = computed<ChartState>(() => {
  if (loadState.value === 'loading') return 'loading';
  if (loadState.value === 'error') return 'error';
  const hasData = trendAggregated.value.some((item) => item.sleepHours !== null || item.exerciseMinutes > 0);
  return hasData ? 'ready' : 'empty';
});

const moodChartState = computed<ChartState>(() => {
  if (loadState.value === 'loading') return 'loading';
  if (loadState.value === 'error') return 'error';
  return moodCounts.value.sampleDays > 0 ? 'ready' : 'empty';
});

// 组装指标卡数据与对比结果
const metricCards = computed<MetricCard[]>(() => {
  const days = getLastNDates(14);
  const currentWeekDays = days.slice(7);
  const prevWeekDays = days.slice(0, 7);
  const today = days[days.length - 1];

  const currentWeekCount = currentWeekDays.reduce((sum, d) => sum + (dailyCounts.value[d] || 0), 0);
  const prevWeekCount = prevWeekDays.reduce((sum, d) => sum + (dailyCounts.value[d] || 0), 0);
  const todayCount = today ? dailyCounts.value[today] || 0 : 0;

  const weeklyGoal = summary.value.weeklyGoal || 7;
  const completionRate = weeklyGoal > 0 ? Math.round((currentWeekCount / weeklyGoal) * 100) : 0;
  const completionRateLastWeek = weeklyGoal > 0 ? Math.round((prevWeekCount / weeklyGoal) * 100) : 0;
  const completionRateYesterday = weeklyGoal > 0 ? Math.round(((currentWeekCount - todayCount) / weeklyGoal) * 100) : 0;

  const streakToday = calculateStreak(dailyCounts.value, days, days.length - 1);
  const streakYesterday = calculateStreak(dailyCounts.value, days, days.length - 2);
  const streakLastWeek = calculateStreak(dailyCounts.value, days, 6);

  const checkinsComparisons = buildComparisons(currentWeekCount, prevWeekCount, currentWeekCount - todayCount);
  const streakComparisons = buildComparisons(streakToday, streakLastWeek, streakYesterday);
  const goalComparisons = buildComparisons(weeklyGoal, weeklyGoal, weeklyGoal);
  const completionComparisons = buildComparisons(completionRate, completionRateLastWeek, completionRateYesterday);

  const anomalyTime = lastUpdated.value || new Date().toLocaleString();

  const checkinsAnomaly = evaluateAnomaly(currentWeekCount, checkinsComparisons, anomalyRules.checkins, anomalyTime);
  const streakAnomaly = evaluateAnomaly(streakToday, streakComparisons, anomalyRules.streak, anomalyTime);
  const goalAnomaly = evaluateAnomaly(weeklyGoal, goalComparisons, anomalyRules.goal, anomalyTime);
  const completionAnomaly = evaluateAnomaly(completionRate, completionComparisons, anomalyRules.completion, anomalyTime);

  const cards: MetricCard[] = [
    {
      id: 'checkins',
      title: '近7天记录数',
      valueText: String(currentWeekCount),
      status: '趋势统计',
      statusClass: 'good',
      iconClass: metricIcons.checkins.iconClass,
      iconPath: metricIcons.checkins.path,
      comparisons: formatComparisonRows(checkinsComparisons),
      anomaly: checkinsAnomaly ? { tooltip: `异常：${checkinsAnomaly.reason}\n时间：${checkinsAnomaly.time}` } : undefined
    },
    {
      id: 'streak',
      title: '连续记录天数',
      valueText: String(streakToday),
      status: '坚持就是胜利',
      statusClass: 'normal',
      iconClass: metricIcons.streak.iconClass,
      iconPath: metricIcons.streak.path,
      comparisons: formatComparisonRows(streakComparisons),
      anomaly: streakAnomaly ? { tooltip: `异常：${streakAnomaly.reason}\n时间：${streakAnomaly.time}` } : undefined
    },
    {
      id: 'goal',
      title: '本周目标',
      valueText: String(weeklyGoal),
      status: '每周7天',
      statusClass: 'excellent',
      iconClass: metricIcons.goal.iconClass,
      iconPath: metricIcons.goal.path,
      comparisons: formatComparisonRows(goalComparisons),
      anomaly: goalAnomaly ? { tooltip: `异常：${goalAnomaly.reason}\n时间：${goalAnomaly.time}` } : undefined
    },
    {
      id: 'completion',
      title: '完成率',
      valueText: `${completionRate}%`,
      status: '目标进度',
      statusClass: 'excellent',
      iconClass: metricIcons.completion.iconClass,
      iconPath: metricIcons.completion.path,
      comparisons: formatComparisonRows(completionComparisons),
      anomaly: completionAnomaly ? { tooltip: `异常：${completionAnomaly.reason}\n时间：${completionAnomaly.time}` } : undefined
    }
  ];

  return cards;
});

// 拉取仪表盘数据并驱动图表绘制
async function loadDashboardMetrics() {
  loadState.value = 'loading';
  errorMessage.value = '';
  chartDrawn.value = { trend: false, mood: false };

  try {
    const s = await getCheckinSummary();
    summary.value = {
      totalCheckins: s.totalCheckins ?? 0,
      consecutiveDays: s.consecutiveDays ?? 0,
      weeklyGoal: s.weeklyGoal ?? 7,
      completionRate: s.completionRate ?? 0
    };

    const t = await getHealthTrends(14);
    const raw: RawTrendRow[] = t.trends || [];
    const byDate = aggregateByDate(raw);
    const days = getLastNDates(14);

    dailyCounts.value = days.reduce((acc, d) => {
      acc[d] = byDate[d] ? 1 : 0;
      return acc;
    }, {} as Record<string, number>);

    const latestDays = days.slice(7);
    trends.value = latestDays.map((d: string) => ({
      date: d,
      sleepHours: byDate[d]?.sleepHours ?? null,
      exerciseMinutes: byDate[d]?.exerciseMinutes ?? 0,
      symptoms: byDate[d]?.symptoms ?? [],
      mood: byDate[d]?.moods?.length
        ? Math.round(byDate[d].moods.reduce((a: number, c: number) => a + c, 0) / byDate[d].moods.length)
        : undefined
    }));

    trendAggregated.value = trends.value.map(d => ({
      date: d.date || '',
      sleepHours: d.sleepHours ?? null,
      exerciseMinutes: d.exerciseMinutes ?? 0
    }));

    const mc: MoodCounts = { positive: 0, neutral: 0, negative: 0, sampleDays: 0, moodDetails: {} };
    trends.value.forEach(d => {
      if (typeof d.mood === 'number') {
        mc.sampleDays += 1;
        mc.moodDetails[d.mood] = (mc.moodDetails[d.mood] || 0) + 1;
        if (d.mood <= 1) mc.negative += 1;
        else if (d.mood === 2) mc.neutral += 1;
        else mc.positive += 1;
      }
    });
    moodCounts.value = mc;

    lastUpdated.value = new Date().toLocaleString();
    loadState.value = raw.length ? 'ready' : 'empty';

    await nextTick();
    if (trendChartState.value === 'ready' && !chartDrawn.value.trend) {
      drawAnimatedLineChart('trendLineCanvas', trendAggregated.value);
      chartDrawn.value.trend = true;
    }
    if (moodChartState.value === 'ready' && !chartDrawn.value.mood) {
      drawAnimatedDonutChart('moodDonutCanvas', moodCounts.value);
      chartDrawn.value.mood = true;
    }
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : '数据获取失败';
    loadState.value = 'error';
  }
}

function retryLoad() {
  loadDashboardMetrics();
}

onMounted(() => {
  loadDashboardMetrics();
});

/* 连续绘制 + 平滑曲线，带参数版本 */
function drawAnimatedLineChart(canvasId: string, data: TrendItem[]) {
  const canvas = document.getElementById(canvasId) as HTMLCanvasElement;
  if (!canvas) return;
  const dpr = window.devicePixelRatio || 1;
  const cssWidth = canvas.clientWidth || 760;
  const cssHeight = canvas.clientHeight || 280;
  canvas.width = Math.floor(cssWidth * dpr);
  canvas.height = Math.floor(cssHeight * dpr);
  const ctx = canvas.getContext('2d')!;

  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  const width = cssWidth;
  const height = cssHeight;
  const padding = { top: 24, right: 28, bottom: 40, left: 48 };
  const chartW = width - padding.left - padding.right;
  const chartH = height - padding.top - padding.bottom;

  const count = Math.max(1, data.length);
  const xStep = chartW / Math.max(1, count - 1);
  const xs: number[] = Array.from({ length: count }, (_, i) => padding.left + i * xStep);

  const sleepVals = data.map(d => d.sleepHours ?? 0);
  const exerciseVals = data.map(d => d.exerciseMinutes ?? 0);
  const sleepMax = Math.max(8, ...sleepVals);
  const exerciseMax = Math.max(60, ...exerciseVals);
  const sleepToY = (v: number) => padding.top + chartH - (v / sleepMax) * chartH;
  const exToY = (v: number) => padding.top + chartH - (v / exerciseMax) * chartH;

  // 非空断言，避免 x 可能为 undefined 的类型错误
  const sleepPoints: { x: number; y: number }[] = sleepVals.map((v, i) => ({ x: xs[i]!, y: sleepToY(v) }));
  const exPoints: { x: number; y: number }[] = exerciseVals.map((v, i) => ({ x: xs[i]!, y: exToY(v) }));

  drawGrid(ctx, width, height, padding);

  const duration = 1200;
  let start = 0;

  function frame(ts: number) {
    if (!start) start = ts;
    const t = Math.min(1, (ts - start) / duration);

    ctx.clearRect(0, 0, width, height);
    drawGrid(ctx, width, height, padding);

    // 一次性连续绘制（不分段跳动）
    drawSmoothLineProgress(ctx, sleepPoints, '#7C4DFF', 4, t, true, padding, chartH);
    drawSmoothLineProgress(ctx, exPoints, '#FF8A00', 3, t, false, padding, chartH);

    if (t < 1) requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);

  function drawGrid(ctx: CanvasRenderingContext2D, w: number, h: number, pad: { top: number; right: number; bottom: number; left: number }) {
    ctx.save();
    ctx.strokeStyle = 'rgba(0,0,0,0.08)';
    ctx.lineWidth = 1;
    const rows = 4;
    for (let i = 0; i <= rows; i++) {
      const y = pad.top + (h - pad.top - pad.bottom) * (i / rows);
      ctx.beginPath();
      ctx.moveTo(pad.left, y);
      ctx.lineTo(w - pad.right, y);
      ctx.stroke();
    }

    // 新增：轴标签与图例
    ctx.font = '12px Segoe UI, system-ui, -apple-system, Roboto';
    ctx.textBaseline = 'top';

    // X 轴日期（显示 MM-DD）
    ctx.fillStyle = '#6b7280';
    ctx.textAlign = 'center';
    const labelY = h - pad.bottom + 8;
    const dateLabels = data.map(d => (d.date || '').slice(5));
    dateLabels.forEach((lab, i) => {
      const x = pad.left + (w - pad.left - pad.right) * (i / Math.max(1, dateLabels.length - 1));
      ctx.fillText(lab, x, labelY);
    });

    // 左侧 Y 轴（睡眠小时）
    ctx.textAlign = 'right';
    for (let i = 0; i <= rows; i++) {
      const y = pad.top + (h - pad.top - pad.bottom) * (i / rows);
      const v = Math.round(((rows - i) / rows) * sleepMax);
      ctx.fillStyle = '#7C4DFF';
      ctx.fillText(String(v), pad.left - 8, y - 6);
    }

    // 右侧 Y 轴（运动分钟）
    ctx.textAlign = 'left';
    for (let i = 0; i <= rows; i++) {
      const y = pad.top + (h - pad.top - pad.bottom) * (i / rows);
      const v = Math.round(((rows - i) / rows) * exerciseMax);
      ctx.fillStyle = '#FF8A00';
      ctx.fillText(String(v), w - pad.right + 8, y - 6);
    }

    // 轴标题
    ctx.textAlign = 'left';
    ctx.fillStyle = '#7C4DFF';
    ctx.fillText('睡眠(小时)', pad.left, pad.top - 18);
    ctx.textAlign = 'right';
    ctx.fillStyle = '#FF8A00';
    ctx.fillText('运动(分钟)', w - pad.right, pad.top - 18);

    // 图例（顶部）
    const legendY = pad.top - 34;
    ctx.lineWidth = 4;
    ctx.strokeStyle = '#7C4DFF';
    ctx.beginPath();
    ctx.moveTo(pad.left, legendY);
    ctx.lineTo(pad.left + 24, legendY);
    ctx.stroke();
    ctx.fillStyle = '#333';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText('睡眠', pad.left + 30, legendY);

    ctx.lineWidth = 3;
    ctx.strokeStyle = '#FF8A00';
    ctx.beginPath();
    ctx.moveTo(pad.left + 90, legendY);
    ctx.lineTo(pad.left + 114, legendY);
    ctx.stroke();
    ctx.fillText('运动', pad.left + 120, legendY);

    ctx.restore();
  }
}

/* 平滑曲线进度绘制：索引保护 + 非空断言 */
function drawSmoothLineProgress(
  ctx: CanvasRenderingContext2D,
  pts: Array<{ x: number; y: number }>,
  color: string,
  lineWidth: number,
  progress: number,
  fillArea: boolean,
  padding: { top: number; right: number; bottom: number; left: number },
  chartH: number
) {
  if (!pts || pts.length < 2) return;

  const totalSegments = Math.max(pts.length - 1, 0);
  if (totalSegments === 0) return;

  const floatIndex = Math.min(progress, 1) * totalSegments;
  const lastFull = Math.min(Math.floor(floatIndex), totalSegments);
  const localT = floatIndex - Math.floor(floatIndex);

  const end =
    lastFull >= totalSegments
      ? pts[pts.length - 1]!
      : {
          x: pts[lastFull]!.x + (pts[lastFull + 1]!.x - pts[lastFull]!.x) * localT,
          y: pts[lastFull]!.y + (pts[lastFull + 1]!.y - pts[lastFull]!.y) * localT,
        };

  ctx.save();
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.lineWidth = lineWidth;
  ctx.strokeStyle = color;

  ctx.beginPath();
  ctx.moveTo(pts[0]!.x, pts[0]!.y);

  for (let i = 1; i <= lastFull && i < pts.length; i++) {
    const p0 = pts[i - 1]!;
    const p1 = pts[i]!;
    const cx = (p0.x + p1.x) / 2;
    const cy = (p0.y + p1.y) / 2;
    ctx.quadraticCurveTo(p0.x, p0.y, cx, cy);
    ctx.quadraticCurveTo(cx, cy, p1.x, p1.y);
  }

  if (lastFull < totalSegments) {
    const p0 = pts[lastFull]!;
    const cx = (p0.x + end.x) / 2;
    const cy = (p0.y + end.y) / 2;
    ctx.quadraticCurveTo(p0.x, p0.y, cx, cy);
    ctx.quadraticCurveTo(cx, cy, end.x, end.y);
  }

  ctx.stroke();

  if (fillArea) {
    ctx.globalAlpha = 0.12;
    ctx.fillStyle = color;
    ctx.lineTo(end.x, padding.top + chartH);
    ctx.lineTo(pts[0]!.x, padding.top + chartH);
    ctx.closePath();
    ctx.fill();
  }

  ctx.restore();
}

/* 甜甜圈（参数版本） */
function drawAnimatedDonutChart(canvasId: string, mood: MoodCounts) {
  const canvas = document.getElementById(canvasId) as HTMLCanvasElement;
  if (!canvas) return;
  const dpr = window.devicePixelRatio || 1;
  const cssWidth = canvas.clientWidth || 340;
  const cssHeight = canvas.clientHeight || 280;
  canvas.width = Math.floor(cssWidth * dpr);
  canvas.height = Math.floor(cssHeight * dpr);
  const ctx = canvas.getContext('2d')!;

  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  const width = cssWidth;
  const height = cssHeight;

  const total = Math.max(1, mood.positive + mood.neutral + mood.negative);
  const parts = [
    { v: mood.positive, color: '#4CAF50', label: '正面情绪', moodRange: [3, 4] },
    { v: mood.neutral, color: '#FFC107', label: '中性情绪', moodRange: [2] },
    { v: mood.negative, color: '#F44336', label: '负面情绪', moodRange: [0, 1] },
  ];

  const cx = width / 2;
  const cy = height / 2;
  const r = Math.min(width, height) / 2 - 20;
  const innerR = r * 0.65;
  
  // 存储每个扇形的角度范围，用于鼠标检测
  const sectors: Array<{
    startAngle: number;
    endAngle: number;
    label: string;
    count: number;
    color: string;
    moodRange: number[];
  }> = [];

  const startAngle = -Math.PI / 2;
  const duration = 900;
  let start = 0;

  function frame(ts: number) {
    if (!start) start = ts;
    const t = Math.min(1, (ts - start) / duration);

    ctx.clearRect(0, 0, width, height);

    // 背景环
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.strokeStyle = 'rgba(0,0,0,0.08)';
    ctx.lineWidth = r - innerR;
    ctx.stroke();

    // 动画填充并记录扇形范围
    sectors.length = 0; // 清空旧数据
    let angle = startAngle;
    parts.forEach(p => {
      const fullSweep = (p.v / total) * Math.PI * 2;
      const sweep = fullSweep * t;
      
      // 记录扇形信息（使用完整角度）
      sectors.push({
        startAngle: angle,
        endAngle: angle + fullSweep,
        label: p.label,
        count: p.v,
        color: p.color,
        moodRange: p.moodRange
      });
      
      ctx.beginPath();
      ctx.strokeStyle = p.color;
      ctx.lineWidth = r - innerR;
      ctx.arc(cx, cy, (r + innerR) / 2, angle, angle + sweep);
      ctx.stroke();
      angle += sweep;
    });

    // 标题（保留）
    ctx.fillStyle = '#6b7280';
    ctx.font = '600 14px Segoe UI, system-ui, -apple-system, Roboto';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    ctx.fillText('心情分布', width / 2, 8);

    // 移除中心“样本天数”文本（不再绘制）
    // 原先的 ctx.fillText(`样本天数: ${mood.sampleDays}`, cx, cy); 已删除

    // 图例移到圆圈中心位置
    const legends = [
      { label: '正面', color: '#4CAF50' },
      { label: '中性', color: '#FFC107' },
      { label: '负面', color: '#F44336' }
    ];
    const spacing = innerR * 0.6;
    const legendY = cy;
    let lx = cx - spacing;
    legends.forEach((l) => {
      ctx.fillStyle = l.color;
      ctx.fillRect(lx - 14, legendY - 6, 12, 12);
      ctx.fillStyle = '#333';
      ctx.font = '12px Segoe UI, system-ui, -apple-system, Roboto';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'middle';
      ctx.fillText(l.label, lx + 2, legendY);
      lx += spacing;
    });

    if (t < 1) requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
  
  // 添加鼠标移动事件监听
  canvas.addEventListener('mousemove', (e: MouseEvent) => {
    const rect = canvas.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;
    
    // 计算鼠标相对于圆心的距离和角度
    const dx = mouseX - cx;
    const dy = mouseY - cy;
    const dist = Math.sqrt(dx * dx + dy * dy);
    
    // 检查是否在圆环范围内
    if (dist >= innerR && dist <= r) {
      let angle = Math.atan2(dy, dx);
      // 调整角度，使其与绘图起始角度一致
      angle = angle - startAngle;
      if (angle < 0) angle += Math.PI * 2;
      
      // 查找对应的扇形
      for (const sector of sectors) {
        let sectorStart = sector.startAngle - startAngle;
        let sectorEnd = sector.endAngle - startAngle;
        if (sectorStart < 0) sectorStart += Math.PI * 2;
        if (sectorEnd < 0) sectorEnd += Math.PI * 2;
        
        // 处理跨越0度的情况
        const inSector = sectorStart <= sectorEnd 
          ? (angle >= sectorStart && angle <= sectorEnd)
          : (angle >= sectorStart || angle <= sectorEnd);
        
        if (inSector && sector.count > 0) {
          // 获取该类别下的具体情绪状态
          const moodStates: Array<{ iconIndex: number; label: string; count: number }> = [];
          sector.moodRange.forEach(moodIndex => {
            const count = mood.moodDetails[moodIndex] || 0;
            if (count > 0) {
              moodStates.push({
                iconIndex: moodIndex,
                label: moodLabels[moodIndex] || '未知',
                count: count
              });
            }
          });
          
          // 计算tooltip位置，确保不超出边界
          const tooltipWidth = 180; // 预估tooltip宽度
          const tooltipHeight = 100; // 预估tooltip高度
          let tooltipX = e.clientX - rect.left + 15;
          let tooltipY = e.clientY - rect.top - 10;
          
          // 防止超出右边界
          if (tooltipX + tooltipWidth > width) {
            tooltipX = e.clientX - rect.left - tooltipWidth - 15;
          }
          
          // 防止超出下边界
          if (tooltipY + tooltipHeight > height) {
            tooltipY = height - tooltipHeight - 10;
          }
          
          // 防止超出上边界
          if (tooltipY < 0) {
            tooltipY = 10;
          }
          
          moodTooltip.value = {
            show: true,
            x: tooltipX,
            y: tooltipY,
            label: sector.label,
            count: sector.count,
            moodStates: moodStates
          };
          canvas.style.cursor = 'pointer';
          return;
        }
      }
    }
    
    // 不在任何扇形内
    moodTooltip.value.show = false;
    canvas.style.cursor = 'default';
  });
  
  // 鼠标离开canvas时隐藏tooltip
  canvas.addEventListener('mouseleave', () => {
    moodTooltip.value.show = false;
    canvas.style.cursor = 'default';
  });
}

function goBack() {
  router.push('/dashboard');
}
</script>

<style scoped>
.dashboard-metrics {
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
  max-width: 1200px;
  margin: 0 auto;
  position: relative;
  z-index: 1;
}

/* 玻璃拟态 */
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

.back-top-left {
  position: fixed !important;
  top: 24px !important;
  left: 24px !important;
  z-index: 100;
  display: flex !important;
  align-items: center !important;
  gap: 12px !important;
  padding: 12px 24px !important;
  border-radius: 30px !important;
}

.back-top-left .back-icon {
  width: 24px;
  height: 24px;
  flex-shrink: 0;
}

.back-top-left .back-text {
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 1px;
  white-space: nowrap;
}

.metrics-header {
  text-align: center;
  margin-bottom: 40px;
}

.metrics-header h1 {
  font-size: 32px;
  font-weight: 800;
  color: var(--text-main);
  margin: 0 0 8px 0;
  background: linear-gradient(135deg, var(--text-main) 0%, var(--text-sub) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.metrics-header p {
  font-size: 16px;
  color: var(--text-sub);
  margin: 0;
}

/* Metric Cards */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.metric-card {
  padding: 24px;
  display: flex;
  gap: 20px;
  align-items: flex-start;
  position: relative;
  overflow: hidden;
}

.metric-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: rgba(255,255,255,0.8);
  color: var(--primary-color);
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}

.metric-icon-wrapper svg { width: 24px; height: 24px; }

.metric-content { flex: 1; }

.metric-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.metric-header-row h3 {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-sub);
}

.anomaly-badge {
  color: #ef4444;
  width: 16px;
  height: 16px;
  cursor: help;
}

.metric-value {
  font-size: 28px;
  font-weight: 800;
  color: var(--text-main);
  line-height: 1.2;
  margin-bottom: 4px;
}

.metric-status {
  font-size: 12px;
  margin-bottom: 12px;
  padding: 2px 8px;
  border-radius: 6px;
  display: inline-block;
}

.metric-status.excellent { background: #dcfce7; color: #166534; }
.metric-status.good { background: #dbeafe; color: #1e40af; }
.metric-status.normal { background: #f3f4f6; color: #475569; }

.compare-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  margin-top: 4px;
}

.compare-label { color: #94a3b8; }

.compare-value {
  display: flex;
  align-items: center;
  gap: 2px;
  font-weight: 600;
}

.compare-value.up { color: #ef4444; } /* Usually red for up? context dependent, assuming health metrics up is good/bad? sticking to generic */
.compare-value.down { color: #10b981; }
.compare-value.flat { color: #94a3b8; }

.compare-value svg { width: 12px; height: 12px; }

.compare-diff { color: #94a3b8; margin-left: auto; }

/* Charts */
.charts-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
}

.chart-card {
  padding: 24px;
  display: flex;
  flex-direction: column;
  min-height: 360px;
}

.card-header {
  margin-bottom: 20px;
  display: flex;
  align-items: center;
}

.card-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: var(--text-main);
  display: flex;
  align-items: center;
  gap: 10px;
}

.icon-box-small {
  width: 32px;
  height: 32px;
  background: var(--primary-light);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-dark);
}

.icon-box-small svg { width: 18px; height: 18px; }

.chart-body {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-body canvas {
  width: 100% !important;
  height: 100% !important;
}

.chart-state {
  text-align: center;
  color: var(--text-sub);
}

.loading-spinner {
  width: 30px;
  height: 30px;
  border: 3px solid rgba(0,0,0,0.1);
  border-top-color: var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 10px;
}

@keyframes spin { to { transform: rotate(360deg); } }

.retry-btn {
  margin-top: 8px;
  padding: 6px 16px;
  border: 1px solid var(--primary-color);
  background: white;
  color: var(--primary-color);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.retry-btn:hover {
  background: var(--primary-color);
  color: white;
}

/* Tooltip */
.mood-tooltip {
  position: fixed;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(0,0,0,0.05);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.15);
  border-radius: 12px;
  padding: 12px;
  pointer-events: none;
  z-index: 1000;
  min-width: 140px;
  transform: translate(10px, 10px);
}

.tooltip-header {
  font-weight: 700;
  color: var(--text-main);
  margin-bottom: 8px;
  font-size: 14px;
}

.tooltip-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--text-sub);
  margin-bottom: 4px;
}

.tooltip-divider {
  height: 1px;
  background: rgba(0,0,0,0.05);
  margin: 6px 0;
}

.mood-icon-small { width: 14px; height: 14px; color: var(--primary-color); }

/* Fade Transition */
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

@media (max-width: 900px) {
  .charts-row { grid-template-columns: 1fr; }
  .chart-card { min-height: 300px; }
}

@media (max-width: 600px) {
  .metrics-grid { grid-template-columns: 1fr; }
  .glass-panel { padding: 24px; }
}
</style>
