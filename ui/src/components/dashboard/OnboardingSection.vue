<template>
  <section class="welcome-section" :class="{ 'compact-mode': isCompact }">
    <div class="welcome-content">
      <div class="journey-section">
        <div class="journey-content glass-panel">
          <!-- 动态背景网格 -->
          <div class="grid-bg"></div>
          
          <div class="journey-header">
            <h2 class="journey-title">三步开启智能养生之旅</h2>
            <p class="journey-desc">
              基于 DeepSeek 大模型构建的个人健康数字孪生系统，为您提供毫秒级的健康分析与决策支持。
            </p>
          </div>
          
          <div class="journey-steps-wrapper">
            <!-- 动态数据流连接线 -->
            <div class="data-flow-line">
              <div class="flow-particle p1"></div>
              <div class="flow-particle p2"></div>
              <div class="flow-particle p3"></div>
            </div>
            
            <div class="journey-steps">
              <!-- Step 1: 扫描/评估 -->
              <div class="journey-step step-1" :class="{ 'active': activeStep >= 1 }">
                <div class="step-card">
                  <div class="card-glow"></div>
                  <div class="step-icon-box">
                    <div class="scan-line"></div>
                    <svg class="step-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                      <path d="M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM17 17l3 3m-3 0l3-3"></path>
                    </svg>
                    <span class="step-num">01</span>
                  </div>
                  <div class="step-content">
                    <h3>多维体质扫描</h3>
                    <p>AI 深度分析 40+ 项体征数据</p>
                  </div>
                </div>
              </div>
              
              <!-- Step 2: 处理/生成 -->
              <div class="journey-step step-2" :class="{ 'active': activeStep >= 2 }">
                <div class="step-card">
                  <div class="card-glow"></div>
                  <div class="step-icon-box processing">
                    <div class="spin-ring"></div>
                    <svg class="step-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                      <path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8z"></path>
                      <path d="M12 6v6l4 2"></path>
                    </svg>
                    <span class="step-num">02</span>
                  </div>
                  <div class="step-content">
                    <h3>生成调养方案</h3>
                    <p>动态匹配 500+ 种食药材组合</p>
                  </div>
                </div>
              </div>
              
              <!-- Step 3: 优化/闭环 -->
              <div class="journey-step step-3" :class="{ 'active': activeStep >= 3 }">
                <div class="step-card">
                  <div class="card-glow"></div>
                  <div class="step-icon-box success">
                    <svg class="step-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                      <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                    <div class="pulse-ring"></div>
                    <span class="step-num">03</span>
                  </div>
                  <div class="step-content">
                    <h3>智能反馈闭环</h3>
                    <p>实时跟踪效果并自我进化</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="action-area">
             <div class="start-btn-wrapper">
               <button class="start-btn" @click="activateSystem" :disabled="isActivating">
                 <span v-if="!isActivating">立即体验</span>
                 <span v-else>{{ buttonText }}</span>
                 <svg v-if="!isActivating" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <line x1="5" y1="12" x2="19" y2="12"></line>
                   <polyline points="12 5 19 12 12 19"></polyline>
                 </svg>
                 <div v-else class="btn-spinner"></div>
               </button>
             </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

defineOptions({ name: 'OnboardingSection' });

const props = defineProps<{
  layout?: 'default' | 'compact'
}>();

const isCompact = computed(() => props.layout === 'compact');

const router = useRouter();
const isActivating = ref(false);
const activeStep = ref(0);
const buttonText = ref('立即体验');

const activateSystem = async () => {
  if (isActivating.value) return;
  
  isActivating.value = true;
  buttonText.value = '系统初始化中...';
  
  // Step 1: Scan
  activeStep.value = 1;
  await new Promise(resolve => setTimeout(resolve, 1500));
  
  // Step 2: Generate
  activeStep.value = 2;
  await new Promise(resolve => setTimeout(resolve, 1500));
  
  // Step 3: Feedback
  activeStep.value = 3;
  await new Promise(resolve => setTimeout(resolve, 1500));
  
  // Complete
  buttonText.value = '进入系统';
  await new Promise(resolve => setTimeout(resolve, 500));
  
  router.push('/assessment');
};
</script>

<style scoped>
.welcome-section {
  padding: 60px 20px 100px;
  display: flex;
  justify-content: center;
  position: relative;
  /* 科技感微光背景 */
  background: radial-gradient(circle at 50% 30%, rgba(236, 253, 245, 0.8) 0%, rgba(240, 253, 250, 0.4) 60%, transparent 100%);
  /* Remove top padding to reduce gap with cards above */
  padding-top: 20px;
}

.welcome-content {
  width: 100%;
  max-width: 1200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
  z-index: 2;
}

.section-header {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.pulse-tag {
  font-size: 12px;
  color: #059669;
  background: rgba(16, 185, 129, 0.1);
  padding: 4px 12px;
  border-radius: 100px;
  font-weight: 700;
  letter-spacing: 1px;
  border: 1px solid rgba(16, 185, 129, 0.2);
  box-shadow: 0 0 15px rgba(16, 185, 129, 0.1);
  animation: tagPulse 3s infinite;
}

@keyframes tagPulse {
  0%, 100% { box-shadow: 0 0 15px rgba(16, 185, 129, 0.1); }
  50% { box-shadow: 0 0 25px rgba(16, 185, 129, 0.3); }
}

.welcome-title {
  font-size: 42px;
  font-weight: 900;
  background: linear-gradient(135deg, #064e3b 0%, #059669 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
  letter-spacing: -1px;
}

.welcome-subtitle {
  font-size: 14px;
  color: #64748b;
  font-family: monospace;
  letter-spacing: 2px;
  opacity: 0.7;
  text-transform: uppercase;
}

.journey-section {
  width: 100%;
  perspective: 1000px;
}

.journey-content.glass-panel {
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 32px;
  padding: 60px;
  box-shadow: 
    0 20px 50px -12px rgba(0, 0, 0, 0.05),
    inset 0 0 0 1px rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(24px);
  position: relative;
  overflow: hidden;
  transform-style: preserve-3d;
  transition: transform 0.3s;
}

.grid-bg {
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(16, 185, 129, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(16, 185, 129, 0.03) 1px, transparent 1px);
  background-size: 40px 40px;
  z-index: 0;
  pointer-events: none;
}

.journey-header {
  text-align: center;
  margin-bottom: 60px;
  position: relative;
  z-index: 2;
}

.journey-title {
  font-size: 28px;
  font-weight: 800;
  color: #1e293b;
  margin: 0 0 16px 0;
}

.journey-desc {
  max-width: 600px;
  margin: 0 auto;
  color: #64748b;
  line-height: 1.6;
}

.journey-steps-wrapper {
  position: relative;
  margin-bottom: 60px;
}

/* Data Flow Line */
.data-flow-line {
  position: absolute;
  top: 40px;
  left: 15%;
  right: 15%;
  height: 2px;
  background: rgba(16, 185, 129, 0.1);
  z-index: 0;
  overflow: hidden;
}

.flow-particle {
  position: absolute;
  top: 0;
  left: 0;
  width: 40px;
  height: 2px;
  background: linear-gradient(90deg, transparent, #10b981, transparent);
  animation: flow 3s linear infinite;
}

.p1 { animation-delay: 0s; }
.p2 { animation-delay: 1s; }
.p3 { animation-delay: 2s; }

@keyframes flow {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(500%); }
}

.journey-steps {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30px;
  position: relative;
  z-index: 2;
}

/* Step Card */
.step-card {
  background: rgba(255, 255, 255, 0.8);
  border-radius: 24px;
  padding: 32px 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.03);
  transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  position: relative;
  overflow: hidden;
}

.step-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px -12px rgba(16, 185, 129, 0.15);
  border-color: rgba(16, 185, 129, 0.3);
}

.card-glow {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 50% 0%, rgba(16, 185, 129, 0.05), transparent 70%);
  opacity: 0;
  transition: opacity 0.4s;
}

.step-card:hover .card-glow {
  opacity: 1;
}

.step-icon-box {
  width: 80px;
  height: 80px;
  background: #fff;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
  position: relative;
  box-shadow: 0 8px 20px -6px rgba(0, 0, 0, 0.05);
  transition: transform 0.4s;
}

.step-card:hover .step-icon-box {
  transform: scale(1.1);
  box-shadow: 0 12px 24px -8px rgba(16, 185, 129, 0.2);
}

.step-icon {
  width: 32px;
  height: 32px;
  color: #334155;
  transition: color 0.3s;
}

.step-card:hover .step-icon {
  color: #10b981;
}

.step-num {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #f1f5f9;
  color: #94a3b8;
  font-size: 12px;
  font-weight: 800;
  padding: 2px 6px;
  border-radius: 6px;
  transition: all 0.3s;
}

.step-card:hover .step-num {
  background: #10b981;
  color: #fff;
}

/* Animations for icons */
.scan-line {
  position: absolute;
  top: 20%;
  left: 20%;
  width: 60%;
  height: 2px;
  background: #10b981;
  opacity: 0;
  transition: opacity 0.3s;
}

.step-card:hover .scan-line {
  opacity: 1;
  animation: scan 1.5s infinite linear;
}

@keyframes scan {
  0% { top: 20%; opacity: 0; }
  20% { opacity: 1; }
  80% { opacity: 1; }
  100% { top: 80%; opacity: 0; }
}

.spin-ring {
  position: absolute;
  width: 50px;
  height: 50px;
  border: 2px solid transparent;
  border-top-color: #10b981;
  border-radius: 50%;
  opacity: 0;
}

.step-card:hover .spin-ring {
  opacity: 1;
  animation: spin 1s infinite linear;
}

@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.pulse-ring {
  position: absolute;
  inset: 0;
  border-radius: 20px;
  border: 2px solid #10b981;
  opacity: 0;
}

.step-card:hover .pulse-ring {
  animation: ripple 1.5s infinite;
}

@keyframes ripple {
  0% { transform: scale(1); opacity: 0.8; }
  100% { transform: scale(1.4); opacity: 0; }
}

.step-content h3 {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 8px 0;
}

.step-content p {
  font-size: 13px;
  color: #64748b;
  line-height: 1.5;
  margin: 0;
}

.action-area {
  display: flex;
  justify-content: center;
  position: relative;
}

.start-btn {
  background: #10b981;
  color: white;
  border: none;
  padding: 16px 48px;
  border-radius: 100px;
  font-size: 16px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  position: relative;
  z-index: 2;
  transition: all 0.3s;
  box-shadow: 0 10px 20px -5px rgba(16, 185, 129, 0.4);
}

.start-btn svg {
  width: 20px;
  height: 20px;
  transition: transform 0.3s;
}

.start-btn:hover {
  background: #059669;
  transform: translateY(-2px);
  box-shadow: 0 15px 30px -5px rgba(16, 185, 129, 0.5);
}

.start-btn:hover svg {
  transform: translateX(4px);
}

.btn-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 100%;
  height: 100%;
  background: #10b981;
  filter: blur(20px);
  opacity: 0.3;
  z-index: 1;
  transition: opacity 0.3s;
}

.start-btn-wrapper:hover .btn-glow {
  opacity: 0.6;
}

/* Active Step Styles */
.journey-step.active .step-card {
  border-color: #10b981;
  box-shadow: 0 20px 40px -12px rgba(16, 185, 129, 0.25);
  transform: translateY(-5px);
}

.journey-step.active .step-icon-box {
  background: #ecfdf5;
  color: #10b981;
}

.journey-step.active .step-icon {
  color: #10b981;
}

.journey-step.active .step-num {
  background: #10b981;
  color: white;
}

/* Spinner */
.btn-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s linear infinite;
}

/* Mobile */
@media (max-width: 768px) {
  .journey-steps {
    grid-template-columns: 1fr;
  }
  .data-flow-line { display: none; }
  .welcome-title { font-size: 32px; }
  .journey-content.glass-panel { padding: 30px 20px; }
}
</style>

/* Compact Mode Styles */
.welcome-section.compact-mode {
  padding: 0;
  background: none;
}

.welcome-section.compact-mode .welcome-content {
  max-width: 100%;
  gap: 20px;
}

.welcome-section.compact-mode .journey-content.glass-panel {
  padding: 24px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.5);
  box-shadow: none;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.welcome-section.compact-mode .journey-steps {
  grid-template-columns: 1fr;
  gap: 16px;
}

.welcome-section.compact-mode .data-flow-line {
  display: none;
}

.welcome-section.compact-mode .journey-header {
  margin-bottom: 24px;
  text-align: left;
  display: block;
}

.welcome-section.compact-mode .journey-title {
  font-size: 20px;
  margin-bottom: 8px;
  background: none;
  -webkit-text-fill-color: #1e293b;
  color: #1e293b;
}

.welcome-section.compact-mode .journey-desc {
  font-size: 13px;
  text-align: left;
  margin: 0;
}

.welcome-section.compact-mode .journey-steps-wrapper {
  margin-bottom: 24px;
}

.welcome-section.compact-mode .step-card {
  display: flex;
  align-items: center;
  padding: 16px;
  gap: 16px;
  text-align: left;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 16px;
}

.welcome-section.compact-mode .step-icon-box {
  width: 44px;
  height: 44px;
  margin-bottom: 0;
  flex-shrink: 0;
}

.welcome-section.compact-mode .step-icon {
  width: 20px;
  height: 20px;
}

.welcome-section.compact-mode .step-content {
  text-align: left;
}

.welcome-section.compact-mode .step-content h3 {
  font-size: 15px;
  margin-bottom: 4px;
  font-weight: 700;
}

.welcome-section.compact-mode .step-content p {
  font-size: 12px;
  margin: 0;
  opacity: 0.8;
}

.welcome-section.compact-mode .start-btn {
  width: 100%;
  height: 48px;
  font-size: 15px;
}

