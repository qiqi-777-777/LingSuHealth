<script setup lang="ts">
import { ref } from 'vue';
import { searchKnowledge } from '../services/api';

const keyword = ref('枸杞');
const results = ref<any[]>([]);
async function run() {
  results.value = await searchKnowledge(keyword.value);
}
run();
</script>

<template>
  <h3>中西食材/药材知识库</h3>
  <input v-model="keyword" placeholder="输入关键字" />
  <button @click="run">搜索</button>
  <ul>
    <li v-for="(k, i) in results" :key="i">
      <strong>{{ k.name }}</strong>：{{ k.tcmEffect }}；{{ k.westernNutrition }}
      <div>适合：{{ k.suitable }}；禁忌：{{ k.taboo }}</div>
    </li>
  </ul>
</template>