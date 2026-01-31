<template>
  <div class="change-password-page">
    <!-- 动态背景元素 -->
    <div class="bg-shape shape-1"></div>
    <div class="bg-shape shape-2"></div>
    <div class="bg-shape shape-3"></div>

    <!-- 左上角返回按钮 -->
    <button class="back-btn back-top-left" @click="goHome">
      <div class="icon-wrapper">
        <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
      </div>
      <span>返回首页</span>
    </button>

    <div class="content-wrapper">
      <div class="page-header">
        <div class="header-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
          </svg>
        </div>
        <h2>安全中心</h2>
        <p class="subtitle">定期修改密码可以保护您的账号安全</p>
      </div>
      
      <div class="card-container">
        <form @submit.prevent="handleSubmit" class="change-password-form">
          <div class="form-group">
            <label for="username">用户名</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
              <input
                type="text"
                id="username"
                v-model="form.username"
                required
                placeholder="请输入用户名"
                class="modern-input"
              />
            </div>
          </div>

          <div class="form-group">
            <label for="currentPassword">当前密码</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
              <input
                :type="showCurrentPassword ? 'text' : 'password'"
                id="currentPassword"
                v-model="form.currentPassword"
                required
                placeholder="请输入当前密码"
                class="modern-input"
              />
              <button type="button" class="toggle-password" @click="showCurrentPassword = !showCurrentPassword">
                <svg v-if="!showCurrentPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                  <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                </svg>
              </button>
            </div>
          </div>

          <div class="form-group">
            <label for="newPassword">新密码</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
              <input
                :type="showNewPassword ? 'text' : 'password'"
                id="newPassword"
                v-model="form.newPassword"
                required
                placeholder="请输入新密码"
                class="modern-input"
                @input="checkPasswordStrength"
              />
              <button type="button" class="toggle-password" @click="showNewPassword = !showNewPassword">
                <svg v-if="!showNewPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                  <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                </svg>
              </button>
            </div>
            <!-- 密码强度条 -->
            <div class="password-strength" v-if="form.newPassword">
              <div class="strength-bar">
                <div class="fill" :style="{ width: strengthPercent + '%', background: strengthColor }"></div>
              </div>
              <span class="strength-text" :style="{ color: strengthColor }">{{ strengthText }}</span>
            </div>
          </div>

          <div class="form-group">
            <label for="confirmPassword">确认新密码</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <input
                :type="showConfirmPassword ? 'text' : 'password'"
                id="confirmPassword"
                v-model="form.confirmPassword"
                required
                placeholder="请再次输入新密码"
                class="modern-input"
              />
              <button type="button" class="toggle-password" @click="showConfirmPassword = !showConfirmPassword">
                <svg v-if="!showConfirmPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                  <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                </svg>
              </button>
            </div>
          </div>

          <div v-if="error" class="message error-message">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            {{ error }}
          </div>

          <div v-if="success" class="message success-message">
             <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ success }}
          </div>

          <div class="form-actions">
            <button type="submit" :disabled="loading" class="submit-btn">
              <span v-if="loading" class="spinner"></span>
              {{ loading ? '修改中...' : '确认修改' }}
            </button>
            <button type="button" @click="goBack" class="cancel-btn">
              取消
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { changePassword } from '../services/api'

defineOptions({ name: 'ChangePassword' })

const router = useRouter()

const form = ref({
  username: '',
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const loading = ref(false)
const error = ref('')
const success = ref('')
const showCurrentPassword = ref(false)
const showNewPassword = ref(false)
const showConfirmPassword = ref(false)

// 密码强度计算
const strengthScore = ref(0)

const checkPasswordStrength = () => {
  const pwd = form.value.newPassword
  let score = 0
  if (!pwd) {
    strengthScore.value = 0
    return
  }
  if (pwd.length >= 6) score += 1
  if (pwd.length >= 10) score += 1
  if (/[A-Z]/.test(pwd)) score += 1
  if (/[0-9]/.test(pwd)) score += 1
  if (/[^A-Za-z0-9]/.test(pwd)) score += 1
  
  strengthScore.value = score
}

const strengthPercent = computed(() => {
  return Math.min(100, (strengthScore.value / 5) * 100)
})

const strengthColor = computed(() => {
  if (strengthScore.value <= 2) return '#ef4444' // red
  if (strengthScore.value <= 3) return '#f59e0b' // yellow
  return '#10b981' // green
})

const strengthText = computed(() => {
  if (strengthScore.value === 0) return ''
  if (strengthScore.value <= 2) return '弱'
  if (strengthScore.value <= 3) return '中'
  return '强'
})

const validateForm = () => {
  if (!form.value.username.trim()) return '请输入用户名'
  if (!form.value.currentPassword) return '请输入当前密码'
  if (!form.value.newPassword) return '请输入新密码'
  if (form.value.newPassword.length < 6) return '新密码长度至少需6位'
  if (form.value.newPassword !== form.value.confirmPassword) return '两次输入的新密码不一致'
  if (form.value.currentPassword === form.value.newPassword) return '新密码不能与当前密码相同'
  return null
}

const handleSubmit = async () => {
  error.value = ''
  success.value = ''

  const validationError = validateForm()
  if (validationError) {
    error.value = validationError
    return
  }

  loading.value = true

  try {
    const response = await changePassword({
      username: form.value.username,
      currentPassword: form.value.currentPassword,
      newPassword: form.value.newPassword
    })
    
    // 假设API返回成功会 resolve
    // 如果是 fetch 可能会返回 string，这里假设 changePassword 处理了
    
    success.value = '密码修改成功，即将返回...'
    form.value = {
      username: '',
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
    
    setTimeout(() => {
      router.push('/dashboard')
    }, 2000)
    
  } catch (err: any) {
    error.value = err.response?.data?.message || err.message || '修改失败，请检查用户名和密码'
  } finally {
    loading.value = false
  }
}

const goHome = () => router.push('/dashboard')
const goBack = () => router.push('/dashboard')
</script>

<style scoped>
.change-password-page {
  min-height: 100vh;
  width: 100%;
  position: relative;
  background-color: #f0fdf4; /* Emerald-50 */
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* 动态背景图形 */
.bg-shape {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  z-index: 0;
  animation: float 20s infinite ease-in-out;
}

.shape-1 {
  width: 400px;
  height: 400px;
  background: rgba(16, 185, 129, 0.15);
  top: -100px;
  left: -100px;
  animation-delay: 0s;
}

.shape-2 {
  width: 300px;
  height: 300px;
  background: rgba(59, 130, 246, 0.15);
  bottom: -50px;
  right: -50px;
  animation-delay: -5s;
}

.shape-3 {
  width: 200px;
  height: 200px;
  background: rgba(245, 158, 11, 0.1);
  top: 40%;
  left: 60%;
  animation-delay: -10s;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

/* 返回按钮 */
.back-btn {
  position: absolute;
  top: 24px;
  left: 24px;
  z-index: 20;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 16px;
  border: none;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  border-radius: 99px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.back-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  background: white;
}

.back-btn span {
  font-size: 15px;
  font-weight: 600;
  color: #0f172a;
}

.icon-wrapper {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #ecfdf5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #10b981;
}

.back-icon {
  width: 18px;
  height: 18px;
}

/* 内容区域 */
.content-wrapper {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 500px;
  padding: 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 32px;
}

.header-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow: 0 10px 25px -5px rgba(16, 185, 129, 0.3);
  transform: rotate(-5deg);
}

.header-icon svg {
  width: 32px;
  height: 32px;
}

.page-header h2 {
  font-size: 28px;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 8px;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #64748b;
  font-size: 15px;
  margin: 0;
}

/* 卡片容器 */
.card-container {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 40px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
  border: 1px solid rgba(255, 255, 255, 0.8);
}

.form-group {
  margin-bottom: 24px;
}

.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #334155;
  margin-bottom: 8px;
  margin-left: 4px;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 16px;
  width: 20px;
  height: 20px;
  color: #94a3b8;
  pointer-events: none;
  transition: color 0.3s;
}

.modern-input {
  width: 100%;
  padding: 14px 44px; /* Left padding for icon */
  font-size: 15px;
  color: #0f172a;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modern-input:focus {
  outline: none;
  border-color: #10b981;
  background: white;
  box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
}

.modern-input:focus + .input-icon,
.input-wrapper:focus-within .input-icon {
  color: #10b981;
}

.toggle-password {
  position: absolute;
  right: 16px;
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.3s;
}

.toggle-password:hover {
  color: #475569;
}

.toggle-password svg {
  width: 20px;
  height: 20px;
}

/* 密码强度条 */
.password-strength {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.strength-bar {
  flex: 1;
  height: 4px;
  background: #e2e8f0;
  border-radius: 2px;
  overflow: hidden;
}

.fill {
  height: 100%;
  transition: all 0.3s ease;
}

.strength-text {
  font-size: 12px;
  font-weight: 600;
  min-width: 24px;
  text-align: right;
}

/* 消息提示 */
.message {
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 24px;
  animation: slideIn 0.3s ease;
}

.error-message {
  background: #fef2f2;
  color: #ef4444;
  border: 1px solid #fecaca;
}

.success-message {
  background: #ecfdf5;
  color: #10b981;
  border: 1px solid #a7f3d0;
}

.message svg {
  width: 18px;
  height: 18px;
}

/* 按钮组 */
.form-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 32px;
}

.submit-btn {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 16px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2);
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.3);
  filter: brightness(1.05);
}

.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.cancel-btn {
  width: 100%;
  padding: 14px;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  background: white;
  color: #64748b;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.cancel-btn:hover {
  border-color: #cbd5e1;
  color: #475569;
  background: #f8fafc;
}

.spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 640px) {
  .card-container {
    padding: 24px;
  }
  
  .page-header h2 {
    font-size: 24px;
  }
}
</style>