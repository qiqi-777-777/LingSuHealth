<template>
  <div class="assistant-container" :class="{ 'dark-theme': isDark }">
    <!-- 头部导航 -->
    <header class="glass-header">
      <div class="header-content">
        <button class="nav-btn" @click="goHome">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M19 12H5M12 19l-7-7 7-7"/>
          </svg>
          <span>返回首页</span>
        </button>
        
        <div class="header-title">
          <div class="logo-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
              <path d="M8 11h8"/>
              <path d="M9 16h6"/>
            </svg>
          </div>
          <div class="title-text">
            <h1>灵素小助手</h1>
            <span class="status-badge">
              <span class="status-dot"></span>
              在线
            </span>
          </div>
        </div>
        
        <div class="header-actions">
          <button class="action-btn" @click="toggleTheme" :title="isDark ? '切换亮色模式' : '切换深色模式'">
            <svg v-if="isDark" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="5"/>
              <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>
            </svg>
            <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
            </svg>
          </button>
          <button class="action-btn" @click="clearHistory" title="清空对话">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- 聊天主区域 -->
    <main class="chat-main" ref="chatArea">
      <div class="chat-content">
        <!-- 欢迎卡片 -->
        <transition name="fade-slide-up" appear>
          <div class="welcome-card" v-if="messages.length === 0">
            <div class="welcome-header">
              <div class="welcome-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                  <path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8zm0-14a6 6 0 1 0 6 6 6 6 0 0 0-6-6zm0 10a4 4 0 1 1 4-4 4 4 0 0 1-4 4z"/>
                </svg>
              </div>
              <h2>您好，我是您的AI健康顾问</h2>
              <p>基于中医理论与现代医学，为您提供专业的健康咨询服务</p>
            </div>
            
            <div class="capabilities-grid">
            <div 
              class="capability-item" 
              v-for="(cap, index) in capabilities" 
              :key="index"
              @click="selectCapability(cap.text)"
              style="cursor: pointer;"
            >
              <div class="cap-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="cap.icon"/>
                </svg>
              </div>
              <span>{{ cap.text }}</span>
            </div>
          </div>
          </div>
        </transition>

        <!-- 消息列表 -->
        <transition-group name="message-fade" tag="div" class="messages-list">
          <div 
            v-for="(msg, index) in messages" 
            :key="index"
            class="message-row"
            :class="msg.type"
          >
            <div class="avatar-container">
              <div class="avatar" :class="msg.type">
                <svg v-if="msg.type === 'assistant'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
              </div>
            </div>
            
            <div class="message-content-wrapper">
              <div class="message-bubble">
                <div v-if="msg.type === 'assistant'" class="markdown-body" v-html="formatAnswer(msg.content)"></div>
                <div v-else>{{ msg.content }}</div>
              </div>
              
              <div class="message-meta">
                <span class="time">{{ formatTime(msg.timestamp) }}</span>
                <div v-if="msg.sources && msg.sources.length" class="sources-tag">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                  </svg>
                  参考来源
                </div>
              </div>
              
              <div v-if="msg.sources && msg.sources.length" class="sources-panel">
                <div class="sources-title">参考资料：</div>
                <div class="source-item" v-for="(source, sIdx) in msg.sources" :key="sIdx">
                  {{ source }}
                </div>
              </div>
            </div>
          </div>
        </transition-group>

        <!-- 加载状态 -->
        <div v-if="isLoading" class="message-row assistant loading">
          <div class="avatar-container">
            <div class="avatar assistant">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                 <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7V5.73C9.4 5.39 9 4.74 9 4a2 2 0 0 1 2-2z"/>
              </svg>
            </div>
          </div>
          <div class="message-content-wrapper">
            <div class="message-bubble typing">
              <span class="dot"></span>
              <span class="dot"></span>
              <span class="dot"></span>
            </div>
            <div class="thinking-text">灵素正在思考中...</div>
          </div>
        </div>
      </div>
    </main>

    <!-- 底部输入区 -->
    <footer class="input-footer">
      <div class="input-container-glass">
        <!-- 快速提问标签 -->
        <div class="quick-tags-wrapper">
          <div 
            v-for="(q, index) in quickQuestions" 
            :key="index"
            class="quick-tag"
            @click="selectQuickQuestion(q)"
          >
            {{ q }}
          </div>
        </div>
        
        <!-- 输入框 -->
        <div class="input-box-wrapper">
          <textarea
            v-model="currentQuestion"
            @keydown="handleKeyDown"
            placeholder="请详细描述您的健康问题..."
            class="main-textarea"
            rows="1"
            ref="textareaRef"
          ></textarea>
          
          <button 
            class="send-btn"
            :class="{ 'is-active': currentQuestion.trim() }"
            @click="sendQuestion"
            :disabled="!currentQuestion.trim() || isLoading"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="22" y1="2" x2="11" y2="13"/>
              <polygon points="22 2 15 22 11 13 2 9 22 2"/>
            </svg>
          </button>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { askAssistant, getUserThemePreference, saveUserThemePreference } from '../services/api';

defineOptions({ name: 'AssistantView' });

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

// 主题状态，默认为浅色
const isDark = ref(false);

// 切换主题并保存到后端
const toggleTheme = async () => {
  isDark.value = !isDark.value;
  const theme = isDark.value ? 'dark' : 'light';
  
  try {
    await saveUserThemePreference(theme);
    console.log('主题偏好已保存:', theme);
  } catch (error) {
    console.error('保存主题偏好失败:', error);
    // 即使保存失败，也保持UI的切换效果
  }
};

// 页面加载时获取用户的主题偏好
onMounted(async () => {
  try {
    const response = await getUserThemePreference();
    if (response.success && response.theme) {
      isDark.value = response.theme === 'dark';
      console.log('已加载用户主题偏好:', response.theme);
    }
  } catch (error) {
    console.error('获取主题偏好失败:', error);
    // 失败时使用默认浅色主题
  }
});

// 功能特性列表
const capabilities = [
  { text: '中医体质调理', icon: 'M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z' },
  { text: '日常养生保健', icon: 'M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z M8 14s1.5 2 4 2 4-2 4-2' },
  { text: '饮食营养搭配', icon: 'M18 8h1a4 4 0 0 1 0 8h-1 M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z M6 1v3 M10 1v3 M14 1v3' },
  { text: '睡眠改善建议', icon: 'M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z' }
];

const quickQuestions = [
  '经常失眠多梦怎么调理？',
  '脾胃虚弱有哪些食疗方案？',
  '如何缓解久坐导致的腰酸？',
  '流感季节如何预防感冒？'
];

const goHome = () => router.push('/dashboard');

const clearHistory = () => {
  if (confirm('确定要清空当前对话记录吗？')) {
    messages.value = [];
  }
};

onMounted(() => {
  adjustTextareaHeight();
});

watch(currentQuestion, () => {
  nextTick(adjustTextareaHeight);
});

async function sendQuestion() {
  if (!currentQuestion.value.trim() || isLoading.value) return;

  const question = currentQuestion.value.trim();
  
  messages.value.push({
    type: 'user',
    content: question,
    timestamp: new Date()
  });

  currentQuestion.value = '';
  isLoading.value = true;
  
  await nextTick();
  scrollToBottom();

  // 重置输入框高度
  if (textareaRef.value) textareaRef.value.style.height = 'auto';

  try {
    const history = messages.value
      .slice(0, -1)
      .slice(-8)
      .map(item => ({
        role: item.type === 'user' ? 'user' : 'assistant',
        content: item.content
      }));

    const response = await askAssistant(question, history);
    
    messages.value.push({
      type: 'assistant',
      content: response.answer || '抱歉，我暂时无法回答您的问题。',
      timestamp: new Date(),
      sources: response.sources || []
    });

  } catch (error) {
    console.error('发送问题失败:', error);
    messages.value.push({
      type: 'assistant',
      content: '抱歉，遇到了一些连接问题。请稍后再试。',
      timestamp: new Date(),
      sources: ['系统错误']
    });
  } finally {
    isLoading.value = false;
    await nextTick();
    scrollToBottom();
  }
}

function selectQuickQuestion(question: string) {
  currentQuestion.value = question;
  // 可选：直接发送
  // sendQuestion(); 
}

function selectCapability(text: string) {
  currentQuestion.value = `请针对"${text}"给我一些建议`;
  // sendQuestion(); // Optional: send immediately
}

function handleKeyDown(event: KeyboardEvent) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    sendQuestion();
  }
}

function adjustTextareaHeight() {
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto';
    const height = Math.min(textareaRef.value.scrollHeight, 120);
    textareaRef.value.style.height = height > 40 ? height + 'px' : '40px';
  }
}

function scrollToBottom() {
  if (chatArea.value) {
    chatArea.value.scrollTo({
      top: chatArea.value.scrollHeight,
      behavior: 'smooth'
    });
  }
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString('zh-CN', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });
}

function formatAnswer(text: string): string {
  // 简单的 Markdown 格式处理
  const formatted = text
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.*?)`/g, '<code>$1</code>');
  return formatted;
}
</script>

<style scoped>
/* 
  Modern Design System - Emerald Theme
  Based on Assessment module style
  With Dark Mode Support via CSS Variables
*/

.assistant-container {
  /* Default Light Theme Variables */
  --bg-gradient-start: #f8fafc;
  --bg-gradient-end: #f1f5f9;
  --glass-header-bg: rgba(255, 255, 255, 0.8);
  --glass-border: rgba(226, 232, 240, 0.8);
  --text-main: #0f172a;
  --text-sub: #64748b;
  --text-placeholder: #94a3b8;
  --card-bg: #ffffff;
  --card-border: #f1f5f9;
  --card-shadow: 0 4px 20px rgba(148, 163, 184, 0.05);
  --input-bg: #ffffff;
  --input-border: #e2e8f0;
  --quick-tag-bg: #ffffff;
  --quick-tag-text: #475569;
  --quick-tag-border: #e2e8f0;
  --assistant-bubble-bg: #ffffff;
  --assistant-bubble-text: #334155;
  --assistant-bubble-border: #f1f5f9;
  --btn-hover-bg: #f1f5f9;
  --code-bg: #f1f5f9;
  
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: var(--bg-gradient-start);
  background-image: 
    radial-gradient(at 0% 0%, rgba(16, 185, 129, 0.1) 0px, transparent 50%),
    radial-gradient(at 100% 100%, rgba(59, 130, 246, 0.1) 0px, transparent 50%);
  position: relative;
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  color: var(--text-main);
  transition: background-color 0.3s ease, color 0.3s ease;
}

/* Dark Theme Overrides */
.assistant-container.dark-theme {
  --bg-gradient-start: #0f172a;
  --bg-gradient-end: #1e293b;
  --glass-header-bg: rgba(15, 23, 42, 0.8);
  --glass-border: rgba(51, 65, 85, 0.5);
  --text-main: #f1f5f9;
  --text-sub: #94a3b8;
  --text-placeholder: #64748b;
  --card-bg: #1e293b;
  --card-border: #334155;
  --card-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  --input-bg: #1e293b;
  --input-border: #334155;
  --quick-tag-bg: #1e293b;
  --quick-tag-text: #cbd5e1;
  --quick-tag-border: #334155;
  --assistant-bubble-bg: #1e293b;
  --assistant-bubble-text: #e2e8f0;
  --assistant-bubble-border: #334155;
  --btn-hover-bg: #334155;
  --code-bg: #0f172a;
}

/* Glass Header */
.glass-header {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 64px;
  background: var(--glass-header-bg);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--glass-border);
  z-index: 50;
  display: flex;
  align-items: center;
  padding: 0 24px;
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

.header-content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 99px;
  color: var(--text-sub);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.nav-btn:hover {
  background: var(--btn-hover-bg);
  color: var(--text-main);
}

.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
}

.logo-icon svg {
  width: 20px;
  height: 20px;
}

.title-text {
  display: flex;
  flex-direction: column;
}

.title-text h1 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
  margin: 0;
  line-height: 1.2;
}

.status-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  color: #10b981;
  font-weight: 500;
}

.status-dot {
  width: 6px;
  height: 6px;
  background: #10b981;
  border-radius: 50%;
  box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
}

.header-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 8px;
  border-radius: 8px;
  color: var(--text-sub);
  background: transparent;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
}

.action-btn:hover {
  background: var(--btn-hover-bg);
  color: #ef4444; /* Keep red for clear history, maybe dynamic for theme toggle? */
}
/* Theme toggle shouldn't be red on hover */
.action-btn:first-child:hover {
  color: #10b981;
}

/* Chat Main Area */
.chat-main {
  flex: 1;
  overflow-y: auto;
  padding: 84px 20px 180px; /* Top padding for header, bottom for footer */
  scroll-behavior: smooth;
}

.chat-content {
  max-width: 800px;
  margin: 0 auto;
}

/* Welcome Card */
.welcome-card {
  background: var(--card-bg);
  border-radius: 24px;
  padding: 40px;
  text-align: center;
  margin-bottom: 40px;
  box-shadow: var(--card-shadow);
  border: 1px solid var(--card-border);
  transition: all 0.3s ease;
}

.welcome-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 24px;
  color: #10b981;
  background: rgba(16, 185, 129, 0.1); /* transparent emerald */
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.welcome-icon svg {
  width: 32px;
  height: 32px;
}

.welcome-card h2 {
  font-size: 24px;
  color: var(--text-main);
  margin-bottom: 8px;
}

.welcome-card p {
  color: var(--text-sub);
  margin-bottom: 32px;
}

.capabilities-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.capability-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: var(--bg-gradient-end);
  border-radius: 12px;
  font-size: 14px;
  color: var(--text-sub);
  transition: all 0.2s;
}

.capability-item:hover {
  background: var(--card-bg);
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  transform: translateY(-2px);
  color: var(--text-main);
}

.cap-icon {
  color: #10b981;
}

.cap-icon svg {
  width: 20px;
  height: 20px;
}

/* Message Styles */
.message-row {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
  opacity: 1;
}

.message-row.user {
  flex-direction: row-reverse;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.avatar.assistant {
  background: var(--card-bg);
  border: 1px solid var(--card-border);
  color: #10b981;
}

.avatar.user {
  background: #10b981;
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
}

.avatar svg {
  width: 20px;
  height: 20px;
}

.message-content-wrapper {
  max-width: 70%;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.message-row.user .message-content-wrapper {
  align-items: flex-end;
}

.message-bubble {
  padding: 16px 20px;
  border-radius: 20px;
  font-size: 15px;
  line-height: 1.6;
  position: relative;
}

.message-row.assistant .message-bubble {
  background: var(--assistant-bubble-bg);
  color: var(--assistant-bubble-text);
  border-top-left-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--assistant-bubble-border);
}

.message-row.user .message-bubble {
  background: #10b981;
  color: white;
  border-top-right-radius: 4px;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
}

.message-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12px;
  color: var(--text-placeholder);
  padding: 0 4px;
}

.sources-tag {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #10b981;
  font-weight: 500;
}

.sources-panel {
  margin-top: 8px;
  background: var(--bg-gradient-end);
  border-radius: 12px;
  padding: 12px;
  border: 1px solid var(--card-border);
  font-size: 13px;
}

.sources-title {
  color: var(--text-sub);
  margin-bottom: 8px;
  font-weight: 500;
}

.source-item {
  color: var(--text-main);
  margin-bottom: 4px;
  padding-left: 12px;
  position: relative;
}

.source-item::before {
  content: "";
  position: absolute;
  left: 0;
  top: 8px;
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: var(--text-placeholder);
}

/* Loading State */
.message-bubble.typing {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 16px 24px;
}

.dot {
  width: 6px;
  height: 6px;
  background: var(--text-placeholder);
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.dot:nth-child(1) { animation-delay: -0.32s; }
.dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.thinking-text {
  font-size: 12px;
  color: var(--text-placeholder);
  margin-top: 4px;
  margin-left: 4px;
}

/* Input Footer */
.input-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 24px;
  /* Use a gradient mask or background that matches theme */
  background: linear-gradient(to top, var(--bg-gradient-start) 80%, rgba(0,0,0,0) 100%);
  z-index: 100;
}

.input-container-glass {
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.quick-tags-wrapper {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
  scrollbar-width: none;
}

.quick-tag {
  white-space: nowrap;
  padding: 8px 16px;
  background: var(--quick-tag-bg);
  border: 1px solid var(--quick-tag-border);
  border-radius: 20px;
  font-size: 13px;
  color: var(--quick-tag-text);
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 2px 6px rgba(0,0,0,0.02);
}

.quick-tag:hover {
  border-color: #10b981;
  color: #10b981;
  transform: translateY(-1px);
}

.input-box-wrapper {
  background: var(--input-bg);
  border-radius: 16px;
  padding: 8px;
  box-shadow: var(--card-shadow);
  border: 1px solid var(--input-border);
  display: flex;
  align-items: flex-end;
  gap: 12px;
  transition: all 0.2s;
}

.input-box-wrapper:focus-within {
  border-color: #10b981;
  box-shadow: 0 4px 24px rgba(16, 185, 129, 0.1);
}

.main-textarea {
  flex: 1;
  border: none;
  background: transparent;
  padding: 12px;
  font-size: 15px;
  color: var(--text-main);
  resize: none;
  max-height: 120px;
  outline: none;
  line-height: 1.5;
}

.main-textarea::placeholder {
  color: var(--text-placeholder);
}

.send-btn {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  border: none;
  background: var(--btn-hover-bg);
  color: var(--text-placeholder);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: not-allowed;
  transition: all 0.2s;
}

.send-btn.is-active {
  background: #10b981;
  color: white;
  cursor: pointer;
}

.send-btn.is-active:hover {
  background: #059669;
  transform: scale(1.05);
}

.send-btn svg {
  width: 20px;
  height: 20px;
  transform: rotate(45deg); /* Adjust icon orientation if needed */
  margin-right: 2px;
  margin-bottom: 2px;
}

/* Animations */
.fade-slide-up-enter-active,
.fade-slide-up-leave-active {
  transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}

.fade-slide-up-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.message-fade-enter-active {
  transition: all 0.4s ease-out;
}

.message-fade-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

/* Markdown Styles Adaptation */
:deep(.markdown-body) {
  color: var(--assistant-bubble-text);
  font-size: 15px;
  line-height: 1.6;
}

:deep(.markdown-body code) {
  background-color: var(--code-bg);
  padding: 2px 4px;
  border-radius: 4px;
  font-family: monospace;
}

/* Mobile Adaptation */
@media (max-width: 640px) {
  .header-content {
    padding: 0 16px;
  }
  
  .chat-main {
    padding: 72px 16px 160px;
  }
  
  .welcome-card {
    padding: 24px;
  }
  
  .capabilities-grid {
    grid-template-columns: 1fr;
  }
  
  .message-content-wrapper {
    max-width: 85%;
  }
  
  .input-footer {
    padding: 16px;
  }
  
  .nav-btn span {
    display: none;
  }
}
</style>
