<template>
  <div class="login-page">
    <!-- 1. 高清背景图与渐变遮罩 -->
    <div class="bg-wrapper">
      <img
        src="https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=2070&auto=format&fit=crop"
        alt="Dark Nature"
        class="bg-image"
      />
      <div class="bg-gradient"></div>
    </div>

    <!-- 2. 背景氛围光晕 (AI 呼吸感) -->
    <div class="ambient-light"></div>

    <!-- 3. 登录面板容器 (高保真毛玻璃效果) -->
    <div class="login-panel">
      <!-- 顶部 Logo 与标题区 -->
      <div class="panel-header">
        <div class="sparkles-container">
          <svg class="icon-sparkles" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/></svg>
        </div>

        <div class="logo-box">
          <svg class="icon-leaf" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/></svg>
        </div>

        <h1 class="title">灵素养生平台</h1>
        <p class="subtitle">登入您的个人健康数字孪生系统</p>
      </div>

      <!-- 表单输入区 -->
      <form class="login-form" @submit.prevent="onLogin">
        <!-- 用户名 -->
        <div class="input-group" :class="{ 'focused': isUsernameFocused }">
          <div class="input-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          </div>
          <input
            type="text"
            v-model.trim="username"
            placeholder="请输入用户名或手机号"
            class="form-input"
            @focus="isUsernameFocused = true"
            @blur="isUsernameFocused = false"
            :disabled="loading"
          />
        </div>

        <!-- 密码 -->
        <div class="input-group" :class="{ 'focused': isPasswordFocused }">
          <div class="input-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          </div>
          <input
            :type="showPassword ? 'text' : 'password'"
            v-model="password"
            placeholder="请输入登录密码"
            class="form-input"
            @focus="isPasswordFocused = true"
            @blur="isPasswordFocused = false"
            :disabled="loading"
          />
          <button type="button" @click="showPassword = !showPassword" class="input-action-btn">
            <svg v-if="showPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><line x1="2" x2="22" y1="2" y2="22"/></svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>
          </button>
        </div>

        <!-- 辅助选项：记住我 & 忘记密码 -->
        <div class="form-options">
          <label class="remember-label">
            <div class="checkbox-box" :class="{ active: rememberMe }">
              <svg v-if="rememberMe" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" class="check-icon"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <input type="checkbox" v-model="rememberMe" class="hidden-input" />
            <span class="remember-text">保持登录</span>
          </label>
          <a href="#" class="forgot-link">忘记密码?</a>
        </div>

        <!-- 错误提示 -->
        <div v-if="msg" class="message" :class="{ 'success': isSuccess, 'error': !isSuccess }">
          {{ msg }}
        </div>

        <!-- 主按钮 -->
        <button type="submit" class="submit-btn" :disabled="loading">
          <span v-if="loading" class="spinner"></span>
          {{ loading ? '进入中...' : '进入系统' }}
          <svg v-if="!loading" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="arrow-right"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
        </button>
      </form>

      <!-- 分割线 -->
      <div class="divider">
        <div class="line"></div>
        <span>快速登录</span>
        <div class="line"></div>
      </div>

      <!-- 第三方登录 & 注册入口 -->
      <div class="bottom-actions">
        <button class="social-btn">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg>
        </button>
        
        <p class="register-tip">
          还没体验过 AI 养生？
          <a href="#" @click.prevent="onRegister" class="register-link">立即注册</a>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuth } from '../composables/useAuth';

defineOptions({ name: 'LoginView' });

const router = useRouter();
const { login: setAuth } = useAuth();

const username = ref('root');
const password = ref('password123');
const showPassword = ref(false);
const rememberMe = ref(false);
const isUsernameFocused = ref(false);
const isPasswordFocused = ref(false);

const msg = ref('');
const loading = ref(false);
const isSuccess = ref(false);

type AuthRequest = {
  username: string;
  password: string;
};

async function post(url: string, body: AuthRequest) {
  const res = await fetch(`/api/auth/${url}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(text || '请求失败');
  return text;
}

async function onLogin() {
  if (!username.value || !password.value) {
    msg.value = '请输入用户名和密码';
    isSuccess.value = false;
    return;
  }

  loading.value = true;
  msg.value = '';
  
  try {
    const result = await post('login', { 
      username: username.value, 
      password: password.value 
    });
    
    // 使用 useAuth 保存登录状态
    setAuth(username.value);
    
    msg.value = result || '登录成功';
    isSuccess.value = true;
    
    // 延迟跳转，让用户看到成功消息
    setTimeout(() => {
      router.push('/dashboard');
    }, 1000);
    
  } catch (e) {
    msg.value = e instanceof Error ? e.message : '登录失败';
    isSuccess.value = false;
  } finally {
    loading.value = false;
  }
}

async function onRegister() {
  if (!username.value || !password.value) {
    msg.value = '请输入用户名和密码';
    isSuccess.value = false;
    return;
  }

  loading.value = true;
  msg.value = '';
  
  try {
    const result = await post('register', { 
      username: username.value, 
      password: password.value 
    });
    msg.value = result || '注册成功，请登录';
    isSuccess.value = true;
  } catch (e) {
    msg.value = e instanceof Error ? e.message : '注册失败';
    isSuccess.value = false;
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
/* Reset some basics */
button {
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  outline: none;
}
input {
  outline: none;
}
a {
  text-decoration: none;
}

.login-page {
  min-height: 100vh;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  overflow: hidden;
  background-color: #050A08;
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

@media (min-width: 1024px) {
  .login-page {
    justify-content: flex-end;
    padding-left: 10%;
    padding-right: 10%;
  }
}

/* 1. 高清背景图与渐变遮罩 */
.bg-wrapper {
  position: absolute;
  inset: 0;
  z-index: 0;
}

.bg-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.5;
  transform: scale(1.05);
}

.bg-gradient {
  position: absolute;
  inset: 0;
  background: linear-gradient(to right, rgba(5, 10, 8, 0.3), rgba(5, 10, 8, 0.6), rgba(5, 10, 8, 0.95));
}

/* 2. 背景氛围光晕 */
.ambient-light {
  position: absolute;
  top: 50%;
  right: 50%;
  transform: translate(50%, -50%);
  width: 600px;
  height: 600px;
  background-color: rgba(5, 150, 105, 0.2);
  filter: blur(120px);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

@media (min-width: 1024px) {
  .ambient-light {
    right: 8%;
    transform: translate(0, -50%);
  }
}

/* 3. 登录面板容器 */
.login-panel {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 420px;
  background-color: rgba(10, 17, 13, 0.6);
  backdrop-filter: blur(40px);
  -webkit-backdrop-filter: blur(40px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 2.5rem;
  padding: 2.5rem;
  box-shadow: 0 20px 60px -15px rgba(0, 0, 0, 0.5);
  box-sizing: border-box;
}

/* 顶部 Logo 与标题区 */
.panel-header {
  margin-bottom: 2.5rem;
  position: relative;
}

.sparkles-container {
  position: absolute;
  top: -1rem;
  right: -1rem;
  color: rgba(16, 185, 129, 0.3);
  width: 48px;
  height: 48px;
}

.logo-box {
  width: 3.5rem;
  height: 3.5rem;
  background: linear-gradient(to bottom right, rgba(16, 185, 129, 0.2), rgba(20, 184, 166, 0.1));
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
  box-shadow: 0 0 20px rgba(16, 185, 129, 0.15);
}

.icon-leaf {
  color: #34d399;
  width: 28px;
  height: 28px;
}

.title {
  font-size: 1.875rem;
  line-height: 2.25rem;
  font-weight: 700;
  letter-spacing: -0.025em;
  margin: 0 0 0.5rem 0;
  background-clip: text;
  -webkit-background-clip: text;
  color: transparent;
  background-image: linear-gradient(to right, #ffffff, #9ca3af);
}

.subtitle {
  font-size: 0.875rem;
  font-weight: 500;
  color: rgba(52, 211, 153, 0.8);
  letter-spacing: 0.025em;
  margin: 0;
}

/* 表单输入区 */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.input-group {
  position: relative;
}

.input-icon {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  padding-left: 1rem;
  display: flex;
  align-items: center;
  pointer-events: none;
  color: #6b7280;
  transition: color 0.3s;
}

.input-icon svg {
  width: 18px;
  height: 18px;
}

.input-group.focused .input-icon {
  color: #34d399;
}

.form-input {
  width: 100%;
  padding: 0.875rem 1rem 0.875rem 2.75rem;
  background-color: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 0.75rem;
  color: #ffffff;
  font-size: 1rem;
  line-height: 1.5rem;
  box-sizing: border-box;
  transition: all 0.3s;
}

.input-group input[type="password"]::-webkit-reveal,
.input-group input[type="password"]::-webkit-contacts-auto-fill-button {
  display: none !important;
}

.form-input::placeholder {
  color: #6b7280;
}

.form-input:focus {
  background-color: rgba(255, 255, 255, 0.1);
  border-color: rgba(16, 185, 129, 0.5);
  box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
}

.form-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.input-action-btn {
  position: absolute;
  top: 0;
  bottom: 0;
  right: 0;
  padding-right: 1rem;
  display: flex;
  align-items: center;
  color: #6b7280;
  transition: color 0.3s;
}

.input-action-btn:hover {
  color: #ffffff;
}

.input-action-btn svg {
  width: 18px;
  height: 18px;
}

/* 辅助选项 */
.form-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 0.25rem;
  padding-bottom: 0.5rem;
}

.remember-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.checkbox-box {
  width: 1rem;
  height: 1rem;
  border-radius: 0.25rem;
  border: 1px solid #6b7280;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  box-sizing: border-box;
}

.checkbox-box.active {
  background-color: #10b981;
  border-color: #10b981;
}

.remember-label:hover .checkbox-box.empty {
  border-color: #34d399;
}

.check-icon {
  width: 12px;
  height: 12px;
  color: #ffffff;
}

.hidden-input {
  display: none;
}

.remember-text {
  font-size: 0.875rem;
  color: #9ca3af;
  transition: color 0.3s;
}

.remember-label:hover .remember-text {
  color: #d1d5db;
}

.forgot-link {
  font-size: 0.875rem;
  color: #10b981;
  transition: color 0.3s;
}

.forgot-link:hover {
  color: #34d399;
}

/* 主按钮 */
.submit-btn {
  width: 100%;
  padding: 0.875rem;
  background-image: linear-gradient(to right, #059669, #14b8a6);
  color: #ffffff;
  font-weight: 500;
  font-size: 1rem;
  border-radius: 0.75rem;
  box-shadow: 0 0 20px rgba(16, 185, 129, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.submit-btn:hover:not(:disabled) {
  background-image: linear-gradient(to right, #10b981, #2dd4bf);
  box-shadow: 0 0 30px rgba(16, 185, 129, 0.4);
}

.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.arrow-right {
  width: 18px;
  height: 18px;
  margin-left: 0.5rem;
  transition: transform 0.3s;
}

.submit-btn:hover:not(:disabled) .arrow-right {
  transform: translateX(4px);
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-right: 8px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* 消息提示 */
.message {
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  text-align: center;
  animation: slideIn 0.3s ease;
}

.message.success {
  background-color: rgba(16, 185, 129, 0.1);
  color: #10b981;
  border: 1px solid rgba(16, 185, 129, 0.2);
}

.message.error {
  background-color: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.2);
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 分割线 */
.divider {
  margin-top: 2rem;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
}

.divider .line {
  flex: 1;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.divider span {
  padding: 0 0.75rem;
  font-size: 0.75rem;
  color: #6b7280;
}

/* 第三方登录 & 注册入口 */
.bottom-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.social-btn {
  width: 3rem;
  height: 3rem;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
  transition: all 0.3s;
}

.social-btn:hover {
  background-color: rgba(255, 255, 255, 0.1);
  color: #07C160;
}

.social-btn svg {
  width: 22px;
  height: 22px;
  transition: transform 0.3s;
}

.social-btn:hover svg {
  transform: scale(1.1);
}

.register-tip {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0;
}

.register-link {
  color: #10b981;
  font-weight: 500;
  transition: all 0.3s;
  text-decoration-thickness: 1px;
  text-underline-offset: 4px;
}

.register-link:hover {
  color: #34d399;
  text-decoration: underline;
}
</style>
