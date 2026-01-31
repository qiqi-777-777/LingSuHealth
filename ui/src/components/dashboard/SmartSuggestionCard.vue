<template>
  <div class="calendar-card-container">
    <div class="calendar-card">
      <div class="calendar-page">
        <div class="cal-header">
          <span class="cal-title">今日宜忌</span>
          <span class="cal-date">{{ currentDate }}</span>
        </div>
        <div class="cal-body">
          <div class="cal-row good">
            <span class="circle-tag">宜</span>
            <span>{{ currentSuggestion?.type === 'morning' ? '晨练、饮水' : (currentSuggestion?.type === 'noon' ? '午休、清淡' : '泡脚、冥想') }}</span>
          </div>
          <div class="cal-row bad">
            <span class="circle-tag">忌</span>
            <span>{{ currentSuggestion?.type === 'morning' ? '空腹浓茶' : (currentSuggestion?.type === 'noon' ? '油腻辛辣' : '剧烈运动') }}</span>
          </div>
        </div>
        <div class="cal-footer">
          <span>{{ currentSuggestion?.text || '保持好心情' }}</span>
        </div>
      </div>
      
      <!-- 撕页动画层 -->
      <div class="tear-overlay"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

const hour = new Date().getHours();
const suggestions = [
  { title: '晨间唤醒', text: '一日之计在于晨，记得喝水哦。', type: 'morning' },
  { title: '午间能量', text: '午休片刻，精力充沛。', type: 'noon' },
  { title: '晚间助眠', text: '早点休息，明天会更好。', type: 'night' },
];

const currentSuggestion = ref(suggestions[0]);

const currentDate = computed(() => {
  const now = new Date();
  return `${now.getMonth() + 1}月${now.getDate()}日`;
});

function refreshSuggestion() {
  if (hour < 11) currentSuggestion.value = suggestions[0];
  else if (hour < 17) currentSuggestion.value = suggestions[1];
  else currentSuggestion.value = suggestions[2];
}

onMounted(() => {
  refreshSuggestion();
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;700&display=swap');

.calendar-card-container {
  height: 100%;
  width: 100%;
  min-height: 180px;
}

.calendar-card {
  height: 100%;
  background: #fff;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  position: relative;
  transition: all 0.3s ease;
  border: 1px solid rgba(0,0,0,0.05);
}

.calendar-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 20px -5px rgba(0, 0, 0, 0.1);
}

.calendar-page {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  position: relative;
  z-index: 2;
}

.cal-header {
  background: #ef4444;
  color: white;
  padding: 12px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: 'Noto Serif SC', serif;
}

.cal-title {
  font-weight: 700;
  font-size: 16px;
}

.cal-date {
  font-size: 14px;
  opacity: 0.9;
}

.cal-body {
  flex: 1;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  justify-content: center;
}

.cal-row {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  color: #334155;
}

.circle-tag {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: white;
  flex-shrink: 0;
  font-weight: bold;
}

.good .circle-tag { background: #10b981; }
.bad .circle-tag { background: #64748b; }

.cal-footer {
  padding: 12px 16px;
  border-top: 1px dashed #e2e8f0;
  font-size: 12px;
  color: #64748b;
  text-align: center;
}

.tear-overlay {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, transparent 50%, rgba(0,0,0,0.05) 50%);
  transition: all 0.3s;
  pointer-events: none;
}

.calendar-card:hover .tear-overlay {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, transparent 50%, rgba(0,0,0,0.1) 50%);
}
</style>
