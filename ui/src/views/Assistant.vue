<template>
  <div class="assistant-container">
    <!-- 返回首页按钮 -->
    <div class="back-to-home">
      <button @click="goHome" class="back-btn">
        ← 返回首页
      </button>
    </div>
    
    <!-- 头部 -->
    <div class="header">
      <div class="header-content">
        <div class="title-section">
          <div class="icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C13.1 2 14 2.9 14 4C14 5.1 13.1 6 12 6C10.9 6 10 5.1 10 4C10 2.9 10.9 2 12 2ZM21 9V7L15 1H5C3.89 1 3 1.89 3 3V19C3 20.1 3.9 21 5 21H11V19H5V3H13V9H21ZM14 15.5L22.5 7L21 5.5L14 12.5L10.5 9L9 10.5L14 15.5Z"/>
            </svg>
          </div>
          <div>
            <h1>AI问答助手</h1>
            <p>专业的中医健康咨询，随时为您答疑解惑</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 聊天区域 -->
    <div class="chat-area" ref="chatArea">
      <div class="messages-container">
        <!-- 欢迎消息 -->
        <div class="message assistant-message" v-if="messages.length === 0">
          <div class="message-avatar">
            <div class="avatar assistant-avatar">AI</div>
          </div>
          <div class="message-content">
            <div class="message-bubble">
              <p>您好！我是您的AI健康顾问，专注于中医养生和健康咨询。</p>
              <p>您可以向我咨询：</p>
              <ul>
                <li>🌿 中医体质调理建议</li>
                <li>🍃 日常养生保健方法</li>
                <li>🥗 饮食营养搭配指导</li>
                <li>💤 睡眠质量改善建议</li>
                <li>🧘 情绪调节和压力管理</li>
              </ul>
              <p>请随时向我提问，我会为您提供专业的建议！</p>
            </div>
            <div class="message-time">{{ formatTime(new Date()) }}</div>
          </div>
        </div>

        <!-- 聊天消息 -->
        <div 
          v-for="(message, index) in messages" 
          :key="index" 
          class="message" 
          :class="message.type + '-message'"
        >
          <div class="message-avatar" v-if="message.type === 'assistant'">
            <div class="avatar assistant-avatar">AI</div>
          </div>
          <div class="message-content">
            <div class="message-bubble" :class="message.type + '-bubble'">
              <div v-if="message.type === 'user'" class="user-question">
                {{ message.content }}
              </div>
              <div v-else class="assistant-answer">
                <div class="answer-text" v-html="formatAnswer(message.content)"></div>
                <div class="sources" v-if="message.sources && message.sources.length > 0">
                  <div class="sources-label">信息来源：</div>
                  <div class="sources-list">
                    <span v-for="source in message.sources" :key="source" class="source-tag">
                      {{ source }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div class="message-time">{{ formatTime(message.timestamp) }}</div>
          </div>
          <div class="message-avatar" v-if="message.type === 'user'">
            <div class="avatar user-avatar">我</div>
          </div>
        </div>

        <!-- 加载指示器 -->
        <div v-if="isLoading" class="message assistant-message">
          <div class="message-avatar">
            <div class="avatar assistant-avatar">AI</div>
          </div>
          <div class="message-content">
            <div class="message-bubble">
              <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 输入区域 -->
    <div class="input-area">
      <div class="input-container">
        <div class="input-wrapper">
          <textarea
            v-model="currentQuestion"
            @keydown="handleKeyDown"
            placeholder="请输入您的健康问题..."
            class="question-input"
            rows="1"
            ref="textareaRef"
          ></textarea>
          <button 
            @click="sendQuestion" 
            :disabled="!currentQuestion.trim() || isLoading"
            class="send-button"
          >
            <svg v-if="!isLoading" viewBox="0 0 24 24" fill="currentColor">
              <path d="M2,21L23,12L2,3V10L17,12L2,14V21Z"/>
            </svg>
            <div v-else class="loading-spinner"></div>
          </button>
        </div>
        <div class="quick-questions">
          <span class="quick-label">快速提问：</span>
          <button 
            v-for="quickQ in quickQuestions" 
            :key="quickQ"
            @click="selectQuickQuestion(quickQ)"
            class="quick-question-btn"
            :disabled="isLoading"
          >
            {{ quickQ }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { askAssistant } from '../services/api';

const router = useRouter();

interface Message {
  type: 'user' | 'assistant';
  content: string;
  timestamp: Date;
  sources?: string[];
}

const messages = ref<Message[]>([]);
const currentQuestion = ref('');
const isLoading = ref(false);
const chatArea = ref<HTMLElement>();
const textareaRef = ref<HTMLTextAreaElement>();

const quickQuestions = [
  '我经常失眠怎么办？',
  '如何调理脾胃虚弱？',
  '秋季养生要注意什么？',
  '熬夜后如何快速恢复？'
];

const goHome = () => {
  router.push('/dashboard');
};

onMounted(() => {
  // 自动调整textarea高度
  adjustTextareaHeight();
});

async function sendQuestion() {
  if (!currentQuestion.value.trim() || isLoading.value) return;

  const question = currentQuestion.value.trim();
  
  // 添加用户消息
  messages.value.push({
    type: 'user',
    content: question,
    timestamp: new Date()
  });

  currentQuestion.value = '';
  isLoading.value = true;
  
  // 滚动到底部
  await nextTick();
  scrollToBottom();

  try {
    // 调用API
    const response = await askAssistant({ q: question });
    
    // 添加助手回复
    messages.value.push({
      type: 'assistant',
      content: response.answer,
      timestamp: new Date(),
      sources: response.sources
    });
  } catch (error) {
    console.error('发送问题失败:', error);
    messages.value.push({
      type: 'assistant',
      content: '抱歉，我暂时无法回答您的问题。请检查网络连接后重试。',
      timestamp: new Date(),
      sources: ['系统错误']
    });
  } finally {
    isLoading.value = false;
    await nextTick();
    scrollToBottom();
    adjustTextareaHeight();
  }
}

function selectQuickQuestion(question: string) {
  currentQuestion.value = question;
  sendQuestion();
}

function handleKeyDown(event: KeyboardEvent) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    sendQuestion();
  }
  
  // 自动调整高度
  nextTick(() => {
    adjustTextareaHeight();
  });
}

function adjustTextareaHeight() {
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto';
    textareaRef.value.style.height = Math.min(textareaRef.value.scrollHeight, 120) + 'px';
  }
}

function scrollToBottom() {
  if (chatArea.value) {
    chatArea.value.scrollTop = chatArea.value.scrollHeight;
  }
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString('zh-CN', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });
}

function formatAnswer(text: string): string {
  // 简单的文本格式化，将换行转换为<br>
  return text.replace(/\n/g, '<br>');
}
</script>

<style scoped>
.assistant-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

/* 返回首页按钮 */
.back-to-home {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 10;
}

.back-btn {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 8px;
  padding: 8px 16px;
  color: #667eea;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  backdrop-filter: blur(10px);
}

.back-btn:hover {
  background: white;
  border-color: #667eea;
  color: #5a67d8;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

/* 头部样式 */
.header {
  background: white;
  border-bottom: 1px solid #e1e8ed;
  padding: 20px 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.title-section {
  display: flex;
  align-items: center;
  gap: 15px;
}

.icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.icon svg {
  width: 24px;
  height: 24px;
}

.title-section h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #2c3e50;
}

.title-section p {
  margin: 4px 0 0 0;
  color: #7f8c8d;
  font-size: 14px;
}

.status-text {
  font-size: 12px;
  font-weight: 500;
}

/* 聊天区域 */
.chat-area {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.messages-container {
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.message {
  display: flex;
  gap: 12px;
  animation: fadeInUp 0.3s ease-out;
}

.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  flex-shrink: 0;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  color: white;
}

.assistant-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.user-avatar {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
  color: #8b4513;
}

.message-content {
  flex: 1;
  max-width: 70%;
}

.message-bubble {
  padding: 16px 20px;
  border-radius: 18px;
  margin-bottom: 4px;
  word-wrap: break-word;
}

.assistant-bubble {
  background: white;
  border: 1px solid #e1e8ed;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.user-bubble {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin-left: auto;
}

.user-question {
  font-size: 15px;
  line-height: 1.5;
}

.assistant-answer {
  font-size: 15px;
  line-height: 1.6;
  color: #2c3e50;
}

.answer-text {
  margin-bottom: 12px;
}

.sources {
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
}

.sources-label {
  font-size: 12px;
  color: #7f8c8d;
  margin-bottom: 6px;
}

.sources-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.source-tag {
  background: #f8f9fa;
  color: #6c757d;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 11px;
  border: 1px solid #e9ecef;
}

.message-time {
  font-size: 11px;
  color: #95a5a6;
  text-align: right;
}

.user-message .message-time {
  text-align: left;
}

/* 打字指示器 */
.typing-indicator {
  display: flex;
  gap: 4px;
  align-items: center;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #bdc3c7;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s; }

@keyframes typing {
  0%, 80%, 100% { transform: scale(0.8); opacity: 0.5; }
  40% { transform: scale(1); opacity: 1; }
}

/* 输入区域 */
.input-area {
  background: white;
  border-top: 1px solid #e1e8ed;
  padding: 20px;
}

.input-container {
  max-width: 800px;
  margin: 0 auto;
}

.input-wrapper {
  display: flex;
  gap: 12px;
  align-items: flex-end;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 24px;
  padding: 12px 16px;
  transition: border-color 0.2s ease;
}

.input-wrapper:focus-within {
  border-color: #667eea;
}

.question-input {
  flex: 1;
  border: none;
  background: transparent;
  resize: none;
  outline: none;
  font-size: 15px;
  line-height: 1.5;
  min-height: 24px;
  max-height: 120px;
  font-family: inherit;
}

.question-input::placeholder {
  color: #adb5bd;
}

.send-button {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.send-button:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.send-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.send-button svg {
  width: 18px;
  height: 18px;
}

.loading-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.quick-questions {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
  flex-wrap: wrap;
}

.quick-label {
  font-size: 12px;
  color: #7f8c8d;
  white-space: nowrap;
}

.quick-question-btn {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 16px;
  padding: 6px 12px;
  font-size: 12px;
  color: #6c757d;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.quick-question-btn:hover:not(:disabled) {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.quick-question-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header {
    padding: 15px 20px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .chat-area {
    padding: 15px;
  }
  
  .message-content {
    max-width: 85%;
  }
  
  .input-area {
    padding: 15px;
  }
  
  .quick-questions {
    justify-content: flex-start;
  }
}
</style>