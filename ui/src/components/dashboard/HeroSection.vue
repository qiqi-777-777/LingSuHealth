<template>
  <div style="display: contents">
    <HomeAIInput />
    
    <!-- 功能模块标题 -->
    <div class="section-header">
      <h3 class="section-title">功能模块</h3>
    </div>
    
    <!-- 快捷入口 (第一组) -->
    <div class="hero-quick-actions">
      <button class="quick-btn primary" @click="$emit('navigate', '/assessment')">
        <div class="btn-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 11l3 3L22 4"/>
            <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
          </svg>
        </div>
        <div class="btn-text">
          <span class="btn-title">体质测评</span>
          <span class="btn-desc">生成专属方案</span>
        </div>
      </button>
      
      <button class="quick-btn secondary" @click="$emit('open-plan-modal')">
        <div class="btn-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 8v4l3 3m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/>
          </svg>
        </div>
        <div class="btn-text">
          <span class="btn-title">今日计划</span>
          <span class="btn-desc">{{ todayDone }}/{{ todayTotal }} 项已完成</span>
        </div>
      </button>

      <button class="quick-btn ghost" @click="$emit('navigate', '/checkin')">
         <div class="btn-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <path d="M14 2v6h6"/>
            <path d="M16 13H8"/>
            <path d="M16 17H8"/>
            <path d="M10 9H8"/>
          </svg>
         </div>
         <div class="btn-text">
           <span class="btn-title">打卡记录</span>
           <span class="btn-desc">{{ hasTodayCheckin ? '今日已打卡' : '记录健康状态' }}</span>
         </div>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import HomeAIInput from './HomeAIInput.vue';

defineOptions({ name: 'HeroSection' });

defineProps<{
  username: string;
  todayDone: number;
  todayTotal: number;
  weekDone: number;
  weekTotal: number;
  hasTodayCheckin: boolean | null;
}>();

defineEmits<{
  (e: 'navigate', path: string): void;
  (e: 'open-plan-modal'): void;
}>();
</script>

<style scoped>
.hero-quick-actions {
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
}

/* 功能模块标签 */
.feature-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  font-size: 11px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 8px;
  z-index: 3;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
  letter-spacing: 0.5px;
}

/* 区块标题 */
.section-header {
  margin-bottom: 16px;
}

.section-title {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
  padding-left: 12px;
  border-left: 4px solid #10b981;
}

/* Base style for all thematic cards */
.quick-btn .btn-text,
.quick-btn .btn-icon {
  position: relative;
  z-index: 2;
}

/* Primary Card - Assessment (Green Theme) */
.quick-btn.primary {
  background: white;
  border: 1px solid rgba(16, 185, 129, 0.2);
  color: #0f172a;
  box-shadow: 0 4px 20px -5px rgba(16, 185, 129, 0.1);
}
.quick-btn.primary .btn-icon {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}
.quick-btn.primary:hover {
  border-color: rgba(16, 185, 129, 0.5);
  box-shadow: 0 10px 30px -5px rgba(16, 185, 129, 0.15);
}
.quick-btn.primary::before {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.05) 0%, rgba(255,255,255,0) 100%);
}

/* Secondary Card - Plan (Amber/Yellow Theme) */
.quick-btn.secondary {
  background: white;
  border: 1px solid rgba(245, 158, 11, 0.2);
  color: #0f172a;
  box-shadow: 0 4px 20px -5px rgba(245, 158, 11, 0.1);
}
.quick-btn.secondary .btn-icon {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}
.quick-btn.secondary:hover {
  border-color: rgba(245, 158, 11, 0.5);
  box-shadow: 0 10px 30px -5px rgba(245, 158, 11, 0.15);
}
.quick-btn.secondary::before {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.05) 0%, rgba(255,255,255,0) 100%);
}

/* Ghost Card - Checkin (Blue Theme) */
.quick-btn.ghost {
  background: white;
  border: 1px solid rgba(59, 130, 246, 0.2);
  color: #0f172a;
  box-shadow: 0 4px 20px -5px rgba(59, 130, 246, 0.1);
}
.quick-btn.ghost .btn-icon {
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
}
.quick-btn.ghost:hover {
  border-color: rgba(59, 130, 246, 0.5);
  box-shadow: 0 10px 30px -5px rgba(59, 130, 246, 0.15);
}
.quick-btn.ghost::before {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.05) 0%, rgba(255,255,255,0) 100%);
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

.hero-side {
  display: flex;
  flex-direction: column;
}

.side-widgets-row {
  display: flex;
  gap: 20px;
  width: 100%;
}

.widget-wrapper {
  animation: slideInRight 0.6s ease-out backwards;
}

.widget-wrapper.compact {
  flex: 1;
  min-width: 0; /* Allow flex shrinking */
}

.widget-wrapper:nth-child(2) {
  animation-delay: 0.1s;
}

@keyframes slideInRight {
  from { opacity: 0; transform: translateX(20px); }
  to { opacity: 1; transform: translateX(0); }
}

@media (max-width: 1024px) {
  .hero-container {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  
  .hero-side {
    flex-direction: row;
    flex-wrap: wrap;
  }
  
  .widget-wrapper {
    flex: 1;
    min-width: 300px;
  }
}

@media (max-width: 768px) {
  .hero-quick-actions {
    flex-direction: column;
    padding-left: 0;
  }
  
  .hero-side {
    flex-direction: column;
  }
}
</style>
