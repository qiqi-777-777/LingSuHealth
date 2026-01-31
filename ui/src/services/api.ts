import axios from 'axios';

// 开发环境使用代理，生产环境使用环境变量或默认代理
const baseURL = import.meta.env.VITE_API_BASE_URL || '/api';

const api = axios.create({ baseURL });

// 添加请求拦截器，自动添加用户认证信息
api.interceptors.request.use(
  (config) => {
    // 从localStorage获取用户名
    const username = localStorage.getItem('username');
    if (username) {
      config.headers['X-Username'] = username;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export const getAssessmentReport = (answers?: unknown) =>
  api.post('/assessment/report', answers).then(r => r.data);

export const getDailyPlan = (constitution?: string) =>
  api.get('/plan/daily', { params: { constitution } }).then(r => r.data);

export const postCheckin = (payload?: unknown) =>
  api.post('/checkin', payload).then(r => r.data);

export const getCheckinSummary = (days?: number) =>
  api.get('/checkin/summary', { params: { days } }).then(r => r.data);

export const checkTodayCheckin = () =>
  api.get('/checkin/check-today').then(r => r.data);

export const updateTodayCheckin = (payload?: unknown) =>
  api.put('/checkin/today', payload).then(r => r.data);

export const deleteCheckin = (date: string) =>
  api.delete(`/checkin/${date}`).then(r => r.data);

export const deleteCheckinById = (id: number) =>
  api.delete(`/checkin/id/${id}`).then(r => r.data);

export const searchKnowledge = (keyword: string) =>
  api.get('/knowledge/search', { params: { keyword } }).then(r => r.data);

export const getAllKnowledge = () =>
  api.get('/knowledge/all').then(r => r.data);

export const getKnowledgeById = (id: number) =>
  api.get(`/knowledge/${id}`).then(r => r.data);

export const getKnowledgeByCategory = (category: string) =>
  api.get(`/knowledge/category/${category}`).then(r => r.data);

export const getKnowledgeCategories = () =>
  api.get('/knowledge/categories').then(r => r.data);

export const createKnowledge = (data: unknown) =>
  api.post('/knowledge', data).then(r => r.data);

export const updateKnowledge = (id: number, data: unknown) =>
  api.put(`/knowledge/${id}`, data).then(r => r.data);

export const deleteKnowledge = (id: number) =>
  api.delete(`/knowledge/${id}`).then(r => r.data);

export const uploadKnowledgeImage = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return api.post('/knowledge/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }).then(r => r.data);
};

export const askAssistant = (question: string, history?: Array<{ role: string; content: string }>) =>
  api.post('/assistant/ask', { q: question, history }).then(r => r.data);

export const getSeasonTips = (season?: string) =>
  api.get('/season/tips', { params: { season } }).then(r => r.data);

export const getCurrentSeasonTip = () =>
  api.get('/season/current').then(r => r.data);

export const getDashboardMetrics = () =>
  api.get('/dashboard/metrics').then(r => r.data);

// 用户资料相关API
export const getUserProfile = () =>
  api.get('/user/profile').then(r => r.data);

export const updateUserProfile = (profile: unknown) =>
  api.put('/user/profile', profile).then(r => r.data);

// DeepSeek AI 健康分析相关API
export const analyzeHealthData = (checkinData: unknown) =>
  api.post('/checkin/ai/analyze-health', checkinData).then(r => r.data);

export const getHealthTrends = (days: number) =>
  api.get('/checkin/trends', { params: { days, _t: Date.now() } }).then(r => r.data);

export const generateHealthPlan = (analysisData: unknown) =>
  api.post('/checkin/ai/generate-plan', analysisData).then(r => r.data);

// 相生相克关系相关API
export const getAllInteractions = () =>
  api.get('/knowledge/interactions').then(r => r.data);

export const getInteractionsByItemId = (itemId: number) =>
  api.get(`/knowledge/interactions/item/${itemId}`).then(r => r.data);

export const getInteractionsByItemName = (itemName: string) =>
  api.get(`/knowledge/interactions/name/${itemName}`).then(r => r.data);

// 用户主题偏好相关API
export const getUserThemePreference = () =>
  api.get('/users/theme-preference').then(r => r.data);

export const saveUserThemePreference = (theme: string) =>
  api.post('/users/theme-preference', { theme }).then(r => r.data);

export const changePassword = (data: unknown) =>
  api.post('/auth/change-password', data).then(r => r.data);

// AI动态生成个性化方案
export const generateAIDynamicPlan = () =>
  api.post('/plan/ai-dynamic').then(r => r.data);
