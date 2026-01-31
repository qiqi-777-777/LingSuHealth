<template>
  <div>
    <!-- 模块介绍标题 -->
    <div class="section-header">
      <h3 class="section-title">模块介绍</h3>
    </div>
    
    <div class="feature-desc-container">
      <div class="desc-card">
        <div class="icon-box icon-teal">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm-1 15h2v2h-2zm0-10h2v8h-2z"/>
          </svg>
        </div>
        <div class="text-content">
          <h4>药食同源</h4>
          <p>基于中医体质辨识，推荐适合您的药膳食疗方案，以食养生。</p>
        </div>
      </div>

      <div class="desc-card">
        <div class="icon-box icon-orange">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
          </svg>
        </div>
        <div class="text-content">
          <h4>动态调理</h4>
          <p>根据您的每日打卡记录，AI 实时动态调整健康方案，精准干预。</p>
        </div>
      </div>

      <div class="desc-card">
        <div class="icon-box icon-blue">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
        </div>
        <div class="text-content">
          <h4>智能预警</h4>
          <p>监测健康数据趋势，异常指标即时提醒，防患于未然。</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: 'FeatureDescription' });
</script>

<style scoped>
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

.feature-desc-container {
  display: flex;
  gap: 20px;
  width: 100%;
}

.desc-card {
  flex: 1;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 20px;
  padding: 20px 24px;
  display: flex;
  gap: 16px;
  align-items: flex-start;
  backdrop-filter: blur(8px);
  transition: all 0.3s ease;
}

.desc-card:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.icon-box {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.icon-box svg {
  width: 20px;
  height: 20px;
}

.icon-teal {
  background: rgba(13, 148, 136, 0.1);
  color: #0d9488;
}

.icon-orange {
  background: rgba(234, 88, 12, 0.1);
  color: #ea580c;
}

.icon-blue {
  background: rgba(37, 99, 235, 0.1);
  color: #2563eb;
}

.text-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.text-content h4 {
  margin: 0;
  font-size: 15px;
  font-weight: 700;
  color: #1e293b;
}

.text-content p {
  margin: 0;
  font-size: 13px;
  color: #64748b;
  line-height: 1.5;
}
</style>
