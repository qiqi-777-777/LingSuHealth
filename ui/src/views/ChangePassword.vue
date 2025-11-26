<template>
  <div class="change-password-page">
    <!-- 左上角返回首页 -->
    <button class="back-btn back-top-left" @click="goHome">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>
    <div class="page-header">
      <h2>修改密码</h2>
    </div>
    
    <div class="page-content">
      <form @submit.prevent="handleSubmit" class="change-password-form">
        <div class="form-group">
          <label for="username">用户名:</label>
          <input
            type="text"
            id="username"
            v-model="form.username"
            required
            placeholder="请输入用户名"
          />
        </div>

        <div class="form-group">
          <label for="currentPassword">当前密码:</label>
          <input
            type="password"
            id="currentPassword"
            v-model="form.currentPassword"
            required
            placeholder="请输入当前密码"
          />
        </div>

        <div class="form-group">
          <label for="newPassword">新密码:</label>
          <input
            type="password"
            id="newPassword"
            v-model="form.newPassword"
            required
            placeholder="请输入新密码"
          />
        </div>

        <div class="form-group">
          <label for="confirmPassword">确认新密码:</label>
          <input
            type="password"
            id="confirmPassword"
            v-model="form.confirmPassword"
            required
            placeholder="请再次输入新密码"
          />
        </div>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <div v-if="success" class="success-message">
          {{ success }}
        </div>

        <div class="form-actions">
          <button type="submit" :disabled="loading" class="submit-btn">
            {{ loading ? '修改中...' : '修改密码' }}
          </button>
          <button type="button" @click="goBack" class="cancel-btn">
            返回
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

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

const validateForm = () => {
  if (!form.value.username.trim()) {
    return '请输入用户名'
  }
  if (!form.value.currentPassword) {
    return '请输入当前密码'
  }
  if (!form.value.newPassword) {
    return '请输入新密码'
  }
  if (form.value.newPassword !== form.value.confirmPassword) {
    return '两次输入的新密码不一致'
  }
  if (form.value.currentPassword === form.value.newPassword) {
    return '新密码不能与当前密码相同'
  }
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
    const response = await fetch('/api/auth/change-password', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        username: form.value.username,
        currentPassword: form.value.currentPassword,
        newPassword: form.value.newPassword
      })
    })

    const result = await response.text()

    if (response.ok) {
      success.value = result
      // 清空表单
      form.value = {
        username: '',
        currentPassword: '',
        newPassword: '',
        confirmPassword: ''
      }
      // 3秒后返回仪表盘
      setTimeout(() => {
        router.push('/dashboard')
      }, 3000)
    } else {
      error.value = result
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
  } finally {
    loading.value = false
  }
}

// 左上角返回首页按钮与底部“返回”统一到仪表盘
const goHome = () => {
  router.push('/dashboard')
}

const goBack = () => {
  router.push('/dashboard')
}
</script>

<style scoped>
.change-password-page {
  padding: 80px 20px 20px 20px; /* 增加顶部padding给按钮留空间 */
  max-width: 600px;
  margin: 0 auto;
  min-height: 100vh;
  position: relative; /* 使左上角按钮锚定到本容器 */
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
}


/* 按钮样式与仪表盘一致 */
/* 左上角返回按钮 */
.back-top-left {
  position: fixed;
  top: 10px;
  left: 20px;
  z-index: 9999;
}

/* 按钮样式 - 现代毛玻璃效果 */
.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 12px 24px;
  border-radius: 30px;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3),
              0 0 0 1px rgba(255, 255, 255, 0.1) inset;
  position: relative;
  overflow: hidden;
}

.back-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.back-btn:hover::before {
  opacity: 1;
}

.back-btn:hover {
  transform: translateY(-2px) translateX(-2px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.4),
              0 0 0 1px rgba(255, 255, 255, 0.2) inset;
  border-color: rgba(255, 255, 255, 0.2);
  background: rgba(0, 0, 0, 0.95);
}

.back-btn:active {
  transform: translateY(0) translateX(0);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.back-icon {
  width: 18px;
  height: 18px;
  transition: transform 0.3s ease;
  position: relative;
  z-index: 1;
}

.back-btn:hover .back-icon {
  transform: translateX(-3px);
}

.back-btn span {
  position: relative;
  z-index: 1;
}
.page-header {
  margin-bottom: 30px;
  margin-top: 20px; /* 增加顶部边距，避免被按钮遮挡 */
}

.page-header h2 {
  color: #333;
  font-size: 24px;
  margin: 0;
}

.page-content {
  background: white;
  border-radius: 8px;
  padding: 30px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.change-password-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-group label {
  font-weight: 500;
  color: #555;
}

.form-group input {
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
  transition: border-color 0.3s;
}

.form-group input:focus {
  outline: none;
  border-color: #007bff;
}

.error-message {
  color: #dc3545;
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 4px;
  padding: 10px;
  text-align: center;
}

.success-message {
  color: #155724;
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 4px;
  padding: 10px;
  text-align: center;
}

.form-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.submit-btn, .cancel-btn {
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.submit-btn {
  background-color: #007bff;
  color: white;
}

.submit-btn:hover:not(:disabled) {
  background-color: #0056b3;
}

.submit-btn:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

.cancel-btn {
  background-color: #6c757d;
  color: white;
}

.cancel-btn:hover {
  background-color: #545b62;
}
</style>