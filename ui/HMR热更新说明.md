# HMR 热更新优化说明

## 问题描述
在开发过程中，每次修改代码后 Vite 的热模块替换（HMR）会导致页面刷新，登录状态丢失，需要重新登录。

## 解决方案

### 1. 创建持久化的认证状态管理 ✅
**文件**: `ui/src/composables/useAuth.ts`

使用模块级别的变量来保持登录状态，即使在 HMR 刷新时也不会丢失：

```typescript
// 使用模块级别的变量，在 HMR 时保持状态
let _username = ref<string | null>(null);
let _isInitialized = false;
```

**特点**:
- 模块级变量在 HMR 时不会被重置
- 自动从 localStorage 恢复登录状态
- 提供统一的登录/登出接口

### 2. 添加路由守卫 ✅
**文件**: `ui/src/router/index.ts`

添加全局导航守卫，自动检查登录状态：

```typescript
router.beforeEach((to, from, next) => {
  const username = localStorage.getItem('username');
  
  if (to.path !== '/login' && !username) {
    next('/login');
  } else if (to.path === '/login' && username) {
    next('/dashboard');
  } else {
    next();
  }
});
```

### 3. 优化 Vite 配置 ✅
**文件**: `ui/vite.config.ts`

优化 HMR 和依赖预构建配置：

```typescript
{
  server: {
    hmr: {
      overlay: true, // 显示错误覆盖层
    },
  },
  optimizeDeps: {
    include: ['vue', 'vue-router', 'axios'],
  },
}
```

### 4. 更新登录/登出逻辑 ✅
**文件**: 
- `ui/src/views/Login.vue`
- `ui/src/views/Dashboard.vue`

统一使用 `useAuth` composable 管理登录状态。

## 使用方法

### 在组件中使用 useAuth

```typescript
import { useAuth } from '@/composables/useAuth';

const { username, isLoggedIn, login, logout, checkAuth } = useAuth();

// 登录
login('username');

// 登出
logout();

// 检查登录状态
if (checkAuth()) {
  console.log('已登录:', username.value);
}
```

## 工作原理

1. **模块级状态**: `useAuth` 使用模块级变量存储状态，HMR 不会重置这些变量
2. **localStorage 同步**: 状态同时保存在 localStorage 中，页面完全刷新时也能恢复
3. **路由守卫**: 每次路由切换时检查登录状态，未登录自动跳转到登录页
4. **优化的 HMR**: Vite 配置优化减少不必要的完全刷新

## 测试步骤

1. 登录系统
2. 修改任意 Vue 文件（如添加注释）
3. 保存文件触发 HMR
4. 验证：页面应该热更新，但不需要重新登录

## 注意事项

- 如果修改了 `useAuth.ts` 本身，可能需要手动刷新页面
- 如果修改了路由配置，可能需要手动刷新页面
- 修改 Vite 配置后需要重启开发服务器

## 额外优化建议

如果仍然遇到频繁刷新的问题，可以：

1. **减少全局样式修改**: 全局样式修改可能触发完全刷新
2. **使用 scoped 样式**: 组件内使用 `<style scoped>` 可以更好地支持 HMR
3. **避免修改 main.ts**: 应用入口文件的修改通常会触发完全刷新
4. **检查浏览器控制台**: 查看 HMR 失败的具体原因

## 相关文件

- `ui/src/composables/useAuth.ts` - 认证状态管理
- `ui/src/router/index.ts` - 路由配置和守卫
- `ui/vite.config.ts` - Vite 配置
- `ui/src/views/Login.vue` - 登录页面
- `ui/src/views/Dashboard.vue` - 主页面
