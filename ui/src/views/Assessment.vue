<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { getAssessmentReport } from '../services/api';

const router = useRouter();

// 定义问题类型，支持多选
interface Question {
  question: string;
  options: string[];
  multiple?: boolean;
}

// 问题数据（按你的问卷）
const questions: Question[] = [
  {
    question: "您的体型如何？",
    options: ["匀称", "偏瘦", "偏胖", "肌肉线条明显"],
  },
  {
    question: "您的睡眠质量如何？",
    options: ["睡得快、起得早，精神好", "偶尔入睡困难或早醒", "经常失眠或睡不醒", "作息紊乱，昼夜颠倒"],
  },
  {
    question: "您的日常精力状态？",
    options: ["白天精神饱满，不易累", "下午容易犯困，需咖啡/茶提神", "经常感到疲惫，睡不够", "一动就累，懒得动"],
  },
  {
    question: "您的排便规律吗？",
    options: ["每天1次，规律顺畅", "偶尔便秘或腹泻", "经常便秘或腹泻", "不规律，很少关注"],
  },
  {
    question: "您的饮食习惯？",
    options: ["三餐规律，少油少糖", "外卖为主，口味偏重", "经常节食或暴饮暴食", "爱吃零食，饮料不断"],
  },
  {
    question: "您每周运动几次？",
    options: ["3次以上，每次30分钟以上", "1-2次，轻度活动", "几乎不运动，能坐不站"],
  },
  {
    question: "您的情绪状态？",
    options: ["情绪稳定，很少焦虑", "偶尔焦虑/烦躁", "经常压力大，易发脾气", "情绪低落，提不起兴趣"],
  },
  {
    question: "您平时是否容易感到以下不适？（可多选）",
    options: ["肩颈僵硬", "久坐后腰酸背痛", "容易手脚冰凉", "经常感到口渴或口干", "以上都没有"],
    multiple: true,
  },
  {
    question: "您的健康目标？",
    options: ["控制体重", "改善睡眠", "增强体力", "调节情绪", "保持轻盈状态"],
  },
  {
    question: "您更希望通过哪种方式开启健康生活？",
    options: ["每日记录挑战", "饮食记录+推荐", "运动跟练计划", "冥想/呼吸练习", "一站式健康方案"],
  },
];

// 状态管理（按题型初始化单选为 -1，多选为 []）
const currentQuestionIndex = ref(0);
const answers = ref<Array<number | number[]>>(questions.map(q => (q.multiple ? [] : -1)));
const showResult = ref(false);
const report = ref<any>(null);
const loading = ref(false);

// 新增：提交成功标记（用于显示“测评已完成”）
const submittedSuccess = ref(false);

// 计算属性
const currentQuestion = computed(() => questions[currentQuestionIndex.value]);
const progress = computed(() => ((currentQuestionIndex.value + 1) / questions.length) * 100);
const canGoNext = computed(() => {
  const a = answers.value[currentQuestionIndex.value];
  return Array.isArray(a) ? a.length > 0 : a !== -1;
});
const isLastQuestion = computed(() => currentQuestionIndex.value === questions.length - 1);


// 上一步
function goToPrevious() {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--;
  }
}

// 下一步
function goToNext() {
  if (canGoNext.value && currentQuestionIndex.value < questions.length - 1) {
    currentQuestionIndex.value++;
  }
}

// 提交测评（多选题按选项展开为多条）
async function submitAssessment() {
  if (!canGoNext.value) return;

  try {
    loading.value = true;

    const validAnswers = answers.value.flatMap((ans, questionIndex) => {
      const q = questions[questionIndex];
      if (!q) return [];
      if (q.multiple) {
        const picked = Array.isArray(ans) ? ans : [];
        return picked
          .filter(idx => q.options[idx])
          .map(idx => ({
            questionIndex,
            answerIndex: idx,
            question: q.question,
            answer: q.options[idx],
          }));
      } else {
        if (typeof ans !== 'number' || ans === -1 || !q.options[ans]) return [];
        return [{
          questionIndex,
          answerIndex: ans,
          question: q.question,
          answer: q.options[ans],
        }];
      }
    });

    // 仅保存，不展示体质报告
    await getAssessmentReport({ answers: validAnswers });
    // 仅显示完成提示，不展示体质分析
    submittedSuccess.value = true;
  } catch (error) {
    console.error('提交测评失败:', error);
    alert('提交测评失败，请重试');
  } finally {
    loading.value = false;
  }
}

// 重新开始测评
function restartAssessment() {
  currentQuestionIndex.value = 0;
  answers.value = questions.map(q => (q.multiple ? [] : -1));
  // 不再使用 showResult/report，仅重置完成标记
  submittedSuccess.value = false;
  report.value = null;
}

// 返回首页
function goHome() {
  router.push('/dashboard');
}

// 新增：完成测评（与返回首页一致）
function finishAssessment() {
  router.push('/dashboard');
}
const NONE_OF_ABOVE_TEXT = '以上都没有';

function getOptionText(opt: any): string {
  return (opt?.text ?? opt?.label ?? String(opt)).trim();
}

// 选项禁用判定（仅第八题互斥）
// 仅第八题互斥禁用（“以上都没有”）
function isDisabled(qIndex: number, optIndex: number): boolean {
  const q = questions[qIndex];
  if (!q) return false;
  if (qIndex !== 7) return false;

  const noneIndex = Array.isArray(q.options) ? q.options.length - 1 : -1;
  const current = answers.value[qIndex];
  const selected = Array.isArray(current) ? (current as number[]) : [];
  const noneSelected = noneIndex >= 0 && selected.includes(noneIndex);

  return noneSelected && optIndex !== noneIndex;
}

// 选中态（统一使用 answers.value）
function isSelected(qIndex: number, optIndex: number): boolean {
  const q = questions[qIndex];
  if (!q) return false;
  const current = answers.value[qIndex];
  if (q.multiple) {
    return Array.isArray(current) && (current as number[]).includes(optIndex);
  }
  return current === optIndex;
}

// 点击选择（更新第八题“以上都没有”为可切换）
function selectOption(qIndex: number, optIndex: number) {
  const q = questions[qIndex];
  if (!q) return;

  if (isDisabled(qIndex, optIndex)) return;

  // 第八题互斥逻辑：再次点击“以上都没有”取消选择
  if (qIndex === 7 && q.multiple) {
    const noneIndex = Array.isArray(q.options) ? q.options.length - 1 : -1;
    const raw = answers.value[qIndex];
    const list = Array.isArray(raw) ? [...(raw as number[])] : [];

    if (optIndex === noneIndex) {
      const hasNone = list.includes(noneIndex);
      // 已选中则取消；未选中则只选它
      answers.value[qIndex] = hasNone ? [] : [noneIndex];
      return;
    } else {
      // 选择其它选项时移除“以上都没有”并进行普通多选
      const filtered = noneIndex >= 0 ? list.filter(v => v !== noneIndex) : list;
      const idx = filtered.indexOf(optIndex);
      if (idx >= 0) filtered.splice(idx, 1);
      else filtered.push(optIndex);
      answers.value[qIndex] = filtered;
      return;
    }
  }

  if (q.multiple) {
    const raw = answers.value[qIndex];
    const list = Array.isArray(raw) ? [...(raw as number[])] : [];
    const idx = list.indexOf(optIndex);
    if (idx >= 0) list.splice(idx, 1);
    else list.push(optIndex);
    answers.value[qIndex] = list;
  } else {
    answers.value[qIndex] = optIndex;
  }
}
</script>

<template>
  <div class="assessment-container">
    <!-- 返回首页 -->
    <button @click="goHome" class="back-btn back-top-left">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>

    <!-- 保留完成提示视图 -->
    <div v-if="submittedSuccess" class="complete-container">
      <div class="complete-card">
        <div class="complete-icon">✅</div>
        <h2 class="complete-title">测评已完成</h2>
        <p class="complete-desc">已保存本次测评，点击下方按钮继续使用应用。</p>
        <button class="finish-btn" @click="finishAssessment">完成测评</button>
      </div>
    </div>

    <!-- 删除体质结果/分析视图；保留问卷 -->
    <!-- 问卷页面 -->
    <div v-else class="questionnaire-container">
      <!-- 问题内容 -->
      <div class="question-container">
        <!-- 标题和进度 -->
        <div class="header">
          <div class="progress-info">{{ currentQuestionIndex + 1 }} / {{ questions.length }}</div>
        </div>

        <!-- 进度条 -->
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: progress + '%' }"></div>
        </div>

        <!-- 当前问题 -->
        <div class="question-content" v-if="currentQuestion">
          <h3 class="question-title">{{ currentQuestion.question }}</h3>
          <p class="question-subtitle">
            {{ currentQuestion.multiple ? '可多选' : '请选择最符合您目前状态的选项' }}
          </p>

          <!-- 选项列表 -->
          <div class="options-list">
            <div
              v-for="(option, index) in currentQuestion.options"
              :key="index"
              class="option-item"
              :class="{ active: isSelected(currentQuestionIndex, index) }"
              @click="selectOption(currentQuestionIndex, index)"
            >
              {{ option }}
            </div>
          </div>
        </div>

        <!-- 导航按钮 -->
        <div class="navigation">
          <button
            v-if="currentQuestionIndex > 0"
            @click="goToPrevious"
            class="nav-btn prev-btn"
          >
            上一步
          </button>

          <button
            v-if="!isLastQuestion"
            @click="goToNext"
            :disabled="!canGoNext"
            class="nav-btn next-btn"
            :class="{ disabled: !canGoNext }"
          >
            下一步
          </button>

          <button
            v-if="isLastQuestion"
            @click="submitAssessment"
            :disabled="!canGoNext || loading"
            class="nav-btn submit-btn"
            :class="{ disabled: !canGoNext || loading }"
          >
            {{ loading ? '提交中...' : '完成测评' }}
          </button>
        </div>
      </div>
    <!-- 温馨提示（放在题目与按钮之间） -->
    <div class="notice-tip">
      <span class="tip-icon">💡</span>
      <div class="tip-content">
        <span class="tip-title">温馨提示：</span>
        本问卷仅用于健康评估，建议结果仅供参考，不能替代医生诊断。如有严重不适，请及时就医。
      </div>
    </div>

    <!-- 导航和提交按钮 -->
    <div class="navigation">
      <!-- ... existing code ... -->
      </div>
      </div>
    </div>
</template>

<style scoped>
.assessment-container {
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
  min-height: 100vh;
  padding: 80px 20px 20px 20px;
  position: relative;
}

.assessment-container > *:not(.back-top-left) {
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

/* 左上角返回按钮 */
.back-top-left {
  position: fixed;
  top: 10px;
  left: 20px;
  z-index: 9999;
  margin: 0 !important;
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

/* 问卷容器 */
.questionnaire-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* 头部 */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.header h2 {
  margin: 0;
  color: #2c3e50;
  font-size: 24px;
}

.progress-info {
  color: #6c757d;
  font-size: 16px;
  font-weight: 500;
}

/* 进度条 */
.progress-bar {
  height: 4px;
  background: #e9ecef;
  position: relative;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #ff6b6b, #ee5a52);
  transition: width 0.3s ease;
}

/* 问题内容 */
.question-content {
  padding: 40px 30px;
}

.question-title {
  font-size: 20px;
  color: #2c3e50;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.question-subtitle {
  color: #6c757d;
  margin: 0 0 30px 0;
  font-size: 14px;
}

/* 选项列表 */
.options-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.option-item {
  padding: 16px 20px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: white;
  font-size: 16px;
  color: #495057;
}

.option-item:hover {
  border-color: #ff6b6b;
  background: #fff5f5;
}

.option-item.active {
  border-color: #ff6b6b;
  background: #ff6b6b;
  color: white;
}

/* 导航按钮 */
.navigation {
  display: flex;
  justify-content: space-between;
  padding: 30px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.nav-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.prev-btn {
  background: #6c757d;
  color: white;
}

.prev-btn:hover {
  background: #5a6268;
}

.next-btn, .submit-btn {
  background: #ff6b6b;
  color: white;
}

.next-btn:hover, .submit-btn:hover {
  background: #ee5a52;
}

.nav-btn.disabled {
  background: #e9ecef;
  color: #6c757d;
  cursor: not-allowed;
}

/* 提示信息（温馨提示样式） */
.notice-tip {
  margin-top: 16px;
  padding: 12px 14px;
  background: #fff9e6;              /* 柔和浅黄 */
  border: 1px solid #ffe58f;         /* 边框淡黄 */
  border-left: 4px solid #faad14;    /* 左侧强调条 */
  border-radius: 10px;
  color: #6b5f3b;
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.tip-icon {
  font-size: 18px;
  line-height: 1;
  margin-top: 2px;
}

.tip-content {
  flex: 1;
  font-size: 14px;
}

.tip-title {
  font-weight: 600;
  margin-right: 4px;
}

@media (max-width: 576px) {
  .notice-tip {
    padding: 10px 12px;
  }
  .tip-content {
    font-size: 13px;
  }
}

/* 结果页面 */
.result-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.result-header h2 {
  margin: 0;
  color: #2c3e50;
}

.result-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-bottom: 20px;
}

/* 新增：完成测评按钮样式 */
.finish-btn {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  border: none;
  padding: 10px 22px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s ease, transform 0.1s ease;
  font-size: 14px;
  font-weight: 600;
}
.finish-btn:hover {
  background: linear-gradient(135deg, #3e8af3 0%, #00d7e6 100%);
  transform: translateY(-1px);
}
.restart-btn, .home-btn {
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s ease;
  font-size: 14px;
}

.restart-btn {
  background: #6c757d;
  color: white;
}

.restart-btn:hover {
  background: #5a6268;
}

.home-btn {
  background: #007bff;
  color: white;
}

.home-btn:hover {
  background: #0056b3;
}

.result-content {
  padding: 30px;
}

.constitution-type h3 {
  color: #ff6b6b;
  font-size: 24px;
  margin: 0 0 20px 0;
}

.summary h4 {
  color: #2c3e50;
  margin: 0 0 10px 0;
}

.summary p {
  color: #495057;
  line-height: 1.6;
  margin: 0;
}

.loading {
  text-align: center;
  color: #6c757d;
  font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .assessment-container {
    padding: 80px 10px 10px 10px; /* 保持顶部padding给按钮留空间 */
  }

  .question-content {
    padding: 20px 15px;
  }

  .navigation {
    padding: 20px 15px;
  }

  .header {
    padding: 15px 20px;
  }

  .result-content {
    padding: 20px 15px;
  }
}
button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  pointer-events: none;
}
/* 完成提示样式 */
.complete-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
}
.complete-card {
  max-width: 720px;
  width: 100%;
  background: #fff;
  border-radius: 16px;
  padding: 40px 32px;
  box-shadow: 0 12px 32px rgba(0,0,0,0.08);
  text-align: center;
}
.complete-icon { font-size: 40px; margin-bottom: 10px; }
.complete-title { margin: 0 0 8px; font-size: 24px; color: #2c3e50; }
.complete-desc { margin: 0 0 22px; color: #6c757d; font-size: 15px; }

/* 完成测评按钮 */
.finish-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  background: linear-gradient(90deg, #4dabf7, #3b82f6);
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: transform .06s ease, box-shadow .2s ease;
  box-shadow: 0 6px 20px rgba(59,130,246,.3);
}
.finish-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 26px rgba(59,130,246,.35);
}

.finish-btn:active {
  transform: translateY(0);
}
</style>
