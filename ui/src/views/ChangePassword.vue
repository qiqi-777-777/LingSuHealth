<template>
  <div class="change-password-page">
    <!-- 左上角返回首页 -->
    <button class="back-btn back-top-left" @click="goHome">← 返回首页</button>
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
  padding: 20px;
  max-width: 600px;
  margin: 0 auto;
  position: relative; /* 使左上角按钮锚定到本容器 */
}

/* 左上角返回按钮 */
.back-top-left {
  position: absolute;
  top: 12px;
  left: 12px;
  z-index: 2;
}

/* 按钮样式与仪表盘一致 */
.back-btn {
  background: #ffffff;
  color: #6b7280;
  border: 2px solid #e9ecef;
  padding: 12px 24px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.back-btn:hover {
  border-color: #7c3aed;
  color: #7c3aed;
  transform: translateY(-1px);
}
.page-header {
  margin-bottom: 30px;
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