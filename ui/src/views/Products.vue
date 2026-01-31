<template>
  <div class="products-container">
    <!-- 顶部导航栏 -->
    <header class="top-header">
      <div class="header-left">
        <button @click="goBack" class="back-button">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M15 18l-6-6 6-6" />
          </svg>
        </button>
        <h1 class="page-title">养生好物</h1>
      </div>

      <div class="header-right">
        <!-- 搜索框 -->
        <div class="search-box">
          <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input 
            type="text" 
            v-model="searchKeyword" 
            placeholder="搜索草本、茶饮..." 
            class="search-input"
          />
        </div>

        <!-- 上传按钮 -->
        <button @click="openUploadModal" class="action-button upload-btn">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 4v16m8-8H4" />
          </svg>
          <span>发布商品</span>
        </button>

        <!-- 购物车按钮 -->
        <button @click="showCart = true" class="action-button cart-btn">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"/>
          </svg>
          <span class="cart-badge" v-if="cartCount > 0">{{ cartCount }}</span>
        </button>
      </div>
    </header>

    <!-- 筛选区域 -->
    <div class="filter-section">
      <div class="category-tabs">
        <button
          v-for="cat in categories"
          :key="cat.id"
          class="category-tab"
          :class="{ active: selectedCategory === cat.id }"
          @click="selectCategory(cat.id)"
        >
          {{ cat.name }}
        </button>
      </div>

      <div class="season-tags">
        <button 
          v-for="season in seasons" 
          :key="season.id"
          class="season-tag"
          :class="{ active: selectedSeason === season.id }"
          @click="selectSeason(season.id)"
        >
          {{ season.name }}
        </button>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <main class="main-content">
      <!-- 商品网格 -->
      <div class="products-grid">
        <div
          v-for="product in paginatedProducts"
          :key="product.id"
          class="product-card"
          @click="viewProduct(product)"
        >
          <div class="card-image-wrapper">
            <img v-if="product.image" :src="product.image" :alt="product.name" loading="lazy" />
            <div v-else class="no-image-placeholder">
              <span class="emoji">🌿</span>
            </div>
            <div class="card-overlay">
              <button class="quick-add-btn" @click.stop="addToCart(product)">
                加入购物车
              </button>
            </div>
          </div>
          
          <div class="card-content">
            <div class="card-header">
              <h3 class="product-name">{{ product.name }}</h3>
              <span class="product-tag" v-if="product.season">{{ product.season }}</span>
            </div>
            <p class="product-desc">{{ product.description }}</p>
            
            <div class="card-footer">
              <div class="price">
                <span class="currency">¥</span>
                <span class="amount">{{ product.price }}</span>
              </div>
              <span class="sales">已售 {{ product.sales }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="filteredProducts.length === 0" class="empty-state">
        <div class="empty-icon">🍃</div>
        <p>暂无相关商品</p>
      </div>

      <!-- 分页 -->
      <div v-if="totalPages > 1" class="pagination">
        <button 
          class="page-btn" 
          :disabled="currentPage === 1"
          @click="changePage(currentPage - 1)"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 18l-6-6 6-6"/></svg>
        </button>
        <span class="page-info">{{ currentPage }} / {{ totalPages }}</span>
        <button 
          class="page-btn" 
          :disabled="currentPage === totalPages"
          @click="changePage(currentPage + 1)"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>
        </button>
      </div>
    </main>

    <!-- 商品详情弹窗 -->
    <Transition name="fade">
      <div v-if="selectedProduct" class="modal-backdrop" @click.self="closeProductDetail">
        <div class="product-detail-modal">
          <button class="close-btn" @click="closeProductDetail">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
          
          <div class="detail-layout">
            <div class="detail-image">
              <img v-if="selectedProduct.image" :src="selectedProduct.image" :alt="selectedProduct.name" />
              <div v-else class="detail-placeholder">🌿</div>
            </div>
            
            <div class="detail-info">
              <div class="info-header">
                <span class="detail-category">{{ selectedProduct.category }}</span>
                <h2 class="detail-title">{{ selectedProduct.name }}</h2>
                <div class="detail-price">
                  <span class="currency">¥</span>
                  <span class="amount">{{ selectedProduct.price }}</span>
                </div>
              </div>

              <div class="info-body">
                <div class="info-item">
                  <span class="label">功效</span>
                  <p>{{ selectedProduct.effect || '暂无描述' }}</p>
                </div>
                <div class="info-item">
                  <span class="label">适宜人群</span>
                  <p>{{ selectedProduct.suitable || '通用' }}</p>
                </div>
                <div class="info-item warning">
                  <span class="label">注意事项</span>
                  <p>{{ selectedProduct.caution || '详见说明书' }}</p>
                </div>
              </div>

              <div class="detail-actions">
                <div class="quantity-control">
                  <button @click="updateDetailQuantity(-1)" :disabled="detailQuantity <= 1">-</button>
                  <span>{{ detailQuantity }}</span>
                  <button @click="updateDetailQuantity(1)">+</button>
                </div>
                <button class="add-cart-btn" @click="addToCart(selectedProduct, detailQuantity)">
                  加入购物车
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- 上传商品弹窗 -->
    <Transition name="fade">
      <div v-if="showUploadModal" class="modal-backdrop" @click.self="closeUploadModal">
        <div class="upload-modal">
          <div class="modal-header">
            <h3>发布养生商品</h3>
            <button class="close-btn" @click="closeUploadModal">✕</button>
          </div>
          
          <div class="modal-body">
            <div class="form-group">
              <label>商品名称</label>
              <input type="text" v-model="newProduct.name" placeholder="请输入商品名称" class="form-input">
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>价格 (¥)</label>
                <input type="number" v-model="newProduct.price" class="form-input">
              </div>
              <div class="form-group">
                <label>分类</label>
                <select v-model="newProduct.category" class="form-select">
                  <option v-for="cat in categories.slice(1)" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                </select>
              </div>
            </div>

            <div class="form-group">
              <label>商品图片</label>
              <div class="image-upload-area" @click="triggerFileInput">
                <input type="file" ref="fileInput" @change="handleFileChange" accept="image/*" style="display: none">
                <div v-if="newProduct.image" class="preview-image">
                  <img :src="newProduct.image" alt="Preview">
                  <button class="remove-image" @click.stop="removeImage">✕</button>
                </div>
                <div v-else class="upload-placeholder">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 4v16m8-8H4" />
                  </svg>
                  <span>点击上传图片</span>
                </div>
              </div>
            </div>

            <div class="form-group">
              <label>商品描述</label>
              <textarea v-model="newProduct.description" placeholder="描述商品的功效与特点..." class="form-textarea"></textarea>
            </div>
          </div>

          <div class="modal-footer">
            <button class="btn-cancel" @click="closeUploadModal">取消</button>
            <button class="btn-submit" @click="submitProduct" :disabled="!isFormValid">发布商品</button>
          </div>
        </div>
      </div>
    </Transition>

    <!-- 购物车侧边栏 -->
    <Transition name="slide">
      <div v-if="showCart" class="cart-sidebar">
        <div class="cart-header">
          <h3>购物车 ({{ cartCount }})</h3>
          <div class="header-actions">
            <button v-if="cartItems.length > 0" @click="clearCart" class="clear-btn">清空</button>
            <button @click="showCart = false" class="close-btn icon-btn">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
        </div>
        
        <div class="cart-items">
          <div v-if="cartItems.length === 0" class="cart-empty">
            <div class="empty-icon-box">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                <path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"/>
              </svg>
            </div>
            <p>购物车是空的</p>
            <button @click="showCart = false" class="go-shop-btn">去逛逛</button>
          </div>
          <div v-else v-for="item in cartItems" :key="item.product.id" class="cart-item">
            <div class="cart-item-image">
              <img v-if="item.product.image" :src="item.product.image">
              <div v-else class="placeholder">🌿</div>
            </div>
            <div class="cart-item-info">
              <h4>{{ item.product.name }}</h4>
              <div class="cart-item-meta">
                <span class="price">¥{{ item.product.price }}</span>
                <div class="qty-control small">
                  <button @click="updateCartQuantity(item.product.id, -1)">-</button>
                  <span>{{ item.quantity }}</span>
                  <button @click="updateCartQuantity(item.product.id, 1)">+</button>
                </div>
              </div>
            </div>
            <button class="remove-btn" @click="removeFromCart(item.product.id)">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
            </button>
          </div>
        </div>

        <div class="cart-footer" v-if="cartItems.length > 0">
          <div class="total">
            <span>合计</span>
            <span class="amount">¥{{ cartTotal.toFixed(2) }}</span>
          </div>
          <button class="checkout-btn" :disabled="cartItems.length === 0" @click="checkout">
            去结算
          </button>
        </div>
      </div>
    </Transition>
    <div v-if="showCart" class="cart-backdrop" @click="showCart = false"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { getAllKnowledge, getKnowledgeCategories } from '../services/api';

defineOptions({ name: 'ProductsView' });

const router = useRouter();
const searchKeyword = ref('');

type Product = {
  id: number | string;
  name: string;
  description: string;
  price: number;
  category: string;
  image: string;
  sales: number;
  specs?: string;
  origin?: string;
  effect?: string;
  suitable?: string;
  caution?: string;
  season?: string;
};

type Category = {
  id: string;
  name: string;
};

// 分类数据
const categories = ref<Category[]>([
  { id: 'all', name: '全部' }
]);

const seasons = [
  { id: 'all', name: '全部' },
  { id: 'spring', name: '春' },
  { id: 'summer', name: '夏' },
  { id: 'autumn', name: '秋' },
  { id: 'winter', name: '冬' },
  { id: 'all_seasons', name: '四季皆宜' }
];

const selectedCategory = ref('all');
const selectedSeason = ref('all');
const currentPage = ref(1);
const itemsPerPage = 12;

// 商品数据
const products = ref<Product[]>([]);

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

function getImageUrl(url?: string) {
  if (!url) return '';
  if (url.startsWith('http') || url.startsWith('data:')) return url;
  return apiBaseUrl + url;
}

// 模拟数据生成
const getRandomPrice = () => Math.floor(Math.random() * 400) + 20;
const getRandomSales = () => Math.floor(Math.random() * 5000) + 100;
const seasonMap: Record<string, string> = {
  'spring': '春',
  'summer': '夏',
  'autumn': '秋',
  'winter': '冬',
  'all_seasons': '四季皆宜'
};
const seasonKeys = Object.keys(seasonMap);
const getRandomSeason = () => seasonKeys[Math.floor(Math.random() * seasonKeys.length)];

onMounted(async () => {
  try {
    const cats = await getKnowledgeCategories();
    if (cats && Array.isArray(cats)) {
      cats.forEach((c: string) => {
        categories.value.push({ id: c, name: c });
      });
    }

    const knowledgeItems = await getAllKnowledge();
    if (knowledgeItems && Array.isArray(knowledgeItems)) {
      products.value = (knowledgeItems as unknown[]).map((raw) => {
        const item = raw as Record<string, unknown>;
        const price = getRandomPrice();
        return {
          id: typeof item.id === 'number' || typeof item.id === 'string' ? item.id : Math.random(),
          name: typeof item.name === 'string' ? item.name : '未命名商品',
          description:
            (typeof item.tcmEffect === 'string' && item.tcmEffect) ||
            (typeof item.westernNutrition === 'string' && item.westernNutrition) ||
            '暂无描述',
          price: price,
          category: typeof item.category === 'string' ? item.category : 'herb',
          image: getImageUrl(typeof item.imageUrl === 'string' ? item.imageUrl : undefined),
          sales: getRandomSales(),
          specs: '500g/份',
          origin: '产地直采',
          effect: typeof item.tcmEffect === 'string' && item.tcmEffect ? item.tcmEffect : '详见详情',
          suitable: typeof item.suitable === 'string' ? item.suitable : '一般人群',
          caution: typeof item.taboo === 'string' ? item.taboo : '详见说明书',
          season: getRandomSeason()
        } as Product;
      });
    }
  } catch (e) {
    console.error('Failed to load products', e);
  }
});

// 筛选逻辑
const filteredProducts = computed(() => {
  let result = products.value;
  if (selectedCategory.value !== 'all') {
    result = result.filter(p => p.category === selectedCategory.value);
  }
  if (selectedSeason.value !== 'all') {
    result = result.filter(p => p.season === selectedSeason.value);
  }
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.toLowerCase();
    result = result.filter(p => 
      p.name.toLowerCase().includes(keyword) || 
      p.description.toLowerCase().includes(keyword)
    );
  }
  return result;
});

const totalPages = computed(() => Math.ceil(filteredProducts.value.length / itemsPerPage));
const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredProducts.value.slice(start, end);
});

const selectCategory = (id: string) => { selectedCategory.value = id; currentPage.value = 1; };
const selectSeason = (id: string) => { selectedSeason.value = id; currentPage.value = 1; };
const changePage = (page: number) => { 
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page; 
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
};
const goBack = () => router.back();

// 详情页逻辑
const selectedProduct = ref<Product | null>(null);
const detailQuantity = ref(1);
const viewProduct = (p: Product) => { selectedProduct.value = p; detailQuantity.value = 1; };
const closeProductDetail = () => selectedProduct.value = null;
const updateDetailQuantity = (d: number) => detailQuantity.value = Math.max(1, detailQuantity.value + d);

// 购物车逻辑
const showCart = ref(false);
const cartItems = ref<{ product: Product; quantity: number }[]>([]);
const cartCount = computed(() => cartItems.value.reduce((sum, item) => sum + item.quantity, 0));
const cartTotal = computed(() => cartItems.value.reduce((sum, item) => sum + item.product.price * item.quantity, 0));

const addToCart = (product: Product, quantity = 1) => {
  const existing = cartItems.value.find(item => item.product.id === product.id);
  if (existing) existing.quantity += quantity;
  else cartItems.value.push({ product, quantity });
  showCart.value = true;
  closeProductDetail();
};

const updateCartQuantity = (id: string | number, delta: number) => {
  const item = cartItems.value.find(i => i.product.id === id);
  if (item) {
    item.quantity = Math.max(1, item.quantity + delta);
    if (item.quantity === 0) removeFromCart(id);
  }
};

const removeFromCart = (id: string | number) => {
  cartItems.value = cartItems.value.filter(i => i.product.id !== id);
};

const clearCart = () => {
  if (confirm('确定要清空购物车吗？')) {
    cartItems.value = [];
  }
};

const checkout = () => {
  alert('功能开发中：结算支付');
};

// 上传商品逻辑
const showUploadModal = ref(false);
const fileInput = ref<HTMLInputElement | null>(null);
const newProduct = reactive({
  name: '',
  price: 0,
  category: '',
  description: '',
  image: ''
});

const openUploadModal = () => showUploadModal.value = true;
const closeUploadModal = () => {
  showUploadModal.value = false;
  // Reset form
  newProduct.name = '';
  newProduct.price = 0;
  newProduct.category = '';
  newProduct.description = '';
  newProduct.image = '';
};

const triggerFileInput = () => fileInput.value?.click();

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files[0]) {
    const file = target.files[0];
    const reader = new FileReader();
    reader.onload = (e) => {
      newProduct.image = e.target?.result as string;
    };
    reader.readAsDataURL(file);
  }
};

const removeImage = () => {
  newProduct.image = '';
  if (fileInput.value) fileInput.value.value = '';
};

const isFormValid = computed(() => {
  return newProduct.name && newProduct.price > 0 && newProduct.category && newProduct.description;
});

const submitProduct = () => {
  if (!isFormValid.value) return;
  
  const product: Product = {
    id: 'custom_' + Date.now(),
    name: newProduct.name,
    price: newProduct.price,
    category: newProduct.category,
    description: newProduct.description,
    image: newProduct.image,
    sales: 0,
    specs: '自定义',
    origin: '用户上传',
    effect: newProduct.description,
    suitable: '通用',
    caution: '无',
    season: 'all_seasons'
  };
  
  products.value.unshift(product);
  closeUploadModal();
  alert('商品发布成功！');
};
</script>

<style scoped>
.products-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0fdf4 0%, #ffffff 100%);
  padding-top: 80px; /* Header height */
}

/* Header */
.top-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 40px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  z-index: 100;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.back-button {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1px solid #e2e8f0;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  color: #64748b;
}

.back-button:hover {
  background: #f1f5f9;
  color: #10b981;
}

.page-title {
  font-size: 24px;
  font-weight: 800;
  color: #0f766e;
  letter-spacing: -0.5px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* Search Box */
.search-box {
  display: flex;
  align-items: center;
  background: white;
  padding: 8px 16px;
  border-radius: 20px;
  border: 1px solid #e2e8f0;
  width: 300px;
  transition: all 0.3s;
}

.search-box:focus-within {
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.search-icon {
  width: 20px;
  height: 20px;
  color: #94a3b8;
  margin-right: 8px;
}

.search-input {
  border: none;
  outline: none;
  width: 100%;
  font-size: 14px;
  color: #334155;
}

/* Action Buttons */
.action-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 20px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.action-button svg {
  width: 20px;
  height: 20px;
}

.upload-btn {
  background: #10b981;
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
}

.upload-btn:hover {
  background: #059669;
  transform: translateY(-1px);
}

.cart-btn {
  background: white;
  border: 1px solid #e2e8f0;
  color: #64748b;
  position: relative;
  width: 44px;
  height: 44px;
  padding: 0;
  justify-content: center;
}

.cart-btn:hover {
  border-color: #10b981;
  color: #10b981;
}

.cart-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #ef4444;
  color: white;
  font-size: 10px;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

/* Filter Section */
.filter-section {
  padding: 24px 40px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.category-tabs {
  display: flex;
  gap: 12px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.category-tab {
  padding: 8px 20px;
  background: white;
  border: 1px solid #f1f5f9;
  border-radius: 12px;
  color: #64748b;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.category-tab.active {
  background: #10b981;
  color: white;
  border-color: #10b981;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
}

.season-tags {
  display: flex;
  gap: 8px;
}

.season-tag {
  padding: 4px 12px;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 8px;
  color: #94a3b8;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.season-tag.active {
  background: #ecfdf5;
  color: #10b981;
  border-color: #10b981;
}

/* Main Content */
.main-content {
  padding: 0 40px 40px 180px; /* Make space for MascotWidget (fixed left) */
  min-height: calc(100vh - 80px);
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); /* Slightly wider cards */
  gap: 24px;
}

/* Product Card */
.product-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  cursor: pointer;
  border: 1px solid #f8fafc;
}

.product-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px -12px rgba(16, 185, 129, 0.15);
  border-color: #d1fae5;
}

.card-image-wrapper {
  position: relative;
  width: 100%;
  padding-top: 100%; /* 1:1 Aspect Ratio */
  background: #f8fafc;
  overflow: hidden;
}

.card-image-wrapper img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.product-card:hover img {
  transform: scale(1.05);
}

.no-image-placeholder {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  color: #cbd5e1;
}

.card-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.product-card:hover .card-overlay {
  opacity: 1;
}

.quick-add-btn {
  background: white;
  color: #10b981;
  padding: 10px 20px;
  border-radius: 20px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transform: translateY(20px);
  transition: transform 0.3s;
}

.product-card:hover .quick-add-btn {
  transform: translateY(0);
}

.card-content {
  padding: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.product-name {
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
  line-height: 1.4;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.product-tag {
  font-size: 10px;
  padding: 2px 6px;
  background: #f0fdf4;
  color: #10b981;
  border-radius: 4px;
  margin-left: 8px;
  white-space: nowrap;
}

.product-desc {
  font-size: 12px;
  color: #94a3b8;
  margin-bottom: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  color: #10b981;
  font-weight: 800;
}

.currency {
  font-size: 12px;
}

.amount {
  font-size: 18px;
}

.sales {
  font-size: 12px;
  color: #cbd5e1;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  margin-top: 40px;
}

.page-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1px solid #e2e8f0;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  color: #64748b;
}

.page-btn:hover:not(:disabled) {
  border-color: #10b981;
  color: #10b981;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-btn svg {
  width: 20px;
  height: 20px;
}

.page-info {
  font-size: 14px;
  color: #64748b;
  font-weight: 600;
}

/* Modal Common */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

/* Upload Modal */
.upload-modal {
  background: white;
  width: 90%;
  max-width: 500px;
  border-radius: 24px;
  padding: 24px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.modal-header h3 {
  font-size: 20px;
  font-weight: 700;
  color: #1e293b;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #94a3b8;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #64748b;
  margin-bottom: 8px;
}

.form-input, .form-select, .form-textarea {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  font-size: 14px;
  transition: all 0.2s;
}

.form-input:focus, .form-select:focus, .form-textarea:focus {
  border-color: #10b981;
  outline: none;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-textarea {
  height: 100px;
  resize: none;
}

.image-upload-area {
  border: 2px dashed #e2e8f0;
  border-radius: 12px;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  height: 160px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.image-upload-area:hover {
  border-color: #10b981;
  background: #f0fdf4;
}

.upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #94a3b8;
  gap: 8px;
}

.preview-image {
  position: absolute;
  inset: 0;
}

.preview-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.remove-image {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  cursor: pointer;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
}

.btn-cancel {
  padding: 10px 20px;
  background: #f1f5f9;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  color: #64748b;
  cursor: pointer;
}

.btn-submit {
  padding: 10px 24px;
  background: #10b981;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  color: white;
  cursor: pointer;
}

.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Product Detail Modal */
.product-detail-modal {
  background: white;
  width: 90%;
  max-width: 800px;
  border-radius: 32px;
  padding: 32px;
  position: relative;
  overflow: hidden;
}

.detail-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
}

.detail-image {
  border-radius: 24px;
  overflow: hidden;
  background: #f8fafc;
  aspect-ratio: 1;
}

.detail-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.detail-info {
  display: flex;
  flex-direction: column;
}

.info-header {
  border-bottom: 1px solid #f1f5f9;
  padding-bottom: 20px;
  margin-bottom: 20px;
}

.detail-category {
  font-size: 12px;
  color: #10b981;
  background: #ecfdf5;
  padding: 4px 10px;
  border-radius: 20px;
  font-weight: 600;
}

.detail-title {
  font-size: 28px;
  font-weight: 800;
  color: #1e293b;
  margin: 12px 0;
}

.detail-price {
  color: #10b981;
  font-weight: 700;
  font-size: 24px;
}

.info-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 30px;
}

.info-item .label {
  display: block;
  font-size: 12px;
  color: #94a3b8;
  margin-bottom: 4px;
}

.info-item p {
  font-size: 14px;
  color: #475569;
  line-height: 1.6;
}

.info-item.warning p {
  color: #f59e0b;
}

.detail-actions {
  display: flex;
  gap: 16px;
}

.quantity-control {
  display: flex;
  align-items: center;
  background: #f1f5f9;
  border-radius: 12px;
  padding: 4px;
}

.quantity-control button {
  width: 32px;
  height: 32px;
  border: none;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.quantity-control span {
  width: 40px;
  text-align: center;
  font-weight: 600;
}

.add-cart-btn {
  flex: 1;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 16px;
  font-weight: 700;
  font-size: 16px;
  cursor: pointer;
  transition: transform 0.2s;
}

.add-cart-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(16, 185, 129, 0.2);
}

/* Cart Sidebar */
.cart-sidebar {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  width: 400px;
  max-width: 100%;
  background: white;
  box-shadow: -10px 0 30px rgba(0, 0, 0, 0.1);
  z-index: 2000; /* Ensure it's above everything including widget */
  display: flex;
  flex-direction: column;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.cart-header {
  padding: 24px;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cart-header h3 {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
}

.cart-items {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.cart-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #94a3b8;
}

.cart-empty .empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.cart-item {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  position: relative;
  transition: all 0.2s;
}

.cart-item:hover {
  border-color: #10b981;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
}

.cart-item-image {
  width: 72px;
  height: 72px;
  border-radius: 12px;
  overflow: hidden;
  background: #f8fafc;
  flex-shrink: 0;
}

.cart-item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cart-item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.cart-item-info h4 {
  font-size: 15px;
  margin: 0;
  color: #334155;
  font-weight: 600;
  padding-right: 24px; /* Make space for remove button */
}

.cart-item-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cart-item-meta .price {
  color: #10b981;
  font-weight: 700;
  font-size: 16px;
}

.qty-control.small {
  background: #f1f5f9;
  border-radius: 8px;
  padding: 2px;
}

.qty-control.small button {
  width: 24px;
  height: 24px;
  font-size: 14px;
  background: white;
  border-radius: 6px;
  color: #64748b;
}

.qty-control.small span {
  width: 32px;
  font-size: 13px;
}

.remove-btn {
  position: absolute;
  top: 12px;
  right: 12px;
  width: 24px;
  height: 24px;
  border: none;
  background: transparent;
  color: #cbd5e1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  padding: 0;
}

.remove-btn:hover {
  color: #ef4444;
  background: #fef2f2;
  border-radius: 50%;
}

.remove-btn svg {
  width: 16px;
  height: 16px;
}

.cart-footer {
  padding: 24px;
  border-top: 1px solid #f1f5f9;
  background: white;
  box-shadow: 0 -4px 20px rgba(0,0,0,0.02);
}

.cart-footer .total {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 20px;
}

.cart-footer .total span:first-child {
  font-size: 14px;
  color: #64748b;
  font-weight: 600;
}

.cart-footer .total .amount {
  font-size: 24px;
  color: #1e293b;
  font-weight: 800;
}

.checkout-btn {
  width: 100%;
  padding: 16px;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 16px;
  font-weight: 700;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
}

.checkout-btn:hover:not(:disabled) {
  background: #059669;
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
}

.checkout-btn:disabled {
  background: #cbd5e1;
  cursor: not-allowed;
  box-shadow: none;
}

.slide-enter-active, .slide-leave-active {
  transition: transform 0.3s;
}

.slide-enter-from, .slide-leave-to {
  transform: translateX(100%);
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .top-header {
    padding: 0 20px;
  }
  
  .main-content {
    padding: 20px;
    padding-bottom: 140px; /* Space for widget at bottom */
  }

  .cart-sidebar {
    width: 100%;
  }

  .search-box {
    display: none;
  }
  .detail-layout {
    grid-template-columns: 1fr;
  }
}

/* Cart Backdrop */
.cart-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  z-index: 1999;
  animation: fade-in 0.3s;
}

@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Header Actions */
.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.clear-btn {
  font-size: 13px;
  color: #94a3b8;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
  transition: all 0.2s;
}

.clear-btn:hover {
  color: #ef4444;
  background: #fef2f2;
}

.icon-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: transparent;
  color: #64748b;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  padding: 0;
}

.icon-btn:hover {
  background: #f1f5f9;
  color: #1e293b;
}

.icon-btn svg {
  width: 20px;
  height: 20px;
}

/* Empty State */
.empty-icon-box {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: #f0fdf4;
  color: #10b981;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.empty-icon-box svg {
  width: 40px;
  height: 40px;
}

.go-shop-btn {
  margin-top: 16px;
  padding: 10px 24px;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 20px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
}

.go-shop-btn:hover {
  background: #059669;
  transform: translateY(-2px);
}
</style>
