<template>
  <div class="dashboard-metrics">
    <button class="back-btn back-top-left" @click="goBack">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>
    <div class="metrics-header">
      <h1>健康仪表盘</h1>
      <p>实时监控您的健康数据</p>
    </div>

    <div class="metrics-grid">
      <!-- 近7天记录数 -->
      <div class="metric-card">
        <div class="metric-icon sleep">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 3a6 6 0 0 0 9 5.2A9 9 0 1 1 8.2 3a6 6 0 0 0 3.8 0z"/>
          </svg>
        </div>
        <div class="metric-content">
          <h3>近7天记录数</h3>
          <div class="metric-value">{{ summary.totalCheckins }}</div>
          <div class="metric-status good">趋势统计</div>
        </div>
      </div>

      <!-- 连续记录天数 -->
      <div class="metric-card">
        <div class="metric-icon activity">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M13 3h-2v10h2V3zm4 4h-2v6h2V7zM7 9H5v4h2V9z"/>
          </svg>
        </div>
        <div class="metric-content">
          <h3>连续记录天数</h3>
          <div class="metric-value">{{ summary.consecutiveDays }}</div>
          <div class="metric-status normal">坚持就是胜利</div>
        </div>
      </div>

      <!-- 本周目标 -->
      <div class="metric-card">
        <div class="metric-icon constitution">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5..."/>
          </svg>
        </div>
        <div class="metric-content">
          <h3>本周目标</h3>
          <div class="metric-value">{{ summary.weeklyGoal }}</div>
          <div class="metric-status excellent">每周7天</div>
        </div>
      </div>

      <!-- 完成率 -->
      <div class="metric-card">
        <div class="metric-icon constitution">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2a10 10 0 100 20 10 10 0 000-20z"/>
          </svg>
        </div>
        <div class="metric-content">
          <h3>完成率</h3>
          <div class="metric-value">{{ summary.completionRate }}%</div>
          <div class="metric-status excellent">目标进度</div>
        </div>
      </div>
    </div>

    <!-- 原趋势图删除，改为两个动画图表 -->
    <div class="card chart-row">
      <div class="trend-card">
        <canvas id="trendLineCanvas"></canvas>
      </div>
      <div class="mood-card">
        <canvas id="moodDonutCanvas"></canvas>
        <!-- 鼠标悬停提示框 -->
        <div v-if="moodTooltip.show" class="mood-tooltip" :style="{
          left: moodTooltip.x + 'px',
          top: moodTooltip.y + 'px'
        }">
          <div class="tooltip-header">{{ moodTooltip.label }}</div>
          <div class="tooltip-content">
            <div class="tooltip-item">
              <span class="tooltip-icon">📊</span>
              <span>共 {{ moodTooltip.count }} 天</span>
            </div>
            <div class="tooltip-divider"></div>
            <div v-for="(state, index) in moodTooltip.moodStates" :key="index" class="tooltip-item mood-detail">
              <span>{{ state }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部返回首页按钮已移除 -->
    <!-- <div class="actions">
         <button class="back-btn" @click="goBack">← 返回首页</button>
       </div> -->
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getCheckinSummary, getHealthTrends } from '../services/api';

// 类型定义
type TrendItem = { date: string; sleepHours: number | null; exerciseMinutes: number | null };
type MoodCounts = { 
  positive: number; 
  neutral: number; 
  negative: number; 
  sampleDays: number;
  moodDetails: { [key: number]: number }; // 记录每种具体情绪的数量
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
const loading = ref(true);
const trendAggregated = ref<TrendItem[]>([]);
const moodCounts = ref<MoodCounts>({ positive: 0, neutral: 0, negative: 0, sampleDays: 0, moodDetails: {} });

// 情绪状态映射（与Checkin.vue保持一致）
const moodLabels = ['很差', '一般', '良好', '很好', '极佳'];
const moodEmojis = ['😢', '😕', '😊', '😄', '🤩'];

// Tooltip状态
const moodTooltip = ref({
  show: false,
  x: 0,
  y: 0,
  label: '',
  count: 0,
  moodStates: [] as string[]
});

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
function aggregateByDate(rows: any[]) {
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

onMounted(async () => {
  try {
    const s = await getCheckinSummary();
    summary.value = {
      totalCheckins: s.totalCheckins ?? 0,
      consecutiveDays: s.consecutiveDays ?? 0,
      weeklyGoal: s.weeklyGoal ?? 7,
      completionRate: s.completionRate ?? 0
    };

    const t = await getHealthTrends(7);
    const raw: any[] = t.trends || [];
    const byDate = aggregateByDate(raw);
    const days = getLastNDates(7);

    trends.value = days.map((d: string) => ({
      date: d,
      sleepHours: byDate[d]?.sleepHours ?? null,
      exerciseMinutes: byDate[d]?.exerciseMinutes ?? 0,
      symptoms: byDate[d]?.symptoms ?? [],
      mood: byDate[d]?.moods?.length
        ? Math.round(byDate[d].moods.reduce((a: number, c: number) => a + c, 0) / byDate[d].moods.length)
        : undefined
    }));

    // 统一把 trends.value 映射为绘图需要的结构
    trendAggregated.value = trends.value.map(d => ({
      date: d.date || '',
      sleepHours: d.sleepHours ?? null,
      exerciseMinutes: d.exerciseMinutes ?? 0
    }));

    // 统计情绪分布（示例分段：0-1 负面，2 中性，3-4 正面）
    const mc: MoodCounts = { positive: 0, neutral: 0, negative: 0, sampleDays: 0, moodDetails: {} };
    trends.value.forEach(d => {
      if (typeof d.mood === 'number') {
        mc.sampleDays += 1;
        // 统计具体情绪
        mc.moodDetails[d.mood] = (mc.moodDetails[d.mood] || 0) + 1;
        
        // 分类统计
        if (d.mood <= 1) mc.negative += 1;
        else if (d.mood === 2) mc.neutral += 1;
        else mc.positive += 1;
      }
    });
    moodCounts.value = mc;

    // 使用带参数版本的绘图函数（此时两个变量已存在）
    drawAnimatedLineChart('trendLineCanvas', trendAggregated.value);
    drawAnimatedDonutChart('moodDonutCanvas', moodCounts.value);
  } catch (error) {
    console.error('获取仪表盘数据失败:', error);
  } finally {
    loading.value = false;
  }
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

  let startAngle = -Math.PI / 2;
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
          const moodStates: string[] = [];
          sector.moodRange.forEach(moodIndex => {
            const count = mood.moodDetails[moodIndex] || 0;
            if (count > 0) {
              moodStates.push(`${moodEmojis[moodIndex]} ${moodLabels[moodIndex]} (${count}天)`);
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
  position: relative;
  min-height: 100vh;
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
  padding: 40px 20px;
}

.metrics-header {
  text-align: center;
  margin-bottom: 28px;
}
.metrics-header h1 {
  font-size: 32px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 8px 0;
}
.metrics-header p {
  font-size: 16px;
  color: #6b7280;
  margin: 0;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  max-width: 1200px;
  margin: 0 auto 24px auto;
}

/* 统一卡片风格 */
.metric-card,
.chart-card {
  background: #ffffff;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.metric-card {
  display: flex;
  align-items: center;
  gap: 16px;
}
.metric-icon {
  width: 72px;
  height: 72px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.metric-icon svg {
  width: 36px;
  height: 36px;
  color: #fff;
}
.metric-icon.sleep { background: linear-gradient(135deg, #667eea, #764ba2); }
.metric-icon.activity { background: linear-gradient(135deg, #f093fb, #f5576c); }
.metric-icon.constitution { background: linear-gradient(135deg, #4facfe, #00f2fe); }

.metric-content h3 {
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 6px 0;
}
.metric-value {
  font-size: 28px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 6px 0;
}
.metric-status {
  font-size: 13px;
  font-weight: 500;
  padding: 4px 10px;
  border-radius: 12px;
  display: inline-block;
}
.metric-status.excellent { background: #d4edda; color: #155724; }
.metric-status.good { background: #cce5ff; color: #004085; }
.metric-status.normal { background: #fff3cd; color: #856404; }

/* 图表卡片标题 */
.chart-card {
  max-width: 1200px;
  margin: 0 auto 24px auto;
}
.chart-card h3 {
  margin: 0 0 12px 0;
  color: #2c3e50;
  font-weight: 600;
}

/* 左上角返回按钮 */
.back-top-left {
  position: absolute;
  top: 10px;
  left: 20px;
  z-index: 100;
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

/* 图表布局 */
.chart-row {
  display: flex;
  gap: 24px;
  align-items: stretch;
}
.trend-card {
  flex: 1;
}
.mood-card {
  width: 340px;
  min-width: 300px;
  position: relative;
}

/* Tooltip样式 */
.mood-tooltip {
  position: absolute;
  background: rgba(0, 0, 0, 0.9);
  color: white;
  padding: 12px 16px;
  border-radius: 8px;
  pointer-events: none;
  z-index: 1000;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  min-width: 140px;
  backdrop-filter: blur(10px);
  animation: tooltipFadeIn 0.2s ease-out;
}

@keyframes tooltipFadeIn {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.tooltip-header {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 8px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  padding-bottom: 6px;
}

.tooltip-content {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.tooltip-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}

.tooltip-icon {
  font-size: 16px;
}

.tooltip-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.2);
  margin: 6px 0;
}

.mood-detail {
  font-size: 12px;
  color: #e0e0e0;
  padding-left: 4px;
}
#trendLineCanvas, #moodDonutCanvas {
  width: 100%;
  height: 280px;
  display: block;
}

/* 响应式 */
@media (max-width: 768px) {
  .metrics-grid { grid-template-columns: 1fr; }
  .metric-card { padding: 20px; }
}
</style>