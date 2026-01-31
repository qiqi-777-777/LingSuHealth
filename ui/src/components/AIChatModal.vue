<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="visible" class="modal-overlay" @click="$emit('close')">
        <div class="modal-content chat-modal" @click.stop>
          <div class="modal-header">
            <div class="header-left">
              <div class="logo-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
                </svg>
              </div>
              <div class="header-text">
                <h3>AI 资讯</h3>
                <span class="status-badge">在线</span>
              </div>
            </div>
            <button class="close-btn" @click="$emit('close')" title="关闭">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <div class="chat-body" ref="chatArea">
            <div v-if="messages.length === 0" class="welcome-msg">
              <p>您好！我是您的AI健康顾问。请问有什么可以帮您？</p>
              <div class="quick-tags">
                <button v-for="q in quickQuestions" :key="q" @click="ask(q)">{{ q }}</button>
              </div>
            </div>

            <div v-for="(msg, index) in messages" :key="index" class="message-row" :class="msg.type">
              <div class="avatar">
                <svg v-if="msg.type === 'assistant'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
              </div>
              <div class="message-bubble">
                <div v-if="msg.type === 'assistant'" v-html="formatAnswer(msg.content)"></div>
                <div v-else>{{ msg.content }}</div>
              </div>
            </div>

            <div v-if="isLoading" class="message-row assistant loading">
              <div class="avatar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
                </svg>
              </div>
              <div class="message-bubble typing">
                <span>.</span><span>.</span><span>.</span>
              </div>
            </div>
          </div>

          <div class="chat-footer">
            <!-- 升级后的输入框，带有呼吸光效和打字机效果 -->
            <div class="glow-container" :class="{ focused: isFocused }">
              <div class="input-wrapper" :class="{ focused: isFocused }">
                <div class="input-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
                  </svg>
                </div>
                <input 
                  v-model="currentQuestion" 
                  @keydown.enter="sendQuestion" 
                  :placeholder="placeholderText"
                  @focus="isFocused = true"
                  @blur="isFocused = false"
                  :disabled="isLoading"
                  class="main-input"
                />
                <button class="send-btn" @click="sendQuestion" :disabled="!currentQuestion.trim() || isLoading">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="22" y1="2" x2="11" y2="13"/>
                    <polygon points="22 2 15 22 11 13 2 9 22 2"/>
                  </svg>
                </button>
              </div>
              <!-- 动态呼吸光晕层 -->
              <div class="breathing-glow"></div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, nextTick, watch, onMounted, onUnmounted } from 'vue';
import { askAssistant } from '../services/api';

const props = defineProps<{
  visible: boolean;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
}>();

interface Message {
  type: 'user' | 'assistant';
  content: string;
}

const messages = ref<Message[]>([]);
const currentQuestion = ref('');
const isLoading = ref(false);
const chatArea = ref<HTMLElement | null>(null);
const isFocused = ref(false);

const quickQuestions = [
  '最近总是失眠怎么办？',
  '脾胃虚弱怎么调理？',
  '推荐一份养生食谱'
];

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

watch(() => props.visible, (newVal) => {
  if (newVal) {
    nextTick(scrollToBottom);
    // 重置打字机
    if (!typeTimer) typeWriter();
  }
});

onMounted(() => {
  typeWriter();
});

onUnmounted(() => {
  if (typeTimer) clearTimeout(typeTimer);
});

function scrollToBottom() {
  if (chatArea.value) {
    chatArea.value.scrollTop = chatArea.value.scrollHeight;
  }
}

async function ask(q: string) {
  currentQuestion.value = q;
  await sendQuestion();
}

defineExpose({
  ask
});

async function sendQuestion() {
  const q = currentQuestion.value.trim();
  if (!q || isLoading.value) return;

  messages.value.push({ type: 'user', content: q });
  currentQuestion.value = '';
  isLoading.value = true;
  nextTick(scrollToBottom);

  try {
    const history = messages.value
      .slice(0, -1)
      .slice(-6)
      .map(m => ({ role: m.type, content: m.content }));

    const res = await askAssistant(q, history);
    messages.value.push({ type: 'assistant', content: res.answer });
  } catch (e) {
    messages.value.push({ type: 'assistant', content: '抱歉，系统暂时繁忙，请稍后再试。' });
  } finally {
    isLoading.value = false;
    nextTick(scrollToBottom);
  }
}

function formatAnswer(text: string) {
  return text.replace(/\n/g, '<br>').replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chat-modal {
  background: #fff;
  width: 90%;
  max-width: 500px;
  height: 600px;
  max-height: 80vh;
  border-radius: 24px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  overflow: hidden;
  animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.modal-header {
  padding: 16px 20px;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.9);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.logo-icon svg { width: 18px; height: 18px; }

.header-text h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
}

.status-badge {
  font-size: 11px;
  color: #10b981;
  background: #d1fae5;
  padding: 2px 6px;
  border-radius: 4px;
}

.close-btn {
  background: #f1f5f9;
  border: 1px solid transparent;
  color: #94a3b8;
  cursor: pointer;
  padding: 6px;
  border-radius: 50%;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
}

.close-btn:hover {
  background: #fee2e2;
  color: #ef4444;
  border-color: #fecaca;
  transform: rotate(90deg);
}

.close-btn svg { width: 18px; height: 18px; }

.chat-body {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f8fafc;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.welcome-msg {
  text-align: center;
  color: #64748b;
  font-size: 14px;
  margin-top: 20px;
}

.quick-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
  margin-top: 12px;
}

.quick-tags button {
  background: #fff;
  border: 1px solid #e2e8f0;
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 12px;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s;
}

.quick-tags button:hover {
  border-color: #10b981;
  color: #10b981;
}

.message-row {
  display: flex;
  gap: 12px;
  max-width: 85%;
}

.message-row.user {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.assistant .avatar {
  background: #fff;
  border: 1px solid #e2e8f0;
  color: #10b981;
}

.user .avatar {
  background: #10b981;
  color: white;
}

.avatar svg { width: 18px; height: 18px; }

.message-bubble {
  padding: 10px 14px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.5;
  word-wrap: break-word;
}

.assistant .message-bubble {
  background: #fff;
  border: 1px solid #e2e8f0;
  color: #334155;
  border-top-left-radius: 2px;
}

.user .message-bubble {
  background: #10b981;
  color: white;
  border-top-right-radius: 2px;
}

.typing span {
  display: inline-block;
  animation: bounce 1.4s infinite ease-in-out both;
  margin: 0 1px;
}

.typing span:nth-child(1) { animation-delay: -0.32s; }
.typing span:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

/* 底部输入框样式升级 */
.chat-footer {
  padding: 16px;
  background: #fff;
  border-top: 1px solid #f1f5f9;
  position: relative;
  z-index: 10;
}

.glow-container {
  position: relative;
  z-index: 10;
  border-radius: 20px;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: #f1f5f9;
  border: 1px solid transparent;
  border-radius: 20px;
  padding: 6px 8px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 2;
}

/* 呼吸光晕背景 */
.breathing-glow {
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border-radius: 22px;
  background: linear-gradient(90deg, #10b981, #34d399, #10b981);
  background-size: 200% 100%;
  opacity: 0;
  filter: blur(8px);
  transform: scale(0.95);
  transition: all 0.5s ease;
  z-index: 1;
}

/* 激活状态特效 */
.glow-container.focused .breathing-glow,
.glow-container:hover .breathing-glow {
  opacity: 0.5;
  transform: scale(1);
  animation: breathe-glow 3s infinite linear;
}

.input-wrapper.focused {
  background: #ffffff;
  border-color: rgba(16, 185, 129, 0.3);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

@keyframes breathe-glow {
  0% { background-position: 0% 50%; opacity: 0.4; }
  50% { background-position: 100% 50%; opacity: 0.7; }
  100% { background-position: 0% 50%; opacity: 0.4; }
}

.input-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #94a3b8;
  transition: all 0.3s;
}

.glow-container.focused .input-icon {
  color: #10b981;
  transform: scale(1.1);
}

.input-icon svg {
  width: 20px;
  height: 20px;
}

.main-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 14px;
  color: #334155;
  padding: 8px;
  outline: none;
}

.main-input::placeholder {
  color: #94a3b8;
  transition: color 0.3s;
}

.send-btn {
  width: 36px;
  height: 36px;
  border-radius: 12px;
  background: #10b981;
  color: white;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.send-btn:disabled {
  background: #cbd5e1;
  cursor: not-allowed;
  box-shadow: none;
}

.send-btn svg { width: 18px; height: 18px; }

@keyframes popIn {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>