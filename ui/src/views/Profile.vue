<template>
  <div class="profile-page">
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
            <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
          </svg>
        </div>
        <h2>个人资料</h2>
        <p class="subtitle">完善信息，让 AI 为您提供更精准的健康建议</p>
      </div>

      <div class="card-container">
        <form @submit.prevent="saveProfile" class="profile-form">
          <!-- 基本信息 -->
          <div class="form-section">
            <h3 class="section-title">
              <span class="title-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              </span>
              基本信息
            </h3>
            
            <div class="form-grid">
              <div class="form-group">
                <label for="username">用户名</label>
                <div class="input-wrapper">
                  <input
                    id="username"
                    v-model="profile.username"
                    type="text"
                    placeholder="请输入用户名"
                    required
                    :disabled="loading"
                    class="modern-input"
                  />
                </div>
              </div>
              
              <div class="form-group">
                <label for="email">邮箱</label>
                <div class="input-wrapper">
                  <input
                    id="email"
                    v-model="profile.email"
                    type="email"
                    placeholder="请输入邮箱地址"
                    :disabled="loading"
                    class="modern-input"
                  />
                </div>
              </div>

              <div class="form-group">
                <label for="phone">手机号</label>
                <div class="input-wrapper">
                  <input
                    id="phone"
                    v-model="profile.phone"
                    type="tel"
                    placeholder="请输入手机号"
                    :disabled="loading"
                    class="modern-input"
                  />
                </div>
              </div>
              
              <div class="form-group">
                <label for="gender">性别</label>
                <div class="input-wrapper">
                  <select id="gender" v-model="profile.gender" :disabled="loading" class="modern-input modern-select">
                    <option value="" disabled>请选择性别</option>
                    <option value="male">男</option>
                    <option value="female">女</option>
                  </select>
                  <svg class="select-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M6 9l6 6 6-6"/>
                  </svg>
                </div>
              </div>

              <div class="form-group">
                <label for="birthDate">出生日期</label>
                <div class="input-wrapper">
                  <input
                    id="birthDate"
                    v-model="profile.birthDate"
                    type="date"
                    :disabled="loading"
                    class="modern-input"
                  />
                </div>
              </div>
              
              <div class="form-group">
                <label for="age">年龄</label>
                <div class="input-wrapper">
                  <input
                    id="age"
                    v-model.number="profile.age"
                    type="number"
                    placeholder="自动计算"
                    readonly
                    :disabled="loading"
                    class="modern-input readonly"
                  />
                </div>
              </div>
            </div>
          </div>

          <!-- 身体信息 -->
          <div class="form-section">
            <h3 class="section-title">
              <span class="title-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
              </span>
              身体信息
            </h3>
            
            <div class="form-grid">
              <div class="form-group">
                <label for="height">身高 (cm)</label>
                <div class="input-wrapper">
                  <input
                    id="height"
                    v-model.number="profile.height"
                    type="number"
                    placeholder="请输入身高"
                    min="100"
                    max="250"
                    :disabled="loading"
                    class="modern-input"
                  />
                </div>
              </div>
              
              <div class="form-group">
                <label for="weight">体重 (kg)</label>
                <div class="input-wrapper">
                  <input
                    id="weight"
                    v-model.number="profile.weight"
                    type="number"
                    placeholder="请输入体重"
                    min="30"
                    max="200"
                    step="0.1"
                    :disabled="loading"
                    class="modern-input"
                  />
                </div>
              </div>

              <div class="form-group full-width">
                <label for="bmi">BMI指数</label>
                <div class="input-wrapper">
                  <input
                    id="bmi"
                    v-model="profile.bmi"
                    type="text"
                    placeholder="自动计算"
                    readonly
                    :disabled="loading"
                    class="modern-input readonly"
                  />
                  <div v-if="profile.bmi" class="bmi-badge" :class="getBmiClass(Number(profile.bmi))">
                    {{ getBmiLabel(Number(profile.bmi)) }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 健康信息 -->
          <div class="form-section">
            <h3 class="section-title">
              <span class="title-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
              </span>
              健康信息
            </h3>
            
            <div class="form-group full-width">
              <label for="allergies">过敏史</label>
              <div class="input-wrapper">
                <textarea
                  id="allergies"
                  v-model="profile.allergies"
                  placeholder="请输入过敏史，如：花粉过敏、海鲜过敏等"
                  rows="2"
                  :disabled="loading"
                  class="modern-textarea"
                ></textarea>
              </div>
            </div>

            <div class="form-group full-width">
              <label for="medicalHistory">既往病史</label>
              <div class="input-wrapper">
                <textarea
                  id="medicalHistory"
                  v-model="profile.medicalHistory"
                  placeholder="请输入既往病史"
                  rows="2"
                  :disabled="loading"
                  class="modern-textarea"
                ></textarea>
              </div>
            </div>

            <div class="form-group full-width">
              <label for="medications">正在服用的药物</label>
              <div class="input-wrapper">
                <textarea
                  id="medications"
                  v-model="profile.medications"
                  placeholder="请输入正在服用的药物"
                  rows="2"
                  :disabled="loading"
                  class="modern-textarea"
                ></textarea>
              </div>
            </div>
          </div>

          <!-- 消息提示 -->
          <div v-if="message" class="message" :class="isSuccess ? 'success-message' : 'error-message'">
            <svg v-if="isSuccess" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            {{ message }}
          </div>

          <!-- 按钮组 -->
          <div class="form-actions">
            <button type="button" @click="goBack" class="cancel-btn" :disabled="loading">
              返回
            </button>
            <button type="submit" class="submit-btn" :disabled="loading">
              <span v-if="loading" class="spinner"></span>
              {{ loading ? '保存中...' : '保存资料' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getUserProfile, updateUserProfile } from '../services/api';

defineOptions({ name: 'ProfileView' });

const router = useRouter();

// 响应式数据
const loading = ref(false);
const message = ref('');
const isSuccess = ref(false);

// 用户资料数据
const profile = ref({
  username: '',
  email: '',
  phone: '',
  gender: '',
  birthDate: '',
  age: null as number | null,
  height: null as number | null,
  weight: null as number | null,
  bmi: '',
  allergies: '',
  medicalHistory: '',
  medications: ''
});

// 计算年龄
watch(() => profile.value.birthDate, (newDate) => {
  if (newDate) {
    const today = new Date();
    const birthDate = new Date(newDate);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    profile.value.age = age;
  } else {
    profile.value.age = null;
  }
});

// 计算BMI
const bmiValue = computed(() => {
  if (profile.value.height && profile.value.weight) {
    const heightInMeters = profile.value.height / 100;
    const bmi = profile.value.weight / (heightInMeters * heightInMeters);
    return bmi.toFixed(1);
  }
  return '';
});

watch(bmiValue, (newBmi) => {
  profile.value.bmi = newBmi;
});

// BMI Helper functions
const getBmiClass = (bmi: number) => {
  if (bmi < 18.5) return 'bmi-underweight';
  if (bmi < 24) return 'bmi-normal';
  if (bmi < 28) return 'bmi-overweight';
  return 'bmi-obese';
};

const getBmiLabel = (bmi: number) => {
  if (bmi < 18.5) return '偏瘦';
  if (bmi < 24) return '正常';
  if (bmi < 28) return '偏胖';
  return '肥胖';
};

// 页面加载时获取用户信息
onMounted(async () => {
  await loadProfile();
});

// 加载用户资料
async function loadProfile() {
  try {
    loading.value = true;
    
    // 从localStorage获取基本信息
    const savedUsername = localStorage.getItem('username');
    if (savedUsername) {
      profile.value.username = savedUsername;
    }
    
    // 从后端API获取完整的用户资料
    try {
      const response = await getUserProfile();
      
      // 检查响应数据结构并合并
      if (response) {
        let userData = null;
        
        // 如果响应包含profile字段
        if (response.profile) {
          userData = response.profile;
        } else if (response.username || response.email || response.phone) {
          // 如果响应直接是用户数据
          userData = response;
        }
        
        if (userData) {
          // 安全地合并数据，确保类型正确
          profile.value.username = userData.username || profile.value.username;
          profile.value.email = userData.email || '';
          profile.value.phone = userData.phone || '';
          profile.value.gender = userData.gender || '';
          profile.value.birthDate = userData.birthDate || '';
          profile.value.age = userData.age || '';
          profile.value.height = userData.height || null;
          profile.value.weight = userData.weight || null;
          profile.value.bmi = userData.bmi || '';
          profile.value.allergies = userData.allergies || '';
          profile.value.medicalHistory = userData.medicalHistory || '';
          profile.value.medications = userData.medications || '';
        }
      }
    } catch (apiError) {
      console.warn('无法加载用户资料，使用默认值:', apiError);
    }
    
  } catch (error) {
    console.error('加载用户资料失败:', error);
  } finally {
    loading.value = false;
  }
}

// 保存用户资料
async function saveProfile() {
  try {
    loading.value = true;
    message.value = '';
    
    // 表单验证
    if (!profile.value.username) {
      showMessage('请填写用户名', false);
      return;
    }
    
    // 准备提交的数据，确保类型正确
    const submitData = {
      ...profile.value,
      // 确保数字类型正确
      height: profile.value.height ? Number(profile.value.height) : null,
      weight: profile.value.weight ? Number(profile.value.weight) : null,
      age: profile.value.age ? Number(profile.value.age) : null,
      // 确保字符串类型正确，gender不能为空字符串或null
      gender: profile.value.gender && profile.value.gender !== '' ? profile.value.gender : undefined,
      email: profile.value.email || null,
      phone: profile.value.phone || null,
      allergies: profile.value.allergies || null,
      medicalHistory: profile.value.medicalHistory || null,
      medications: profile.value.medications || null
    };
    
    // 如果gender为undefined，从提交数据中删除该字段
    if (submitData.gender === undefined) {
      delete submitData.gender;
    }
    
    // 调用后端API保存用户资料
    await updateUserProfile(submitData);
    
    // 更新localStorage中的用户名
    localStorage.setItem('username', profile.value.username);
    
    showMessage('个人资料保存成功！', true);
    
    // 延迟返回
    setTimeout(() => {
      goHome();
    }, 1500);
    
  } catch (error) {
    console.error('保存用户资料失败:', error);
    const errorMessage = error instanceof Error ? error.message : '保存失败，请重试';
    showMessage(errorMessage, false);
  } finally {
    loading.value = false;
  }
}

// 显示消息
function showMessage(msg: string, success: boolean) {
  message.value = msg;
  isSuccess.value = success;
  
  // 3秒后自动清除消息
  setTimeout(() => {
    message.value = '';
  }, 3000);
}

// 返回首页（编辑资料页面走 /dashboard）
function goHome() {
  router.push('/dashboard');
}

// 返回上一页
function goBack() {
  router.back();
}
</script>

<style scoped>
.profile-page {
  min-height: 100vh;
  width: 100%;
  position: relative;
  background-color: #f0fdf4; /* Emerald-50 */
  overflow-x: hidden;
  padding: 80px 20px 40px;
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
  width: 500px;
  height: 500px;
  background: rgba(16, 185, 129, 0.1);
  top: -100px;
  left: -100px;
  animation-delay: 0s;
}

.shape-2 {
  width: 400px;
  height: 400px;
  background: rgba(59, 130, 246, 0.1);
  bottom: -50px;
  right: -50px;
  animation-delay: -5s;
}

.shape-3 {
  width: 300px;
  height: 300px;
  background: rgba(245, 158, 11, 0.08);
  top: 30%;
  left: 50%;
  animation-delay: -10s;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

/* 返回按钮 */
.back-btn {
  position: fixed;
  top: 24px;
  left: 24px;
  z-index: 100;
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
  max-width: 800px;
  margin: 0 auto;
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

.form-section {
  margin-bottom: 32px;
  padding-bottom: 32px;
  border-bottom: 1px solid #f1f5f9;
}

.form-section:last-child {
  border-bottom: none;
  padding-bottom: 0;
  margin-bottom: 0;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: 700;
  color: #0f172a;
  margin-bottom: 24px;
}

.title-icon {
  width: 32px;
  height: 32px;
  border-radius: 10px;
  background: #ecfdf5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #10b981;
}

.title-icon svg {
  width: 18px;
  height: 18px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.form-group {
  margin-bottom: 0;
}

.form-group.full-width {
  grid-column: span 2;
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

.modern-input,
.modern-textarea {
  width: 100%;
  padding: 12px 16px;
  font-size: 15px;
  color: #0f172a;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 14px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modern-textarea {
  resize: vertical;
  min-height: 80px;
}

.modern-input:focus,
.modern-textarea:focus {
  outline: none;
  border-color: #10b981;
  background: white;
  box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
}

.modern-input.readonly {
  background: #f1f5f9;
  cursor: default;
  border-color: #e2e8f0;
}

.modern-select {
  appearance: none;
  cursor: pointer;
}

.select-arrow {
  position: absolute;
  right: 16px;
  width: 20px;
  height: 20px;
  color: #94a3b8;
  pointer-events: none;
}

.bmi-badge {
  position: absolute;
  right: 12px;
  padding: 4px 10px;
  border-radius: 99px;
  font-size: 12px;
  font-weight: 600;
}

.bmi-underweight { background: #fee2e2; color: #ef4444; }
.bmi-normal { background: #ecfdf5; color: #10b981; }
.bmi-overweight { background: #ffedd5; color: #f97316; }
.bmi-obese { background: #fef2f2; color: #dc2626; }

/* 消息提示 */
.message {
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 24px 0;
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
  justify-content: flex-end;
  gap: 12px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f1f5f9;
}

.submit-btn {
  padding: 12px 32px;
  border: none;
  border-radius: 14px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  font-size: 15px;
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
  padding: 12px 24px;
  border: 2px solid #e2e8f0;
  border-radius: 14px;
  background: white;
  color: #64748b;
  font-size: 15px;
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
  width: 16px;
  height: 16px;
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
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .form-group.full-width {
    grid-column: span 1;
  }
  
  .form-actions {
    flex-direction: column-reverse;
  }
  
  .submit-btn, .cancel-btn {
    width: 100%;
  }
}
</style>