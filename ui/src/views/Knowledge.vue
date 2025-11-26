<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { 
  searchKnowledge, 
  getAllKnowledge, 
  getKnowledgeCategories,
  getKnowledgeByCategory,
  createKnowledge,
  updateKnowledge,
  deleteKnowledge,
  uploadKnowledgeImage
} from '../services/api';

const router = useRouter();

interface KnowledgeItem {
  id?: number;
  name: string;
  category: string;
  imageUrl?: string;
  tcmEffect: string;
  westernNutrition: string;
  suitable: string;
  taboo: string;
  usageMethod?: string;
  season?: string;
}

const keyword = ref('');
const results = ref<KnowledgeItem[]>([]);
const categories = ref<string[]>([]);
const selectedCategory = ref('');
const showAddDialog = ref(false);
const showEditDialog = ref(false);
const currentItem = ref<KnowledgeItem>({
  name: '',
  category: '',
  tcmEffect: '',
  westernNutrition: '',
  suitable: '',
  taboo: '',
  usageMethod: '',
  season: ''
});
const uploadingImage = ref(false);
const isAdmin = ref(false); // 判断是否是管理员

// 分页相关
const currentPage = ref(1);
const pageSize = ref(9); // 每页显示9个

// 计算总页数
const totalPages = computed(() => {
  return Math.ceil(results.value.length / pageSize.value);
});

// 计算当前页显示的数据
const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return results.value.slice(start, end);
});

// 获取后端URL
const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

onMounted(async () => {
  await loadAll();
  await loadCategories();
  // 简单判断：如果用户名是admin则显示管理功能
  isAdmin.value = localStorage.getItem('username') === 'root';
});

async function loadAll() {
  results.value = await getAllKnowledge();
  currentPage.value = 1; // 重置到第一页
}

async function loadCategories() {
  categories.value = await getKnowledgeCategories();
}

async function search() {
  if (keyword.value.trim()) {
    results.value = await searchKnowledge(keyword.value);
  } else {
    await loadAll();
  }
  currentPage.value = 1; // 搜索后重置到第一页
}

async function filterByCategory() {
  if (selectedCategory.value) {
    results.value = await getKnowledgeByCategory(selectedCategory.value);
  } else {
    await loadAll();
  }
  currentPage.value = 1; // 筛选后重置到第一页
}

// 计算显示的页码（智能省略）
const visiblePages = computed(() => {
  const total = totalPages.value;
  const current = currentPage.value;
  const pages: (number | string)[] = [];
  
  if (total <= 7) {
    // 总页数少于等于7，全部显示
    for (let i = 1; i <= total; i++) {
      pages.push(i);
    }
  } else {
    // 总页数大于7，使用省略号
    if (current <= 4) {
      // 当前页在前面
      for (let i = 1; i <= 5; i++) {
        pages.push(i);
      }
      pages.push('...');
      pages.push(total);
    } else if (current >= total - 3) {
      // 当前页在后面
      pages.push(1);
      pages.push('...');
      for (let i = total - 4; i <= total; i++) {
        pages.push(i);
      }
    } else {
      // 当前页在中间
      pages.push(1);
      pages.push('...');
      for (let i = current - 1; i <= current + 1; i++) {
        pages.push(i);
      }
      pages.push('...');
      pages.push(total);
    }
  }
  
  return pages;
});

// 分页相关函数
function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    // 滚动到顶部
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function openAddDialog() {
  currentItem.value = {
    name: '',
    category: '',
    tcmEffect: '',
    westernNutrition: '',
    suitable: '',
    taboo: '',
    usageMethod: '',
    season: ''
  };
  showAddDialog.value = true;
}

function openEditDialog(item: KnowledgeItem) {
  currentItem.value = { ...item };
  showEditDialog.value = true;
}

async function handleImageUpload(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;
  
  uploadingImage.value = true;
  try {
    const response = await uploadKnowledgeImage(file);
    currentItem.value.imageUrl = response.imageUrl;
  } catch (error) {
    alert('图片上传失败');
  } finally {
    uploadingImage.value = false;
  }
}

async function saveNew() {
  try {
    await createKnowledge(currentItem.value);
    showAddDialog.value = false;
    await loadAll();
    await loadCategories();
    alert('添加成功');
  } catch (error) {
    alert('添加失败');
  }
}

async function saveEdit() {
  try {
    if (currentItem.value.id) {
      await updateKnowledge(currentItem.value.id, currentItem.value);
      showEditDialog.value = false;
      await loadAll();
      alert('更新成功');
    }
  } catch (error) {
    alert('更新失败');
  }
}

async function handleDelete(id: number) {
  if (!confirm('确定要删除这个条目吗？')) return;
  try {
    await deleteKnowledge(id);
    await loadAll();
    await loadCategories();
    alert('删除成功');
  } catch (error) {
    alert('删除失败');
  }
}

function getImageUrl(url?: string) {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return apiBaseUrl + url;
}

const goHome = () => {
  router.push('/dashboard');
};
</script>

<template>
  <div class="knowledge-page">
    <!-- 返回首页按钮 -->
    <button @click="goHome" class="back-btn back-top-left">
      <svg class="back-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      <span>返回首页</span>
    </button>

    <div class="header">
      <h2>🌿 食材药材知识库</h2>
      <p class="subtitle">中医养生智慧 · 现代营养科学</p>
    </div>

    <!-- 搜索和筛选区 -->
    <div class="search-section">
      <div class="search-bar">
        <input 
          v-model="keyword" 
          placeholder="🔍 搜索食材、药材名称或功效..." 
          @keyup.enter="search"
        />
        <button @click="search" class="btn-primary">搜索</button>
        <button @click="loadAll" class="btn-secondary">显示全部</button>
      </div>
      
      <div class="filter-bar">
        <label>分类筛选：</label>
        <select v-model="selectedCategory" @change="filterByCategory">
          <option value="">全部分类</option>
          <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
        </select>
        
        <button v-if="isAdmin" @click="openAddDialog" class="btn-add">➕ 添加条目</button>
      </div>

      <!-- 顶部分页控件 -->
      <div v-if="results.length > pageSize" class="top-pagination">
        <div class="page-info">
          共 {{ results.length }} 条，第 {{ currentPage }} / {{ totalPages }} 页
        </div>
      </div>
    </div>

    <!-- 知识库列表 -->
    <div class="knowledge-grid">
      <div v-for="item in paginatedResults" :key="item.id" class="knowledge-card">
        <!-- 图片区域 -->
        <div class="image-container">
          <img 
            v-if="item.imageUrl" 
            :src="getImageUrl(item.imageUrl)" 
            :alt="item.name"
            class="item-image"
          />
          <div v-else class="no-image">
            <span>📷</span>
            <p>暂无图片</p>
          </div>
          <span v-if="item.category" class="category-badge">{{ item.category }}</span>
        </div>

        <!-- 内容区域 -->
        <div class="card-content">
          <h3>{{ item.name }}</h3>
          
          <div class="info-section">
            <h4>🏮 中医功效</h4>
            <p>{{ item.tcmEffect }}</p>
          </div>

          <div class="info-section">
            <h4>🔬 现代营养</h4>
            <p>{{ item.westernNutrition }}</p>
          </div>

          <div class="info-section" v-if="item.usageMethod">
            <h4>💊 使用方法</h4>
            <p>{{ item.usageMethod }}</p>
          </div>

          <div class="tags">
            <span class="tag suitable">✅ 适合：{{ item.suitable }}</span>
            <span class="tag taboo">⚠️ 禁忌：{{ item.taboo }}</span>
            <span v-if="item.season" class="tag season">🌸 {{ item.season }}</span>
          </div>

          <!-- 管理按钮 -->
          <div v-if="isAdmin" class="admin-actions">
            <button @click="openEditDialog(item)" class="btn-edit">编辑</button>
            <button @click="handleDelete(item.id!)" class="btn-delete">删除</button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="results.length === 0" class="empty-state">
      <p>😔 暂无数据</p>
    </div>

    <!-- 分页控件 -->
    <div v-if="results.length > 0" class="pagination">
      <button 
        @click="prevPage" 
        :disabled="currentPage === 1"
        class="pagination-btn"
      >
        ← 上一页
      </button>
      
      <div class="page-numbers">
        <template v-for="(page, index) in visiblePages" :key="index">
          <button
            v-if="typeof page === 'number'"
            @click="goToPage(page)"
            :class="['page-number', { active: currentPage === page }]"
          >
            {{ page }}
          </button>
          <span v-else class="page-ellipsis">{{ page }}</span>
        </template>
      </div>
      
      <button 
        @click="nextPage" 
        :disabled="currentPage === totalPages"
        class="pagination-btn"
      >
        下一页 →
      </button>
      
      <div class="page-info">
        第 {{ currentPage }} / {{ totalPages }} 页 （共 {{ results.length }} 条）
      </div>
    </div>

    <!-- 添加对话框 -->
    <div v-if="showAddDialog" class="modal-overlay" @click.self="showAddDialog = false">
      <div class="modal-content">
        <h3>添加知识库条目</h3>
        <form @submit.prevent="saveNew">
          <div class="form-group">
            <label>名称*</label>
            <input v-model="currentItem.name" required />
          </div>
          <div class="form-group">
            <label>分类*</label>
            <input v-model="currentItem.category" placeholder="如：食材、药材、茶饮" required />
          </div>
          <div class="form-group">
            <label>图片</label>
            <input type="file" @change="handleImageUpload" accept="image/*" />
            <img v-if="currentItem.imageUrl" :src="getImageUrl(currentItem.imageUrl)" class="preview-image" />
            <span v-if="uploadingImage">上传中...</span>
          </div>
          <div class="form-group">
            <label>中医功效*</label>
            <textarea v-model="currentItem.tcmEffect" required></textarea>
          </div>
          <div class="form-group">
            <label>现代营养*</label>
            <textarea v-model="currentItem.westernNutrition" required></textarea>
          </div>
          <div class="form-group">
            <label>适合体质*</label>
            <input v-model="currentItem.suitable" required />
          </div>
          <div class="form-group">
            <label>禁忌*</label>
            <input v-model="currentItem.taboo" required />
          </div>
          <div class="form-group">
            <label>使用方法</label>
            <textarea v-model="currentItem.usageMethod"></textarea>
          </div>
          <div class="form-group">
            <label>适宜季节</label>
            <input v-model="currentItem.season" placeholder="如：春夏秋冬、四季皆宜" />
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-primary">保存</button>
            <button type="button" @click="showAddDialog = false" class="btn-secondary">取消</button>
          </div>
        </form>
      </div>
    </div>

    <!-- 编辑对话框 -->
    <div v-if="showEditDialog" class="modal-overlay" @click.self="showEditDialog = false">
      <div class="modal-content">
        <h3>编辑知识库条目</h3>
        <form @submit.prevent="saveEdit">
          <div class="form-group">
            <label>名称*</label>
            <input v-model="currentItem.name" required />
          </div>
          <div class="form-group">
            <label>分类*</label>
            <input v-model="currentItem.category" required />
          </div>
          <div class="form-group">
            <label>图片</label>
            <input type="file" @change="handleImageUpload" accept="image/*" />
            <img v-if="currentItem.imageUrl" :src="getImageUrl(currentItem.imageUrl)" class="preview-image" />
            <span v-if="uploadingImage">上传中...</span>
          </div>
          <div class="form-group">
            <label>中医功效*</label>
            <textarea v-model="currentItem.tcmEffect" required></textarea>
          </div>
          <div class="form-group">
            <label>现代营养*</label>
            <textarea v-model="currentItem.westernNutrition" required></textarea>
          </div>
          <div class="form-group">
            <label>适合体质*</label>
            <input v-model="currentItem.suitable" required />
          </div>
          <div class="form-group">
            <label>禁忌*</label>
            <input v-model="currentItem.taboo" required />
          </div>
          <div class="form-group">
            <label>使用方法</label>
            <textarea v-model="currentItem.usageMethod"></textarea>
          </div>
          <div class="form-group">
            <label>适宜季节</label>
            <input v-model="currentItem.season" />
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-primary">保存</button>
            <button type="button" @click="showEditDialog = false" class="btn-secondary">取消</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.knowledge-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #fff5e6 0%, #ffe4d1 100%);
  max-width: 1400px;
  margin: 0 auto;
  padding: 80px 20px 20px 20px;
  position: relative;
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

.header {
  text-align: center;
  margin-bottom: 30px;
  padding-top: 10px;
}

.header h2 {
  color: #2c5f2d;
  margin-bottom: 8px;
}

.subtitle {
  color: #666;
  font-size: 14px;
}

.search-section {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 30px;
}

.search-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.search-bar input {
  flex: 1;
  padding: 10px 15px;
  border: 2px solid #ddd;
  border-radius: 6px;
  font-size: 15px;
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-bar select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
}

.top-pagination {
  margin-top: 15px;
  text-align: center;
}

.top-pagination .page-info {
  display: inline-block;
  padding: 8px 20px;
  background: #f1f8f4;
  border-radius: 20px;
  color: #fff;
  font-weight: 500;
  font-size: 14px;
}

.btn-primary {
  background: #4CAF50;
  color: white;
  padding: 10px 24px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 15px;
}

.btn-primary:hover {
  background: #45a049;
}

.btn-secondary {
  background: #f0f0f0;
  color: #333;
  padding: 10px 20px;
  border: 1px solid #ddd;
  border-radius: 6px;
  cursor: pointer;
}

.btn-add {
  background: #2196F3;
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  margin-left: auto;
}

.knowledge-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 25px;
  margin-bottom: 20px;
}

@media (max-width: 1200px) {
  .knowledge-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .knowledge-grid {
    grid-template-columns: 1fr;
  }
}

.knowledge-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
}

.knowledge-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.image-container {
  position: relative;
  width: 100%;
  height: 200px;
  background: #f5f5f5;
  overflow: hidden;
}

.item-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-image {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #999;
}

.no-image span {
  font-size: 48px;
}

.category-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(76, 175, 80, 0.9);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: bold;
}

.card-content {
  padding: 20px;
}

.card-content h3 {
  color: #2c5f2d;
  margin: 0 0 15px 0;
  font-size: 22px;
}

.info-section {
  margin-bottom: 15px;
}

.info-section h4 {
  font-size: 14px;
  color: #666;
  margin: 0 0 5px 0;
}

.info-section p {
  margin: 0;
  color: #333;
  line-height: 1.6;
  font-size: 14px;
}

.tags {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 15px;
}

.tag {
  display: inline-block;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 13px;
  line-height: 1.4;
}

.tag.suitable {
  background: #e8f5e9;
  color: #2e7d32;
}

.tag.taboo {
  background: #fff3e0;
  color: #e65100;
}

.tag.season {
  background: #e3f2fd;
  color: #1565c0;
}

.admin-actions {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #eee;
  display: flex;
  gap: 10px;
}

.btn-edit {
  background: #FF9800;
  color: white;
  padding: 6px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
}

.btn-delete {
  background: #f44336;
  color: white;
  padding: 6px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #999;
  font-size: 18px;
}

/* 分页样式 */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
  margin-top: 40px;
  padding: 20px;
  flex-wrap: wrap;
}

.pagination-btn {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 25px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
}

.pagination-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.4);
}

.pagination-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
  opacity: 0.6;
  box-shadow: none;
}

.page-numbers {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.page-number {
  width: 40px;
  height: 40px;
  border: 2px solid #e0e0e0;
  background: white;
  color: #666;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.page-number:hover {
  border-color: #4CAF50;
  color: #fff;
  background: #f1f8f4;
}

.page-number.active {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  border-color: #4CAF50;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
}

.page-info {
  color: #666;
  font-size: 14px;
  padding: 0 10px;
  white-space: nowrap;
}

.page-ellipsis {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-weight: bold;
  font-size: 16px;
}

/* 模态框样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-content h3 {
  margin: 0 0 20px 0;
  color: #2c5f2d;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #333;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  box-sizing: border-box;
}

.form-group textarea {
  min-height: 80px;
  resize: vertical;
}

.preview-image {
  max-width: 200px;
  max-height: 200px;
  margin-top: 10px;
  border-radius: 8px;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 25px;
}
</style>