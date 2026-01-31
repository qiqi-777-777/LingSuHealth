<template>
  <div v-if="modelValue" class="plan-modal" @click="closeModal">
    <div class="plan-modal-content" @click.stop>
      <div class="plan-panel plan-panel-modal">
        <div class="plan-panel-header">
          <div>
            <h3 class="plan-panel-title">养生计划任务</h3>
            <p class="plan-panel-subtitle">选择任务或自定义任务并完成打卡</p>
          </div>
          <div class="plan-panel-meta">
            <span>今日剩余 {{ todayRemaining }} 项</span>
            <span v-if="smsReminderEnabled" class="plan-panel-tag">短信提醒已开启</span>
            <button type="button" class="plan-modal-close" @click="closeModal">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.3 5.71 12 12l6.3 6.29-1.42 1.42L10.59 13.4l-6.3 6.3-1.42-1.42L9.17 12 2.87 5.7l1.42-1.41 6.3 6.29 6.29-6.3z"/>
              </svg>
            </button>
          </div>
        </div>
        <div class="plan-panel-grid">
          <div class="plan-panel-column">
            <div class="plan-section" v-for="section in dayPlanSections" :key="section.key">
              <div class="plan-section-header">
                <div class="plan-section-icon">
                  <svg v-if="section.key === 'morning'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M12 4v2m6.36.64-1.41 1.41M20 12h-2M6.05 6.05 4.64 4.64M6 12H4m1.64 5.36 1.41-1.41M12 20v-2m5.36-1.64 1.41 1.41"/>
                    <circle cx="12" cy="12" r="3"/>
                  </svg>
                  <svg v-else-if="section.key === 'noon'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M12 3v2m6.36.64-1.41 1.41M21 12h-2M6.05 6.05 4.64 4.64M6 12H4m1.64 5.36 1.41-1.41M12 21v-2m5.36-1.64 1.41 1.41"/>
                    <circle cx="12" cy="12" r="5"/>
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M21 12.8A9 9 0 1 1 11.2 3 7 7 0 0 0 21 12.8z"/>
                  </svg>
                </div>
                <span class="plan-section-title">{{ section.label }}</span>
              </div>
              <div class="plan-task" v-for="task in section.tasks" :key="task.id">
                <label class="task-checkbox">
                  <input type="checkbox" v-model="task.done">
                  <span class="task-checkmark"></span>
                  <span class="task-text" :class="{ 'task-completed': task.done }">{{ task.label }}</span>
                  <span v-if="task.done" class="task-done-badge">已完成</span>
                </label>
                <button v-if="task.source === 'custom'" type="button" class="task-remove" @click="removeCustomTask(section.key, task.id)">
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M18.3 5.71 12 12l6.3 6.29-1.42 1.42L10.59 13.4l-6.3 6.3-1.42-1.42L9.17 12 2.87 5.7l1.42-1.41 6.3 6.29 6.29-6.3z"/>
                  </svg>
                </button>
              </div>
            </div>

            <div class="plan-section week-plan">
              <div class="plan-section-header">
                <div class="plan-section-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M4 4h16v16H4zM8 2v4M16 2v4M4 10h16"/>
                  </svg>
                </div>
                <span class="plan-section-title">周计划</span>
              </div>
              <div class="plan-task" v-for="task in weekPlan" :key="task.id">
                <label class="task-checkbox">
                  <input type="checkbox" v-model="task.done">
                  <span class="task-checkmark"></span>
                  <span class="task-text" :class="{ 'task-completed': task.done }">{{ task.label }}</span>
                  <span v-if="task.done" class="task-done-badge">已完成</span>
                </label>
                <button v-if="task.source === 'custom'" type="button" class="task-remove" @click="removeCustomWeekTask(task.id)">
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M18.3 5.71 12 12l6.3 6.29-1.42 1.42L10.59 13.4l-6.3 6.3-1.42-1.42L9.17 12 2.87 5.7l1.42-1.41 6.3 6.29 6.29-6.3z"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>

          <div class="plan-panel-column">
            <div class="panel-card">
              <h4 class="panel-card-title">选择任务</h4>
              <div class="library-group" v-for="group in taskLibraryGroups" :key="group.key">
                <div class="library-title">{{ group.label }}</div>
                <label class="library-item" v-for="task in group.tasks" :key="task.id">
                  <input type="checkbox" :checked="isLibraryTaskSelected(task.id)" @change="toggleLibraryTask(task)">
                  <span>{{ task.label }}</span>
                </label>
              </div>
            </div>
          </div>

          <div class="plan-panel-column">
            <div class="panel-card">
              <h4 class="panel-card-title">自定义任务</h4>
              <div class="custom-row">
                <select v-model="customTaskSection" class="custom-select">
                  <option value="morning">晨</option>
                  <option value="noon">午</option>
                  <option value="night">晚</option>
                  <option value="week">周计划</option>
                </select>
                <input v-model="customTaskText" type="text" class="custom-input" placeholder="输入任务内容">
              </div>
              <button type="button" class="custom-add" @click="handleAddCustomTask">添加任务</button>
            </div>

            <div class="panel-card">
              <h4 class="panel-card-title">短信提醒</h4>
              <label class="reminder-toggle">
                <input type="checkbox" v-model="smsReminderEnabled">
                <span class="toggle-track"></span>
                <span class="toggle-text">开启短信提醒</span>
              </label>
              <div class="reminder-fields" v-if="smsReminderEnabled">
                <input v-model="reminderPhone" type="text" class="custom-input" placeholder="手机号">
                <input v-model="reminderTime" type="time" class="custom-input">
                <button type="button" class="custom-add" @click="saveReminder">保存提醒</button>
              </div>
              <p v-if="reminderStatus" class="reminder-status">{{ reminderStatus }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useHealthPlan } from '../../composables/useHealthPlan';

defineProps<{
  modelValue: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void;
}>();

const {
  dayPlanSections,
  weekPlan,
  taskLibraryGroups,
  isLibraryTaskSelected,
  toggleLibraryTask,
  addCustomTask,
  removeCustomTask,
  removeCustomWeekTask,
  todayRemaining,
  smsReminderEnabled,
  reminderPhone,
  reminderTime,
  reminderStatus,
  saveReminder
} = useHealthPlan();

const customTaskText = ref('');
const customTaskSection = ref('morning');

function handleAddCustomTask() {
  addCustomTask(customTaskText.value, customTaskSection.value);
  customTaskText.value = '';
}

function closeModal() {
  emit('update:modelValue', false);
}
</script>

<style scoped>
.plan-modal {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  z-index: 1200;
}

.plan-modal-content {
  width: min(1100px, 96vw);
  max-height: 90vh;
  overflow: auto;
  border-radius: 24px;
}

.plan-panel {
  width: 100%;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.plan-panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.plan-panel-title {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 700;
  color: #1a1a1a;
}

.plan-panel-subtitle {
  margin: 0;
  font-size: 13px;
  color: #666;
}

.plan-panel-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12px;
  color: #2c6e49;
  font-weight: 600;
}

.plan-panel-tag {
  background: rgba(44, 110, 73, 0.12);
  padding: 4px 10px;
  border-radius: 999px;
}

.plan-modal-close {
  border: none;
  background: rgba(0, 0, 0, 0.08);
  width: 32px;
  height: 32px;
  border-radius: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #2c3e50;
}

.plan-modal-close:hover {
  background: rgba(0, 0, 0, 0.15);
}

.plan-modal-close svg {
  width: 16px;
  height: 16px;
}

.plan-panel-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.plan-panel-column {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.panel-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 16px;
  padding: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.06);
}

.panel-card-title {
  margin: 0 0 12px 0;
  font-size: 14px;
  font-weight: 700;
  color: #1f2d3d;
}

.plan-section {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 14px;
  padding: 12px;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.plan-section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.plan-section-icon {
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #2c6e49;
  flex-shrink: 0;
}

.plan-section-icon svg {
  width: 18px;
  height: 18px;
}

.plan-section-title {
  font-size: 12px;
  font-weight: 600;
  color: #1f2d3d;
}

.plan-task {
  margin-top: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.task-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #2c3e50;
  cursor: pointer;
  position: relative;
  flex: 1;
}

.task-checkbox input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.task-checkmark {
  width: 14px;
  height: 14px;
  border-radius: 4px;
  border: 1.5px solid #2c6e49;
  background: #fff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.task-checkbox input:checked + .task-checkmark {
  background: #2c6e49;
  border-color: #2c6e49;
}

.task-checkbox input:checked + .task-checkmark::after {
  content: '';
  width: 6px;
  height: 3px;
  border-left: 2px solid #fff;
  border-bottom: 2px solid #fff;
  transform: rotate(-45deg);
  margin-top: -1px;
}

.task-checkbox input:checked ~ .task-text {
  color: #2c6e49;
}

.task-text {
  flex: 1;
  transition: all 0.3s ease;
}

.task-text.task-completed {
  text-decoration: line-through;
  opacity: 0.7;
}

.task-done-badge {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  font-size: 11px;
  font-weight: 600;
  border-radius: 10px;
  margin-left: 8px;
  animation: fadeInScale 0.3s ease;
}

@keyframes fadeInScale {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.task-remove {
  border: none;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  width: 24px;
  height: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #8b8b8b;
  transition: all 0.2s ease;
}

.task-remove:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #2c6e49;
}

.task-remove svg {
  width: 14px;
  height: 14px;
}

.week-plan {
  margin-top: 12px;
}

.library-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
}

.library-title {
  font-size: 12px;
  font-weight: 600;
  color: #2c6e49;
}

.library-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #444;
}

.library-item input {
  width: 14px;
  height: 14px;
  accent-color: #2c6e49;
}

.custom-row {
  display: flex;
  gap: 8px;
  margin-bottom: 10px;
}

.custom-select {
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 10px;
  padding: 8px 10px;
  font-size: 12px;
  background: white;
  color: #333;
}

.custom-input {
  flex: 1;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 10px;
  padding: 8px 10px;
  font-size: 12px;
}

.custom-add {
  width: 100%;
  border: none;
  border-radius: 12px;
  padding: 10px;
  background: #2c6e49;
  color: white;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
}

.custom-add:hover {
  background: #23573a;
}

.reminder-toggle {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 12px;
  color: #2c3e50;
  margin-bottom: 12px;
}

.reminder-toggle input {
  display: none;
}

.toggle-track {
  width: 36px;
  height: 20px;
  background: rgba(0, 0, 0, 0.15);
  border-radius: 999px;
  position: relative;
  transition: background 0.2s ease;
}

.toggle-track::after {
  content: '';
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: white;
  position: absolute;
  top: 3px;
  left: 3px;
  transition: transform 0.2s ease;
}

.reminder-toggle input:checked + .toggle-track {
  background: #2c6e49;
}

.reminder-toggle input:checked + .toggle-track::after {
  transform: translateX(16px);
}

.toggle-text {
  font-weight: 600;
}

.reminder-fields {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.reminder-status {
  margin-top: 10px;
  font-size: 12px;
  color: #2c6e49;
  font-weight: 600;
}

@media (max-width: 768px) {
  .plan-panel {
    padding: 18px;
  }

  .plan-panel-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .plan-panel-grid {
    grid-template-columns: 1fr;
  }
}
</style>
