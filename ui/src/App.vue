<template>
  <MascotWidget />
  <router-view />
</template>

<script setup lang="ts">
import MascotWidget from './components/MascotWidget.vue';
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  line-height: 1.6;
  color: #333;
  background: #f8f9fa;
}

#app {
  min-height: 100vh;
}

/* 全局滚动条样式 */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>

<style>
/* 统一滚动：只让 #app 滚动，避免 body 与内部容器各自出现滚动条 */
html,
body {
  height: 100%;
}

body {
  overflow: hidden;
}

#app {
  height: 100%;
  overflow-y: auto;
}

/* 只定制 #app 自己的滚动条，减少嵌套滚动条的视觉干扰 */
#app::-webkit-scrollbar {
  width: 8px;
}

#app::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

#app::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

#app::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
