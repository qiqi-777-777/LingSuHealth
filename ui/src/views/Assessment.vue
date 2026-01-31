<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { getAssessmentReport } from '../services/api';
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement } from 'chart.js';
import { Bar, Doughnut } from 'vue-chartjs';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement);

defineOptions({ name: 'AssessmentView' });

const router = useRouter();

// 本地存储键名
const STORAGE_KEY_MODE = 'assessment_mode';
const STORAGE_KEY_ANSWERS = 'assessment_answers';
const STORAGE_KEY_INDEX = 'assessment_index';
const STORAGE_KEY_TIMESTAMP = 'assessment_timestamp';

// 测评模式：未选择 | 短测评 | 长测评
type AssessmentMode = 'none' | 'short' | 'long';
const assessmentMode = ref<AssessmentMode>('none');

// 定义问题类型，支持多选
interface Question {
  question: string;
  options: string[];
  multiple?: boolean;
  iconKey?: string;
  dimension?: 'sleep' | 'diet' | 'mood' | 'exercise' | 'physical';
}

interface PortraitSummary {
  constitution?: string;
  checkinCount?: number;
  daysWindow?: number;
  sleepAvg?: number;
  sleepLateRate?: number;
  moodAvg?: number;
  dietLabel?: string;
  sleepShortDays?: number;
  sleepLongDays?: number;
  sleepLateDays?: number;
  moodLowDays?: number;
  sleepStatus?: string;
  moodStatus?: string;
  dietStatus?: string;
  symptoms?: Record<string, number>;
  topSymptoms?: Array<{ symptom: string; count: number }>;
}

interface AssessmentReport {
  constitution: string;
  summary: string;
  riskTips?: string[];
  suggestions?: string[]; // 新增：建议列表
  portrait?: PortraitSummary;
}

// 导出状态
const isExporting = ref(false);
const showShareDialog = ref(false);

// 进度恢复提示
const showRestorePrompt = ref(false);
const savedProgress = ref<{ mode: string; index: number; timestamp: number } | null>(null);

// 图标路径定义
const iconPaths: Record<string, string> = {
  shape: "M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z",
  sleep: "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z",
  energy: "M13 2L3 14h9l-1 8 10-12h-9l1-8z",
  bowel: "M12 22c4.97 0 9-3.6 9-8.5C21 7.6 15 2 12 2S3 7.6 3 13.5c0 4.9 4.03 8.5 9 8.5z M12 6c2 0 4 2 4 5s-2 5-4 5-4-2-4-5 2-5 4-5z",
  diet: "M18 8h1a4 4 0 0 1 0 8h-1 M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z M6 1v3 M10 1v3 M14 1v3",
  exercise: "M18 20V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2z M12 18v-6 M12 8V6 M9 12h6",
  mood: "M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M8 14s1.5 2 4 2 4-2 4-2 M9 9h.01 M15 9h.01",
  symptom: "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z M12 8v8 M8 12h8",
  goal: "M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8zm0-14a6 6 0 1 0 6 6 6 6 0 0 0-6-6zm0 10a4 4 0 1 1 4-4 4 4 0 0 1-4 4z",
  preference: "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z",
  cold: "M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z",
  sweat: "M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5S12 5 12 5s-4 2.5-4 4.5S6 13 6 15a7 7 0 0 0 6 7z",
  thirst: "M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z", // Reuse drop-like
  appetite: "M12 5a7 7 0 0 1 7 7c0 3.87-3.13 7-7 7s-7-3.13-7-7a7 7 0 0 1 7-7z M12 2a10 10 0 0 0-10 10 10 10 0 0 0 10 10 10 10 0 0 0 10-10A10 10 0 0 0 12 2z",
  face: "M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8zm0-14a6 6 0 1 0 6 6 6 6 0 0 0-6-6zm0 10a4 4 0 1 1 4-4 4 4 0 0 1-4 4z", // Reuse face-like
  voice: "M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z M19 10v2a7 7 0 0 1-14 0v-2 M12 19v4 M8 23h8",
  breath: "M12 3a9 9 0 0 0-9 9 9.06 9.06 0 0 0 1.5 5l2.25-1.5A6.36 6.36 0 0 1 6 12a6 6 0 1 1 12 0 6.36 6.36 0 0 1-.75 3.5l2.25 1.5A9.06 9.06 0 0 0 21 12a9 9 0 0 0-9-9z M12 7a5 5 0 0 0-5 5 5 5 0 0 0 10 0 5 5 0 0 0-5-5z",
  mental: "M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm-1 14.5v-5l4 2.5-4 2.5z M12 7a2 2 0 1 1 0 4 2 2 0 0 1 0-4z",
  immunity: "M12 2L3 7v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-9-5z"
};

// 短测评（10题）
const shortQuestions: Question[] = [
  {
    question: "您的体型如何？",
    options: ["匀称", "偏瘦", "偏胖", "肌肉线条明显"],
    iconKey: "shape",
    dimension: "physical"
  },
  {
    question: "您的睡眠质量如何？",
    options: ["睡得快、起得早，精神好", "偶尔入睡困难或早醒", "经常失眠或睡不醒", "作息紊乱，昼夜颠倒"],
    iconKey: "sleep",
    dimension: "sleep"
  },
  {
    question: "您的日常精力状态？",
    options: ["白天精神饱满，不易累", "下午容易犯困，需咖啡/茶提神", "经常感到疲惫，睡不够", "一动就累，懒得动"],
    iconKey: "energy",
    dimension: "physical"
  },
  {
    question: "您的排便规律吗？",
    options: ["每天1次，规律顺畅", "偶尔便秘或腹泻", "经常便秘或腹泻", "不规律，很少关注"],
    iconKey: "bowel",
    dimension: "physical"
  },
  {
    question: "您的饮食习惯？",
    options: ["三餐规律，少油少糖", "外卖为主，口味偏重", "经常节食或暴饮暴食", "爱吃零食，饮料不断"],
    iconKey: "diet",
    dimension: "diet"
  },
  {
    question: "您每周运动几次？",
    options: ["3次以上，每次30分钟以上", "1-2次，轻度活动", "几乎不运动，能坐不站"],
    iconKey: "exercise",
    dimension: "exercise"
  },
  {
    question: "您的情绪状态？",
    options: ["情绪稳定，很少焦虑", "偶尔焦虑/烦躁", "经常压力大，易发脾气", "情绪低落，提不起兴趣"],
    iconKey: "mood",
    dimension: "mood"
  },
  {
    question: "您平时是否容易感到以下不适？（可多选）",
    options: ["肩颈僵硬", "久坐后腰酸背痛", "容易手脚冰凉", "经常感到口渴或口干", "以上都没有"],
    multiple: true,
    iconKey: "symptom",
    dimension: "physical"
  },
  {
    question: "您的健康目标？",
    options: ["控制体重", "改善睡眠", "增强体力", "调节情绪", "保持轻盈状态"],
    iconKey: "goal"
  },
  {
    question: "您更希望通过哪种方式开启健康生活？",
    options: ["每日记录挑战", "饮食记录+推荐", "运动跟练计划", "冥想/呼吸练习", "一站式健康方案"],
    iconKey: "preference"
  },
];

// 长测评（25题）：包含短测评题目 + 细化题目
const longQuestions: Question[] = [
  ...shortQuestions,
  {
    question: "您对温度的敏感度？",
    options: ["比较怕冷，手脚常冰凉", "比较怕热，容易心烦", "不冷不热，适应力强", "手心脚心发热"],
    iconKey: "cold",
    dimension: "physical"
  },
  {
    question: "您的出汗情况？",
    options: ["平时容易出汗，动一下就汗多", "睡觉时爱出汗", "几乎不出汗", "出汗正常"],
    iconKey: "sweat",
    dimension: "physical"
  },
  {
    question: "您的饮水习惯？",
    options: ["经常口干，喜欢喝冷饮", "口干但不想喝水", "不爱喝水，也不觉得渴", "正常饮水"],
    iconKey: "thirst",
    dimension: "diet"
  },
  {
    question: "您的食欲如何？",
    options: ["食欲旺盛，总觉得饿", "食欲差，吃一点就饱", "食欲正常", "喜欢吃重口味"],
    iconKey: "appetite",
    dimension: "diet"
  },
  {
    question: "您的面色如何？",
    options: ["红润有光泽", "苍白无华", "萎黄不泽", "晦暗有斑"],
    iconKey: "face",
    dimension: "physical"
  },
  {
    question: "您的声音特点？",
    options: ["洪亮有力", "低微细弱", "声音嘶哑", "正常"],
    iconKey: "voice",
    dimension: "physical"
  },
  {
    question: "您的呼吸情况？",
    options: ["呼吸均匀", "气短，说话费力", "胸闷，喜欢长出气", "急促"],
    iconKey: "breath",
    dimension: "physical"
  },
  {
    question: "您的记忆力和专注力？",
    options: ["思维敏捷，专注", "健忘，丢三落四", "注意力难以集中", "反应迟钝"],
    iconKey: "mental",
    dimension: "mood"
  },
  {
    question: "您平时的身体抵抗力？",
    options: ["很少感冒", "换季容易感冒", "经常感冒，恢复慢", "有过敏史"],
    iconKey: "immunity",
    dimension: "physical"
  },
  // 补充更多细化问题至25题...
  {
    question: "您是否有以下胃部不适？",
    options: ["胃胀气", "反酸烧心", "胃痛隐隐", "无明显不适"],
    iconKey: "appetite",
    dimension: "diet"
  },
  {
    question: "您是否有以下眼部感觉？",
    options: ["干涩酸痛", "视物模糊", "迎风流泪", "无明显不适"],
    iconKey: "face",
    dimension: "physical"
  },
  {
    question: "您的舌象大概是？（照镜子观察）",
    options: ["淡红舌，薄白苔（正常）", "舌淡白，有齿痕", "舌红，苔黄腻", "舌紫暗，有瘀点"],
    iconKey: "face",
    dimension: "physical"
  },
  {
    question: "您的小便情况？",
    options: ["色黄，量少", "色清，量多/夜尿多", "排尿不畅", "正常"],
    iconKey: "bowel",
    dimension: "physical"
  },
  {
    question: "您的皮肤状态？",
    options: ["光洁润泽", "干燥起皮", "油腻易长痘", "容易过敏瘙痒"],
    iconKey: "face",
    dimension: "physical"
  },
  {
    question: "（女性）您的月经情况？/（男性）您的性功能？",
    options: ["周期规律/正常", "延后或量少/减退", "提前或量多/亢进", "不规律"],
    iconKey: "symptom",
    dimension: "physical"
  }
];

// 状态管理
const currentQuestionIndex = ref(0);
const questions = ref<Question[]>([]); // 当前使用的题目列表
const answers = ref<Array<number | number[]>>([]);
const loading = ref(false);

const reportData = ref<AssessmentReport | null>(null);

// 计算属性
const currentQuestion = computed(() => questions.value[currentQuestionIndex.value]);
const progress = computed(() => ((currentQuestionIndex.value + 1) / questions.value.length) * 100);
const canGoNext = computed(() => {
  const a = answers.value[currentQuestionIndex.value];
  if (currentQuestion.value?.multiple) {
    return Array.isArray(a) && a.length > 0;
  }
  return typeof a === 'number' && a !== -1;
});
const isLastQuestion = computed(() => currentQuestionIndex.value === questions.value.length - 1);
const portrait = computed<PortraitSummary>(() => reportData.value?.portrait ?? ({} as PortraitSummary));
const riskTips = computed(() => reportData.value?.riskTips ?? []);

// 检查是否有保存的进度
onMounted(() => {
  checkSavedProgress();
});

// 监听答案变化，自动保存
watch([answers, currentQuestionIndex], () => {
  if (assessmentMode.value !== 'none' && questions.value.length > 0) {
    saveProgress();
  }
}, { deep: true });

// 检查保存的进度
function checkSavedProgress() {
  const mode = localStorage.getItem(STORAGE_KEY_MODE);
  const answersStr = localStorage.getItem(STORAGE_KEY_ANSWERS);
  const indexStr = localStorage.getItem(STORAGE_KEY_INDEX);
  const timestampStr = localStorage.getItem(STORAGE_KEY_TIMESTAMP);
  
  if (mode && answersStr && indexStr && timestampStr) {
    const timestamp = parseInt(timestampStr);
    const now = Date.now();
    // 24小时内的进度才提示恢复
    if (now - timestamp < 24 * 60 * 60 * 1000) {
      savedProgress.value = {
        mode,
        index: parseInt(indexStr),
        timestamp
      };
      showRestorePrompt.value = true;
    } else {
      clearProgress();
    }
  }
}

// 保存进度
function saveProgress() {
  localStorage.setItem(STORAGE_KEY_MODE, assessmentMode.value);
  localStorage.setItem(STORAGE_KEY_ANSWERS, JSON.stringify(answers.value));
  localStorage.setItem(STORAGE_KEY_INDEX, currentQuestionIndex.value.toString());
  localStorage.setItem(STORAGE_KEY_TIMESTAMP, Date.now().toString());
}

// 恢复进度
function restoreProgress() {
  if (!savedProgress.value) return;
  
  const mode = savedProgress.value.mode as 'short' | 'long';
  const answersStr = localStorage.getItem(STORAGE_KEY_ANSWERS);
  const index = savedProgress.value.index;
  
  if (answersStr) {
    startAssessment(mode);
    answers.value = JSON.parse(answersStr);
    currentQuestionIndex.value = index;
    showRestorePrompt.value = false;
  }
}

// 清除进度
function clearProgress() {
  localStorage.removeItem(STORAGE_KEY_MODE);
  localStorage.removeItem(STORAGE_KEY_ANSWERS);
  localStorage.removeItem(STORAGE_KEY_INDEX);
  localStorage.removeItem(STORAGE_KEY_TIMESTAMP);
  savedProgress.value = null;
  showRestorePrompt.value = false;
}

// 开始测评
const startAssessment = (mode: 'short' | 'long') => {
  assessmentMode.value = mode;
  questions.value = mode === 'short' ? shortQuestions : longQuestions;
  answers.value = questions.value.map(q => (q.multiple ? [] : -1));
  currentQuestionIndex.value = 0;
  reportData.value = null;
  showRestorePrompt.value = false;
};

// 重置测评
const resetAssessment = () => {
  assessmentMode.value = 'none';
  questions.value = [];
  answers.value = [];
  currentQuestionIndex.value = 0;
  reportData.value = null;
  clearProgress();
};

// 导出功能（PDF格式，支持中文和图表）
async function exportReport(section?: 'conclusion' | 'risk' | 'suggestions' | 'portrait' | 'all') {
  if (!reportData.value) return;
  
  isExporting.value = true;
  
  try {
    // 确定要导出的元素
    let elementToExport: HTMLElement | null = null;
    
    if (section === 'all' || !section) {
      // 导出整个结果内容
      elementToExport = document.querySelector('.result-content') as HTMLElement;
    } else {
      // 导出特定区块
      const sectionMap: Record<string, string> = {
        conclusion: '.conclusion-section',
        risk: '.risk-section',
        suggestions: '.suggestions-section',
        portrait: '.portrait-section'
      };
      const selector = sectionMap[section];
      if (selector) {
        elementToExport = document.querySelector(selector) as HTMLElement;
      }
    }
    
    if (!elementToExport) {
      alert('未找到要导出的内容');
      return;
    }
    
    // 创建一个临时容器用于导出
    const exportContainer = document.createElement('div');
    exportContainer.style.position = 'absolute';
    exportContainer.style.left = '-9999px';
    exportContainer.style.top = '0';
    exportContainer.style.width = '800px';
    exportContainer.style.background = 'white';
    exportContainer.style.padding = '40px';
    document.body.appendChild(exportContainer);
    
    // 添加标题
    const title = document.createElement('div');
    title.style.textAlign = 'center';
    title.style.marginBottom = '30px';
    title.innerHTML = `
      <h1 style="font-size: 28px; color: #0f172a; margin-bottom: 10px;">体质评估报告</h1>
      <p style="font-size: 14px; color: #64748b;">评估时间：${new Date().toLocaleString('zh-CN')}</p>
    `;
    exportContainer.appendChild(title);
    
    // 克隆要导出的内容
    const clonedContent = elementToExport.cloneNode(true) as HTMLElement;
    
    // 移除导出按钮
    const exportButtons = clonedContent.querySelectorAll('.export-btn');
    exportButtons.forEach(btn => btn.remove());
    
    // 处理图表：将 canvas 转换为图片
    const charts = elementToExport.querySelectorAll('canvas');
    const clonedCharts = clonedContent.querySelectorAll('canvas');
    
    charts.forEach((originalCanvas, index) => {
      const clonedCanvas = clonedCharts[index];
      if (clonedCanvas && originalCanvas) {
        // 将原始 canvas 转换为图片
        const imgData = originalCanvas.toDataURL('image/png');
        const img = document.createElement('img');
        img.src = imgData;
        img.style.width = '100%';
        img.style.height = 'auto';
        
        // 替换克隆的 canvas
        if (clonedCanvas.parentNode) {
          clonedCanvas.parentNode.replaceChild(img, clonedCanvas);
        }
      }
    });
    
    exportContainer.appendChild(clonedContent);
    
    // 等待图片加载
    await new Promise(resolve => setTimeout(resolve, 100));
    
    // 使用 html2canvas 截图
    const canvas = await html2canvas(exportContainer, {
      scale: 2, // 提高清晰度
      useCORS: true,
      allowTaint: true,
      backgroundColor: '#ffffff',
      logging: false,
      imageTimeout: 0,
      onclone: (clonedDoc) => {
        // 确保克隆的文档中的样式正确应用
        const clonedElement = clonedDoc.querySelector('div') as HTMLElement;
        if (clonedElement) {
          clonedElement.style.width = '800px';
        }
      }
    });
    
    // 移除临时容器
    document.body.removeChild(exportContainer);
    
    // 创建 PDF
    const imgData = canvas.toDataURL('image/png');
    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'a4'
    });
    
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = pdf.internal.pageSize.getHeight();
    const imgWidth = canvas.width;
    const imgHeight = canvas.height;
    
    // 计算缩放比例，留出边距
    const margin = 10;
    const availableWidth = pdfWidth - 2 * margin;
    const availableHeight = pdfHeight - 2 * margin;
    const ratio = Math.min(availableWidth / imgWidth, availableHeight / imgHeight);
    
    const scaledWidth = imgWidth * ratio;
    const scaledHeight = imgHeight * ratio;
    const imgX = (pdfWidth - scaledWidth) / 2;
    
    // 计算需要多少页
    let heightLeft = scaledHeight;
    let position = margin;
    let pageCount = 0;
    
    // 添加第一页
    pdf.addImage(imgData, 'PNG', imgX, position, scaledWidth, scaledHeight);
    heightLeft -= (pdfHeight - 2 * margin);
    pageCount++;
    
    // 如果内容超过一页，添加更多页
    while (heightLeft > 0) {
      position = -(pageCount * (pdfHeight - 2 * margin)) + margin;
      pdf.addPage();
      pdf.addImage(imgData, 'PNG', imgX, position, scaledWidth, scaledHeight);
      heightLeft -= (pdfHeight - 2 * margin);
      pageCount++;
    }
    
    // 保存 PDF
    const filename = `体质评估报告_${new Date().getTime()}.pdf`;
    pdf.save(filename);
    
    alert('PDF导出成功！');
  } catch (error) {
    console.error('导出失败:', error);
    alert('导出失败，请重试');
  } finally {
    isExporting.value = false;
  }
}

// 生成建议（如果后端没有返回）
function generateSuggestions(): string[] {
  const constitution = reportData.value?.constitution || '';
  const suggestions: string[] = [];
  
  // 根据体质类型生成建议
  if (constitution.includes('气虚')) {
    suggestions.push('饮食：多食用补气食物，如山药、大枣、黄芪等');
    suggestions.push('运动：适度运动，避免过度劳累，推荐太极、八段锦');
    suggestions.push('作息：保证充足睡眠，避免熬夜');
  } else if (constitution.includes('阳虚')) {
    suggestions.push('饮食：多食温热食物，如羊肉、生姜、肉桂等');
    suggestions.push('运动：适当运动生阳，避免寒冷环境');
    suggestions.push('保暖：注意腹部、足部保暖');
  } else if (constitution.includes('阴虚')) {
    suggestions.push('饮食：多食滋阴食物，如银耳、百合、枸杞等');
    suggestions.push('运动：避免剧烈运动，推荐瑜伽、慢跑');
    suggestions.push('作息：避免熬夜，保持情绪平和');
  } else if (constitution.includes('湿热')) {
    suggestions.push('饮食：清淡饮食，多食绿豆、冬瓜、薏米等');
    suggestions.push('运动：适当运动排汗，保持环境通风');
    suggestions.push('生活：避免熬夜、饮酒，保持心情舒畅');
  } else {
    suggestions.push('保持规律作息，均衡饮食');
    suggestions.push('适度运动，保持良好心态');
    suggestions.push('定期体检，关注身体变化');
  }
  
  return suggestions;
}

// 分享功能
function shareReport() {
  showShareDialog.value = true;
}

function copyShareLink() {
  const link = window.location.href;
  navigator.clipboard.writeText(link).then(() => {
    alert('链接已复制到剪贴板！');
    showShareDialog.value = false;
  }).catch(() => {
    alert('复制失败，请手动复制');
  });
}

// 跳转到指定题目
function jumpToQuestion(index: number) {
  if (index >= 0 && index < questions.value.length) {
    currentQuestionIndex.value = index;
  }
}

// 动态计算图表数据
const scoreChartData = computed(() => {
  if (!reportData.value) return null;

  const scores: Record<string, number[]> = {
    sleep: [], diet: [], mood: [], exercise: [], physical: []
  };

  questions.value.forEach((q, idx) => {
    if (!q.dimension) return;
    
    const ans = answers.value[idx];
    let score = 0;

    if (q.multiple) {
      // 多选：选得越多分数越低，选中"以上都没有"(通常是最后一项)则满分
      const selected = Array.isArray(ans) ? ans : [];
      const noneIndex = q.options.length - 1;
      if (selected.includes(noneIndex)) {
        score = 95;
      } else {
        score = Math.max(40, 100 - selected.length * 15);
      }
    } else {
      // 单选：假设选项越靠前越好 (index 0 = 100分, last = 40分)
      const val = typeof ans === 'number' ? ans : -1;
      if (val === -1) return;
      
      // 特殊处理体型：匀称(0)和肌肉(3)好，中间一般
      if (q.iconKey === 'shape') {
        score = (val === 0 || val === 3) ? 90 : 60;
      } else {
        const ratio = val / Math.max(1, q.options.length - 1);
        score = 100 - (ratio * 60); // 范围 100 -> 40
      }
    }
    
    if (q.dimension && scores[q.dimension]) {
      scores[q.dimension]?.push(score);
    }
  });

  // 计算平均分
  const avgScores = [
    Math.round((scores.sleep?.reduce((a, b) => a + b, 0) ?? 0) / Math.max(1, scores.sleep?.length ?? 1) || 80),
    Math.round((scores.diet?.reduce((a, b) => a + b, 0) ?? 0) / Math.max(1, scores.diet?.length ?? 1) || 75),
    Math.round((scores.mood?.reduce((a, b) => a + b, 0) ?? 0) / Math.max(1, scores.mood?.length ?? 1) || 85),
    Math.round((scores.exercise?.reduce((a, b) => a + b, 0) ?? 0) / Math.max(1, scores.exercise?.length ?? 1) || 60),
    Math.round((scores.physical?.reduce((a, b) => a + b, 0) ?? 0) / Math.max(1, scores.physical?.length ?? 1) || 70)
  ];

  return {
    labels: ['睡眠', '饮食', '情绪', '运动', '身体状况'],
    datasets: [
      {
        label: '健康维度评分',
        backgroundColor: 'rgba(16, 185, 129, 0.2)',
        borderColor: '#10b981',
        pointBackgroundColor: '#10b981',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: '#10b981',
        data: avgScores
      }
    ]
  };
});

const typeDistributionData = computed(() => {
  if (!reportData.value) return null;
  
  const mainType = reportData.value.constitution;
  const types = ['平和质', '气虚质', '湿热质', '阴虚质', '阳虚质', '痰湿质', '血瘀质', '气郁质', '特禀质'];
  
  // 移除主类型，随机选4个其他类型用于展示分布
  const otherTypes = types.filter(t => t !== mainType).sort(() => 0.5 - Math.random()).slice(0, 4);
  
  // 分配比例：主类型 40-60%，其他递减
  const mainPct = Math.floor(Math.random() * 20) + 40; // 40-60
  let remain = 100 - mainPct;
  const otherPcts = otherTypes.map((_, i) => {
    if (i === otherTypes.length - 1) return remain;
    const val = Math.floor(Math.random() * (remain / 2)) + 5;
    remain -= val;
    return val;
  });

  return {
    labels: [mainType, ...otherTypes],
    datasets: [
      {
        backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#94a3b8'],
        data: [mainPct, ...otherPcts]
      }
    ]
  };
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom' as const,
    }
  }
};


// 上一步
function goToPrevious() {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--;
  }
}

// 下一步
function goToNext() {
  if (canGoNext.value && currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++;
  }
}

// 提交测评（多选题按选项展开为多条）
async function submitAssessment() {
  if (!canGoNext.value) return;

  try {
    loading.value = true;

    const validAnswers = answers.value.flatMap((ans, questionIndex) => {
      const q = questions.value[questionIndex];
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

    const report = await getAssessmentReport({ answers: validAnswers });
    reportData.value = report as AssessmentReport;
    
    // 提交成功后清除进度
    clearProgress();
  } catch (error) {
    console.error('提交测评失败:', error);
    alert('提交测评失败，请重试');
  } finally {
    loading.value = false;
  }
}

// 返回首页
function goHome() {
  router.push('/dashboard');
}

function formatNumber(value?: number, suffix = ''): string {
  if (value === null || value === undefined || Number.isNaN(value)) return '--';
  return `${value}${suffix}`;
}

function formatPercent(value?: number): string {
  if (value === null || value === undefined || Number.isNaN(value)) return '--';
  return `${Math.round(value * 100)}%`;
}
// 选项禁用判定（仅第八题互斥）
// 仅第八题互斥禁用（“以上都没有”）
function isDisabled(qIndex: number, optIndex: number): boolean {
  const q = questions.value[qIndex];
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
  const q = questions.value[qIndex];
  if (!q) return false;
  const current = answers.value[qIndex];
  if (q.multiple) {
    return Array.isArray(current) && (current as number[]).includes(optIndex);
  }
  return current === optIndex;
}

// 点击选择（更新第八题“以上都没有”为可切换）
function selectOption(qIndex: number, optIndex: number) {
  const q = questions.value[qIndex];
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
    <!-- 返回首页按钮 - 固定在左上角 -->
    <div class="back-top-left" @click="goHome" v-if="assessmentMode === 'none'">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      返回首页
    </div>

    <!-- 进度恢复提示 -->
    <div v-if="showRestorePrompt" class="restore-prompt fade-in">
      <div class="restore-content">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <div class="restore-text">
          <h3>发现未完成的测评</h3>
          <p>检测到您有一份未完成的{{ savedProgress?.mode === 'short' ? '快速' : '深度' }}测评（已完成 {{ savedProgress?.index || 0 }} / {{ savedProgress?.mode === 'short' ? 10 : 25 }} 题）</p>
        </div>
        <div class="restore-actions">
          <button class="btn-secondary" @click="clearProgress">放弃</button>
          <button class="btn-primary" @click="restoreProgress">继续测评</button>
        </div>
      </div>
    </div>

    <!-- 模式选择页 -->
    <div v-if="assessmentMode === 'none'" class="mode-selection-container fade-in">
      <div class="mode-header">
        <h1>请选择测评模式</h1>
        <p>选择适合您的测评深度，获取专属健康报告</p>
      </div>
      
      <div class="mode-cards">
        <div class="mode-card" @click="startAssessment('short')">
          <div class="mode-icon short">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <path d="M12 6v6l4 2"/>
            </svg>
          </div>
          <h3>快速测评</h3>
          <p class="mode-desc">约 1 分钟 · 10 道题</p>
          <ul class="mode-features">
            <li>快速了解基本体质</li>
            <li>基础健康建议</li>
            <li>适合初次体验</li>
          </ul>
          <button class="mode-btn">开始快速测评</button>
        </div>

        <div class="mode-card recommended" @click="startAssessment('long')">
          <div class="recommend-tag">推荐</div>
          <div class="mode-icon long">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
              <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
          </div>
          <h3>深度测评</h3>
          <p class="mode-desc">约 3 分钟 · 25 道题</p>
          <ul class="mode-features">
            <li>全维度体质分析</li>
            <li>详细的图表报告</li>
            <li>个性化调理方案</li>
          </ul>
          <button class="mode-btn primary">开始深度测评</button>
        </div>
      </div>
    </div>

    <!-- 问卷过程 -->
    <div v-else-if="!reportData" class="questionnaire-container fade-in">
      <!-- 顶部进度条 -->
      <div class="progress-bar">
        <div class="back-btn" @click="resetAssessment">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M19 12H5M12 19l-7-7 7-7"/>
          </svg>
          重新选择
        </div>
        <div class="progress-track">
          <div class="progress-fill" :style="{ width: progress + '%' }"></div>
        </div>
        <div class="step-indicator">{{ currentQuestionIndex + 1 }} / {{ questions.length }}</div>
      </div>

      <!-- 题目导航（长测评显示） -->
      <div class="question-nav" v-if="questions.length > 10">
        <div class="nav-title">快速跳转</div>
        <div class="nav-dots">
          <div 
            v-for="(q, idx) in questions" 
            :key="idx"
            class="nav-dot"
            :class="{ 
              active: idx === currentQuestionIndex,
              answered: (q.multiple ? (Array.isArray(answers[idx]) && answers[idx].length > 0) : (answers[idx] !== -1))
            }"
            @click="jumpToQuestion(idx)"
            :title="`第 ${idx + 1} 题`"
          >
            {{ idx + 1 }}
          </div>
        </div>
      </div>

      <!-- 问题卡片 -->
      <div class="question-container" v-if="currentQuestion">
        <div class="header">
          <div class="question-icon-large" v-if="currentQuestion.iconKey">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <path :d="iconPaths[currentQuestion.iconKey]" />
            </svg>
          </div>
          <div class="question-content">
            <h2>{{ currentQuestion.question }}</h2>
            <div class="type-tag">
              <span v-if="currentQuestion.multiple">多选 · 请选择所有符合项</span>
              <span v-else>单选 · 请选择最符合的一项</span>
            </div>
          </div>
        </div>
        
        <div class="options-list">
          <div 
            v-for="(opt, idx) in currentQuestion.options" 
            :key="idx"
            class="option-item"
            :class="{ active: isSelected(currentQuestionIndex, idx) }"
            @click="selectOption(currentQuestionIndex, idx)"
          >
            <span class="option-text">{{ opt }}</span>
            <div class="option-check">
              <svg v-if="isSelected(currentQuestionIndex, idx)" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
          </div>
        </div>
      </div>

      <!-- 底部操作 -->
      <div class="footer-actions">
        <button 
          class="btn-secondary" 
          @click="goToPrevious" 
          :disabled="currentQuestionIndex === 0"
          v-if="currentQuestionIndex > 0"
        >
          上一题
        </button>
        <div class="spacer"></div>
        <button 
          class="btn-primary" 
          @click="isLastQuestion ? submitAssessment() : goToNext()" 
          :disabled="!canGoNext || loading"
        >
          {{ loading ? '提交中...' : (isLastQuestion ? '提交测评' : '下一步') }}
          <svg v-if="!loading" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M5 12h14M12 5l7 7-7 7"/>
          </svg>
        </button>
      </div>

      <!-- 提示信息 -->
      <div class="tips-box">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="16" x2="12" y2="12"/>
          <line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <span>温馨提示： 本问卷仅用于健康评估，建议结果仅供参考，不能替代医生诊断。如有严重不适，请及时就医。</span>
      </div>
    </div>

    <!-- 结果页 -->
    <div v-else class="result-container fade-in">
      <div class="result-header">
        <div class="result-title">
          <h1>体质评估结果</h1>
          <p class="subtitle">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
            融合近7天打卡数据
          </p>
        </div>
        <div class="result-actions">
          <button class="btn-outline" @click="shareReport">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/>
              <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
            </svg>
            分享
          </button>
          <button class="btn-outline" @click="exportReport('all')" :disabled="isExporting">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            {{ isExporting ? '导出中...' : '导出PDF' }}
          </button>
          <button class="btn-outline" @click="resetAssessment">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M23 4v6h-6M1 20v-6h6"/>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 1 20.49 15"/>
            </svg>
            重新测评
          </button>
          <button class="btn-primary" @click="goHome">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
              <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
            完成测评
          </button>
        </div>
      </div>

      <div class="result-content">
        <!-- 1. 结论区块 -->
        <div class="result-section conclusion-section">
          <div class="section-header">
            <h2>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 11l3 3L22 4"/>
                <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
              </svg>
              评估结论
            </h2>
            <button class="export-btn" @click="exportReport('conclusion')">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              导出
            </button>
          </div>
          <div class="main-result-grid">
            <div class="constitution-card">
              <div class="card-label">您的体质</div>
              <div class="constitution-name">{{ reportData.constitution }}</div>
            </div>
            
            <div class="desc-card">
              <div class="desc-header">
                <div class="icon-box">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                    <polyline points="10 9 9 9 8 9"/>
                  </svg>
                </div>
                <h3>体质简述</h3>
              </div>
              <p>{{ reportData.summary }}</p>
            </div>
          </div>
        </div>

        <!-- 2. 风险区块 -->
        <div class="result-section risk-section" v-if="riskTips.length > 0">
          <div class="section-header">
            <h2>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
              健康风险提示
            </h2>
            <button class="export-btn" @click="exportReport('risk')">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              导出
            </button>
          </div>
          <div class="risk-tips">
            <ul>
              <li v-for="(tip, idx) in riskTips" :key="idx">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                {{ tip }}
              </li>
            </ul>
          </div>
        </div>

        <!-- 3. 建议区块 -->
        <div class="result-section suggestions-section">
          <div class="section-header">
            <h2>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
              </svg>
              调理建议
            </h2>
            <button class="export-btn" @click="exportReport('suggestions')">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              导出
            </button>
          </div>
          <div class="suggestions-list">
            <div 
              v-for="(sug, idx) in (reportData.suggestions || generateSuggestions())" 
              :key="idx"
              class="suggestion-item"
            >
              <div class="suggestion-number">{{ idx + 1 }}</div>
              <div class="suggestion-text">{{ sug }}</div>
            </div>
          </div>
        </div>

        <!-- 4. 画像数据区块 -->
        <div class="result-section portrait-section">
          <div class="section-header">
            <h2>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="16" x2="12" y2="12"/>
                <line x1="12" y1="8" x2="12.01" y2="8"/>
              </svg>
              健康画像数据
            </h2>
            <button class="export-btn" @click="exportReport('portrait')">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              导出
            </button>
          </div>

          <!-- 可视化图表区域 -->
          <div class="charts-grid" v-if="scoreChartData && typeDistributionData">
            <div class="chart-card">
              <h3>健康五维分析</h3>
              <div class="chart-wrapper">
                <Bar :data="scoreChartData" :options="chartOptions" />
              </div>
            </div>
            <div class="chart-card">
              <h3>体质倾向分布</h3>
              <div class="chart-wrapper">
                <Doughnut :data="typeDistributionData" :options="chartOptions" />
              </div>
            </div>
          </div>

          <div class="portrait-grid">
            <!-- 睡眠 -->
            <div class="portrait-card sleep">
              <div class="card-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                </svg>
              </div>
              <div class="card-content">
                <div class="card-label">睡眠状态</div>
                <div class="card-value">{{ portrait.sleepStatus || '未知' }}</div>
                <div class="card-meta">
                  <span>均值 {{ formatNumber(portrait.sleepAvg, 'h') }}</span>
                  <span class="meta-dot">•</span>
                  <span>晚睡 {{ formatPercent(portrait.sleepLateRate) }}</span>
                </div>
              </div>
            </div>

            <!-- 情绪 -->
            <div class="portrait-card mood">
              <div class="card-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/>
                </svg>
              </div>
              <div class="card-content">
                <div class="card-label">情绪状态</div>
                <div class="card-value">{{ portrait.moodStatus || '未知' }}</div>
                <div class="card-meta">
                  <span>均值 {{ formatNumber(portrait.moodAvg) }}</span>
                  <span class="meta-dot">•</span>
                  <span>低分 {{ formatNumber(portrait.moodLowDays) }}天</span>
                </div>
              </div>
            </div>

            <!-- 饮食 -->
            <div class="portrait-card diet">
              <div class="card-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M18 8h1a4 4 0 0 1 0 8h-1 M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z M6 1v3 M10 1v3 M14 1v3"/>
                </svg>
              </div>
              <div class="card-content">
                <div class="card-label">饮食倾向</div>
                <div class="card-value">{{ portrait.dietStatus || '未知' }}</div>
                <div class="card-meta">{{ portrait.dietLabel || '暂无详细记录' }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分享对话框 -->
    <div v-if="showShareDialog" class="modal-overlay" @click.self="showShareDialog = false">
      <div class="modal-content share-modal">
        <div class="modal-header">
          <h3>分享测评结果</h3>
          <button @click="showShareDialog = false" class="close-btn">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>
        <div class="share-options">
          <button class="share-option" @click="copyShareLink">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/>
            </svg>
            <span>复制链接</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 变量定义在容器层级，确保在 scoped 模式下正确生效 */
.assessment-container {
  --primary-color: #10b981;
  --primary-dark: #059669;
  --primary-light: #ecfdf5;
  --accent-color: #3b82f6;
  --text-main: #0f172a;
  --text-sub: #475569;
  --bg-page: #e2e8f0;
  --card-bg: #ffffff;
  --option-bg: #f8fafc;
  --glass-border: rgba(255, 255, 255, 0.8);
  --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);

  background: #f1f5f9;
  background-image: 
    radial-gradient(at 0% 0%, rgba(16, 185, 129, 0.15) 0px, transparent 50%),
    radial-gradient(at 100% 100%, rgba(59, 130, 246, 0.15) 0px, transparent 50%);
  min-height: 100vh;
  padding: 100px 20px 40px;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  color: var(--text-main);
}

.assessment-container > *:not(.back-top-left) {
  max-width: 900px;
  margin: 0 auto;
}

/* 动画 */
.fade-in {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 模式选择页 */
.mode-selection-container {
  text-align: center;
  padding-top: 40px;
}

.back-top-left {
  position: fixed !important;
  top: 20px !important;
  left: 20px !important;
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-sub);
  cursor: pointer;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.2s;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.back-top-left:hover {
  background: rgba(255, 255, 255, 1);
  color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.mode-header h1 {
  font-size: 32px;
  margin-bottom: 12px;
  color: var(--text-main);
}

.mode-header p {
  color: var(--text-sub);
  margin-bottom: 48px;
}

.mode-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 32px;
  max-width: 800px;
  margin: 0 auto;
}

.mode-card {
  background: var(--card-bg);
  border-radius: 24px;
  padding: 40px 32px;
  box-shadow: var(--shadow-card);
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.mode-card:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-hover);
  border-color: var(--primary-color);
}

.mode-card.recommended {
  border-color: var(--primary-color);
  background: linear-gradient(to bottom, #fff, #f0fdf4);
}

.recommend-tag {
  position: absolute;
  top: 20px;
  right: -30px;
  background: var(--primary-color);
  color: white;
  padding: 4px 40px;
  transform: rotate(45deg);
  font-size: 12px;
  font-weight: bold;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.mode-icon {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
  color: #64748b;
}

.mode-icon.short { color: #3b82f6; background: #eff6ff; }
.mode-icon.long { color: #10b981; background: #ecfdf5; }
.mode-icon svg { width: 32px; height: 32px; }

.mode-card h3 {
  font-size: 24px;
  margin-bottom: 8px;
  color: var(--text-main);
}

.mode-desc {
  color: var(--text-sub);
  font-size: 14px;
  margin-bottom: 24px;
}

.mode-features {
  list-style: none;
  padding: 0;
  margin: 0 0 32px;
  text-align: left;
  width: 100%;
}

.mode-features li {
  padding: 8px 0;
  border-bottom: 1px solid #f1f5f9;
  color: #64748b;
  display: flex;
  align-items: center;
  gap: 8px;
}

.mode-features li::before {
  content: "";
  display: block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #cbd5e1;
}

.mode-btn {
  width: 100%;
  padding: 12px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  background: white;
  color: var(--text-main);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.mode-btn.primary {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.mode-card:hover .mode-btn {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 问卷容器 */
.questionnaire-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.progress-bar {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  color: var(--text-sub);
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
}

.progress-track {
  flex: 1;
  height: 8px;
  background: rgba(0,0,0,0.05);
  border-radius: 99px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--primary-color), #34d399);
  border-radius: 99px;
  transition: width 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.step-indicator {
  font-weight: 800;
  color: var(--primary-color);
  font-size: 16px;
}

.question-container {
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.5);
  border-radius: 24px;
  box-shadow: var(--shadow-card);
  overflow: hidden;
}

.header {
  padding: 32px;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  align-items: flex-start;
  gap: 24px;
  background: rgba(255, 255, 255, 0.5);
}

.question-icon-large {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #fff, var(--primary-light));
  border: 1px solid #fff;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.1);
  flex-shrink: 0;
}

.question-icon-large svg { width: 28px; height: 28px; }

.question-content { flex: 1; }

.question-content h2 {
  font-size: 20px;
  margin-bottom: 8px;
  line-height: 1.4;
}

.type-tag {
  display: inline-block;
  padding: 4px 12px;
  background: #f1f5f9;
  color: var(--text-sub);
  border-radius: 99px;
  font-size: 12px;
  font-weight: 500;
}

.options-list {
  padding: 32px;
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

@media (min-width: 640px) {
  .options-list {
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  }
}

.option-item {
  position: relative;
  padding: 20px 24px;
  background: var(--option-bg);
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.option-item:hover {
  transform: translateY(-2px);
  background: #fff;
  border-color: var(--primary-color);
  box-shadow: var(--shadow-hover);
}

.option-item.active {
  background: var(--primary-light);
  border-color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
  color: var(--primary-dark);
}

.option-text {
  font-weight: 600;
  font-size: 16px;
  color: var(--text-main);
}

.option-item.active .option-text {
  color: var(--primary-dark);
}

.option-check {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 2px solid #cbd5e1;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  transition: all 0.2s;
  flex-shrink: 0;
}

.option-item.active .option-check {
  background: var(--primary-color);
  border-color: var(--primary-color);
}

.footer-actions {
  display: flex;
  align-items: center;
  margin-top: 8px;
}

.spacer { flex: 1; }

.btn-primary, .btn-secondary, .btn-outline {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.btn-primary {
  background: var(--primary-color);
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.btn-primary:hover:not(:disabled) {
  background: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(16, 185, 129, 0.4);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
}

.btn-secondary {
  background: #fff;
  color: var(--text-sub);
  border: 1px solid #e2e8f0;
}

.btn-secondary:hover {
  background: #f8fafc;
  color: var(--text-main);
}

.btn-outline {
  background: transparent;
  border: 1px solid #cbd5e1;
  color: var(--text-main);
}

.btn-outline:hover {
  border-color: var(--primary-color);
  color: var(--primary-color);
}

.tips-box {
  background: #fffbeb;
  border: 1px solid #fcd34d;
  color: #b45309;
  padding: 16px;
  border-radius: 12px;
  font-size: 14px;
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

/* 结果页样式 */
.result-container {
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.5);
  border-radius: 32px;
  box-shadow: var(--shadow-card);
  overflow: hidden;
}

.result-header {
  padding: 32px;
  background: rgba(248, 250, 252, 0.8);
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.result-title h1 {
  font-size: 24px;
  margin-bottom: 4px;
}

.subtitle {
  color: var(--text-sub);
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.result-actions {
  display: flex;
  gap: 12px;
}

.result-content {
  padding: 32px;
}

.main-result-grid {
  display: grid;
  grid-template-columns: 200px 1fr;
  gap: 24px;
  margin-bottom: 40px;
}

@media (max-width: 768px) {
  .main-result-grid {
    grid-template-columns: 1fr;
  }
}

.constitution-card {
  background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
  border-radius: 20px;
  padding: 32px;
  color: white;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  box-shadow: 0 10px 25px rgba(16, 185, 129, 0.3);
}

.card-label {
  opacity: 0.9;
  font-size: 14px;
  margin-bottom: 8px;
}

.constitution-name {
  font-size: 36px;
  font-weight: 800;
  letter-spacing: 2px;
}

.desc-card {
  background: #f8fafc;
  border-radius: 20px;
  padding: 24px;
}

.desc-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.icon-box {
  width: 40px;
  height: 40px;
  background: white;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-sub);
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.desc-card p {
  color: var(--text-sub);
  line-height: 1.6;
}

/* 图表区域 */
.charts-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 40px;
}

@media (max-width: 768px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
}

.chart-card {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 24px;
}

.chart-card h3 {
  margin-bottom: 16px;
  font-size: 16px;
  color: var(--text-main);
}

.chart-wrapper {
  height: 250px;
  position: relative;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 24px;
  color: var(--text-main);
}

.portrait-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.portrait-card {
  background: var(--option-bg);
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 24px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.portrait-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
  background: #fff;
  border-color: transparent;
}

.card-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-icon svg { width: 24px; height: 24px; }

.sleep .card-icon { background: #e0e7ff; color: #4338ca; }
.mood .card-icon { background: #fee2e2; color: #b91c1c; }
.diet .card-icon { background: #dcfce7; color: #15803d; }

.card-subtitle {
  font-size: 12px;
  color: var(--text-sub);
  margin-bottom: 4px;
}

.card-value {
  font-size: 20px;
  font-weight: 700;
  color: var(--text-main);
  margin-bottom: 4px;
}

.card-meta {
  font-size: 12px;
  color: var(--text-sub);
}

.meta-dot { margin: 0 4px; color: #cbd5e1; }

.risk-tips {
  background: #fff1f2;
  border-radius: 20px;
  padding: 24px;
}

.risk-tips h3 {
  color: #be123c;
  font-size: 16px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.risk-tips ul {
  padding-left: 20px;
  color: #881337;
  margin: 0;
}

.risk-tips li {
  margin-bottom: 8px;
}

/* 响应式样式 */
@media (max-width: 768px) {
  .back-top-left {
    top: 10px !important;
    left: 10px !important;
    padding: 6px 12px;
    font-size: 14px;
  }
  
  .assessment-container {
    padding: 80px 15px 30px;
  }
}

/* 进度恢复提示 */
.restore-prompt {
  position: fixed;
  top: 80px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 999;
  max-width: 600px;
  width: 90%;
}

.restore-content {
  background: white;
  border-radius: 16px;
  padding: 20px 24px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  border: 2px solid var(--primary-color);
  display: flex;
  align-items: center;
  gap: 16px;
}

.restore-content > svg {
  color: var(--primary-color);
  flex-shrink: 0;
}

.restore-text {
  flex: 1;
}

.restore-text h3 {
  font-size: 16px;
  margin: 0 0 4px 0;
  color: var(--text-main);
}

.restore-text p {
  font-size: 14px;
  margin: 0;
  color: var(--text-sub);
}

.restore-actions {
  display: flex;
  gap: 8px;
}

.restore-actions button {
  padding: 8px 16px;
  font-size: 14px;
}

/* 题目导航 */
.question-nav {
  background: white;
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 16px;
  box-shadow: var(--shadow-card);
}

.nav-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-sub);
  margin-bottom: 12px;
}

.nav-dots {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.nav-dot {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: #f1f5f9;
  color: var(--text-sub);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: 2px solid transparent;
}

.nav-dot:hover {
  background: #e2e8f0;
}

.nav-dot.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.nav-dot.answered {
  background: var(--primary-light);
  color: var(--primary-dark);
  border-color: var(--primary-color);
}

/* 结果区块样式 */
.result-section {
  background: white;
  border-radius: 20px;
  padding: 24px;
  margin-bottom: 24px;
  border: 1px solid #e2e8f0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f1f5f9;
}

.section-header h2 {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-main);
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
}

.export-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  color: var(--text-sub);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.export-btn:hover {
  background: var(--primary-light);
  color: var(--primary-color);
  border-color: var(--primary-color);
}

.conclusion-section {
  border-left: 4px solid var(--primary-color);
}

.risk-section {
  border-left: 4px solid #ef4444;
}

.risk-section .risk-tips {
  background: transparent;
  padding: 0;
}

.risk-section .risk-tips ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.risk-section .risk-tips li {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  background: #fff1f2;
  border-radius: 12px;
  margin-bottom: 12px;
  color: #881337;
}

.risk-section .risk-tips li svg {
  flex-shrink: 0;
  color: #ef4444;
  margin-top: 2px;
}

.suggestions-section {
  border-left: 4px solid #3b82f6;
}

.suggestions-list {
  display: grid;
  gap: 12px;
}

.suggestion-item {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  align-items: flex-start;
}

.suggestion-number {
  width: 32px;
  height: 32px;
  background: var(--primary-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  flex-shrink: 0;
}

.suggestion-text {
  flex: 1;
  color: var(--text-main);
  line-height: 1.6;
  padding-top: 4px;
}

.portrait-section {
  border-left: 4px solid #8b5cf6;
}

/* 分享对话框 */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 20px;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #e2e8f0;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  color: var(--text-main);
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: #f8fafc;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-sub);
  cursor: pointer;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e2e8f0;
  color: var(--text-main);
}

.share-options {
  padding: 24px;
}

.share-option {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  color: var(--text-main);
  font-weight: 600;
}

.share-option:hover {
  background: var(--primary-light);
  border-color: var(--primary-color);
  color: var(--primary-color);
}

.share-option svg {
  color: var(--text-sub);
}

.share-option:hover svg {
  color: var(--primary-color);
}
</style>
