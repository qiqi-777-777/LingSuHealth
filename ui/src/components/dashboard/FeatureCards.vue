<template>
  <div class="feature-cards-container">
    <button class="quick-btn secondary" @click="$emit('navigate', '/knowledge')">
      <div class="btn-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>
          <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
        </svg>
      </div>
      <div class="btn-text">
        <span class="btn-title">中医知识库</span>
        <span class="btn-desc">探索药膳与穴位</span>
      </div>
    </button>

    <button class="quick-btn secondary" @click="$emit('navigate', '/plan')">
      <div class="btn-icon" style="color: #f97316; background: rgba(249, 115, 22, 0.1);">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"/>
          <rect x="9" y="3" width="6" height="4" rx="2"/>
          <path d="M9 14h6"/>
          <path d="M9 18h6"/>
          <path d="M9 10h6"/>
        </svg>
      </div>
      <div class="btn-text">
        <span class="btn-title">个性化方案</span>
        <span class="btn-desc">专属健康调理</span>
      </div>
    </button>

    <button class="quick-btn secondary" @click="$emit('navigate', '/dashboard-metrics')">
      <div class="btn-icon" style="color: #3b82f6; background: rgba(59, 130, 246, 0.1);">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="4" y="4" width="16" height="16" rx="2" ry="2"/>
          <line x1="12" y1="20" x2="12" y2="10"/>
          <line x1="16" y1="20" x2="16" y2="14"/>
          <line x1="8" y1="20" x2="8" y2="16"/>
        </svg>
      </div>
      <div class="btn-text">
        <span class="btn-title">健康仪表盘</span>
        <span class="btn-desc">数据趋势监控</span>
      </div>
    </button>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: 'FeatureCards' });

defineProps<{
  todayDone: number;
  todayTotal: number;
  weekDone: number;
  weekTotal: number;
}>();

defineEmits<{
  (e: 'navigate', path: string): void;
  (e: 'open-plan-modal'): void;
}>();
</script>

<style scoped>
.feature-cards-container {
  display: flex;
  gap: 20px;
  width: 100%;
}

.quick-btn {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  border-radius: 20px;
  border: none;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  text-align: left;
  flex: 1;
  min-height: 110px; /* Reduced height */
  height: auto;
  position: relative;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  color: white; /* Default text color for all cards */
}

/* Base style for all thematic cards */
.quick-btn .btn-text,
.quick-btn .btn-icon {
  position: relative;
  z-index: 2;
}

/* Specific Colors for Feature Cards */
.quick-btn:nth-child(1) { /* Knowledge - Teal */
  background: white;
  border: 1px solid rgba(13, 148, 136, 0.2);
  color: #0f172a;
  box-shadow: 0 4px 20px -5px rgba(13, 148, 136, 0.1);
}
.quick-btn:nth-child(1) .btn-icon {
  background: rgba(13, 148, 136, 0.1);
  color: #0d9488;
}
.quick-btn:nth-child(1):hover {
  border-color: rgba(13, 148, 136, 0.5);
  box-shadow: 0 10px 30px -5px rgba(13, 148, 136, 0.15);
}
.quick-btn:nth-child(1)::before {
  background: linear-gradient(135deg, rgba(13, 148, 136, 0.05) 0%, rgba(255,255,255,0) 100%);
}

.quick-btn:nth-child(2) { /* Plan - Orange */
  background: white;
  border: 1px solid rgba(234, 88, 12, 0.2);
  color: #0f172a;
  box-shadow: 0 4px 20px -5px rgba(234, 88, 12, 0.1);
}
.quick-btn:nth-child(2) .btn-icon {
  background: rgba(234, 88, 12, 0.1);
  color: #ea580c;
}
.quick-btn:nth-child(2):hover {
  border-color: rgba(234, 88, 12, 0.5);
  box-shadow: 0 10px 30px -5px rgba(234, 88, 12, 0.15);
}
.quick-btn:nth-child(2)::before {
  background: linear-gradient(135deg, rgba(234, 88, 12, 0.05) 0%, rgba(255,255,255,0) 100%);
}

.quick-btn:nth-child(3) { /* Metrics - Blue */
  background: white;
  border: 1px solid rgba(37, 99, 235, 0.2);
  color: #0f172a;
  box-shadow: 0 4px 20px -5px rgba(37, 99, 235, 0.1);
}
.quick-btn:nth-child(3) .btn-icon {
  background: rgba(37, 99, 235, 0.1);
  color: #2563eb;
}
.quick-btn:nth-child(3):hover {
  border-color: rgba(37, 99, 235, 0.5);
  box-shadow: 0 10px 30px -5px rgba(37, 99, 235, 0.15);
}
.quick-btn:nth-child(3)::before {
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.05) 0%, rgba(255,255,255,0) 100%);
}

/* Hover Effects */
.quick-btn:hover {
  transform: translateY(-4px) scale(1.02);
  box-shadow: 0 15px 30px -10px rgba(0, 0, 0, 0.2);
}

.btn-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 14px;
  flex-shrink: 0;
  backdrop-filter: blur(4px);
}

.btn-icon svg {
  width: 24px;
  height: 24px;
}

.btn-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.btn-title {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: -0.3px;
}

.btn-desc {
  font-size: 12px;
  opacity: 0.9;
  font-weight: 500;
  line-height: 1.4;
}

/* Decorative Background Watermark */
.quick-btn::after {
  content: '';
  position: absolute;
  right: -10px;
  bottom: -10px;
  width: 80px;
  height: 80px;
  background: currentColor; /* Uses text color (white) */
  mask-image: var(--bg-icon);
  -webkit-mask-image: var(--bg-icon);
  mask-size: contain;
  mask-repeat: no-repeat;
  opacity: 0.1;
  transform: rotate(-15deg);
  pointer-events: none;
  z-index: 1;
}

/* Assign icons to ::after for watermark effect (simulated with border-radius for now or simple shapes) */
.quick-btn::after {
  border-radius: 50%; /* Fallback shape */
  background: radial-gradient(circle, rgba(255,255,255,0.4) 0%, transparent 70%);
}
</style>