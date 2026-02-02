<template>
  <div class="checkin-container">
    <!-- 背景装饰 -->
    <div class="bg-decoration top-right"></div>
    <div class="bg-decoration bottom-left"></div>

    <!-- 顶部导航 -->
    <div class="nav-header">
      <button @click="goHome" class="back-btn">
        <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        <span>返回首页</span>
      </button>
      <div class="page-title">
        <h1>养生记录</h1>
        <p>记录每日状态，开启健康生活</p>
      </div>
      <div class="header-actions">
         <!-- 占位，保持平衡 -->
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 左侧：记录表单 -->
      <div class="form-panel glass-card" v-if="!showResult">
        <div class="panel-header">
          <div class="header-left">
            <h2>今日记录</h2>
            <div class="date-badge">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path :d="iconPaths.calendar" />
              </svg>
              {{ getCurrentDate() }}
            </div>
          </div>
        </div>

        <!-- 步骤指示器 -->
        <div class="stepper">
          <div 
            v-for="step in totalSteps" 
            :key="step" 
            class="step-item"
            :class="{ active: currentStep === step, completed: currentStep > step }"
            @click="goToStep(step)"
          >
            <div class="step-circle">
              <span v-if="currentStep > step" class="check-icon">✓</span>
              <span v-else>{{ step }}</span>
            </div>
            <span class="step-label">
              {{ step === 1 ? '基础信息' : step === 2 ? '健康状态' : '饮食记录' }}
            </span>
            <div class="step-line" v-if="step < totalSteps"></div>
          </div>
        </div>

        <div class="form-body">
          <!-- 步骤1：基础信息 -->
          <div v-show="currentStep === 1" class="step-content fade-in">
            <div class="form-group">
              <label class="input-label">
                <span class="icon-box sm">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.sleep" />
                  </svg>
                </span>
                睡眠时长 <span class="required">*</span>
              </label>
              <div class="slider-wrapper">
                <div class="slider-value">{{ checkinData.sleepHours }} <small>小时</small></div>
                <input 
                  type="range" 
                  v-model="checkinData.sleepHours" 
                  min="0" 
                  max="12" 
                  step="0.5" 
                  class="custom-slider"
                  :style="{ backgroundSize: (checkinData.sleepHours / 12) * 100 + '% 100%' }"
                >
                <div class="slider-labels">
                  <span>0</span>
                  <span>6</span>
                  <span>12</span>
                </div>
              </div>
            </div>

            <div class="form-group">
              <label class="input-label">
                <span class="icon-box sm">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.sleep_moon" />
                  </svg>
                </span>
                入睡时间 <span class="required">*</span>
              </label>
              <div class="input-wrapper">
                <input type="time" v-model="checkinData.sleepTime" class="custom-input time-input">
              </div>
            </div>
          </div>

          <!-- 步骤2：健康状态 -->
          <div v-show="currentStep === 2" class="step-content fade-in">
            <div class="form-group">
              <label class="input-label">
                <span class="icon-box sm">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.symptom" />
                  </svg>
                </span>
                今日症状
              </label>
              <div class="tags-grid">
                <div 
                  v-for="symptom in symptoms" 
                  :key="symptom"
                  class="tag-item"
                  :class="{ active: checkinData.symptoms.includes(symptom) }"
                  @click="toggleSymptom(symptom)"
                >
                  {{ symptom }}
                </div>
              </div>
            </div>

            <div class="form-group">
              <label class="input-label">
                <span class="icon-box sm">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.mood_status" />
                  </svg>
                </span>
                情绪状态 <span class="required">*</span>
              </label>
              <div class="mood-selector">
                <div 
                  v-for="(moodItem, index) in moods" 
                  :key="index"
                  class="mood-item"
                  :class="{ active: checkinData.mood === index }"
                  @click="checkinData.mood = index"
                >
                  <div class="mood-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path :d="iconPaths[moodItem.iconKey]" />
                    </svg>
                  </div>
                  <span class="mood-name">{{ moodItem.name }}</span>
                </div>
              </div>
            </div>

            <div class="form-group">
              <label class="input-label">
                <span class="icon-box sm">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.exercise_run" />
                  </svg>
                </span>
                运动时长
              </label>
              <div class="counter-input">
                <button @click="adjustExercise(-10)" class="counter-btn minus">-</button>
                <div class="counter-display">
                  <input type="number" v-model="checkinData.exerciseMinutes" min="0" max="300">
                  <span>分钟</span>
                </div>
                <button @click="adjustExercise(10)" class="counter-btn plus">+</button>
              </div>
            </div>
          </div>

          <!-- 步骤3：饮食记录 -->
          <div v-show="currentStep === 3" class="step-content fade-in">
            <div class="form-group full-height">
              <label class="input-label">
                <span class="icon-box sm">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.diet" />
                  </svg>
                </span>
                饮食记录
              </label>
              <textarea 
                v-model="checkinData.dietNotes"
                placeholder="简单记录今日饮食，如：早餐小米粥，午餐青菜炒肉..."
                class="custom-textarea"
              ></textarea>
            </div>
          </div>
        </div>

        <div class="form-footer">
          <button v-if="currentStep > 1" @click="prevStep" class="btn-secondary">
            上一步
          </button>
          <div class="spacer"></div>
          <button 
            v-if="currentStep < totalSteps" 
            @click="nextStep" 
            class="btn-primary"
            :disabled="!isCurrentStepValid"
          >
            下一步
          </button>
          <button 
            v-else 
            @click="submitCheckin" 
            class="btn-primary submit"
            :disabled="loading || !isFormValid"
          >
            <span v-if="loading" class="spinner"></span>
            提交记录
          </button>
        </div>
      </div>

      <!-- AI分析结果展示页 (移入 main-content) -->
      <div class="result-view" v-if="showResult && analysisResult">
         <div class="result-card glass-card">
           <div class="result-header">
             <div class="title-group">
               <div class="icon-box lg success">
                 <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <path :d="iconPaths.check_circle" />
                 </svg>
               </div>
               <div>
                 <h2>AI健康分析报告</h2>
                <p>{{ formatTime(new Date()) }}</p>
               </div>
             </div>
             <div class="score-display">
               <div class="score-circle">
                 <span class="score-val">{{ analysisResult.healthScore || '-' }}</span>
                 <span class="score-lbl">健康分</span>
               </div>
             </div>
           </div>
  
           <div class="result-body">
              <!-- 智能总结 -->
              <div class="info-section primary">
                 <h3>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.bulb" /></svg>
                  今日总结
                </h3>
                <p>{{ sanitizeText(analysisResult.summary) }}</p>
              </div>
  
              <!-- 风险提示 -->
              <div v-if="analysisResult.risks && analysisResult.risks.length" class="info-section danger">
                <h3>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.warning" /></svg>
                  风险提示
                </h3>
                <ul class="risk-list">
                  <li v-for="(risk, idx) in analysisResult.risks" :key="idx">
                    <span class="risk-badge">{{ risk.level }}</span>
                    {{ risk.content }}
                  </li>
                </ul>
              </div>
  
              <!-- 个性化建议 -->
              <div class="info-section info">
                <h3>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.target" /></svg>
                  个性化建议
                </h3>
                <div class="suggestion-cards">
                  <div v-for="(sug, idx) in analysisResult.suggestions" :key="idx" class="sug-card">
                    <h4>{{ sug.title }}</h4>
                    <p>{{ sug.content }}</p>
                  </div>
                </div>
              </div>
              
              <div v-if="analysisResult.tomorrowPlan" class="info-section primary">
                <h3>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.calendar" /></svg>
                  明日建议
                </h3>
                <p>{{ sanitizeText(analysisResult.tomorrowPlan) }}</p>
              </div>
              
              <!-- 明日提醒 -->
              <div v-if="analysisResult.tomorrowTasks && analysisResult.tomorrowTasks.length" class="info-section warning">
                 <h3>
                   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.calendar" /></svg>
                   明日提醒
                 </h3>
                 <ul class="task-list">
                   <li v-for="(task, idx) in analysisResult.tomorrowTasks" :key="idx">
                     <span class="task-num">{{ idx + 1 }}</span>
                    {{ sanitizeText(task) }}
                   </li>
                 </ul>
              </div>
  
               <!-- 趋势图 -->
              <div class="chart-box">
                <h3>健康趋势</h3>
                <canvas ref="chartCanvas" width="600" height="250"></canvas>
              </div>
           </div>
  
          <div class="result-footer">
            <button @click="resetForm" class="btn-secondary">再次记录</button>
            <button @click="goHome" class="btn-primary">返回首页</button>
          </div>
         </div>
      </div>

      <!-- 右侧：历史记录 -->
      <div class="history-panel glass-card">

        <div class="panel-header">
          <h3>近期记录</h3>
          <div class="header-actions">
            <button @click="toggleFilter" class="icon-btn" :class="{ active: showFilter }" title="筛选">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M22 3H2l8 9.46V19l4 2v-8.54L22 3z"/>
              </svg>
            </button>
            <button @click="openExportDialog" class="icon-btn" title="导出">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/>
                <line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- 筛选面板 -->
        <div v-if="showFilter" class="filter-panel fade-in">
          <div class="filter-row mb-2">
            <input 
              type="text" 
              v-model="searchKeyword" 
              placeholder="搜索症状、饮食或总结..." 
              class="custom-input sm"
              style="width: 100%"
            >
          </div>
          <div class="filter-row">
            <input type="date" v-model="filterStartDate" class="custom-input sm">
            <span>至</span>
            <input type="date" v-model="filterEndDate" class="custom-input sm">
          </div>
          <div class="filter-row actions">
            <button @click="clearFilter" class="text-btn">清除</button>
            <button @click="applyFilter" class="btn-primary sm">应用</button>
          </div>
        </div>

        <div class="history-list">
          <div 
            v-for="record in checkinHistory" 
            :key="record.date" 
            class="history-card"
            @click="openDetailModal(record)"
          >
            <div class="card-left">
              <div class="record-date">{{ formatDateShort(record.date) }}</div>
              <div class="record-mood">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths[getMoodInfo(record.mood).iconKey] || ''" />
                </svg>
              </div>
            </div>
            <div class="card-right">
              <div class="score-tag" :class="getScoreClass(record.healthScore)">
                {{ record.healthScore || '-' }}分
              </div>
              <div class="tags-row">
                 <span v-if="record.sleepHours" class="mini-tag">
                   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.sleep" /></svg>
                   {{ record.sleepHours }}h
                 </span>
                 <span v-if="record.exerciseMinutes" class="mini-tag">
                   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.exercise" /></svg>
                   {{ record.exerciseMinutes }}min
                 </span>
              </div>
            </div>
            <button 
              class="delete-btn" 
              @click.stop="deleteCheckinRecord(record)"
              title="删除记录"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M10 11v6M14 11v6"/>
              </svg>
            </button>
          </div>
          <div v-if="checkinHistory.length === 0" class="empty-state">
            暂无记录
          </div>
        </div>
      </div>
    </div>

    <!-- 模态框组件 -->
    <div v-if="showDetailModal && selectedRecord" class="modal-overlay fade-in" @click="closeDetailModal">
      <div class="modal-card glass-card" @click.stop>
        <div class="modal-header">
          <h3>记录详情</h3>
          <button @click="closeDetailModal" class="close-btn">×</button>
        </div>
        <div class="modal-content">
          <div class="detail-row">
            <span class="label">日期</span>
            <span class="value">{{ selectedRecord.date }}</span>
          </div>
          <div class="detail-row">
            <span class="label">健康分</span>
            <span class="value highlight">{{ selectedRecord.healthScore }}</span>
          </div>
          <div class="detail-grid">
             <div class="detail-item">
               <span class="icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.sleep" /></svg></span>
               <span>睡眠 {{ selectedRecord.sleepHours }}h</span>
             </div>
             <div class="detail-item">
               <span class="icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths.exercise" /></svg></span>
               <span>运动 {{ selectedRecord.exerciseMinutes }}min</span>
             </div>
             <div class="detail-item">
               <span class="icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="iconPaths[getMoodInfo(selectedRecord?.mood).iconKey] || ''" /></svg></span>
               <span>{{ getMoodInfo(selectedRecord?.mood).name }}</span>
             </div>
          </div>
          <div v-if="selectedRecord.symptoms && selectedRecord.symptoms.length" class="detail-section">
            <h4>症状</h4>
            <div class="tags-row">
              <span v-for="s in selectedRecord.symptoms" :key="s" class="mini-tag danger">{{ s }}</span>
            </div>
          </div>
          <div v-if="selectedRecord.dietNotes" class="detail-section">
            <h4>饮食</h4>
            <p>{{ selectedRecord.dietNotes }}</p>
          </div>
          
          <!-- AI分析详情 -->
          <div v-if="selectedRecord.summary" class="detail-section highlight-section">
             <h4>智能总结</h4>
             <p>{{ selectedRecord.summary }}</p>
          </div>

          <div v-if="selectedRecord.risks && selectedRecord.risks.length" class="detail-section">
             <h4>风险提示</h4>
             <ul class="risk-list">
               <li v-for="(risk, idx) in selectedRecord.risks" :key="idx">
                 <span class="risk-badge" :class="risk.level === '高' ? 'high' : 'medium'">{{ risk.level }}</span>
                 {{ risk.content }}
               </li>
             </ul>
          </div>
          
          <div v-if="selectedRecord.suggestions && selectedRecord.suggestions.length" class="detail-section">
             <h4>建议</h4>
             <div class="mini-suggestions">
               <div v-for="(sug, idx) in selectedRecord.suggestions" :key="idx" class="mini-sug-item">
                 <strong>{{ sug.title }}</strong>
                 <p>{{ sug.content }}</p>
               </div>
             </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 导出对话框 -->
    <div v-if="showExportDialog" class="modal-overlay fade-in" @click="closeExportDialog">
      <div class="modal-card glass-card export-dialog" @click.stop>
         <div class="modal-header">
           <h3>导出记录</h3>
           <button @click="closeExportDialog" class="close-btn">×</button>
         </div>
         <div class="export-body">
            <p class="export-hint">请选择要导出的打卡记录：</p>
            <div class="export-list">
               <label 
                 v-for="(record, index) in filteredHistory" 
                 :key="index"
                 class="export-item"
                 :class="{ selected: selectedExportIndex === index }"
               >
                 <input 
                   type="radio" 
                   v-model="selectedExportIndex" 
                   :value="index"
                   class="export-radio"
                 >
                 <div class="export-item-content">
                   <div class="export-item-header">
                     <span class="export-date">{{ formatDateFull(record.date) }}</span>
                     <span class="export-score" :class="getScoreClass(record.healthScore)">
                       {{ record.healthScore }}分
                     </span>
                   </div>
                   <div class="export-item-info">
                     <span class="info-tag">
                       <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                         <path :d="iconPaths.sleep" />
                       </svg>
                       {{ record.sleepHours }}h
                     </span>
                     <span class="info-tag">
                       <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                         <path :d="getMoodInfo(record.mood).iconKey === 'mood_happy' ? iconPaths.mood_happy : 
                                   getMoodInfo(record.mood).iconKey === 'mood_good' ? iconPaths.mood_good :
                                   getMoodInfo(record.mood).iconKey === 'mood_normal' ? iconPaths.mood_normal :
                                   getMoodInfo(record.mood).iconKey === 'mood_bad' ? iconPaths.mood_bad :
                                   iconPaths.mood_terrible" />
                       </svg>
                       {{ getMoodInfo(record.mood).name }}
                     </span>
                     <span class="info-tag">
                       <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                         <path :d="iconPaths.exercise_run" />
                       </svg>
                       {{ record.exerciseMinutes }}min
                     </span>
                   </div>
                 </div>
                 <div class="export-check">
                   <svg v-if="selectedExportIndex === index" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                     <path d="M5 13l4 4L19 7" />
                   </svg>
                 </div>
               </label>
            </div>
         </div>
         <div class="modal-footer">
            <button @click="closeExportDialog" class="btn-secondary">取消</button>
            <button 
              @click="exportToPDF" 
              class="btn-primary" 
              :disabled="isExporting || selectedExportIndex === null"
            >
              {{ isExporting ? '导出中...' : '确认导出' }}
            </button>
         </div>
      </div>
    </div>

    <!-- PDF导出内容（隐藏） -->
    <div v-if="exportRecord" ref="pdfContent" class="pdf-content">
      <div class="pdf-header">
        <h1>健康打卡记录</h1>
        <p class="pdf-date">{{ formatDateFull(exportRecord.date) }}</p>
      </div>
      
      <div class="pdf-section">
        <h2>健康评分</h2>
        <div class="pdf-score-box">
          <div class="pdf-score-circle" :class="getScoreClass(exportRecord.healthScore)">
            <span class="pdf-score-value">{{ exportRecord.healthScore }}</span>
            <span class="pdf-score-label">综合健康分</span>
          </div>
        </div>
      </div>

      <div class="pdf-section">
        <h2>基础数据</h2>
        <div class="pdf-data-grid">
          <div class="pdf-data-item">
            <span class="pdf-label">睡眠时长</span>
            <span class="pdf-value">{{ exportRecord.sleepHours }} 小时</span>
          </div>
          <div class="pdf-data-item">
            <span class="pdf-label">入睡时间</span>
            <span class="pdf-value">{{ exportRecord.sleepTime }}</span>
          </div>
          <div class="pdf-data-item">
            <span class="pdf-label">情绪状态</span>
            <span class="pdf-value">{{ getMoodInfo(exportRecord.mood).name }}</span>
          </div>
          <div class="pdf-data-item">
            <span class="pdf-label">运动时长</span>
            <span class="pdf-value">{{ exportRecord.exerciseMinutes }} 分钟</span>
          </div>
        </div>
      </div>

      <div class="pdf-section" v-if="exportRecord.symptoms && exportRecord.symptoms.length > 0">
        <h2>身体症状</h2>
        <div class="pdf-tags">
          <span v-for="symptom in exportRecord.symptoms" :key="symptom" class="pdf-tag">
            {{ symptom }}
          </span>
        </div>
      </div>

      <div class="pdf-section" v-if="exportRecord.dietNotes">
        <h2>饮食记录</h2>
        <p class="pdf-text">{{ exportRecord.dietNotes }}</p>
      </div>

      <div class="pdf-section" v-if="exportRecord.summary">
        <h2>健康总结</h2>
        <p class="pdf-text">{{ exportRecord.summary }}</p>
      </div>

      <div class="pdf-section" v-if="exportRecord.suggestions && exportRecord.suggestions.length > 0">
        <h2>个性化建议</h2>
        <div class="pdf-suggestions">
          <div v-for="(sug, idx) in exportRecord.suggestions" :key="idx" class="pdf-suggestion-item">
            <strong>{{ sug.title }}：</strong>{{ sug.content }}
          </div>
        </div>
      </div>

      <div class="pdf-section" v-if="exportRecord.tomorrowPlan">
        <h2>明日养生方案</h2>
        <p class="pdf-text">{{ exportRecord.tomorrowPlan }}</p>
      </div>

      <div class="pdf-footer">
        <p>导出时间：{{ new Date().toLocaleString('zh-CN') }}</p>
        <p>灵素养生健康管理系统</p>
      </div>
    </div>

    <!-- 成功提示 -->
    <div v-if="showSuccessModal" class="modal-overlay fade-in">
       <div class="modal-card glass-card text-center" @click.stop>
          <div class="icon-box xl success mb-4">
             <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
               <path :d="iconPaths.check_circle" />
             </svg>
          </div>
          <h3>记录成功</h3>
          <p class="mb-6 text-sub">
            您的健康数据已保存
          </p>
          <div class="btn-group-center">
             <button @click="closeSuccessModal" class="btn-primary">确定</button>
          </div>
       </div>
    </div>

    <!-- 删除确认弹窗 -->
    <div v-if="showDeleteConfirm" class="modal-overlay fade-in">
       <div class="modal-card glass-card text-center" @click.stop>
          <div class="icon-box xl danger mb-4">
             <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
               <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
             </svg>
          </div>
          <h3>确认删除</h3>
          <p class="mb-6 text-sub">
            确定要删除 {{ deleteTargetDate }} 的打卡记录吗？<br>
            此操作无法撤销
          </p>
          <div class="btn-group-center">
             <button @click="cancelDelete" class="btn-secondary">取消</button>
             <button @click="confirmDelete" class="btn-danger">确认删除</button>
          </div>
       </div>
    </div>

    <!-- AI生成健康报告提示 -->
    <div v-if="showAIGenerating" class="modal-overlay fade-in">
       <div class="modal-card glass-card text-center ai-generating-modal" @click.stop>
          <div class="ai-icon-wrapper">
            <div class="ai-icon-box">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>
              </svg>
            </div>
            <div class="ai-pulse-ring"></div>
            <div class="ai-pulse-ring delay-1"></div>
            <div class="ai-pulse-ring delay-2"></div>
          </div>
          <h3 class="ai-title">AI智能分析中</h3>
          <p class="ai-subtitle">
            正在为您生成个性化健康报告<br>
            <span class="ai-dots">
              <span class="dot">.</span>
              <span class="dot">.</span>
              <span class="dot">.</span>
            </span>
          </p>
          <div class="ai-progress-bar">
            <div class="ai-progress-fill"></div>
          </div>
       </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { postCheckin, getCheckinSummary, deleteCheckinById } from '../services/api';

defineOptions({ name: 'CheckinView' });

// 类型定义
interface HealthTrend {
  id?: number;
  date: string;
  healthScore: number;
  summary?: string;
  sleepHours?: number;
  sleepTime?: string;
  symptoms?: string[];
  mood?: number;
  exerciseMinutes?: number;
  dietNotes?: string;
  createdAt?: string;
  suggestions?: Suggestion[];
  risks?: Array<{ level: string; content: string }>;
  tomorrowPlan?: string;
  tomorrowTasks?: string[];
}

interface Suggestion {
  icon: string;
  title: string;
  content: string;
}

interface AnalysisResult {
  summary: string;
  suggestions: Suggestion[];
  healthScore?: number;
  tomorrowPlan: string;
  tomorrowTasks?: string[];
  risks?: Array<{ level: string; content: string }>;
}

const router = useRouter();

// 状态管理
const loading = ref(false);
const showResult = ref(false);
const showSuccessModal = ref(false);
const showDetailModal = ref(false);
const selectedRecord = ref<HealthTrend | null>(null);
const analysisResult = ref<AnalysisResult | null>(null);
const checkinHistory = ref<HealthTrend[]>([]);
const chartCanvas = ref<HTMLCanvasElement>();
const showDeleteConfirm = ref(false);
const deleteTargetId = ref<number | null>(null);
const deleteTargetDate = ref('');
const showExportDialog = ref(false);
const selectedExportIndex = ref<number | null>(null);
const exportRecord = ref<HealthTrend | null>(null);
const isExporting = ref(false);
const pdfContent = ref<HTMLElement>();
const showAIGenerating = ref(false);

const currentStep = ref(1);
const totalSteps = 3;

// 筛选
const showFilter = ref(false);
const filterStartDate = ref('');
const filterEndDate = ref('');
const searchKeyword = ref('');

// 记录数据
const checkinData = ref({
  sleepHours: 8,
  sleepTime: '23:00',
  symptoms: [] as string[],
  mood: 2,
  exerciseMinutes: 30,
  dietNotes: ''
});

// 选项数据
const symptoms = [
  '头痛', '疲劳', '失眠', '食欲不振', '腹胀', '便秘', '腹泻',
  '口干', '怕冷', '怕热', '出汗多', '心悸', '无症状'
];

const moods = [
  { iconKey: 'mood_very_bad', name: '很差' },
  { iconKey: 'mood_bad', name: '一般' },
  { iconKey: 'mood_normal', name: '良好' },
  { iconKey: 'mood_good', name: '很好' },
  { iconKey: 'mood_excellent', name: '极佳' }
];

// 图标路径 (SVG Paths)
const iconPaths: Record<string, string> = {
  sleep: 'M2 20h20M5 20V8h14v12M5 12h14M12 3a4 4 0 0 0-4 4h8a4 4 0 0 0-4-4z',
  sleep_moon: 'M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z',
  time: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zm0-2a8 8 0 100-16 8 8 0 000 16zm-1-8V6a1 1 0 112 0v5a1 1 0 01-1 1H7a1 1 0 110-2h4z',
  symptom: 'M14 4a2 2 0 10-4 0v9.172a3 3 0 104 0V4z M12 14a1 1 0 100 2 1 1 0 000-2z',
  exercise: 'M13.49 5.48c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm-3.6 13.9l1-4.4 2.1 2v6h2v-7.5l-2.1-2 .6-3c1.3 1.5 3.3 2.5 5.5 2.5v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1l-5.2 2.2v4.7h2v-3.4l1.8-.7-1.6 8.1-4.9-1-.4 2 7 1.4z',
  exercise_run: 'M20.38 8.57l-1.23 1.85a8 8 0 0 1-1.99 1.93l-.64 1.53L12 12v-2.7l1.7-1.12c.3-.2.5-.53.5-.88V3.25c0-.69-.56-1.25-1.25-1.25H9.05c-.69 0-1.25.56-1.25 1.25v2.85c0 .33.12.65.34.89l1.86 2.05V12l-4.52 1.65a1 1 0 0 0-.64 1.22c.1.5.54.85 1.05.85.1 0 .21-.02.32-.05L9 14.7v5.05c0 .55.45 1 1 1s1-.45 1-1v-4.4l4.2-1.5c.26-.09.49-.25.66-.46l1.54-1.93 1.28.85c.18.12.39.19.6.19.26 0 .52-.11.71-.29.39-.39.39-1.02 0-1.41z M11 5h2v2h-2V5zm10-3h-4c-.55 0-1 .45-1 1s.45 1 1 1h4c.55 0 1-.45 1-1s-.45-1-1-1zm0 3h-2c-.55 0-1 .45-1 1s.45 1 1 1h2c.55 0 1-.45 1-1s-.45-1-1-1z',
  diet: 'M8.5 4a.5.5 0 01.5.5v2a.5.5 0 01-.5.5H8a.5.5 0 00-.5.5v11a.5.5 0 00.5.5h1a.5.5 0 00.5-.5v-11a.5.5 0 00-.5-.5H13a.5.5 0 01-.5-.5v-2a.5.5 0 01.5-.5h2a.5.5 0 01.5.5v2a.5.5 0 01-.5.5h-.5a.5.5 0 00-.5.5v11a.5.5 0 00.5.5h1a.5.5 0 00.5-.5v-11a.5.5 0 00-.5-.5H13a.5.5 0 01-.5-.5v-2a.5.5 0 01.5-.5h2z',
  calendar: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  check_circle: 'M22 11.08V12a10 10 0 1 1-5.93-9.14M22 4L12 14.01l-3-3',
  bulb: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z',
  chart: 'M18 20V10M12 20V4M6 20v-6',
  target: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zm0-2a8 8 0 100-16 8 8 0 000 16zm0-4a4 4 0 100-8 4 4 0 000 8z',
  warning: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
  
  // Section Icons
  mood_status: 'M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z M3.5 12h3l2 3 2-6 2 3h3',
  exercise_time: 'M13.5 5.5c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zM9.8 8.9L7 23h2.1l1.8-8 2.1 2v6h2v-7.5l-2.1-2 .6-3c1.3 1.5 3.3 2.5 5.5 2.5v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1L6 8.3V13h2V9.6l1.8-.7zM22 12c0 5.52-4.48 10-10 10S2 17.52 2 12h2c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8V2c5.52 0 10 4.48 10 10z',

  // Mood Icons (Redesigned)
  mood_very_bad: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M9 16c1.5-1.5 4.5-1.5 6 0 M9 9h.01 M15 9h.01',
  mood_bad: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M9 15c1.5-1 4.5-1 6 0 M9 9h.01 M15 9h.01',
  mood_normal: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M9 14h6 M9 9h.01 M15 9h.01',
  mood_good: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M9 14c1.5 1 4.5 1 6 0 M9 9h.01 M15 9h.01',
  mood_excellent: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M8 14s1.5 2 4 2 4-2 4-2 M9 9h.01 M15 9h.01',
};

// Computed
const isFormValid = computed(() => {
  return checkinData.value.sleepTime &&
         checkinData.value.sleepHours > 0 &&
         checkinData.value.mood !== null;
});

const isCurrentStepValid = computed(() => {
  switch (currentStep.value) {
    case 1:
      return !!(checkinData.value.sleepTime && checkinData.value.sleepHours > 0);
    case 2:
      return checkinData.value.mood !== null;
    case 3:
      return true;
    default:
      return false;
  }
});

const filteredHistory = computed(() => {
  let filtered = [...checkinHistory.value];
  if (filterStartDate.value) filtered = filtered.filter(r => r.date >= filterStartDate.value);
  if (filterEndDate.value) filtered = filtered.filter(r => r.date <= filterEndDate.value);
  
  if (searchKeyword.value) {
    const k = searchKeyword.value.toLowerCase();
    filtered = filtered.filter(r => 
      (r.dietNotes && r.dietNotes.toLowerCase().includes(k)) ||
      (r.summary && r.summary.toLowerCase().includes(k)) ||
      (r.symptoms && r.symptoms.some(s => s.toLowerCase().includes(k)))
    );
  }
  
  return filtered;
});

// Helper Functions
const getMoodInfo = (index: number | undefined) => {
  const i = index ?? 2;
  return moods[i] || moods[2] || { iconKey: 'mood_normal', name: '良好' };
};

const getScoreClass = (score: number) => {
  if (!score) return 'bg-gray';
  if (score >= 85) return 'bg-success';
  if (score >= 70) return 'bg-primary';
  if (score >= 60) return 'bg-warning';
  return 'bg-danger';
};

const formatDateShort = (dateStr: string) => {
  const d = new Date(dateStr);
  return `${d.getMonth() + 1}/${d.getDate()}`;
};

const formatDateFull = (dateStr: string) => {
  const d = new Date(dateStr);
  const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 ${weekdays[d.getDay()]}`;
};

const getCurrentDate = () => {
  return new Date().toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  });
};

const formatTime = (date: Date) => date.toLocaleString('zh-CN');

const sanitizeText = (text: string) => {
  return text
    .replace(/\*\*/g, '')
    .replace(/^\s*[*•-]\s*/gm, '');
};

const buildTodaySummary = (data: typeof checkinData.value) => {
  const mood = getMoodInfo(data.mood).name;
  const symptomText = data.symptoms.length ? `症状：${data.symptoms.join('、')}` : '无明显不适';
  const dietText = data.dietNotes ? '已记录饮食' : '饮食待记录';
  return `今日睡眠${data.sleepHours}小时，入睡${data.sleepTime}，情绪${mood}，运动${data.exerciseMinutes}分钟，${symptomText}，${dietText}。`;
};

const buildTomorrowPlan = (data: typeof checkinData.value) => {
  const hints: string[] = [];
  if (data.sleepHours < 7) hints.push('今晚提前入睡，保证7小时以上睡眠');
  if (data.exerciseMinutes < 30) hints.push('安排20-30分钟轻量运动');
  if (data.symptoms.includes('失眠')) hints.push('睡前放松，减少电子屏幕使用');
  if (!data.dietNotes) hints.push('明日三餐清淡并记录饮食');
  if (!hints.length) hints.push('保持当前节奏，适度运动与清淡饮食');
  return hints.join('，') + '。';
};

const buildTomorrowTasks = (data: typeof checkinData.value) => {
  const tasks: string[] = [];
  if (data.sleepHours < 7) tasks.push('今晚提前入睡，保证7小时以上睡眠');
  if (data.exerciseMinutes < 30) tasks.push('安排轻量运动20-30分钟');
  if (data.symptoms.includes('便秘')) tasks.push('增加膳食纤维与饮水量');
  if (data.symptoms.includes('失眠')) tasks.push('睡前热水泡脚10分钟');
  if (!data.dietNotes) tasks.push('明日记录三餐，优先清淡少油');
  if (!tasks.length) tasks.push('保持规律作息与适度拉伸放松');
  return tasks.slice(0, 4);
};

const buildFallbackSuggestions = (data: typeof checkinData.value): Suggestion[] => {
  const suggestions: Suggestion[] = [];
  if (data.sleepHours < 7) {
    suggestions.push({
      icon: '',
      title: '睡眠优化',
      content: '睡前减少刺激性内容，提前30分钟上床，提升恢复质量。'
    });
  }
  if (data.exerciseMinutes < 30) {
    suggestions.push({
      icon: '',
      title: '运动建议',
      content: '选择快走或舒缓拉伸，坚持20-30分钟。'
    });
  }
  if (!data.dietNotes) {
    suggestions.push({
      icon: '',
      title: '饮食记录',
      content: '明日三餐尽量清淡，记下主食与蔬菜比例。'
    });
  }
  if (!suggestions.length) {
    suggestions.push({
      icon: '',
      title: '保持状态',
      content: '继续维持良好作息与适度运动，关注身体反馈。'
    });
  }
  return suggestions.slice(0, 3);
};

// Actions
const goHome = () => router.push('/dashboard');

const toggleSymptom = (symptom: string) => {
  const index = checkinData.value.symptoms.indexOf(symptom);
  if (index > -1) {
    checkinData.value.symptoms.splice(index, 1);
  } else {
    checkinData.value.symptoms.push(symptom);
  }
};

const adjustExercise = (amount: number) => {
  const val = checkinData.value.exerciseMinutes + amount;
  if (val >= 0 && val <= 300) checkinData.value.exerciseMinutes = val;
};

const goToStep = (step: number) => {
  if (step < currentStep.value) {
    currentStep.value = step;
  } else if (step > currentStep.value && isCurrentStepValid.value) {
    currentStep.value = step;
  }
};

const nextStep = () => {
  if (isCurrentStepValid.value && currentStep.value < totalSteps) {
    currentStep.value++;
  }
};

const prevStep = () => {
  if (currentStep.value > 1) currentStep.value--;
};

// Data Loading & Submission
onMounted(async () => {
  // 移除打卡检查，允许多次打卡
  await loadCheckinHistory();
});

const loadCheckinHistory = async () => {
  try {
    const res = await getCheckinSummary(7);
    checkinHistory.value = res.history || [];
  } catch (e) {
    console.error('Failed to load history', e);
  }
};

// 删除打卡记录
const deleteCheckinRecord = async (record: HealthTrend) => {
  if (!record.id) {
    alert('无法删除：记录ID不存在');
    return;
  }
  deleteTargetId.value = record.id;
  deleteTargetDate.value = record.date;
  showDeleteConfirm.value = true;
};

const confirmDelete = async () => {
  if (deleteTargetId.value === null) {
    alert('删除失败：记录ID不存在');
    return;
  }
  
  try {
    loading.value = true;
    showDeleteConfirm.value = false;
    console.log('准备删除记录ID:', deleteTargetId.value);
    const response = await deleteCheckinById(deleteTargetId.value);
    console.log('删除响应:', response);
    
    if (response.success) {
      await loadCheckinHistory();
      console.log('历史记录已刷新');
    } else {
      alert(`删除失败: ${response.message}`);
    }
  } catch (e) {
    const error = e as { response?: { data?: { message?: string } }; message?: string };
    console.error('删除失败，错误对象:', error);
    console.error('错误响应:', error.response?.data);
    alert(`删除失败: ${error.response?.data?.message || error.message || '请稍后重试'}`);
  } finally {
    loading.value = false;
    deleteTargetId.value = null;
    deleteTargetDate.value = '';
  }
};

const cancelDelete = () => {
  showDeleteConfirm.value = false;
  deleteTargetId.value = null;
  deleteTargetDate.value = '';
};

const submitCheckin = async () => {
  if (!isFormValid.value || loading.value) return;
  loading.value = true;
  showAIGenerating.value = true; // 显示AI生成提示
  
  try {
    const submitData = {
      ...checkinData.value,
      sleepHours: Number(checkinData.value.sleepHours),
      mood: Number(checkinData.value.mood),
      exerciseMinutes: Number(checkinData.value.exerciseMinutes),
      date: new Date().toISOString().split('T')[0]
    };
    
    // 直接提交，不再区分编辑模式
    const response = await postCheckin(submitData);

    if (response.success) {
      // 隐藏AI生成提示
      showAIGenerating.value = false;
      
      const fallbackSummary = buildTodaySummary(submitData);
      const fallbackTomorrowPlan = buildTomorrowPlan(submitData);
      const fallbackTomorrowTasks = buildTomorrowTasks(submitData);
      const fallbackSuggestions = buildFallbackSuggestions(submitData);
      
      analysisResult.value = {
        summary: response.summary || fallbackSummary,
        suggestions: response.suggestions?.length ? response.suggestions : fallbackSuggestions,
        healthScore: response.healthScore,
        tomorrowPlan: response.tomorrowPlan || fallbackTomorrowPlan,
        tomorrowTasks: response.tomorrowTasks?.length ? response.tomorrowTasks : fallbackTomorrowTasks,
        risks: response.risks || []
      };
      
      // 先刷新历史记录，再显示结果页面
      await loadCheckinHistory();
      showResult.value = true;
      showSuccessModal.value = true;
    } else {
      showAIGenerating.value = false;
      alert(response.message || '提交失败');
    }
  } catch (e) {
    console.error(e);
    showAIGenerating.value = false;
    alert('网络错误');
  } finally {
    loading.value = false;
  }
};

const resetForm = () => {
  showResult.value = false;
  currentStep.value = 1;
  checkinData.value = {
    sleepHours: 8,
    sleepTime: '23:00',
    symptoms: [],
    mood: 2,
    exerciseMinutes: 30,
    dietNotes: ''
  };
};

const closeSuccessModal = async () => {
  showSuccessModal.value = false;
};

// Detail Modal
const openDetailModal = (record: HealthTrend) => {
  selectedRecord.value = record;
  showDetailModal.value = true;
};
const closeDetailModal = () => showDetailModal.value = false;

// Filter
const toggleFilter = () => showFilter.value = !showFilter.value;
const clearFilter = () => {
  filterStartDate.value = '';
  filterEndDate.value = '';
  searchKeyword.value = '';
};
const applyFilter = () => showFilter.value = false;

// Export
const openExportDialog = () => {
  selectedExportIndex.value = null;
  exportRecord.value = null;
  showExportDialog.value = true;
};

const closeExportDialog = () => {
  showExportDialog.value = false;
  selectedExportIndex.value = null;
  exportRecord.value = null;
};

const exportToPDF = async () => {
  if (selectedExportIndex.value === null) {
    alert('请选择要导出的记录');
    return;
  }

  isExporting.value = true;
  
  try {
    // 找到选中的记录
    const record = filteredHistory.value[selectedExportIndex.value];
    if (!record) {
      alert('未找到选中的记录');
      return;
    }

    exportRecord.value = record;
    
    // 等待DOM更新
    await nextTick();
    await new Promise(resolve => setTimeout(resolve, 100));

    if (!pdfContent.value) {
      alert('PDF内容未加载');
      return;
    }

    // 动态导入库
    const html2canvas = (await import('html2canvas')).default;
    const { jsPDF } = await import('jspdf');

    // 生成canvas
    const canvas = await html2canvas(pdfContent.value, {
      scale: 2,
      useCORS: true,
      logging: false,
      backgroundColor: '#ffffff'
    });

    // 创建PDF
    const imgWidth = 210; // A4宽度(mm)
    const imgHeight = (canvas.height * imgWidth) / canvas.width;
    const pdf = new jsPDF('p', 'mm', 'a4');
    
    const imgData = canvas.toDataURL('image/png');
    pdf.addImage(imgData, 'PNG', 0, 0, imgWidth, imgHeight);

    // 下载PDF
    const fileName = `健康打卡记录_${record.date}.pdf`;
    pdf.save(fileName);

    closeExportDialog();
    alert('导出成功！');
  } catch (error) {
    console.error('导出失败:', error);
    alert('导出失败，请重试');
  } finally {
    isExporting.value = false;
    exportRecord.value = null;
  }
};

// Chart drawing logic
watch(showResult, (val) => {
  if (val) nextTick(() => drawHealthChart());
});

// 监听历史数据变化，自动重绘图表
watch(checkinHistory, () => {
  if (showResult.value) {
    nextTick(() => drawHealthChart());
  }
}, { deep: true });

const drawHealthChart = async () => {
  if (!chartCanvas.value) return;
  const ctx = chartCanvas.value.getContext('2d');
  if (!ctx) return;
  
  const canvas = chartCanvas.value;
  const width = canvas.width;
  const height = canvas.height;
  
  // 清空画布
  ctx.clearRect(0, 0, width, height);
  
  // 获取最近7天的数据
  const recentData = checkinHistory.value.slice(0, 7).reverse();
  if (recentData.length === 0) return;
  
  // 设置样式
  const padding = 40;
  const chartWidth = width - padding * 2;
  const chartHeight = height - padding * 2;
  
  // 绘制背景网格
  ctx.strokeStyle = '#e2e8f0';
  ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = padding + (chartHeight / 4) * i;
    ctx.beginPath();
    ctx.moveTo(padding, y);
    ctx.lineTo(width - padding, y);
    ctx.stroke();
  }
  
  // 绘制Y轴标签（健康分）
  ctx.fillStyle = '#64748b';
  ctx.font = '12px sans-serif';
  ctx.textAlign = 'right';
  for (let i = 0; i <= 4; i++) {
    const score = 100 - (i * 25);
    const y = padding + (chartHeight / 4) * i;
    ctx.fillText(score.toString(), padding - 10, y + 4);
  }
  
  // 计算数据点位置
  const points: Array<{x: number, y: number, score: number, date: string}> = [];
  const step = chartWidth / Math.max(recentData.length - 1, 1);
  
  recentData.forEach((item, index) => {
    const score = item.healthScore || 0;
    const x = padding + step * index;
    const y = padding + chartHeight - (score / 100) * chartHeight;
    points.push({ x, y, score, date: item.date });
  });
  
  // 绘制渐变区域
  if (points.length > 1) {
    const gradient = ctx.createLinearGradient(0, padding, 0, height - padding);
    gradient.addColorStop(0, 'rgba(16, 185, 129, 0.2)');
    gradient.addColorStop(1, 'rgba(16, 185, 129, 0.0)');
    
    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.moveTo(points[0]!.x, height - padding);
    points.forEach(point => {
      ctx.lineTo(point.x, point.y);
    });
    ctx.lineTo(points[points.length - 1]!.x, height - padding);
    ctx.closePath();
    ctx.fill();
  }
  
  // 绘制折线
  if (points.length > 0) {
    ctx.strokeStyle = '#10b981';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(points[0]!.x, points[0]!.y);
    points.forEach(point => {
      ctx.lineTo(point.x, point.y);
    });
    ctx.stroke();
  }
  
  // 绘制数据点
  points.forEach(point => {
    // 外圈
    ctx.fillStyle = '#ffffff';
    ctx.beginPath();
    ctx.arc(point.x, point.y, 6, 0, Math.PI * 2);
    ctx.fill();
    
    // 内圈
    ctx.fillStyle = '#10b981';
    ctx.beginPath();
    ctx.arc(point.x, point.y, 4, 0, Math.PI * 2);
    ctx.fill();
  });
  
  // 绘制X轴日期标签
  ctx.fillStyle = '#64748b';
  ctx.font = '11px sans-serif';
  ctx.textAlign = 'center';
  points.forEach(point => {
    const dateStr = formatDateShort(point.date);
    ctx.fillText(dateStr, point.x, height - padding + 20);
  });
};

</script>

<style scoped>
:root {
  --primary: #10b981;
  --primary-hover: #059669;
  --bg-color: #f0fdf4;
  --text-main: #1e293b;
  --text-sub: #64748b;
  --glass-bg: rgba(255, 255, 255, 0.7);
  --glass-border: rgba(255, 255, 255, 0.5);
  --glass-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
}

.checkin-container {
  min-height: 100vh;
  background-color: #f0fdf4;
  padding: 24px;
  position: relative;
  overflow-x: hidden;
  font-family: 'Segoe UI', system-ui, sans-serif;
  color: #1e293b;
}

/* Background Decorations */
.bg-decoration {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  z-index: 0;
}
.top-right {
  top: -100px;
  right: -100px;
  width: 400px;
  height: 400px;
  background: rgba(16, 185, 129, 0.15);
}
.bottom-left {
  bottom: -100px;
  left: -100px;
  width: 300px;
  height: 300px;
  background: rgba(59, 130, 246, 0.1);
}

/* Header */
.nav-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  position: relative;
  z-index: 10;
}
.page-title h1 {
  font-size: 28px;
  font-weight: 800;
  margin: 0;
  color: #064e3b;
}
.page-title p {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 14px;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  color: #64748b;
}
.back-btn:hover {
  background: #f8fafc;
  color: #10b981;
}
.back-icon { width: 20px; height: 20px; }

/* Main Content Layout */
.main-content {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 24px;
  position: relative;
  z-index: 10;
  max-width: 1200px;
  margin: 0 auto;
}

@media (max-width: 900px) {
  .main-content { grid-template-columns: 1fr; }
}

/* Glass Card Style */
.glass-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
  border-radius: 24px;
  padding: 32px;
  min-height: 800px; /* 设置最小高度，防止内容切换时页面跳动 */
}

/* Form Panel */
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}
.panel-header h2 { margin: 0; font-size: 20px; color: #1e293b; }
.date-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #64748b;
  background: #f1f5f9;
  padding: 4px 12px;
  border-radius: 20px;
  margin-top: 4px;
}
.date-badge svg { width: 14px; height: 14px; }

/* Stepper */
.stepper {
  display: flex;
  justify-content: space-between;
  margin-bottom: 40px;
  position: relative;
}
.step-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  cursor: pointer;
  opacity: 0.5;
  transition: all 0.3s;
}
.step-item.active, .step-item.completed { opacity: 1; }
.step-circle {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: white;
  border: 2px solid #e2e8f0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  margin-bottom: 8px;
  z-index: 2;
  transition: all 0.3s;
}
.step-item.active .step-circle {
  border-color: #10b981;
  background: #ecfdf5;
  color: #10b981;
  transform: scale(1.1);
}
.step-item.completed .step-circle {
  background: #10b981;
  border-color: #10b981;
  color: white;
}
.step-line {
  position: absolute;
  top: 18px;
  left: 50%;
  width: 100%;
  height: 2px;
  background: #e2e8f0;
  z-index: 1;
}
.step-item.completed .step-line { background: #10b981; }

/* Form Controls */
.form-group { margin-bottom: 32px; }
.input-label {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  font-weight: 600;
  color: #334155;
}
.icon-box.sm {
  width: 28px; height: 28px;
  background: #e0f2fe;
  color: #0284c7;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.icon-box.sm svg { width: 16px; height: 16px; }
.required { color: #ef4444; margin-left: 4px; }

/* Exercise Icon Animation */
.exercise-icon-box {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.exercise-icon-box:hover {
  background: #dbeafe;
  color: #2563eb;
  transform: scale(1.1) rotate(-5deg);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.exercise-icon-box:active {
  transform: scale(0.95);
  background: #bfdbfe;
}

/* Custom Inputs */
.slider-wrapper { padding: 0 10px; }
.slider-value { text-align: center; font-size: 24px; font-weight: 700; color: #10b981; margin-bottom: 12px; }
.custom-slider {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: #e2e8f0;
  background-image: linear-gradient(#10b981, #10b981);
  background-repeat: no-repeat;
  appearance: none;
}
.custom-slider::-webkit-slider-thumb {
  appearance: none;
  width: 20px; height: 20px;
  border-radius: 50%;
  background: white;
  border: 2px solid #10b981;
  cursor: pointer;
  box-shadow: 0 2px 6px rgba(0,0,0,0.1);
}

/* Custom Inputs */
.custom-input {
  padding: 10px 16px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  outline: none;
  transition: all 0.2s;
  font-family: inherit;
  width: 100%;
  font-size: 14px;
  color: #334155;
  background: white;
}
.custom-input:focus {
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}
.custom-input.sm {
  padding: 8px 12px;
  font-size: 13px;
}
.time-input {
  font-size: 24px;
  font-weight: 700;
  color: #334155;
  text-align: center;
  width: auto;
  min-width: 140px;
  background: #f8fafc;
  letter-spacing: 1px;
}

.tags-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}
.tag-item {
  padding: 8px 16px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}
.tag-item:hover { border-color: #10b981; color: #10b981; }
.tag-item.active { background: #10b981; color: white; border-color: #10b981; }

.counter-input {
  display: flex;
  align-items: center;
  gap: 16px;
}
.counter-btn {
  width: 40px; height: 40px;
  border-radius: 12px;
  border: none;
  background: #f1f5f9;
  font-size: 20px;
  cursor: pointer;
  transition: all 0.2s;
}
.counter-btn:hover { background: #e2e8f0; }
.counter-display {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.counter-display input {
  width: 60px;
  border: none;
  text-align: center;
  font-size: 18px;
  font-weight: 600;
  outline: none;
}

.custom-textarea {
  width: 100%;
  min-height: 120px;
  padding: 16px;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  outline: none;
  resize: none;
  font-family: inherit;
  transition: all 0.3s;
}
.custom-textarea:focus { border-color: #10b981; box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1); }

/* Buttons */
.form-footer {
  display: flex;
  align-items: center;
  margin-top: 40px;
}
.spacer { flex: 1; }
.btn-primary {
  background: #10b981;
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2);
}
.btn-primary:hover:not(:disabled) {
  background: #059669;
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.3);
}
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }

.btn-secondary {
  background: transparent;
  border: 1px solid #cbd5e1;
  color: #64748b;
  padding: 12px 24px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-secondary:hover { background: #f8fafc; color: #334155; }

.text-btn {
  background: transparent;
  border: 1px solid #e2e8f0;
  color: #64748b;
  padding: 8px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}
.text-btn:hover {
  background: #f8fafc;
  color: #334155;
  border-color: #cbd5e1;
}
.text-btn:active {
  transform: scale(0.98);
}

.btn-primary.sm,
.btn-secondary.sm {
  padding: 8px 20px;
  font-size: 14px;
}

/* History Panel */
.history-panel .panel-header h3 { font-size: 20px; margin: 0; font-weight: 600; color: #1e293b; }
.icon-btn {
  background: white;
  border: 1px solid #e2e8f0;
  padding: 8px;
  border-radius: 12px;
  cursor: pointer;
  color: #64748b;
  transition: all 0.2s;
}
.icon-btn:hover, .icon-btn.active { background: #f1f5f9; color: #10b981; border-color: #10b981; }
.icon-btn svg { width: 20px; height: 20px; }

/* Filter Panel */
.filter-panel {
  background: #f8fafc;
  border-radius: 16px;
  padding: 20px;
  margin-top: 16px;
  margin-bottom: 16px;
  border: 1px solid #e2e8f0;
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.filter-row:last-child {
  margin-bottom: 0;
}

.filter-row.actions {
  justify-content: flex-end;
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #e2e8f0;
}

.filter-row span {
  color: #64748b;
  font-size: 14px;
}

.custom-input.sm {
  padding: 8px 12px;
  font-size: 14px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  outline: none;
  transition: all 0.2s;
}

.custom-input.sm:focus {
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 24px;
}
.history-card {
  background: white;
  border-radius: 24px;
  padding: 24px;
  padding-right: 50px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  position: relative;
}
.history-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border-color: #10b981;
}

.delete-btn {
  position: absolute;
  top: 50%;
  right: 16px;
  transform: translateY(-50%);
  width: 36px;
  height: 36px;
  border: none;
  background: #fee2e2;
  color: #ef4444;
  border-radius: 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all 0.2s;
  z-index: 10;
}

.delete-btn svg {
  width: 18px;
  height: 18px;
}

.history-card:hover .delete-btn {
  opacity: 1;
}

.delete-btn:hover {
  background: #ef4444;
  color: white;
  transform: translateY(-50%) scale(1.1);
}

.card-left { display: flex; align-items: center; gap: 16px; }
.record-date { font-weight: 600; color: #334155; font-size: 16px; }
.record-mood svg { width: 32px; height: 32px; color: #64748b; }
.card-right { text-align: right; }
.score-tag {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 6px;
}

.mini-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #64748b;
  margin-left: 12px;
  background: #f1f5f9;
  padding: 4px 8px;
  border-radius: 6px;
}
.mini-tag svg { width: 14px; height: 14px; }

/* Result View */
.result-view {
  width: 100%;
}
.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  background: white;
  padding: 32px;
  border-radius: 24px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}
.title-group { display: flex; align-items: center; gap: 20px; }
.icon-box.success { background: #dcfce7; color: #15803d; }
.icon-box.danger { background: #fee2e2; color: #dc2626; }
.icon-box.xl { width: 72px; height: 72px; border-radius: 24px; }
.icon-box.xl svg { width: 36px; height: 36px; }

.btn-danger {
  background: #ef4444;
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.2);
}
.btn-danger:hover:not(:disabled) {
  background: #dc2626;
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(239, 68, 68, 0.3);
}
.btn-danger:disabled { opacity: 0.6; cursor: not-allowed; }

.score-circle {
  width: 96px; height: 96px;
  border-radius: 50%;
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
  border: 4px solid #ecfdf5;
}
.score-val { font-size: 32px; font-weight: 800; line-height: 1; }
.score-lbl { font-size: 12px; opacity: 0.9; }

.info-section {
  background: white;
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 32px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}
.info-section:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}
.info-section.primary { border-top: 4px solid #10b981; }
.info-section.danger { border-top: 4px solid #ef4444; background: #fff1f2; }
.info-section h3 {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0 0 20px 0;
  font-size: 18px;
  color: #1e293b;
  font-weight: 600;
}
.info-section h3 svg { width: 24px; height: 24px; color: #10b981; }

.chart-box {
  background: white;
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 32px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}
.chart-box h3 {
  margin: 0 0 24px 0;
  font-size: 18px;
  color: #1e293b;
  font-weight: 600;
}
.chart-box canvas {
  width: 100%;
  height: auto;
  display: block;
}

/* Modals */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal-card {
  background: white;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.close-btn {
  background: none; border: none; font-size: 24px; cursor: pointer; color: #94a3b8;
}

/* Utils */
.fade-in { animation: fadeIn 0.4s ease; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
.text-center { text-align: center; }
.btn-group-center { display: flex; justify-content: center; gap: 16px; }
.mb-2 { margin-bottom: 8px; }
.mb-4 { margin-bottom: 16px; }
.mb-6 { margin-bottom: 24px; }

/* ========== 图标优化样式 ========== */

/* 情绪状态选择器 - 简约风格 */
.mood-selector {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 8px;
  margin-top: 24px;
}

.mood-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 16px 8px;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: transparent;
  border: 2px solid transparent;
}

.mood-item:hover {
  background: rgba(255, 255, 255, 0.6);
  transform: translateY(-4px);
}

.mood-item.active {
  background: #ecfdf5;
  border-color: #10b981;
}

.mood-icon {
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: white;
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
  color: #94a3b8;
}

.mood-icon svg {
  width: 32px;
  height: 32px;
  stroke-width: 1.5;
  transition: all 0.3s ease;
  stroke: #94a3b8;
  fill: none;
}

/* 选中状态 */
.mood-item.active .mood-icon {
  background: #10b981;
  border-color: #10b981;
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
  transform: scale(1.1);
}

.mood-item.active .mood-icon svg {
  stroke: white;
  stroke-width: 2;
}

.mood-name {
  font-size: 14px;
  font-weight: 500;
  color: #64748b;
  transition: all 0.2s;
}

.mood-item.active .mood-name {
  color: #10b981;
  font-weight: 600;
}


/* 图标盒子样式 - 增强版 */
.icon-box {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ECFDF5 0%, #D1FAE5 100%);
  border-radius: 12px;
  flex-shrink: 0;
  transition: all 0.3s;
  box-shadow: 0 2px 4px rgba(16, 185, 129, 0.1);
}

.icon-box svg {
  width: 24px;
  height: 24px;
  stroke: #10B981;
  stroke-width: 2;
  transition: all 0.3s;
}

.icon-box:hover {
  transform: scale(1.1) rotate(5deg);
  box-shadow: 0 4px 8px rgba(16, 185, 129, 0.2);
}

/* 运动时长图标特殊样式 */
.form-group:has(.counter-input) .icon-box {
  background: linear-gradient(135deg, #EFF6FF 0%, #DBEAFE 100%);
  box-shadow: 0 2px 4px rgba(59, 130, 246, 0.1);
}

.form-group:has(.counter-input) .icon-box svg {
  stroke: #3B82F6;
}

.form-group:has(.counter-input) .icon-box:hover {
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.2);
}

/* 情绪状态标签图标样式 */
.form-group:has(.mood-selector) .icon-box {
  background: linear-gradient(135deg, #FEF2F2 0%, #FEE2E2 100%);
  box-shadow: 0 2px 4px rgba(239, 68, 68, 0.1);
}

.form-group:has(.mood-selector) .icon-box svg {
  stroke: #EF4444;
}

.form-group:has(.mood-selector) .icon-box:hover {
  box-shadow: 0 4px 8px rgba(239, 68, 68, 0.2);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .mood-selector {
    gap: 8px;
    padding: 12px;
    overflow-x: auto;
    padding-bottom: 16px; /* Space for scrollbar if needed */
  }
  
  .mood-item {
    min-width: 70px; /* Ensure items don't get too small */
    padding: 12px 6px;
  }
  
  .mood-icon {
    width: 44px;
    height: 44px;
  }
  
  .mood-name {
    font-size: 12px;
  }
  
  .icon-box {
    width: 36px;
    height: 36px;
  }
  
  .icon-box svg {
    width: 20px;
    height: 20px;
  }
}

@media (max-width: 480px) {
  .mood-item {
    padding: 10px 4px;
  }
  
  .mood-icon {
    width: 40px;
    height: 40px;
  }
}

/* 动画效果 */
@keyframes moodPulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.mood-item.active .mood-icon {
  animation: moodPulse 2s ease-in-out infinite;
}

/* 无障碍支持 */
.mood-item:focus {
  outline: 2px solid #10B981;
  outline-offset: 2px;
}

.mood-item:focus-visible {
  box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.2);
}

/* 深色模式支持 */
@media (prefers-color-scheme: dark) {
  /* 适配暗色模式，但保持原有浅色主题的一致性，或者可以简单适配 */
  /* 目前Checkin页面主要基于浅色设计，这里做简单适配 */
}

/* Analysis Result & Modal Styles */
.risk-list { list-style: none; padding: 0; margin: 0; }
.risk-list li { display: flex; align-items: flex-start; gap: 8px; margin-bottom: 8px; font-size: 14px; color: #475569; }
.risk-badge {
  font-size: 11px; padding: 2px 6px; border-radius: 4px;
  background: #fee2e2; color: #ef4444; font-weight: 600;
  flex-shrink: 0;
}
.risk-badge.high { background: #ef4444; color: white; }
.risk-badge.medium { background: #fee2e2; color: #b91c1c; }

.suggestion-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
.sug-card { background: #f8fafc; padding: 16px; border-radius: 12px; border: 1px solid #e2e8f0; }
.sug-card h4 { margin: 0 0 8px 0; font-size: 15px; color: #1e293b; }
.sug-card p { margin: 0; font-size: 13px; color: #64748b; line-height: 1.5; }

.task-list { list-style: none; padding: 0; margin: 0; }
.task-list li { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; font-size: 15px; color: #334155; }
.task-num {
  width: 24px; height: 24px; background: #fff7ed; color: #f97316;
  border-radius: 50%; display: flex; align-items: center; justify-content: center;
  font-weight: 600; font-size: 13px; border: 1px solid #ffedd5;
}

/* Modal Specific */
.detail-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin: 20px 0;
}
.detail-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 12px;
  text-align: center;
}
.detail-item .icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
  color: #64748b;
}
.detail-item .icon svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}
.detail-item span:last-child {
  font-size: 13px;
  color: #334155;
  font-weight: 500;
}

.modal-content .value.highlight {
  font-size: 32px;
  font-weight: 800;
  color: #10b981;
  display: block;
  text-align: center;
  margin: 10px 0;
}
.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #f1f5f9;
}
.detail-row:last-child { border-bottom: none; }

.detail-section { margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; }
.detail-section h4 { margin: 0 0 12px 0; font-size: 15px; color: #64748b; }
.highlight-section { background: #f0fdf4; padding: 16px; border-radius: 12px; border: none; }
.highlight-section h4 { color: #10b981; }

.mini-suggestions { display: flex; flex-direction: column; gap: 12px; }
.mini-sug-item { background: #f8fafc; padding: 12px; border-radius: 8px; }
.mini-sug-item strong { display: block; font-size: 14px; color: #334155; margin-bottom: 4px; }
.mini-sug-item p { margin: 0; font-size: 13px; color: #64748b; }

/* 导出对话框样式 */
.export-dialog { max-width: 600px; max-height: 80vh; }
.export-body { padding: 24px; max-height: 60vh; overflow-y: auto; }
.export-hint { margin: 0 0 16px 0; color: #64748b; font-size: 14px; }
.export-list { display: flex; flex-direction: column; gap: 12px; }

.export-item {
  display: flex;
  align-items: center;
  padding: 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  background: white;
}

.export-item:hover { border-color: #10b981; background: #f0fdf4; }
.export-item.selected { border-color: #10b981; background: #f0fdf4; }

.export-radio { display: none; }

.export-item-content { flex: 1; }

.export-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.export-date { font-weight: 600; color: #1e293b; font-size: 15px; }

.export-score {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  color: white;
}

.export-item-info {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.info-tag {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #64748b;
}

.info-tag svg { width: 14px; height: 14px; }

.export-check {
  width: 24px;
  height: 24px;
  border: 2px solid #e2e8f0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: 12px;
  transition: all 0.2s;
}

.export-item.selected .export-check {
  border-color: #10b981;
  background: #10b981;
}

.export-check svg {
  width: 16px;
  height: 16px;
  stroke: white;
}

/* PDF内容样式（隐藏但用于生成） */
.pdf-content {
  position: fixed;
  left: -9999px;
  top: 0;
  width: 210mm;
  background: white;
  padding: 20mm;
  font-family: 'Microsoft YaHei', 'SimSun', sans-serif;
}

.pdf-header {
  text-align: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 3px solid #10b981;
}

.pdf-header h1 {
  margin: 0 0 10px 0;
  font-size: 28px;
  color: #1e293b;
}

.pdf-date {
  margin: 0;
  font-size: 16px;
  color: #64748b;
}

.pdf-section {
  margin-bottom: 25px;
  page-break-inside: avoid;
}

.pdf-section h2 {
  margin: 0 0 15px 0;
  font-size: 18px;
  color: #10b981;
  padding-bottom: 8px;
  border-bottom: 2px solid #e2e8f0;
}

.pdf-score-box {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}

.pdf-score-circle {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 4px solid;
}

.pdf-score-circle.bg-success { border-color: #10b981; background: #f0fdf4; }
.pdf-score-circle.bg-primary { border-color: #3b82f6; background: #eff6ff; }
.pdf-score-circle.bg-warning { border-color: #f59e0b; background: #fffbeb; }
.pdf-score-circle.bg-danger { border-color: #ef4444; background: #fef2f2; }

.pdf-score-value {
  font-size: 36px;
  font-weight: bold;
  color: #1e293b;
}

.pdf-score-label {
  font-size: 14px;
  color: #64748b;
  margin-top: 4px;
}

.pdf-data-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.pdf-data-item {
  display: flex;
  justify-content: space-between;
  padding: 12px;
  background: #f8fafc;
  border-radius: 8px;
}

.pdf-label {
  font-weight: 600;
  color: #64748b;
}

.pdf-value {
  color: #1e293b;
  font-weight: 500;
}

.pdf-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.pdf-tag {
  padding: 6px 12px;
  background: #f0fdf4;
  border: 1px solid #10b981;
  border-radius: 6px;
  font-size: 14px;
  color: #10b981;
}

.pdf-text {
  line-height: 1.8;
  color: #334155;
  font-size: 14px;
  margin: 0;
  white-space: pre-wrap;
}

.pdf-suggestions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.pdf-suggestion-item {
  padding: 12px;
  background: #f8fafc;
  border-left: 4px solid #10b981;
  border-radius: 4px;
  line-height: 1.6;
  font-size: 14px;
  color: #334155;
}

.pdf-suggestion-item strong {
  color: #10b981;
}

.pdf-footer {
  margin-top: 40px;
  padding-top: 20px;
  border-top: 2px solid #e2e8f0;
  text-align: center;
  color: #94a3b8;
  font-size: 12px;
}

.pdf-footer p {
  margin: 5px 0;
}

/* AI生成提示样式 */
.ai-generating-modal {
  max-width: 450px;
  padding: 40px 30px;
}

.ai-icon-wrapper {
  position: relative;
  width: 120px;
  height: 120px;
  margin: 0 auto 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ai-icon-box {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 2;
  animation: aiPulse 2s ease-in-out infinite;
}

.ai-icon-box svg {
  width: 40px;
  height: 40px;
  stroke: white;
  stroke-width: 2.5;
}

@keyframes aiPulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.ai-pulse-ring {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80px;
  height: 80px;
  border: 3px solid #10b981;
  border-radius: 50%;
  opacity: 0;
  animation: aiRingPulse 2s ease-out infinite;
}

.ai-pulse-ring.delay-1 {
  animation-delay: 0.5s;
}

.ai-pulse-ring.delay-2 {
  animation-delay: 1s;
}

@keyframes aiRingPulse {
  0% {
    width: 80px;
    height: 80px;
    opacity: 1;
  }
  100% {
    width: 120px;
    height: 120px;
    opacity: 0;
  }
}

.ai-title {
  margin: 0 0 12px 0;
  font-size: 22px;
  color: #1e293b;
  font-weight: 600;
}

.ai-subtitle {
  margin: 0 0 24px 0;
  color: #64748b;
  font-size: 15px;
  line-height: 1.6;
}

.ai-dots {
  display: inline-block;
  margin-left: 4px;
}

.ai-dots .dot {
  animation: aiDotBlink 1.4s infinite;
  opacity: 0;
}

.ai-dots .dot:nth-child(1) {
  animation-delay: 0s;
}

.ai-dots .dot:nth-child(2) {
  animation-delay: 0.2s;
}

.ai-dots .dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes aiDotBlink {
  0%, 20% { opacity: 0; }
  50% { opacity: 1; }
  100% { opacity: 0; }
}

.ai-progress-bar {
  width: 100%;
  height: 6px;
  background: #e2e8f0;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 20px;
}

.ai-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #10b981 0%, #059669 50%, #10b981 100%);
  background-size: 200% 100%;
  animation: aiProgressMove 1.5s linear infinite;
  border-radius: 3px;
}

@keyframes aiProgressMove {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

.ai-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin: 0;
  color: #94a3b8;
  font-size: 13px;
}

.ai-hint svg {
  width: 16px;
  height: 16px;
  stroke: #94a3b8;
}

</style>
