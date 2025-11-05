<template>
  <div class="login-container">
    <div class="login-background">
      <div class="floating-shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
        <div class="shape shape-4"></div>
      </div>
    </div>
    
    <div class="login-card">
      <div class="login-header">
        <div class="logo">
          <div class="logo-icon">🌿</div>
          <h1>灵素养生平台</h1>
        </div>
        <p class="subtitle">传承中医智慧，守护现代健康</p>
      </div>

      <form @submit.prevent="onLogin" class="login-form">
        <div class="form-group">
          <label for="username">
            <i class="icon">◐</i>
            用户名
          </label>
          <input 
            id="username"
            v-model.trim="username" 
            placeholder="请输入用户名" 
            required
            :disabled="loading"
          />
        </div>

        <div class="form-group">
          <label for="password">
            <i class="icon">◑</i>
            密码
          </label>
          <input 
            id="password"
            v-model="password" 
            type="password" 
            placeholder="请输入密码" 
            required
            :disabled="loading"
          />
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary" :disabled="loading">
            <span v-if="loading" class="loading-spinner"></span>
            {{ loading ? '登录中...' : '登录' }}
          </button>
          <button type="button" @click="onRegister" class="btn btn-secondary" :disabled="loading">
            注册账号
          </button>
        </div>
      </form>

      <div v-if="msg" class="message" :class="{ 'success': isSuccess, 'error': !isSuccess }">
        <i class="message-icon">{{ isSuccess ? '●' : '○' }}</i>
        {{ msg }}
      </div>

      <div class="login-footer">
        <p>©灵素养生平台 - 您的健康管理专家</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const username = ref('');
const password = ref('');
const msg = ref('');
const loading = ref(false);
const isSuccess = ref(false);

async function post(url: string, body: any) {
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
    
    // 保存登录状态
    localStorage.setItem('token', 'logged-in');
    localStorage.setItem('username', username.value);
    
    msg.value = result || '登录成功';
    isSuccess.value = true;
    
    // 延迟跳转，让用户看到成功消息
    setTimeout(() => {
      router.push('/dashboard');
    }, 1000);
    
  } catch (e: any) {
    msg.value = e.message;
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
  } catch (e: any) {
    msg.value = e.message;
    isSuccess.value = false;
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.login-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  z-index: -1;
}

.floating-shapes {
  position: absolute;
  width: 100%;
  height: 100%;
}

.shape {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  animation: float 6s ease-in-out infinite;
}

.shape-1 {
  width: 80px;
  height: 80px;
  top: 20%;
  left: 10%;
  animation-delay: 0s;
}

.shape-2 {
  width: 120px;
  height: 120px;
  top: 60%;
  right: 10%;
  animation-delay: 2s;
}

.shape-3 {
  width: 60px;
  height: 60px;
  top: 80%;
  left: 20%;
  animation-delay: 4s;
}

.shape-4 {
  width: 100px;
  height: 100px;
  top: 10%;
  right: 30%;
  animation-delay: 1s;
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(180deg); }
}

.login-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 420px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.logo {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 16px;
}

.logo-icon {
  font-size: 48px;
  margin-bottom: 12px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.logo h1 {
  margin: 0;
  color: #2c3e50;
  font-size: 28px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  color: #666;
  font-size: 14px;
  margin: 0;
  font-style: italic;
}

.login-form {
  margin-bottom: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c3e50;
  font-size: 14px;
}

.form-group label .icon {
  margin-right: 8px;
  font-size: 16px;
}

.form-group input {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e1e8ed;
  border-radius: 12px;
  font-size: 16px;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.9);
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  transform: translateY(-2px);
}

.form-group input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

.form-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 24px;
}

.btn {
  padding: 14px 24px;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.btn:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
  background: transparent;
  color: #667eea;
  border: 2px solid #667eea;
}

.btn-secondary:hover:not(:disabled) {
  background: #667eea;
  color: white;
  transform: translateY(-2px);
}

.loading-spinner {
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

.message {
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  font-size: 14px;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.message.success {
  background: rgba(46, 204, 113, 0.1);
  color: #27ae60;
  border: 1px solid rgba(46, 204, 113, 0.2);
}

.message.error {
  background: rgba(231, 76, 60, 0.1);
  color: #e74c3c;
  border: 1px solid rgba(231, 76, 60, 0.2);
}

.message-icon {
  margin-right: 8px;
}

.login-footer {
  text-align: center;
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}

.login-footer p {
  margin: 0;
  color: #666;
  font-size: 12px;
}

/* 响应式设计 */
@media (max-width: 480px) {
  .login-card {
    margin: 20px;
    padding: 24px;
  }
  
  .logo h1 {
    font-size: 24px;
  }
  
  .form-actions {
    gap: 8px;
  }
}
</style>