import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0', // 允许局域网访问
    port: 5173,
    strictPort: false,
    // 本地开发时不设置 clientPort，让 Vite 自动处理
    // 如果需要通过 Cpolar 等内网穿透工具访问，取消下面的注释
    // hmr: {
    //   clientPort: 443,
    // },
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
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
})
