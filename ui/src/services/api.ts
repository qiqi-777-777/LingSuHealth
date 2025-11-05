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

export const getAssessmentReport = (answers?: any) =>
  api.post('/assessment/report', answers).then(r => r.data);

export const getDailyPlan = (constitution?: string) =>
  api.get('/plan/daily', { params: { constitution } }).then(r => r.data);

export const postCheckin = (payload?: any) =>
  api.post('/checkin', payload).then(r => r.data);

export const getCheckinSummary = () =>
  api.get('/checkin/summary').then(r => r.data);

export const searchKnowledge = (keyword: string) =>
  api.get('/knowledge/search', { params: { keyword } }).then(r => r.data);

export const askAssistant = (question: any) =>
  api.post('/assistant/ask', question).then(r => r.data);

export const getSeasonTips = (season?: string) =>
  api.get('/season/tips', { params: { season } }).then(r => r.data);

export const getCurrentSeasonTip = () =>
  api.get('/season/current').then(r => r.data);

export const getDashboardMetrics = () =>
  api.get('/dashboard/metrics').then(r => r.data);

// 用户资料相关API
export const getUserProfile = () =>
  api.get('/user/profile').then(r => r.data);

export const updateUserProfile = (profile: any) =>
  api.put('/user/profile', profile).then(r => r.data);

// DeepSeek AI 健康分析相关API
export const analyzeHealthData = (checkinData: any) =>
  api.post('/checkin/ai/analyze-health', checkinData).then(r => r.data);

export const getHealthTrends = (days: number) =>
  api.get('/checkin/trends', { params: { days } }).then(r => r.data);

export const generateHealthPlan = (analysisData: any) =>
  api.post('/checkin/ai/generate-plan', analysisData).then(r => r.data);