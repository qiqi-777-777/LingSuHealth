import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0', // 允许局域网访问
    port: 5173,
    strictPort: false,
    fs: {
      allow: ['..'],
    },
    // HMR 配置 - 优化热更新，避免完全刷新
    hmr: {
      overlay: true, // 显示错误覆盖层
    },
    proxy: {
      '/api': {
        target: 'http://localhost:8080', // 本地开发用这个
        // target: 'https://你的后端cpolar地址.cpolar.cn', // 内网穿透时改成这个
        changeOrigin: true,
      },
    },
  },
  // 允许任何主机访问（解决 Cpolar 域名限制）
  preview: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: false,
  },
  // 优化依赖预构建，减少页面刷新
  optimizeDeps: {
    include: ['vue', 'vue-router', 'axios'],
  },
})
