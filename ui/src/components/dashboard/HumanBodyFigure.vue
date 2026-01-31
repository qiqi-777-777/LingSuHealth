<template>
  <div class="energy-wrapper">
    <div class="energy-container">
      <div class="orbit o1"></div>
      <div class="orbit o2"></div>
      <div class="orbit o3"></div>
      
      <div class="core" :class="{ 'has-warning': hasHealthIssues }">
        <!-- 动态警告点：根据健康问题显示 -->
        <div 
          v-for="(issue, index) in healthIssues" 
          :key="index"
          class="warning-glitch"
          :style="getIssuePosition(issue.area)"
          :title="issue.description"
        >
          <div class="pulse-ring"></div>
        </div>
      </div>
      
      <div class="status-text">
        <span v-if="!hasHealthIssues" class="normal-status">
          AI 生命能量体：<span class="normal-span">状态良好</span>
        </span>
        <span v-else class="warning-status">
          AI 生命能量体：<span class="warn-span">检测到 {{ healthIssues.length }} 处异常波动</span>
        </span>
      </div>
      
      <!-- 问题详情提示 -->
      <div v-if="hasHealthIssues" class="issues-detail">
        <div v-for="(issue, index) in healthIssues" :key="index" class="issue-item">
          <span class="issue-icon">⚠</span>
          <span class="issue-text">{{ issue.description }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';

interface HealthIssue {
  area: string; // 'head', 'chest', 'stomach', 'legs'
  description: string;
  severity: 'low' | 'medium' | 'high';
}

const props = defineProps<{
  userSymptoms?: string[]; // 从外部传入的症状
  checkinData?: any; // 打卡数据
  assessmentData?: any; // 测评数据
}>();

const healthIssues = ref<HealthIssue[]>([]);

const hasHealthIssues = computed(() => healthIssues.value.length > 0);

// 根据身体部位返回警告点的位置（围绕能量体）
function getIssuePosition(area: string) {
  const positions: Record<string, { top: string; left: string }> = {
    head: { top: '5%', left: '50%' },           // 顶部
    chest: { top: '30%', left: '85%' },         // 右侧
    stomach: { top: '50%', left: '50%' },       // 中心
    legs: { top: '85%', left: '50%' },          // 底部
    left_shoulder: { top: '25%', left: '15%' }, // 左上
    right_shoulder: { top: '25%', left: '85%' },// 右上
  };
  return positions[area] || { top: '50%', left: '50%' };
}

// 分析症状并映射到身体部位
function analyzeSymptoms(symptoms: string[]) {
  const issues: HealthIssue[] = [];
  
  symptoms.forEach(symptom => {
    const lowerSymptom = symptom.toLowerCase();
    
    // 头部相关
    if (lowerSymptom.includes('头痛') || lowerSymptom.includes('头晕') || 
        lowerSymptom.includes('失眠') || lowerSymptom.includes('偏头痛')) {
      issues.push({
        area: 'head',
        description: '头部不适',
        severity: 'medium'
      });
    }
    
    // 胸部相关
    if (lowerSymptom.includes('胸闷') || lowerSymptom.includes('心悸') || 
        lowerSymptom.includes('气短') || lowerSymptom.includes('呼吸')) {
      issues.push({
        area: 'chest',
        description: '胸部不适',
        severity: 'high'
      });
    }
    
    // 胃部相关
    if (lowerSymptom.includes('胃') || lowerSymptom.includes('腹') || 
        lowerSymptom.includes('消化') || lowerSymptom.includes('恶心')) {
      issues.push({
        area: 'stomach',
        description: '消化系统不适',
        severity: 'medium'
      });
    }
    
    // 腿部相关
    if (lowerSymptom.includes('腿') || lowerSymptom.includes('膝盖') || 
        lowerSymptom.includes('脚') || lowerSymptom.includes('关节')) {
      issues.push({
        area: 'legs',
        description: '下肢不适',
        severity: 'low'
      });
    }
    
    // 肩部相关
    if (lowerSymptom.includes('肩') || lowerSymptom.includes('颈')) {
      issues.push({
        area: 'left_shoulder',
        description: '肩颈不适',
        severity: 'medium'
      });
    }
  });
  
  return issues;
}

// 从打卡数据分析健康问题
function analyzeCheckinData(data: any) {
  const issues: HealthIssue[] = [];
  
  if (data?.sleepHours && data.sleepHours < 6) {
    issues.push({
      area: 'head',
      description: '睡眠不足',
      severity: 'high'
    });
  }
  
  if (data?.mood && data.mood === '焦虑') {
    issues.push({
      area: 'chest',
      description: '情绪焦虑',
      severity: 'medium'
    });
  }
  
  if (data?.exerciseMinutes && data.exerciseMinutes < 30) {
    issues.push({
      area: 'legs',
      description: '运动不足',
      severity: 'low'
    });
  }
  
  return issues;
}

// 从测评数据分析健康问题
function analyzeAssessmentData(data: any) {
  const issues: HealthIssue[] = [];
  
  if (data?.constitution) {
    const constitution = data.constitution.toLowerCase();
    
    if (constitution.includes('气虚')) {
      issues.push({
        area: 'chest',
        description: '气虚体质',
        severity: 'medium'
      });
    }
    
    if (constitution.includes('阳虚')) {
      issues.push({
        area: 'stomach',
        description: '阳虚体质',
        severity: 'medium'
      });
    }
    
    if (constitution.includes('阴虚')) {
      issues.push({
        area: 'head',
        description: '阴虚体质',
        severity: 'medium'
      });
    }
  }
  
  return issues;
}

// 更新健康问题
function updateHealthIssues() {
  const allIssues: HealthIssue[] = [];
  
  // 分析症状
  if (props.userSymptoms && props.userSymptoms.length > 0) {
    allIssues.push(...analyzeSymptoms(props.userSymptoms));
  }
  
  // 分析打卡数据
  if (props.checkinData) {
    allIssues.push(...analyzeCheckinData(props.checkinData));
  }
  
  // 分析测评数据
  if (props.assessmentData) {
    allIssues.push(...analyzeAssessmentData(props.assessmentData));
  }
  
  // 去重（相同区域只保留一个）
  const uniqueIssues = allIssues.reduce((acc, issue) => {
    if (!acc.find(i => i.area === issue.area)) {
      acc.push(issue);
    }
    return acc;
  }, [] as HealthIssue[]);
  
  healthIssues.value = uniqueIssues;
}

// 监听props变化
watch(() => [props.userSymptoms, props.checkinData, props.assessmentData], () => {
  updateHealthIssues();
}, { deep: true });

onMounted(() => {
  updateHealthIssues();
});
</script>

<style scoped>
.energy-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  min-height: 380px; /* 增加高度以容纳问题列表 */
  /* 保持与周围环境融合的背景，或者使用用户提供的深色背景 */
  /* background: #0f172a;  User's body bg, can be optional if parent is already dark */
}

.energy-container {
  position: relative;
  width: 240px; /* 从300px压缩到240px */
  height: 240px;
  perspective: 1000px;
  /* Define variables locally */
  --core-color: #00f2fe; /* 正常时的青色 */
  --warn-color: #ff4d4d; /* 不适时的红色 */
}

/* 旋转的光环 */
.orbit {
  position: absolute;
  width: 100%;
  height: 100%;
  border: 2px solid rgba(0, 242, 254, 0.2);
  border-radius: 50%;
  transform-style: preserve-3d;
  box-shadow: 0 0 10px rgba(0, 242, 254, 0.1);
}

.o1 {
  animation: rotate 10s linear infinite;
}

.o2 {
  transform: rotateX(70deg) rotateY(30deg);
  animation: rotate-o2 7s linear infinite;
}

.o3 {
  transform: rotateX(-70deg) rotateY(-30deg);
  animation: rotate-o3 5s linear infinite;
}

/* 核心能量球 */
.core {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100px; /* 从120px压缩到100px */
  height: 100px;
  margin-left: -50px; /* 调整居中 */
  margin-top: -50px;
  background: radial-gradient(circle, var(--core-color) 0%, transparent 70%);
  border-radius: 50%;
  box-shadow: 0 0 50px var(--core-color);
  animation: breath 3s ease-in-out infinite;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: all 0.5s;
}

.core.has-warning {
  --core-color: #ff9966;
  box-shadow: 0 0 60px var(--warn-color);
  animation: breath-warning 2s ease-in-out infinite;
}

@keyframes breath-warning {
  0%, 100% { transform: scale(1); opacity: 0.9; }
  50% { transform: scale(1.15); opacity: 1; box-shadow: 0 0 100px var(--warn-color); }
}

/* 红色警告点 - 围绕能量体分布 */
.warning-glitch {
  position: absolute;
  width: 28px;
  height: 28px;
  background: var(--warn-color);
  border-radius: 50%;
  filter: blur(6px);
  animation: pulse 1.5s infinite;
  transform: translate(-50%, -50%);
  z-index: 10;
  box-shadow: 0 0 15px var(--warn-color);
}

.pulse-ring {
  position: absolute;
  inset: -8px;
  border: 2px solid var(--warn-color);
  border-radius: 50%;
  animation: ripple 2s infinite;
  filter: blur(1px);
}

@keyframes ripple {
  0% { transform: scale(0.8); opacity: 1; }
  100% { transform: scale(2.5); opacity: 0; }
}

.normal-status {
  color: var(--core-color);
}

.normal-span {
  color: #34d399;
  font-weight: bold;
  text-shadow: 0 0 5px rgba(52, 211, 153, 0.5);
}

.warning-status {
  color: var(--core-color);
}

/* 问题详情列表 */
.issues-detail {
  position: absolute;
  bottom: -150px;
  left: 50%;
  transform: translateX(-50%);
  width: 300px;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 77, 77, 0.4);
  border-radius: 16px;
  padding: 14px;
  max-height: 130px;
  overflow-y: auto;
  box-shadow: 0 8px 24px rgba(255, 77, 77, 0.3);
}

.issue-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 10px;
  margin-bottom: 6px;
  background: rgba(255, 77, 77, 0.15);
  border-radius: 10px;
  font-size: 13px;
  color: #fecaca;
  border: 1px solid rgba(255, 77, 77, 0.2);
  transition: all 0.3s;
}

.issue-item:hover {
  background: rgba(255, 77, 77, 0.25);
  border-color: rgba(255, 77, 77, 0.4);
}

.issue-item:last-child {
  margin-bottom: 0;
}

.issue-icon {
  font-size: 16px;
  flex-shrink: 0;
  animation: warning-blink 2s infinite;
}

@keyframes warning-blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.issue-text {
  flex: 1;
  line-height: 1.5;
  font-weight: 500;
}

.status-text {
  position: absolute;
  bottom: -60px; /* 从-80px调整到-60px，减少底部空间 */
  width: 100%;
  text-align: center;
  color: var(--core-color);
  font-family: "Microsoft YaHei", sans-serif;
  letter-spacing: 2px;
  font-size: 13px; /* 从14px减小到13px */
  text-shadow: 0 0 5px rgba(0, 242, 254, 0.5);
}

.warn-span {
  color: var(--warn-color);
  font-weight: bold;
  text-shadow: 0 0 5px rgba(255, 77, 77, 0.5);
}

@keyframes rotate {
  from { transform: rotateZ(0deg) rotateX(60deg); }
  to { transform: rotateZ(360deg) rotateX(60deg); }
}

@keyframes rotate-o2 {
  from { transform: rotateX(70deg) rotateY(30deg) rotateZ(0deg); }
  to { transform: rotateX(70deg) rotateY(30deg) rotateZ(360deg); }
}

@keyframes rotate-o3 {
  from { transform: rotateX(-70deg) rotateY(-30deg) rotateZ(0deg); }
  to { transform: rotateX(-70deg) rotateY(-30deg) rotateZ(360deg); }
}

@keyframes breath {
  0%, 100% { transform: scale(1); opacity: 0.8; }
  50% { transform: scale(1.1); opacity: 1; box-shadow: 0 0 80px var(--core-color); }
}

@keyframes pulse {
  0% { 
    transform: scale(1); 
    opacity: 1; 
    filter: blur(6px);
  }
  50% { 
    transform: scale(1.3); 
    opacity: 0.8; 
    filter: blur(8px);
  }
  100% { 
    transform: scale(1); 
    opacity: 1; 
    filter: blur(6px);
  }
}
</style>
