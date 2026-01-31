import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

// 使用模块级别的变量，在 HMR 时保持状态
const _username = ref<string | null>(null);
let _isInitialized = false;

export function useAuth() {
  const router = useRouter();

  // 只在第一次调用时从 localStorage 初始化
  if (!_isInitialized) {
    _username.value = localStorage.getItem('username');
    _isInitialized = true;
  }

  const username = computed(() => _username.value);
  const isLoggedIn = computed(() => !!_username.value);

  const login = (user: string) => {
    _username.value = user;
    localStorage.setItem('username', user);
  };

  const logout = () => {
    _username.value = null;
    localStorage.removeItem('username');
    router.push('/login');
  };

  const checkAuth = () => {
    const stored = localStorage.getItem('username');
    if (stored && stored !== _username.value) {
      _username.value = stored;
    }
    return !!_username.value;
  };

  return {
    username,
    isLoggedIn,
    login,
    logout,
    checkAuth,
  };
}
