<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import AIChatModal from '../AIChatModal.vue';

const router = useRouter();
const query = ref('');
const isFocused = ref(false);
const showChatModal = ref(false);
const chatModalRef = ref<InstanceType<typeof AIChatModal> | null>(null);

const timeGreeting = computed(() => {
  const hour = new Date().getHours();
  if (hour < 6) return '夜深了';
  if (hour < 9) return '早上好';
  if (hour < 12) return '上午好';
  if (hour < 14) return '中午好';
  if (hour < 18) return '下午好';
  return '晚上好';
});

// 打字机效果逻辑
const placeholderText = ref('');
const placeholders = [
  '告诉我您的不适，或询问养生建议...',
  '最近总是失眠怎么办？',
  '立春该吃什么？',
  '推荐一份护眼食谱...',
  '胃胀气怎么缓解？',
  '怎样通过饮食改善气虚？'
];
let placeholderIndex = 0;
let charIndex = 0;
let isDeleting = false;
let typeTimer: number | undefined;

const typeWriter = () => {
  const currentFullText = placeholders[placeholderIndex] || '';
  let typeSpeed: number;

  if (isDeleting) {
    placeholderText.value = currentFullText.substring(0, charIndex - 1);
    charIndex--;
    typeSpeed = 50;
  } else {
    placeholderText.value = currentFullText.substring(0, charIndex + 1);
    charIndex++;
    typeSpeed = 150;
  }

  if (!isDeleting && charIndex === currentFullText.length) {
    isDeleting = true;
    typeSpeed = 2000; // 停顿等待
  } else if (isDeleting && charIndex === 0) {
    isDeleting = false;
    placeholderIndex = (placeholderIndex + 1) % placeholders.length;
    typeSpeed = 500;
  }

  typeTimer = window.setTimeout(typeWriter, typeSpeed);
};

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
  '消化不良吃什么？',
  '经常熬夜怎么补？',
  '湿气重有什么表现？',
  '脾胃虚弱怎么调理？',
  '肝火旺吃什么好？',
  '缓解痛经的小妙招',
  '脱发严重怎么办？',
  '怎样缓解焦虑情绪？',
  '适合高血压的食谱',
  '补钙吃什么最好？',
  '记忆力减退怎么办？',
  '经常牙痛怎么缓解？',
  '视力模糊怎么调理？',
  '如何科学减肥？',
  '口腔溃疡怎么办？'
];

const suggestionsRow1 = allSuggestions.slice(0, Math.ceil(allSuggestions.length / 2));
const suggestionsRow2 = allSuggestions.slice(Math.ceil(allSuggestions.length / 2));

onMounted(() => {
  typeWriter();
});

onUnmounted(() => {
  if (typeTimer) clearTimeout(typeTimer);
});

function handleSearch() {
  if (!query.value.trim()) return;
  
  showChatModal.value = true;
  setTimeout(() => {
    chatModalRef.value?.ask(query.value);
  }, 100);
}

function selectSuggestion(text: string) {
  query.value = text;
  handleSearch();
}
</script>

<template>
  <div class="ai-home-input">
    <div class="greeting-container">
      <h1 class="greeting-text">
        <span class="greeting-time">{{ timeGreeting }}，</span>
        <span class="greeting-ai">我是您的 AI 养生顾问</span>
      </h1>
      <p class="greeting-sub">基于传统中医与现代医学，为您提供个性化建议</p>
    </div>

    <!-- 增加 glow-container 用于呼吸光效 -->
    <div class="glow-container" :class="{ focused: isFocused }">
      <div class="input-wrapper" :class="{ focused: isFocused }">
        <div class="input-icon">
          <!-- 替换为更有 AI 感的图标（例如 sparkles 或 brain） -->
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
          </svg>
        </div>
        <input
          v-model="query"
          type="text"
          class="main-input"
          :placeholder="placeholderText"
          @focus="isFocused = true"
          @blur="isFocused = false"
          @keydown.enter="handleSearch"
        />
        <button class="send-btn" @click="handleSearch" :disabled="!query.trim()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
          </svg>
        </button>
      </div>
      <!-- 动态呼吸光晕层 -->
      <div class="breathing-glow"></div>
    </div>

    <div class="suggestion-container">
      <!-- 第一行滚动 -->
      <div class="scroll-row">
        <div class="scroll-track">
          <button
            v-for="(chip, index) in [...suggestionsRow1, ...suggestionsRow1]"
            :key="`row1-${index}`"
            class="chip"
            @click="selectSuggestion(chip)"
          >
            {{ chip }}
          </button>
        </div>
      </div>
      <!-- 第二行滚动 -->
      <div class="scroll-row">
        <div class="scroll-track slow">
          <button
            v-for="(chip, index) in [...suggestionsRow2, ...suggestionsRow2]"
            :key="`row2-${index}`"
            class="chip"
            @click="selectSuggestion(chip)"
          >
            {{ chip }}
          </button>
        </div>
      </div>
    </div>

    <AIChatModal
      ref="chatModalRef"
      :visible="showChatModal"
      @close="showChatModal = false"
    />
  </div>
</template>

<style scoped>
.ai-home-input {
  width: 100%;
  max-width: 800px;
  display: flex;
  flex-direction: column;
  gap: 32px;
  padding: 20px 20px 40px;
  overflow: hidden; /* 防止滚动条溢出 */
}

.greeting-text {
  font-size: 48px;
  font-weight: 800;
  margin: 0 0 8px 0;
  line-height: 1.2;
  color: #1e293b;
  letter-spacing: -1px;
}

.greeting-time {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.greeting-sub {
  font-size: 18px;
  color: #64748b;
  margin: 0;
}

.glow-container {
  position: relative;
  z-index: 10;
  border-radius: 28px;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(16, 185, 129, 0.1);
  border-radius: 28px;
  padding: 10px 12px;
  box-shadow: 
    0 4px 6px -1px rgba(0, 0, 0, 0.05),
    0 10px 15px -3px rgba(0, 0, 0, 0.05);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 2;
  height: 72px;
}

.breathing-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 28px;
  background: linear-gradient(90deg, #10b981, #34d399, #10b981);
  background-size: 200% 100%;
  opacity: 0;
  filter: blur(15px);
  transform: scale(0.95);
  transition: all 0.5s ease;
  z-index: 1;
}

/* 激活状态特效 */
.glow-container.focused .breathing-glow,
.glow-container:hover .breathing-glow {
  opacity: 0.6;
  transform: scale(1.02);
  animation: breathe-glow 3s infinite linear;
}

.input-wrapper.focused {
  background: #ffffff;
  border-color: rgba(16, 185, 129, 0.3);
  transform: scale(1.01);
}

@keyframes breathe-glow {
  0% { background-position: 0% 50%; opacity: 0.5; filter: blur(15px); }
  50% { background-position: 100% 50%; opacity: 0.8; filter: blur(20px); }
  100% { background-position: 0% 50%; opacity: 0.5; filter: blur(15px); }
}

.input-icon {
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #10b981;
  transition: all 0.3s;
}

.glow-container.focused .input-icon {
  transform: scale(1.1);
  color: #059669;
}

.input-icon svg {
  width: 28px;
  height: 28px;
}

.main-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 20px;
  color: #1e293b;
  padding: 12px 8px;
  outline: none;
  font-weight: 500;
}

.main-input::placeholder {
  color: #94a3b8;
  font-weight: 400;
  transition: color 0.3s;
}

.send-btn {
  width: 52px;
  height: 52px;
  border-radius: 20px;
  border: none;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.1) rotate(5deg);
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
}

.send-btn:disabled {
  background: #e2e8f0;
  cursor: not-allowed;
  color: #94a3b8;
  box-shadow: none;
  transform: none;
}

.send-btn svg {
  width: 24px;
  height: 24px;
  margin-left: -2px;
}

.suggestion-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
  width: 100%;
  mask-image: linear-gradient(90deg, transparent 0%, #000 5%, #000 95%, transparent 100%);
  -webkit-mask-image: linear-gradient(90deg, transparent 0%, #000 5%, #000 95%, transparent 100%);
}

.scroll-row {
  width: 100%;
  overflow: hidden;
  display: flex;
}

.scroll-track {
  display: flex;
  gap: 0;
  width: max-content;
  animation: scroll 40s linear infinite;
}

.scroll-track.slow {
  animation-duration: 50s;
}

/* Hover to pause - Independent for each row */
.scroll-row:hover .scroll-track {
  animation-play-state: paused;
}

@keyframes scroll {
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-50%);
  }
}

.chip {
  flex-shrink: 0;
  margin-right: 12px;
  padding: 10px 20px;
  border-radius: 100px;
  border: 1px solid rgba(16, 185, 129, 0.15);
  background: rgba(255, 255, 255, 0.6);
  color: #475569;
  font-size: 15px;
  cursor: pointer;
  transition: all 0.3s;
  backdrop-filter: blur(10px);
  white-space: nowrap;
  text-align: center;
}

.chip:hover {
  background: rgba(16, 185, 129, 0.1);
  border-color: rgba(16, 185, 129, 0.5);
  color: #059669;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
}

@media (max-width: 768px) {
  .greeting-text {
    font-size: 32px;
  }
  
  .ai-home-input {
    padding: 10px;
  }
  
  .input-wrapper {
    height: 64px;
  }
  
  .main-input {
    font-size: 16px;
  }
}
</style>
