<template>
  <section class="dark-section">
    <!-- 极光背景 -->
    <div class="aurora-bg">
      <div class="aurora-light a1"></div>
      <div class="aurora-light a2"></div>
      <div class="aurora-light a3"></div>
    </div>
    
    <!-- 神经网络背景 -->
    <div class="neural-bg">
      <div class="neural-node n1"></div>
      <div class="neural-node n2"></div>
      <div class="neural-node n3"></div>
      <svg class="connection-lines" viewBox="0 0 100 100" preserveAspectRatio="none">
        <path d="M10,20 Q50,50 90,30" stroke="rgba(255,255,255,0.05)" stroke-width="0.5" fill="none"/>
        <path d="M20,80 Q50,40 80,70" stroke="rgba(255,255,255,0.05)" stroke-width="0.5" fill="none"/>
      </svg>
    </div>

    <div class="dark-content">
      <div class="dark-left">
        <div class="title-group">
          <div class="ai-badge glass-badge">
            <span class="dot"></span>
            AI Powered
          </div>
          <h2 class="dark-title font-serif">
            开启您的<br>
            <span class="gradient-text">数字养生之旅</span>
          </h2>
        </div>
        <p class="dark-description">
          融合传统中医智慧与 DeepSeek 大模型，为您构建全方位的健康管理闭环。
        </p>
        
        <div class="quick-consult glass-panel">
          <div class="input-group">
            <input 
              v-model="consultQuery" 
              type="text" 
              placeholder="输入您的症状 (如: 头痛、失眠)..."
              @keyup.enter="handleConsult"
            />
            <button @click="handleConsult" :disabled="isAnalyzing || !consultQuery">
              <span v-if="!isAnalyzing">分析</span>
              <div v-else class="spinner-sm"></div>
            </button>
          </div>
          <div v-if="analysisResult" class="consult-result">
            <div class="ai-avatar">AI</div>
            <p>{{ analysisResult }}</p>
          </div>
        </div>
        
        <!-- Bento Grid Features -->
        <div class="features-bento">
          <div class="bento-item glass-card item-1" :class="{ active: activeFeature === 0 }" @click="setActiveFeature(0)">
            <div class="bento-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
              </svg>
            </div>
            <div class="bento-text">
              <h4 class="font-serif">个性化定制</h4>
              <p>千人千面的健康方案</p>
            </div>
          </div>
          <div class="bento-item glass-card item-2" :class="{ active: activeFeature === 1 }" @click="setActiveFeature(1)">
            <div class="bento-icon">
               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
              </svg>
            </div>
            <div class="bento-text">
              <h4 class="font-serif">智能评估</h4>
              <p>多维数据实时分析</p>
            </div>
          </div>
          <div class="bento-item glass-card item-3" :class="{ active: activeFeature === 2 }" @click="setActiveFeature(2)">
            <div class="bento-icon">
               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"></circle>
                <polyline points="12 6 12 12 16 14"></polyline>
              </svg>
            </div>
            <div class="bento-text">
              <h4 class="font-serif">四季指南</h4>
              <p>顺应节气的养生智慧</p>
            </div>
          </div>
          <div class="bento-item glass-card item-4" :class="{ active: activeFeature === 3 }" @click="setActiveFeature(3)">
            <div class="bento-icon">
               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 2a10 10 0 0 1 10 10c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2m0 2a8 8 0 1 0 0 16 8 8 0 0 0 0-16"></path>
              </svg>
            </div>
            <div class="bento-text">
              <h4 class="font-serif">专业支持</h4>
              <p>科学营养建议</p>
            </div>
          </div>
        </div>
      </div>
      
      <div class="dark-right">
        <!-- 3D 数字孪生模型 (替代原有的 showcase-card) -->
        <div class="digital-twin-container">
          <HumanBodyFigure 
            :user-symptoms="detectedSymptoms"
            :checkin-data="latestCheckin"
            :assessment-data="latestAssessment"
          />
          <div class="scan-text">
            <span class="scan-label">AI 全息扫描中</span>
            <span class="scan-dots">...</span>
          </div>
        </div>
      </div>
    </div>
    
    <div class="dark-footer">
      <div class="footer-line"></div>
      <div class="mission-statement">
        <p class="mission-text-cn font-serif">让中医养生更科学，让健康管理更智能</p>
        <p class="mission-text-en">Scientific TCM Wellness · Intelligent Health Management</p>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue';
import HumanBodyFigure from './HumanBodyFigure.vue';
import { checkTodayCheckin } from '../../services/api';

defineOptions({ name: 'MarketingSection' });

const activeFeature = ref(0);
const consultQuery = ref('');
const isAnalyzing = ref(false);
const analysisResult = ref<string | null>(null);
const detectedSymptoms = ref<string[]>([]);
const latestCheckin = ref<any>(null);
const latestAssessment = ref<any>(null);

// 扩展的建议标签列表
const allSuggestions = [
  '最近总是失眠怎么办？',
  '霜降节气该吃什么？',
  '推荐一份护眼食谱',
  '胃胀气怎么缓解？',
  '经常头痛是什么原因？',
  '如何改善气虚体质？',
  '春季养生注意事项',
  '颈椎疼痛如何调理？',
  '手脚冰凉怎么改善？',
  '便秘吃什么好？',
  '口干舌燥怎么办？',
  '腰酸背痛如何缓解？',
  '皮肤干燥吃什么？',
  '如何提高免疫力？',
  '经常疲劳怎么调理？',
  '消化不良吃什么？'
];

const currentIndex = ref(0);
let rotateTimer: number | null = null;

// 当前显示的8个建议（两行，每行4个）
const visibleSuggestions = computed(() => {
  const result = [];
  for (let i = 0; i < 8; i++) {
    const index = (currentIndex.value + i) % allSuggestions.length;
    result.push(allSuggestions[index]);
  }
  return result;
});

// 启动轮播
function startRotation() {
  rotateTimer = window.setInterval(() => {
    // 逆时针转动：索引递减
    currentIndex.value = (currentIndex.value - 1 + allSuggestions.length) % allSuggestions.length;
  }, 3000); // 每3秒轮换一次
}

// 停止轮播
function stopRotation() {
  if (rotateTimer) {
    clearInterval(rotateTimer);
    rotateTimer = null;
  }
}

const setActiveFeature = (index: number) => {
  activeFeature.value = index;
};

// 从用户输入中提取症状
function extractSymptoms(query: string): string[] {
  const symptoms: string[] = [];
  const symptomKeywords = [
    '头痛', '头晕', '失眠', '偏头痛',
    '胸闷', '心悸', '气短', '呼吸困难',
    '胃痛', '腹痛', '消化不良', '恶心', '胃胀',
    '腿疼', '膝盖疼', '关节痛',
    '肩痛', '颈椎痛', '腰痛', '背痛',
    '手脚冰凉', '便秘', '口干', '疲劳'
  ];
  
  symptomKeywords.forEach(keyword => {
    if (query.includes(keyword)) {
      symptoms.push(keyword);
    }
  });
  
  return symptoms;
}

const handleConsult = async () => {
  if (!consultQuery.value.trim()) return;
  
  isAnalyzing.value = true;
  analysisResult.value = null;
  
  // 提取症状并更新能量体
  const symptoms = extractSymptoms(consultQuery.value);
  if (symptoms.length > 0) {
    detectedSymptoms.value = symptoms;
  }
  
  try {
    // 调用后端AI分析接口
    const response = await fetch('/api/assistant/quick-consult', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      },
      body: JSON.stringify({
        query: consultQuery.value
      })
    });
    
    if (!response.ok) {
      throw new Error('AI分析失败');
    }
    
    const data = await response.json();
    analysisResult.value = data.advice || data.message || '暂无建议';
  } catch (error) {
    console.error('AI分析错误:', error);
    // 降级到本地简单分析
    analysisResult.value = generateLocalAdvice(consultQuery.value, symptoms);
  } finally {
    isAnalyzing.value = false;
  }
};

// 点击建议标签：自动填充并发送
function selectSuggestion(text: string) {
  consultQuery.value = text;
  handleConsult();
}

// 本地简单建议生成（作为降级方案）
function generateLocalAdvice(query: string, symptoms: string[]): string {
  if (symptoms.length === 0) {
    return '建议您详细描述症状，以便获得更准确的建议。';
  }
  
  const adviceMap: Record<string, string> = {
    '头痛': '建议您尝试菊花决明子茶，并注意颈椎放松。',
    '头晕': '建议您保证充足睡眠，避免久坐，适当运动。',
    '失眠': '建议您睡前喝温牛奶，避免使用电子设备，保持规律作息。',
    '胸闷': '建议您深呼吸放松，如持续不适请及时就医。',
    '心悸': '建议您减少咖啡因摄入，保持情绪平稳。',
    '胃痛': '建议您少食多餐，避免辛辣刺激食物，可饮用温热粥类。',
    '胃胀': '建议您饭后散步，避免暴饮暴食，可饮用山楂茶。',
    '腹痛': '建议您注意腹部保暖，避免生冷食物。',
    '腿疼': '建议您适当休息，热敷患处，避免过度运动。',
    '关节痛': '建议您注意保暖，适当补充钙质。',
    '肩痛': '建议您做肩部拉伸运动，避免长时间保持同一姿势。',
    '颈椎痛': '建议您调整坐姿，每小时活动颈部，避免低头过久。',
    '腰痛': '建议您加强腰部肌肉锻炼，避免久坐。',
    '背痛': '建议您改善睡眠姿势，选择合适的枕头和床垫。',
    '手脚冰凉': '建议您多吃温热食物，适当运动促进血液循环。',
    '便秘': '建议您多喝水，多吃蔬菜水果，养成定时排便习惯。',
    '口干': '建议您多喝水，避免辛辣食物，可饮用麦冬茶。',
    '疲劳': '建议您保证充足睡眠，适当运动，均衡饮食。'
  };
  
  const firstSymptom = symptoms[0];
  return adviceMap[firstSymptom] || `根据您的描述"${query}"，建议您注意休息，保持良好作息。如症状持续，请及时就医。`;
}

// 加载用户健康数据
async function loadHealthData() {
  try {
    // 加载最新打卡数据
    const checkinResponse: any = await checkTodayCheckin();
    if (checkinResponse && typeof checkinResponse === 'object') {
      latestCheckin.value = checkinResponse;
    }
  } catch (error) {
    console.error('Failed to load checkin data:', error);
  }
  
  // TODO: 加载最新测评数据 - 需要后端API支持
  // try {
  //   const assessmentResponse: any = await getLatestAssessment();
  //   if (assessmentResponse) {
  //     latestAssessment.value = assessmentResponse;
  //   }
  // } catch (error) {
  //   console.error('Failed to load assessment data:', error);
  // }
}

onMounted(() => {
  loadHealthData();
  startRotation();
});

onUnmounted(() => {
  stopRotation();
});
</script>

<style scoped>
/* 引入字体 */
@import url('https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;700&display=swap');

.font-serif {
  font-family: 'Noto Serif SC', serif;
}

.dark-section {
  position: relative;
  z-index: 10;
  background: #022c22;
  margin: -100px -40px -60px -40px;
  padding: 80px 60px 100px 60px; /* 从120px 60px 160px 60px压缩到80px 60px 100px 60px */
  border-radius: 64px 64px 0 0;
  box-shadow: 0 -30px 80px rgba(0, 0, 0, 0.4);
  overflow: hidden;
  color: white;
}

/* 极光背景 */
.aurora-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
  opacity: 0.6;
}

.aurora-light {
  position: absolute;
  filter: blur(80px);
  border-radius: 50%;
  animation: aurora 20s infinite ease-in-out;
}

.a1 {
  top: -20%;
  left: -10%;
  width: 60%;
  height: 60%;
  background: radial-gradient(circle, rgba(52, 211, 153, 0.2), transparent 70%);
  animation-delay: 0s;
}

.a2 {
  bottom: -20%;
  right: -10%;
  width: 70%;
  height: 60%;
  background: radial-gradient(circle, rgba(6, 182, 212, 0.15), transparent 70%);
  animation-delay: -5s;
}

.a3 {
  top: 40%;
  left: 40%;
  width: 40%;
  height: 40%;
  background: radial-gradient(circle, rgba(251, 191, 36, 0.1), transparent 70%);
  animation-delay: -10s;
}

@keyframes aurora {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(20px, -20px) scale(1.1); }
}

.neural-bg {
  position: absolute;
  inset: 0;
  opacity: 0.3;
  pointer-events: none;
  z-index: 0;
}

.neural-node {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
}

.n1 { width: 400px; height: 400px; background: #10b981; top: -100px; left: -100px; opacity: 0.2; animation: float 10s infinite; }
.n2 { width: 300px; height: 300px; background: #34d399; bottom: 0; right: 0; opacity: 0.15; animation: float 12s infinite reverse; }
.n3 { width: 200px; height: 200px; background: #059669; top: 40%; left: 40%; opacity: 0.1; }

.connection-lines {
  width: 100%;
  height: 100%;
  opacity: 0.3;
}

.dark-content {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 60px; /* 从80px减少到60px */
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
  position: relative;
  z-index: 2;
}

.glass-badge {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.ai-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: 100px;
  font-size: 12px;
  font-weight: 700;
  color: #34d399;
  margin-bottom: 16px;
}

.dot {
  width: 6px;
  height: 6px;
  background: #34d399;
  border-radius: 50%;
  box-shadow: 0 0 8px #34d399;
}

.dark-title {
  font-size: 48px; /* 从56px减小到48px */
  font-weight: 800;
  line-height: 1.2;
  margin: 0;
  color: white;
  letter-spacing: 1px;
}

.gradient-text {
  background: linear-gradient(135deg, #34d399 0%, #a7f3d0 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.dark-description {
  font-size: 16px; /* 从18px减小到16px */
  color: #94a3b8;
  margin: 20px 0 32px 0; /* 从24px 0 40px 0压缩到20px 0 32px 0 */
  max-width: 90%;
  line-height: 1.6;
}

/* Quick Consult Glass Panel */
.glass-panel {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.quick-consult {
  margin: 24px 0; /* 从30px 0减少到24px 0 */
  padding: 20px; /* 从24px减少到20px */
  border-radius: 24px;
}

.input-group {
  display: flex;
  gap: 10px;
}

.input-group input {
  flex: 1;
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 12px 16px;
  color: white;
  font-size: 14px;
  outline: none;
  transition: border-color 0.3s;
}

.input-group input:focus {
  border-color: #34d399;
  background: rgba(0, 0, 0, 0.3);
}

.input-group button {
  background: #10b981;
  color: white;
  border: none;
  border-radius: 12px;
  padding: 0 24px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.input-group button:hover {
  background: #059669;
  transform: translateY(-2px);
}

.input-group button:disabled {
  opacity: 0.7;
  cursor: wait;
  transform: none;
}

.consult-result {
  margin-top: 16px;
  background: rgba(16, 185, 129, 0.1);
  padding: 12px;
  border-radius: 12px;
  display: flex;
  gap: 12px;
  align-items: flex-start;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.ai-avatar {
  width: 24px;
  height: 24px;
  background: #10b981;
  border-radius: 50%;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  flex-shrink: 0;
}

.consult-result p {
  margin: 0;
  font-size: 13px;
  color: #d1fae5;
  line-height: 1.5;
}

.spinner-sm {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s linear infinite;
}

.features-bento {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px; /* 从20px减少到16px */
  margin-bottom: 24px;
}

.glass-card {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.bento-item {
  padding: 20px; /* 从24px减少到20px */
  border-radius: 20px;
  display: flex;
  align-items: flex-start;
  gap: 14px; /* 从16px减少到14px */
  transition: all 0.3s;
  cursor: pointer;
}

.bento-item:hover, .bento-item.active {
  background: rgba(255, 255, 255, 0.08);
  transform: translateY(-4px);
  border-color: rgba(16, 185, 129, 0.4);
  box-shadow: 0 10px 20px -5px rgba(0, 0, 0, 0.2);
}

.bento-item.active .bento-icon {
  background: #10b981;
  color: white;
}

.bento-icon {
  width: 40px;
  height: 40px;
  background: rgba(16, 185, 129, 0.1);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #34d399;
  flex-shrink: 0;
  transition: all 0.3s;
}

.bento-text h4 {
  font-size: 16px;
  font-weight: 700;
  margin: 0 0 4px 0;
  color: white;
}

.bento-text p {
  font-size: 13px;
  color: #94a3b8;
  margin: 0;
}

/* Digital Twin Container */
.digital-twin-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.scan-text {
  margin-top: 20px;
  color: #34d399;
  font-family: monospace;
  font-size: 14px;
  letter-spacing: 2px;
  opacity: 0.8;
}

.scan-dots {
  display: inline-block;
  animation: blink 1.5s infinite;
}

@keyframes blink {
  0%, 100% { opacity: 0.2; }
  50% { opacity: 1; }
}

.dark-footer {
  margin-top: 60px; /* 从80px减少到60px */
  text-align: center;
}

.footer-line {
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  margin-bottom: 32px; /* 从40px减少到32px */
}

.mission-text-cn {
  font-size: 20px; /* 从24px减小到20px */
  font-weight: 700;
  color: white;
  margin-bottom: 6px; /* 从8px减少到6px */
  letter-spacing: 2px;
}

.mission-text-en {
  font-size: 12px;
  color: #64748b;
  letter-spacing: 2px;
  text-transform: uppercase;
}

@media (max-width: 960px) {
  .dark-content {
    grid-template-columns: 1fr;
    gap: 60px;
  }
  .features-bento {
    grid-template-columns: 1fr;
  }
  .dark-right { display: none; }
}

@media (max-width: 768px) {
  .dark-section {
    padding: 40px 20px; /* 从60px 20px压缩到40px 20px */
  }
  .dark-title {
    font-size: 32px; /* 从36px减小到32px */
  }
}
</style>