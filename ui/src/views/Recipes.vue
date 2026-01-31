<template>
  <div class="recipes-container">
    <!-- 返回按钮 -->
    <button @click="goBack" class="back-btn">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回</span>
    </button>

    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">养生食谱</h1>
      <p class="page-subtitle">四季养生美食推荐，药食同源</p>
    </div>

    <!-- 分类筛选 -->
    <div class="category-filter">
      <button
        v-for="cat in categories"
        :key="cat.id"
        class="category-btn"
        :class="{ active: selectedCategory === cat.id }"
        @click="selectedCategory = cat.id"
      >
        {{ cat.name }}
      </button>
    </div>

    <!-- 食谱列表 -->
    <div class="recipes-grid">
      <div
        v-for="recipe in filteredRecipes"
        :key="recipe.id"
        class="recipe-card"
        @click="viewRecipe(recipe)"
      >
        <div class="recipe-image">
          <img :src="recipe.image" :alt="recipe.name" />
          <span class="recipe-badge" v-if="recipe.badge">{{ recipe.badge }}</span>
        </div>
        <div class="recipe-info">
          <h3 class="recipe-name">{{ recipe.name }}</h3>
          <p class="recipe-desc">{{ recipe.description }}</p>
          <div class="recipe-meta">
            <span class="meta-item">
              <svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
              </svg>
              {{ recipe.time }}
            </span>
            <span class="meta-item">
              <svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16">
                <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
              </svg>
              {{ recipe.difficulty }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-if="filteredRecipes.length === 0" class="empty-state">
      <div class="empty-icon">🍽️</div>
      <p class="empty-text">暂无食谱</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

defineOptions({ name: 'RecipesView' });

const router = useRouter();

interface RecipeItem {
  id: number;
  name: string;
  description: string;
  time: string;
  difficulty: string;
  category: string;
  image: string;
  badge?: string;
}

// 分类数据
const categories = [
  { id: 'all', name: '全部' },
  { id: 'medicated', name: '药膳' },
  { id: 'therapy', name: '食疗' },
  { id: 'soup', name: '养生汤' },
  { id: 'tea', name: '养生茶饮' }
];

const selectedCategory = ref('all');

// 食谱数据（示例）
const recipes = ref<RecipeItem[]>([
  {
    id: 1,
    name: '当归生姜羊肉汤',
    description: '温中补虚，补血调经，适合冬季进补',
    time: '90分钟',
    difficulty: '简单',
    category: 'medicated',
    image: 'https://via.placeholder.com/400x300/f0fff4/000000?text=羊肉汤',
    badge: '推荐'
  },
  {
    id: 2,
    name: '红枣银耳莲子羹',
    description: '滋阴润肺，养颜美容，四季皆宜',
    time: '60分钟',
    difficulty: '简单',
    category: 'therapy',
    image: 'https://via.placeholder.com/400x300/fff8e1/000000?text=银耳羹',
    badge: ''
  },
  {
    id: 3,
    name: '山药排骨汤',
    description: '健脾养胃，补肾益精',
    time: '120分钟',
    difficulty: '中等',
    category: 'soup',
    image: 'https://via.placeholder.com/400x300/fff3e0/000000?text=排骨汤',
    badge: '热门'
  },
  {
    id: 4,
    name: '枸杞菊花茶',
    description: '清肝明目，缓解眼疲劳',
    time: '10分钟',
    difficulty: '简单',
    category: 'tea',
    image: 'https://via.placeholder.com/400x300/e8f5e9/000000?text=菊花茶',
    badge: ''
  },
  {
    id: 5,
    name: '黄芪党参鸡汤',
    description: '补气养血，增强免疫力',
    time: '150分钟',
    difficulty: '中等',
    category: 'medicated',
    image: 'https://via.placeholder.com/400x300/fff9c4/000000?text=鸡汤',
    badge: '推荐'
  },
  {
    id: 6,
    name: '百合莲子粥',
    description: '安神助眠，润肺止咳',
    time: '45分钟',
    difficulty: '简单',
    category: 'therapy',
    image: 'https://via.placeholder.com/400x300/ffebee/000000?text=莲子粥',
    badge: ''
  }
]);

// 筛选食谱
const filteredRecipes = computed(() => {
  if (selectedCategory.value === 'all') {
    return recipes.value;
  }
  return recipes.value.filter(r => r.category === selectedCategory.value);
});

const goBack = () => {
  router.back();
};

const viewRecipe = (recipe: RecipeItem) => {
  alert(`查看食谱：${recipe.name}\n\n${recipe.description}\n\n详细步骤功能开发中...`);
};
</script>

<style scoped>
.recipes-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0fff4 0%, #e0f7e9 100%);
  padding: 80px 40px 40px 40px;
}

/* 返回按钮 */
.back-btn {
  position: fixed;
  top: 24px;
  left: 24px;
  z-index: 999;
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(226, 232, 240, 0.8);
  padding: 10px 20px;
  border-radius: 30px;
  color: #475569;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.back-btn:hover {
  background: #fff;
  color: #4caf50;
  border-color: #4caf50;
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(76, 175, 80, 0.15);
}

.back-icon {
  width: 18px;
  height: 18px;
}

/* 页面头部 */
.page-header {
  text-align: center;
  margin-bottom: 50px;
}

.page-title {
  font-size: 3rem;
  font-weight: 800;
  margin: 0 0 16px 0;
  background: linear-gradient(135deg, #388e3c 0%, #4caf50 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.page-subtitle {
  font-size: 1.125rem;
  color: #64748b;
  margin: 0;
  font-weight: 500;
}

/* 分类筛选 */
.category-filter {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-bottom: 40px;
  flex-wrap: wrap;
}

.category-btn {
  padding: 10px 24px;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 9999px;
  font-size: 14px;
  font-weight: 600;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
}

.category-btn:hover {
  border-color: #4caf50;
  color: #4caf50;
  transform: translateY(-2px);
}

.category-btn.active {
  background: #4caf50;
  color: white;
  border-color: #4caf50;
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

/* 食谱网格 */
.recipes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

/* 食谱卡片 */
.recipe-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border: 2px solid transparent;
}

.recipe-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
  border-color: #4caf50;
}

.recipe-image {
  position: relative;
  width: 100%;
  height: 220px;
  overflow: hidden;
  background: #f8f9fa;
}

.recipe-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.recipe-card:hover .recipe-image img {
  transform: scale(1.1);
}

.recipe-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  background: #4caf50;
  color: white;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.recipe-info {
  padding: 20px;
}

.recipe-name {
  font-size: 18px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 8px 0;
}

.recipe-desc {
  font-size: 14px;
  color: #666;
  margin: 0 0 16px 0;
  line-height: 1.5;
}

.recipe-meta {
  display: flex;
  gap: 16px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #888;
}

.meta-item svg {
  flex-shrink: 0;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 80px 20px;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 18px;
  color: #666;
  margin: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .recipes-container {
    padding: 60px 20px 20px 20px;
  }

  .page-title {
    font-size: 2rem;
  }

  .recipes-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .recipe-image {
    height: 200px;
  }
}
</style>
