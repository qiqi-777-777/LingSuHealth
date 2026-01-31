# Checkin.vue 优化版使用说明

## 重要提示

由于 Checkin.vue 文件非常大（2019行），完整替换可能导致问题。建议采用以下方式：

### 方案1：手动添加功能（推荐）

#### 1. 在 script 部分添加新的导入
```typescript
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
```

#### 2. 添加新的响应式变量
```typescript
// 分步骤相关
const currentStep = ref(1);
const totalSteps = 3;

// 筛选相关
const showFilter = ref(false);
const filterStartDate = ref('');
const filterEndDate = ref('');
const filterMinScore = ref(0);
const filterMaxScore = ref(100);
const filterSymptoms = ref<string[]>([]);

// 导出相关
const isExporting = ref(false);
const showExportDialog = ref(false);
const exportRange = ref<'current' | 'all'>('current');
```

#### 3. 修改 AnalysisResult 接口
```typescript
interface AnalysisResult {
  summary: string;
  suggestions: Suggestion[];
  healthScore?: number;
  tomorrowPlan: string;
  tomorrowTasks?: string[]; // 新增
  risks?: Array<{ level: string; content: string }>; // 新增
}
```

#### 4. 添加新的计算属性
```typescript
// 当前步骤验证
const isCurrentStepValid = computed(() => {
  switch (currentStep.value) {
    case 1:
      return checkinData.value.sleepTime && checkinData.value.sleepHours > 0;
    case 2:
      return checkinData.value.mood !== null;
    case 3:
      return true;
    default:
      return false;
  }
});

// 筛选后的历史记录
const filteredHistory = computed(() => {
  let filtered = [...checkinHistory.value];
  
  if (filterStartDate.value) {
    filtered = filtered.filter(r => r.date >= filterStartDate.value);
  }
  if (filterEndDate.value) {
    filtered = filtered.filter(r => r.date <= filterEndDate.value);
  }
  
  filtered = filtered.filter(r => {
    const score = r.healthScore ?? 0;
    return score >= filterMinScore.value && score <= filterMaxScore.value;
  });
  
  if (filterSymptoms.value.length > 0) {
    filtered = filtered.filter(r => {
      if (!r.symptoms || r.symptoms.length === 0) return false;
      return filterSymptoms.value.some(s => r.symptoms?.includes(s));
    });
  }
  
  return filtered;
});
```

#### 5. 添加新的方法
参考 `Checkin功能优化说明.md` 中的完整代码

### 方案2：使用 Git 分支（最安全）

1. 创建新分支进行测试
```bash
git checkout -b feature/checkin-optimization
```

2. 备份当前文件
```bash
cp ui/src/views/Checkin.vue ui/src/views/Checkin.vue.backup
```

3. 应用修改并测试

4. 如果有问题，可以快速回滚
```bash
git checkout main
```

## 新增功能详解

### 1. 分步骤表单

**步骤1：基础信息**（必填）
- 睡眠时长 *
- 入睡时间 *

**步骤2：健康状态**（部分必填）
- 今日症状
- 情绪状态 *
- 运动时长

**步骤3：饮食记录**（选填）
- 饮食简记

**实现要点：**
- 使用 `currentStep` 控制当前步骤
- `isCurrentStepValid` 验证当前步骤
- 必填项用红色星号标识
- 点击"下一步"自动验证

### 2. 结果页优化

#### 明日重点任务板块
```vue
<div class="tomorrow-tasks-section">
  <h3>
    <span class="section-icon">🚀</span>
    明日重点任务
  </h3>
  <div class="tasks-list">
    <div v-for="(task, index) in analysisResult.tomorrowTasks" 
         :key="index" 
         class="task-item">
      <span class="task-number">{{ index + 1 }}</span>
      <span class="task-text">{{ task }}</span>
    </div>
  </div>
</div>
```

**样式特点：**
- 橙色渐变背景
- 火箭图标
- 编号列表
- 悬停动画

#### 风险提示板块
```vue
<div class="risks-section" v-if="analysisResult.risks && analysisResult.risks.length > 0">
  <h3>
    <span class="section-icon">⚠️</span>
    健康风险提示
  </h3>
  <div class="risks-list">
    <div v-for="(risk, index) in analysisResult.risks" 
         :key="index" 
         class="risk-item"
         :class="`risk-${risk.level}`">
      <span class="risk-icon">⚠️</span>
      <div class="risk-content">
        <span class="risk-level">{{ risk.level }}</span>
        <p>{{ risk.content }}</p>
      </div>
    </div>
  </div>
</div>
```

**样式特点：**
- 红色警告背景
- 风险等级标识（高/中/低）
- 警告图标
- 渐变边框

### 3. 历史筛选功能

#### 筛选器UI
```vue
<div class="filter-panel" v-if="showFilter">
  <div class="filter-group">
    <label>日期范围</label>
    <input type="date" v-model="filterStartDate">
    <span>至</span>
    <input type="date" v-model="filterEndDate">
  </div>
  
  <div class="filter-group">
    <label>健康分</label>
    <input type="range" v-model="filterMinScore" min="0" max="100">
    <span>{{ filterMinScore }} - {{ filterMaxScore }}</span>
    <input type="range" v-model="filterMaxScore" min="0" max="100">
  </div>
  
  <div class="filter-group">
    <label>症状筛选</label>
    <div class="symptom-filters">
      <span v-for="symptom in symptoms" 
            :key="symptom"
            :class="{ active: filterSymptoms.includes(symptom) }"
            @click="toggleFilterSymptom(symptom)">
        {{ symptom }}
      </span>
    </div>
  </div>
  
  <div class="filter-actions">
    <button @click="applyFilter">应用筛选</button>
    <button @click="clearFilter">清除</button>
  </div>
</div>
```

### 4. PDF 导出功能

#### 导出对话框
```vue
<div v-if="showExportDialog" class="modal-overlay">
  <div class="modal-content export-dialog">
    <h3>导出健康记录</h3>
    <div class="export-options">
      <label>
        <input type="radio" v-model="exportRange" value="current">
        导出当前页（前10条）
      </label>
      <label>
        <input type="radio" v-model="exportRange" value="all">
        导出全部筛选结果（{{ filteredHistory.length }}条）
      </label>
    </div>
    <div class="export-actions">
      <button @click="exportToPDF" :disabled="isExporting">
        {{ isExporting ? '导出中...' : '确认导出' }}
      </button>
      <button @click="closeExportDialog">取消</button>
    </div>
  </div>
</div>
```

## 样式添加

### 1. 步骤指示器样式
```css
.step-indicator {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 40px;
}

.step-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.step-number {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #e2e8f0;
  color: #64748b;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  transition: all 0.3s;
}

.step-item.active .step-number {
  background: #10b981;
  color: white;
}

.step-item.completed .step-number {
  background: #10b981;
  color: white;
}
```

### 2. 明日任务样式
```css
.tomorrow-tasks-section {
  background: linear-gradient(135deg, #fff7ed 0%, #fed7aa 100%);
  border: 2px solid #fb923c;
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 32px;
}

.tasks-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.task-item {
  display: flex;
  align-items: center;
  gap: 16px;
  background: white;
  padding: 16px 20px;
  border-radius: 16px;
  transition: all 0.3s;
}

.task-item:hover {
  transform: translateX(8px);
  box-shadow: 0 4px 12px rgba(251, 146, 60, 0.2);
}

.task-number {
  width: 32px;
  height: 32px;
  background: #fb923c;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  flex-shrink: 0;
}
```

### 3. 风险提示样式
```css
.risks-section {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border: 2px solid #ef4444;
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 32px;
}

.risk-item {
  display: flex;
  gap: 16px;
  background: white;
  padding: 20px;
  border-radius: 16px;
  margin-bottom: 16px;
  border-left: 4px solid #ef4444;
}

.risk-item.risk-高 {
  border-left-color: #dc2626;
  background: #fef2f2;
}

.risk-item.risk-中 {
  border-left-color: #f59e0b;
  background: #fffbeb;
}

.risk-item.risk-低 {
  border-left-color: #3b82f6;
  background: #eff6ff;
}

.risk-level {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 8px;
}

.risk-高 .risk-level {
  background: #dc2626;
  color: white;
}

.risk-中 .risk-level {
  background: #f59e0b;
  color: white;
}

.risk-低 .risk-level {
  background: #3b82f6;
  color: white;
}
```

### 4. 筛选面板样式
```css
.filter-panel {
  background: white;
  border-radius: 20px;
  padding: 24px;
  margin-bottom: 20px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  border: 1px solid #e2e8f0;
}

.filter-group {
  margin-bottom: 20px;
}

.filter-group label {
  display: block;
  font-weight: 600;
  color: #334155;
  margin-bottom: 8px;
}

.filter-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}
```

## 测试清单

- [ ] 分步骤表单正常切换
- [ ] 必填项验证生效
- [ ] 筛选功能正常工作
- [ ] PDF 导出成功
- [ ] 明日任务正确显示
- [ ] 风险提示正确显示
- [ ] 移动端响应式正常
- [ ] 历史记录点击查看详情

## 注意事项

1. 确保已安装 `html2canvas` 和 `jspdf`
2. 导出功能需要 1-3 秒时间
3. 筛选条件可以组合使用
4. 移动端会自动隐藏部分功能
5. 建议在测试环境先验证

## 回滚方案

如果出现问题，可以：
1. 使用备份文件恢复
2. Git 回滚到之前的提交
3. 只保留部分新功能

## 技术支持

如有问题，请检查：
1. 浏览器控制台错误信息
2. 网络请求是否正常
3. 依赖包是否正确安装
