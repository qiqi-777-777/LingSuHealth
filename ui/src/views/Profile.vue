<template>
  <div class="profile-container">
    <!-- 左上角返回首页 -->
    <button class="back-btn back-top-left" @click="goHome">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>
    <div class="profile-header">
      <h2>编辑个人资料</h2>
      <p class="subtitle">完善您的个人信息，获得更精准的养生建议</p>
    </div>

    <div class="profile-form-container">
      <form @submit.prevent="saveProfile" class="profile-form">
        <!-- 基本信息 -->
        <div class="form-section">
          <h3 class="section-title">
            基本信息
          </h3>
          
          <div class="form-row">
            <div class="form-group">
              <label for="username">用户名</label>
              <input
                id="username"
                v-model="profile.username"
                type="text"
                placeholder="请输入用户名"
                required
                :disabled="loading"
              />
            </div>
            
            <div class="form-group">
              <label for="email">邮箱</label>
              <input
                id="email"
                v-model="profile.email"
                type="email"
                placeholder="请输入邮箱地址"
                :disabled="loading"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="phone">手机号</label>
              <input
                id="phone"
                v-model="profile.phone"
                type="tel"
                placeholder="请输入手机号"
                :disabled="loading"
              />
            </div>
            
            <div class="form-group">
              <label for="gender">性别</label>
              <select id="gender" v-model="profile.gender" :disabled="loading">
                <option value="" disabled>请选择性别</option>
                <option value="male">男</option>
                <option value="female">女</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="birthDate">出生日期</label>
              <input
                id="birthDate"
                v-model="profile.birthDate"
                type="date"
                :disabled="loading"
              />
            </div>
            
            <div class="form-group">
              <label for="age">年龄</label>
              <input
                id="age"
                v-model.number="profile.age"
                type="number"
                placeholder="自动计算"
                readonly
                :disabled="loading"
              />
            </div>
          </div>
        </div>

        <!-- 身体信息 -->
        <div class="form-section">
          <h3 class="section-title">
            身体信息
          </h3>
          
          <div class="form-row">
            <div class="form-group">
              <label for="height">身高 (cm)</label>
              <input
                id="height"
                v-model.number="profile.height"
                type="number"
                placeholder="请输入身高"
                min="100"
                max="250"
                :disabled="loading"
              />
            </div>
            
            <div class="form-group">
              <label for="weight">体重 (kg)</label>
              <input
                id="weight"
                v-model.number="profile.weight"
                type="number"
                placeholder="请输入体重"
                min="30"
                max="200"
                step="0.1"
                :disabled="loading"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="bmi">BMI指数</label>
              <input
                id="bmi"
                v-model="profile.bmi"
                type="text"
                placeholder="自动计算"
                readonly
                :disabled="loading"
              />
            </div>
          </div>
        </div>

        <!-- 健康信息 -->
        <div class="form-section">
          <h3 class="section-title">
            健康信息
          </h3>
          
          <div class="form-group full-width">
            <label for="allergies">过敏史</label>
            <textarea
              id="allergies"
              v-model="profile.allergies"
              placeholder="请输入过敏史，如：花粉过敏、海鲜过敏等"
              rows="3"
              :disabled="loading"
            ></textarea>
          </div>

          <div class="form-group full-width">
            <label for="medicalHistory">既往病史</label>
            <textarea
              id="medicalHistory"
              v-model="profile.medicalHistory"
              placeholder="请输入既往病史"
              rows="3"
              :disabled="loading"
            ></textarea>
          </div>

          <div class="form-group full-width">
            <label for="medications">正在服用的药物</label>
            <textarea
              id="medications"
              v-model="profile.medications"
              placeholder="请输入正在服用的药物"
              rows="3"
              :disabled="loading"
            ></textarea>
          </div>
        </div>

        <!-- 按钮组 -->
        <div class="form-actions">
          <button type="button" @click="goBack" class="btn btn-secondary" :disabled="loading">
            返回
          </button>
          <button type="submit" class="btn btn-primary" :disabled="loading">
            <span v-if="loading" class="loading-spinner"></span>
            {{ loading ? '保存中...' : '保存资料' }}
          </button>
        </div>
      </form>
    </div>

    <!-- 消息提示 -->
    <div v-if="message" class="message" :class="{ 'success': isSuccess, 'error': !isSuccess }">
      {{ message }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getUserProfile, updateUserProfile } from '../services/api';

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
      console.log('API响应:', response); // 调试日志
      
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
          console.log('用户数据:', userData); // 调试日志
          
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
          
          console.log('合并后的profile:', profile.value); // 调试日志
        }
      }
    } catch (apiError) {
      // 如果API调用失败，不显示错误消息，只是使用默认值
      console.warn('无法加载用户资料，使用默认值:', apiError);
    }
    
  } catch (error) {
    console.error('加载用户资料失败:', error);
    // 不显示错误消息，允许用户继续编辑
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
    
    console.log('提交的数据:', submitData); // 调试日志
    
    // 调用后端API保存用户资料
    const response = await updateUserProfile(submitData);
    
    console.log('保存响应:', response); // 调试日志
    
    // 更新localStorage中的用户名
    localStorage.setItem('username', profile.value.username);
    
    showMessage('个人资料保存成功！', true);
    
    // 延迟返回
    setTimeout(() => {
      goBack();
    }, 1500);
    
  } catch (error: any) {
    console.error('保存用户资料失败:', error);
    const errorMessage = error.response?.data?.error || error.message || '保存失败，请重试';
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
.profile-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 80px 20px 20px 20px; /* 增加顶部padding给按钮留空间 */
  position: relative; /* 使左上角按钮锚定到本容器 */
  min-height: 100vh;
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
}

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
.profile-header {
  text-align: center;
  margin-bottom: 32px;
}

.profile-header h2 {
  margin: 0 0 8px 0;
  color: #2c3e50;
  font-size: 28px;
  font-weight: 600;
}

.subtitle {
  color: #666;
  font-size: 16px;
  margin: 0;
}

.profile-form-container {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  margin-bottom: 24px;
}

.form-section {
  margin-bottom: 32px;
}

.form-section:last-child {
  margin-bottom: 0;
}

.section-title {
  display: flex;
  align-items: center;
  margin: 0 0 20px 0;
  color: #2c3e50;
  font-size: 18px;
  font-weight: 600;
  padding-bottom: 8px;
  border-bottom: 2px solid #e9ecef;
}

.section-icon {
  margin-right: 8px;
  font-size: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  flex: 1;
}

.form-group.full-width {
  width: 100%;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  font-weight: 600;
  color: #2c3e50;
  font-size: 14px;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #e1e8ed;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s ease;
  background: white;
  box-sizing: border-box;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group input:disabled,
.form-group select:disabled,
.form-group textarea:disabled {
  background: #f8f9fa;
  cursor: not-allowed;
}

.form-group input[readonly] {
  background: #f8f9fa;
  color: #666;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #e9ecef;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 120px;
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

.btn-icon {
  margin-right: 6px;
  font-size: 16px;
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
  position: fixed;
  top: 10px;
  right: 20px;
  padding: 16px 20px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  font-size: 14px;
  font-weight: 500;
  z-index: 1000;
  animation: slideIn 0.3s ease;
  max-width: 400px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

@keyframes slideIn {
  from { opacity: 0; transform: translateX(100%); }
  to { opacity: 1; transform: translateX(0); }
}

.message.success {
  background: rgba(46, 204, 113, 0.1);
  color: #27ae60;
  border: 1px solid rgba(46, 204, 113, 0.3);
}

.message.error {
  background: rgba(231, 76, 60, 0.1);
  color: #e74c3c;
  border: 1px solid rgba(231, 76, 60, 0.3);
}

.message-icon {
  margin-right: 8px;
  font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .profile-container {
    padding: 80px 16px 16px 16px; /* 保持顶部padding给按钮留空间 */
  }
  
  .profile-form-container {
    padding: 24px 20px;
  }
  
  .form-row {
    flex-direction: column;
    gap: 16px;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
  }
}
</style>