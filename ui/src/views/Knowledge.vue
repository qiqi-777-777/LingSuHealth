<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import {
  getAllKnowledge,
  getKnowledgeCategories,
  createKnowledge,
  updateKnowledge,
  deleteKnowledge,
  uploadKnowledgeImage,
  getAllInteractions
} from '../services/api';

defineOptions({ name: 'KnowledgeView' });

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

interface ImportItem extends KnowledgeItem {
  tags?: string[];
}

interface KnowledgeInteraction {
  id: number;
  item1Name: string;
  item2Name: string;
  relationshipType: string;
  severityLevel: string;
  effectDescription: string;
  scientificBasis: string;
  recommendation: string;
}

const keyword = ref('');
const results = ref<KnowledgeItem[]>([]);
const categories = ref<string[]>([]);
const selectedCategory = ref('');
const selectedSeason = ref('');
const effectKeyword = ref('');
const selectedTagsInput = ref('');
const sortOption = ref('default');
const loading = ref(false);
const errorMessage = ref('');
const showAddDialog = ref(false);
const showEditDialog = ref(false);
const showEditConfirm = ref(false);
const showBatchImportDialog = ref(false);
const showInteractionsDialog = ref(false);
const interactions = ref<KnowledgeInteraction[]>([]);
const loadingInteractions = ref(false);
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
const tagsInput = ref('');
const uploadingImage = ref(false);
const isAdmin = ref(false); // 判断是否是管理员
const favorites = ref<Set<string>>(new Set());
const tagsMap = ref<Record<string, string[]>>({});
const batchItems = ref<ImportItem[]>([]);
const importingBatch = ref(false);
const batchError = ref('');

// 分页相关
const currentPage = ref(1);
const pageSize = ref(12); // 每页显示12个（4列 × 3行）

const selectedTags = computed(() => {
  return selectedTagsInput.value
    .split(/[,，]/)
    .map((tag) => tag.trim())
    .filter(Boolean);
});

const seasonOptions = computed(() => {
  const set = new Set<string>();
  results.value.forEach((item) => {
    if (item.season) set.add(item.season);
  });
  return Array.from(set);
});

function getItemKey(item: KnowledgeItem) {
  return item.id ? `id:${item.id}` : `name:${item.name}`;
}

function getItemTags(item: KnowledgeItem) {
  const key = getItemKey(item);
  const storedTags = tagsMap.value[key] || [];
  const derivedTags = [item.category, item.season].filter(Boolean) as string[];
  const set = new Set<string>();
  [...storedTags, ...derivedTags].forEach((tag) => {
    if (tag && tag.trim()) set.add(tag.trim());
  });
  return Array.from(set);
}

function getStorageKeys() {
  const username = localStorage.getItem('username') || 'guest';
  return {
    favorites: `knowledge-favorites:${username}`,
    tags: `knowledge-tags:${username}`
  };
}

function loadFavorites() {
  const { favorites: key } = getStorageKeys();
  const raw = localStorage.getItem(key);
  if (raw) {
    try {
      favorites.value = new Set<string>(JSON.parse(raw));
    } catch {
      favorites.value = new Set<string>();
    }
  }
}

function saveFavorites() {
  const { favorites: key } = getStorageKeys();
  localStorage.setItem(key, JSON.stringify(Array.from(favorites.value)));
}

function loadTagsMap() {
  const { tags: key } = getStorageKeys();
  const raw = localStorage.getItem(key);
  if (raw) {
    try {
      tagsMap.value = JSON.parse(raw);
    } catch {
      tagsMap.value = {};
    }
  }
}

function saveTagsMap() {
  const { tags: key } = getStorageKeys();
  localStorage.setItem(key, JSON.stringify(tagsMap.value));
}

function isFavorite(item: KnowledgeItem) {
  return favorites.value.has(getItemKey(item));
}

function toggleFavorite(item: KnowledgeItem) {
  const key = getItemKey(item);
  if (favorites.value.has(key)) {
    favorites.value.delete(key);
  } else {
    favorites.value.add(key);
  }
  saveFavorites();
}

function setTagsForItem(item: KnowledgeItem, tags: string[]) {
  const key = getItemKey(item);
  const cleanTags = tags.map((tag) => tag.trim()).filter(Boolean);
  if (cleanTags.length > 0) {
    tagsMap.value[key] = cleanTags;
  } else {
    delete tagsMap.value[key];
  }
  saveTagsMap();
}

const filteredResults = computed(() => {
  const list = [...results.value];
  const keywordTerm = keyword.value.trim().toLowerCase();
  const effectTerm = effectKeyword.value.trim().toLowerCase();
  const selectedTagsList = selectedTags.value.map((tag) => tag.toLowerCase());

  return list.filter((item) => {
    if (selectedCategory.value && item.category !== selectedCategory.value) {
      return false;
    }
    if (selectedSeason.value && !(item.season || '').includes(selectedSeason.value)) {
      return false;
    }
    if (effectTerm) {
      const tcmText = (item.tcmEffect || '').toLowerCase();
      const nutritionText = (item.westernNutrition || '').toLowerCase();
      if (!tcmText.includes(effectTerm) && !nutritionText.includes(effectTerm)) {
        return false;
      }
    }
    if (selectedTagsList.length > 0) {
      const itemTags = getItemTags(item).map((tag) => tag.toLowerCase());
      const matchesAll = selectedTagsList.every((tag) =>
        itemTags.some((itemTag) => itemTag.includes(tag))
      );
      if (!matchesAll) return false;
    }
    if (keywordTerm) {
      const searchableText = [
        item.name,
        item.category,
        item.tcmEffect,
        item.westernNutrition,
        item.suitable,
        item.taboo,
        item.usageMethod,
        item.season,
        getItemTags(item).join(' ')
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase();
      if (!searchableText.includes(keywordTerm)) {
        return false;
      }
    }
    return true;
  });
});

// 计算总页数
const sortedResults = computed(() => {
  const list = [...filteredResults.value];
  if (sortOption.value === 'name') {
    return list.sort((a, b) => a.name.localeCompare(b.name, 'zh-Hans-CN'));
  }
  if (sortOption.value === 'category') {
    return list.sort((a, b) => (a.category || '').localeCompare(b.category || '', 'zh-Hans-CN'));
  }
  return list;
});

const totalPages = computed(() => {
  return Math.ceil(sortedResults.value.length / pageSize.value);
});

// 计算当前页显示的数据
const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return sortedResults.value.slice(start, end);
});

const totalCount = computed(() => sortedResults.value.length);

// 获取后端URL
const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

onMounted(async () => {
  await loadAll();
  await loadCategories();
  loadFavorites();
  loadTagsMap();
  // 简单判断：如果用户名是admin则显示管理功能
  isAdmin.value = localStorage.getItem('username') === 'root';
});

async function loadAll() {
  loading.value = true;
  errorMessage.value = '';
  try {
    results.value = await getAllKnowledge();
  } catch {
    results.value = [];
    errorMessage.value = '加载失败，请稍后重试';
  } finally {
    loading.value = false;
    currentPage.value = 1;
  }
}

async function loadCategories() {
  try {
    categories.value = await getKnowledgeCategories();
  } catch {
    categories.value = [];
  }
}

async function search() {
  currentPage.value = 1;
}

async function filterByCategory() {
  currentPage.value = 1;
}

async function resetFilters() {
  keyword.value = '';
  selectedCategory.value = '';
  selectedSeason.value = '';
  effectKeyword.value = '';
  selectedTagsInput.value = '';
  sortOption.value = 'default';
  await loadAll();
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
  tagsInput.value = '';
  showAddDialog.value = true;
}

function openEditDialog(item: KnowledgeItem) {
  currentItem.value = { ...item };
  tagsInput.value = (tagsMap.value[getItemKey(item)] || []).join(', ');
  showEditDialog.value = true;
}

async function compressImage(file: File) {
  if (!file.type.startsWith('image/')) return file;
  const image = new Image();
  const objectUrl = URL.createObjectURL(file);
  try {
    await new Promise<void>((resolve, reject) => {
      image.onload = () => resolve();
      image.onerror = () => reject(new Error('image load failed'));
      image.src = objectUrl;
    });
    const maxSize = 1200;
    let { width, height } = image;
    if (width > maxSize || height > maxSize) {
      const ratio = Math.min(maxSize / width, maxSize / height);
      width = Math.round(width * ratio);
      height = Math.round(height * ratio);
    }
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    if (!ctx) return file;
    ctx.drawImage(image, 0, 0, width, height);
    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, 'image/jpeg', 0.82)
    );
    if (!blob) return file;
    return new File([blob], file.name.replace(/\.\w+$/, '.jpg'), { type: 'image/jpeg' });
  } finally {
    URL.revokeObjectURL(objectUrl);
  }
}

async function handleImageUpload(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  uploadingImage.value = true;
  try {
    const compressed = await compressImage(file);
    const response = await uploadKnowledgeImage(compressed);
    currentItem.value.imageUrl = response.imageUrl;
  } catch {
    alert('图片上传失败');
  } finally {
    uploadingImage.value = false;
  }
}

async function saveNew() {
  try {
    const created = await createKnowledge(currentItem.value);
    showAddDialog.value = false;
    await loadAll();
    await loadCategories();
    const tagList = tagsInput.value.split(/[,，]/).map((tag) => tag.trim()).filter(Boolean);
    const targetItem = created?.id
      ? { ...currentItem.value, id: created.id }
      : results.value.find((item) => item.name === currentItem.value.name) || currentItem.value;
    if (tagList.length > 0) {
      setTagsForItem(targetItem, tagList);
    }
    alert('添加成功');
  } catch {
    alert('添加失败');
  }
}

async function saveEditInternal() {
  try {
    if (currentItem.value.id) {
      await updateKnowledge(currentItem.value.id, currentItem.value);
      showEditDialog.value = false;
      await loadAll();
      const tagList = tagsInput.value.split(/[,，]/).map((tag) => tag.trim()).filter(Boolean);
      setTagsForItem(currentItem.value, tagList);
      alert('更新成功');
    }
  } catch {
    alert('更新失败');
  }
}

function requestEditSave() {
  showEditConfirm.value = true;
}

async function confirmEditSave() {
  showEditConfirm.value = false;
  await saveEditInternal();
}

async function handleDelete(id: number) {
  if (!confirm('确定要删除这个条目吗？')) return;
  try {
    const targetItem = results.value.find((item) => item.id === id);
    await deleteKnowledge(id);
    await loadAll();
    await loadCategories();
    if (targetItem) {
      const key = getItemKey(targetItem);
      if (favorites.value.has(key)) {
        favorites.value.delete(key);
        saveFavorites();
      }
      if (tagsMap.value[key]) {
        delete tagsMap.value[key];
        saveTagsMap();
      }
    }
    alert('删除成功');
  } catch {
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

async function openInteractionsDialog() {
  showInteractionsDialog.value = true;
  loadingInteractions.value = true;
  try {
    interactions.value = await getAllInteractions();
  } catch {
    alert('加载相生相克数据失败');
  } finally {
    loadingInteractions.value = false;
  }
}

// 图标路径定义
const iconPaths = {
  search: "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z",
  reset: "M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15",
  interactions: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4",
  close: "M18.3 5.71 12 12l6.3 6.29-1.42 1.42L10.59 13.4l-6.3 6.3-1.42-1.42L9.17 12 2.87 5.7l1.42-1.41 6.3 6.29 6.29-6.3z",
  add: "M12 4v16m8-8H4",
  image: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z",
  tcm: "M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z",
  nutrition: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01",
  usage: "M13 10V3L4 14h7v7l9-11h-7z",
  check: "M5 13l4 4L19 7",
  warning: "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
  season: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z",
  empty: "M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 018 0z",
  favorite: "M4.318 6.318a4.5 4.5 0 010-6.364 4.5 4.5 0 016.364 0L12 1.272l1.318-1.318a4.5 4.5 0 116.364 6.364L12 13.364 4.318 6.318z",
  favoriteFilled: "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 6 3.5 4 5.5 4c1.54 0 3.04.99 3.57 2.36h1.87C13.46 4.99 14.96 4 16.5 4 18.5 4 20 6 20 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z",
  effect: "M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z",
  science: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253",
  recommendation: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2",
  chevronDown: "M19 9l-7 7-7-7",
  chevronUp: "M5 15l7-7 7 7"
};

const expandedId = ref<number | null>(null);

function toggleExpand(id: number) {
  if (expandedId.value === id) {
    expandedId.value = null;
  } else {
    expandedId.value = id;
  }
}

// 检查是否应该向左展开（第3、4列）
// 逻辑移至 CSS :nth-child 处理以支持响应式

function getRelationshipColor(type: string) {
  return type === '相生' ? '#4CAF50' : '#f44336';
}

function getRelationshipIconKey(type: string) {
  return type === '相生' ? 'check' : 'warning';
}

function escapeHtml(text: string) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function highlightText(text: string) {
  const safeText = escapeHtml(text || '');
  const term = keyword.value.trim();
  if (!term) return safeText;
  const escapedTerm = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(escapedTerm, 'gi');
  return safeText.replace(regex, (match) => `<span class="highlight-text">${match}</span>`);
}

function openBatchImportDialog() {
  batchItems.value = [];
  batchError.value = '';
  showBatchImportDialog.value = true;
}

function closeBatchImportDialog() {
  showBatchImportDialog.value = false;
  batchItems.value = [];
  batchError.value = '';
}

function parseCsvLine(line: string): string[] {
  const result: string[] = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === ',' && !inQuotes) {
      result.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  result.push(current);
  return result.map((cell: string) => cell.trim());
}

function normalizeImportItems(items: Record<string, string>[]) {
  const fieldMap: Record<string, keyof ImportItem> = {
    name: 'name',
    名称: 'name',
    category: 'category',
    分类: 'category',
    tcmEffect: 'tcmEffect',
    中医功效: 'tcmEffect',
    westernNutrition: 'westernNutrition',
    现代营养: 'westernNutrition',
    suitable: 'suitable',
    适合体质: 'suitable',
    taboo: 'taboo',
    禁忌: 'taboo',
    usageMethod: 'usageMethod',
    使用方法: 'usageMethod',
    season: 'season',
    适宜季节: 'season',
    imageUrl: 'imageUrl',
    图片: 'imageUrl',
    图片地址: 'imageUrl',
    tags: 'tags',
    标签: 'tags'
  };
  return items.map((row) => {
    const item: ImportItem = {
      name: '',
      category: '',
      tcmEffect: '',
      westernNutrition: '',
      suitable: '',
      taboo: '',
      usageMethod: '',
      season: ''
    };
    Object.entries(row).forEach(([key, value]) => {
      const mapped = fieldMap[key.trim()];
      if (!mapped) return;
      if (mapped === 'tags') {
        item.tags = value
          .split(/[,，]/)
          .map((tag) => tag.trim())
          .filter(Boolean);
      } else {
        (item[mapped] as string) = value;
      }
    });
    return item;
  });
}

async function handleBatchFileChange(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;
  batchError.value = '';
  try {
    const text = await file.text();
    let parsedItems: ImportItem[] = [];
    if (file.name.toLowerCase().endsWith('.json')) {
      const data = JSON.parse(text) as unknown;
      const list: unknown[] = Array.isArray(data)
        ? data
        : typeof data === 'object' &&
            data !== null &&
            Array.isArray((data as Record<string, unknown>).items)
          ? ((data as Record<string, unknown>).items as unknown[])
          : [];
      parsedItems = list.map((raw: unknown) => {
        const item = raw as Record<string, unknown>;
        const tagsValue = item.tags;
        const tags = Array.isArray(tagsValue)
          ? tagsValue.filter((tag) => typeof tag === 'string')
          : typeof tagsValue === 'string'
            ? tagsValue.split(/[,，]/).map((tag) => tag.trim()).filter(Boolean)
            : undefined;

        return {
          name: typeof item.name === 'string' ? item.name : '',
          category: typeof item.category === 'string' ? item.category : '',
          imageUrl: typeof item.imageUrl === 'string' ? item.imageUrl : undefined,
          tcmEffect: typeof item.tcmEffect === 'string' ? item.tcmEffect : '',
          westernNutrition: typeof item.westernNutrition === 'string' ? item.westernNutrition : '',
          suitable: typeof item.suitable === 'string' ? item.suitable : '',
          taboo: typeof item.taboo === 'string' ? item.taboo : '',
          usageMethod: typeof item.usageMethod === 'string' ? item.usageMethod : undefined,
          season: typeof item.season === 'string' ? item.season : undefined,
          tags
        };
      });
    } else {
      const lines = text.split(/\r?\n/).filter((line) => line.trim());
      if (lines.length < 2) {
        batchError.value = '文件内容不足';
        return;
      }
      const headerLine = lines[0];
      if (!headerLine) {
        batchError.value = '文件内容不足';
        return;
      }
      const headers = parseCsvLine(headerLine);
      const rows = lines.slice(1).map((line: string) => {
        const cells = parseCsvLine(line);
        const row: Record<string, string> = {};
        headers.forEach((header: string, index: number) => {
          row[header] = String(cells[index] ?? '');
        });
        return row;
      });
      parsedItems = normalizeImportItems(rows);
    }
    batchItems.value = parsedItems.filter((item) => item.name && item.category && item.tcmEffect);
    if (batchItems.value.length === 0) {
      batchError.value = '未识别到可导入的数据';
    }
  } catch {
    batchError.value = '解析失败，请检查文件格式';
  }
}

async function confirmBatchImport() {
  if (batchItems.value.length === 0) return;
  importingBatch.value = true;
  batchError.value = '';
  try {
    for (const item of batchItems.value) {
      const { tags, ...payload } = item;
      const created = await createKnowledge(payload);
      const targetItem = created?.id
        ? { ...payload, id: created.id }
        : payload;
      if (tags && tags.length > 0) {
        setTagsForItem(targetItem, tags);
      }
    }
    await loadAll();
    await loadCategories();
    closeBatchImportDialog();
    alert('批量导入完成');
  } catch {
    batchError.value = '批量导入失败，请稍后重试';
  } finally {
    importingBatch.value = false;
  }
}

watch(
  [keyword, selectedCategory, selectedSeason, effectKeyword, selectedTagsInput, sortOption],
  () => {
    currentPage.value = 1;
  }
);
</script>

<template>
  <div class="knowledge-page">
    <!-- 返回首页按钮 -->
    <button @click="goHome" class="back-top-left">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      返回首页
    </button>

    <div class="header">
      <h1>食材药材知识库</h1>
      <p class="subtitle">中医养生智慧 · 现代营养科学</p>
    </div>

    <!-- 搜索和筛选区 -->
    <div class="search-section">
      <div class="search-bar">
        <input
          v-model="keyword"
          placeholder="搜索食材、药材名称或功效..."
          @keyup.enter="search"
        />
        <button @click="search" class="btn-primary">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path :d="iconPaths.search" />
          </svg>
          搜索
        </button>
        <button @click="loadAll" class="btn-secondary">显示全部</button>
        <button @click="resetFilters" class="btn-secondary">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path :d="iconPaths.reset" />
          </svg>
          重置条件
        </button>
        <button @click="openInteractionsDialog" class="btn-interactions">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path :d="iconPaths.interactions" />
          </svg>
          相生相克
        </button>
      </div>

      <div class="filter-bar">
        <label>分类筛选：</label>
        <select v-model="selectedCategory" @change="filterByCategory">
          <option value="">全部分类</option>
          <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
        </select>
        <label>标签：</label>
        <input
          v-model="selectedTagsInput"
          class="filter-input"
          placeholder="如：补气、润肺"
        />
        <label>功效：</label>
        <input
          v-model="effectKeyword"
          class="filter-input"
          placeholder="如：清热"
          @keyup.enter="search"
        />
        <label>季节：</label>
        <select v-model="selectedSeason">
          <option value="">全部季节</option>
          <option v-for="season in seasonOptions" :key="season" :value="season">{{ season }}</option>
        </select>
        <label class="sort-label">排序：</label>
        <select v-model="sortOption">
          <option value="default">默认</option>
          <option value="name">名称</option>
          <option value="category">分类</option>
        </select>
        <button v-if="isAdmin" @click="openBatchImportDialog" class="btn-secondary btn-batch">
          批量导入
        </button>
        <button v-if="isAdmin" @click="openAddDialog" class="btn-add">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path :d="iconPaths.add" />
          </svg>
          添加条目
        </button>
      </div>

      <!-- 顶部分页控件 -->
      <div v-if="totalCount > pageSize" class="top-pagination">
        <div class="page-info">
          共 {{ totalCount }} 条，第 {{ currentPage }} / {{ totalPages }} 页
        </div>
      </div>
    </div>

    <!-- 知识库列表 -->
    <div v-if="loading" class="knowledge-grid">
      <div v-for="n in pageSize" :key="n" class="knowledge-card skeleton-card">
        <div class="image-container skeleton-block"></div>
        <div class="card-content">
          <div class="skeleton-line title"></div>
          <div class="skeleton-line"></div>
          <div class="skeleton-line"></div>
          <div class="skeleton-line short"></div>
        </div>
      </div>
    </div>

    <div v-else-if="errorMessage" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path :d="iconPaths.empty" />
      </svg>
      <p>{{ errorMessage }}</p>
      <button class="btn-primary retry-btn" @click="loadAll">重新加载</button>
    </div>

    <div v-else class="knowledge-grid">
      <div v-for="item in paginatedResults" :key="item.id" class="knowledge-card">
        <!-- 主体卡片内容 -->
        <div class="card-main">
          <!-- 图片区域 -->
          <div class="image-container">
            <img
              v-if="item.imageUrl"
              :src="getImageUrl(item.imageUrl)"
              :alt="item.name"
              class="item-image"
            />
            <div v-else class="no-image">
              <svg class="placeholder-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path :d="iconPaths.image" />
              </svg>
              <p>暂无图片</p>
            </div>
            <button
              class="favorite-btn"
              :class="{ active: isFavorite(item) }"
              @click.stop="toggleFavorite(item)"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path :d="isFavorite(item) ? iconPaths.favoriteFilled : iconPaths.favorite" />
              </svg>
            </button>
            <span v-if="item.category" class="category-badge">{{ item.category }}</span>
          </div>

          <!-- 内容区域 -->
          <div class="card-content">
            <h3 v-html="highlightText(item.name)"></h3>

            <button
              class="toggle-btn"
              @click="toggleExpand(item.id ?? -1)"
              :class="{ expanded: expandedId === (item.id ?? -1) }"
            >
              {{ expandedId === (item.id ?? -1) ? '收起详情' : '查看详情' }}
            </button>
          </div>
        </div>

        <!-- 详情面板 -->
        <div
          class="card-details-panel"
          :class="{ expanded: expandedId === (item.id ?? -1) }"
        >
          <div class="details-wrapper">
            <div class="info-section">
              <h4>
                <svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.tcm" />
                </svg>
                中医功效
              </h4>
              <p v-html="highlightText(item.tcmEffect)"></p>
            </div>

            <div class="info-section">
              <h4>
                <svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.nutrition" />
                </svg>
                现代营养
              </h4>
              <p v-html="highlightText(item.westernNutrition)"></p>
            </div>

            <div class="info-section" v-if="item.usageMethod">
              <h4>
                <svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.usage" />
                </svg>
                使用方法
              </h4>
              <p v-html="highlightText(item.usageMethod)"></p>
            </div>

            <div class="tags">
              <span class="tag suitable">
                <svg class="tag-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.check" />
                </svg>
                适合：{{ item.suitable }}
              </span>
              <span class="tag taboo">
                <svg class="tag-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.warning" />
                </svg>
                禁忌：{{ item.taboo }}
              </span>
              <span v-if="item.season" class="tag season">
                <svg class="tag-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path :d="iconPaths.season" />
                </svg>
                {{ item.season }}
              </span>
            </div>
            <div v-if="getItemTags(item).length > 0" class="tag-group">
              <span v-for="tag in getItemTags(item)" :key="tag" class="tag info">
                {{ tag }}
              </span>
            </div>

            <!-- 管理按钮 -->
            <div v-if="isAdmin" class="admin-actions">
              <button @click="openEditDialog(item)" class="btn-edit">编辑</button>
              <button @click="handleDelete(item.id ?? -1)" class="btn-delete">删除</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="!loading && !errorMessage && totalCount === 0" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path :d="iconPaths.empty" />
      </svg>
      <p>暂无数据</p>
    </div>

    <!-- 分页控件 -->
    <div v-if="totalCount > 0" class="pagination">
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
        第 {{ currentPage }} / {{ totalPages }} 页 （共 {{ totalCount }} 条）
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
            <label>标签</label>
            <input v-model="tagsInput" placeholder="如：补气、润肺" />
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
        <form @submit.prevent="requestEditSave">
          <div class="form-group">
            <label>名称*</label>
            <input v-model="currentItem.name" required />
          </div>
          <div class="form-group">
            <label>分类*</label>
            <input v-model="currentItem.category" required />
          </div>
          <div class="form-group">
            <label>标签</label>
            <input v-model="tagsInput" placeholder="如：补气、润肺" />
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

    <div v-if="showEditConfirm" class="modal-overlay" @click.self="showEditConfirm = false">
      <div class="modal-content confirm-modal">
        <h3>确认保存修改</h3>
        <p class="confirm-text">确认保存对 {{ currentItem.name || '该条目' }} 的修改？</p>
        <div class="modal-actions">
          <button class="btn-primary" @click="confirmEditSave">确认保存</button>
          <button class="btn-secondary" @click="showEditConfirm = false">取消</button>
        </div>
      </div>
    </div>

    <div v-if="showBatchImportDialog" class="modal-overlay" @click.self="closeBatchImportDialog">
      <div class="modal-content batch-modal">
        <div class="modal-header">
          <h3>批量导入知识库</h3>
          <button @click="closeBatchImportDialog" class="close-btn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path :d="iconPaths.close" />
            </svg>
          </button>
        </div>
        <div class="form-group">
          <label>选择文件</label>
          <input type="file" @change="handleBatchFileChange" accept=".json,.csv" />
        </div>
        <div class="batch-hint">支持 JSON 数组或 CSV 表格，字段可包含名称、分类、中医功效、现代营养、适合体质、禁忌、使用方法、适宜季节、标签、图片地址</div>
        <div v-if="batchError" class="form-error">{{ batchError }}</div>
        <div v-if="batchItems.length > 0" class="batch-preview">
          <div class="batch-summary">已识别 {{ batchItems.length }} 条记录</div>
          <div class="batch-list">
            <div v-for="(item, index) in batchItems" :key="index" class="batch-item">
              <div class="batch-name">{{ item.name }}</div>
              <div class="batch-meta">{{ item.category }} · {{ item.season || '未设置季节' }}</div>
            </div>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-primary" :disabled="importingBatch || batchItems.length === 0" @click="confirmBatchImport">
            {{ importingBatch ? '导入中...' : '开始导入' }}
          </button>
          <button class="btn-secondary" @click="closeBatchImportDialog">取消</button>
        </div>
      </div>
    </div>

    <!-- 相生相克对话框 -->
    <div v-if="showInteractionsDialog" class="modal-overlay" @click.self="showInteractionsDialog = false">
      <div class="modal-content interactions-modal">
        <div class="modal-header">
          <h3>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 24px; height: 24px; vertical-align: text-bottom; margin-right: 8px;">
              <path :d="iconPaths.interactions" />
            </svg>
            食材药材相生相克关系
          </h3>
          <button @click="showInteractionsDialog = false" class="close-btn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path :d="iconPaths.close" />
            </svg>
          </button>
        </div>

        <div v-if="loadingInteractions" class="loading-state">
          <p>加载中...</p>
        </div>

        <div v-else-if="interactions.length === 0" class="empty-state">
          <p>暂无数据</p>
        </div>

        <div v-else class="interactions-list">
          <div
            v-for="interaction in interactions"
            :key="interaction.id"
            class="interaction-card"
            :class="interaction.relationshipType === '相生' ? 'positive' : 'negative'"
          >
            <div class="interaction-header">
              <div class="items-row">
                <span class="item-name">{{ interaction.item1Name }}</span>
                <span class="relation-icon" :style="{ color: getRelationshipColor(interaction.relationshipType), display: 'flex', alignItems: 'center', gap: '4px' }">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
                    <path :d="iconPaths[getRelationshipIconKey(interaction.relationshipType)]" />
                  </svg>
                  {{ interaction.relationshipType }}
                </span>
                <span class="item-name">{{ interaction.item2Name }}</span>
              </div>
              <span class="severity-badge" :class="interaction.severityLevel">
                {{ interaction.severityLevel }}
              </span>
            </div>

            <div class="interaction-body">
              <div class="info-row">
                <strong>
                  <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.effect" />
                  </svg>
                  效果描述：
                </strong>
                <p>{{ interaction.effectDescription }}</p>
              </div>

              <div class="info-row">
                <strong>
                  <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.science" />
                  </svg>
                  科学依据：
                </strong>
                <p>{{ interaction.scientificBasis }}</p>
              </div>

              <div class="info-row recommendation">
                <strong>
                  <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path :d="iconPaths.recommendation" />
                  </svg>
                  建议：
                </strong>
                <p>{{ interaction.recommendation }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.knowledge-page {
  --primary-color: #10b981;
  --primary-dark: #059669;
  --primary-light: #ecfdf5;
  --accent-color: #3b82f6;
  --text-main: #0f172a;
  --text-sub: #475569;
  --bg-page: #e2e8f0;
  --card-bg: #ffffff;
  --option-bg: #f8fafc;
  --glass-border: rgba(255, 255, 255, 0.8);
  --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);

  min-height: 100vh;
  padding: 100px 20px 40px;
  background: #f1f5f9;
  background-image:
    radial-gradient(at 0% 0%, rgba(16, 185, 129, 0.15) 0px, transparent 50%),
    radial-gradient(at 100% 100%, rgba(59, 130, 246, 0.15) 0px, transparent 50%);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  color: var(--text-main);
}

.knowledge-page > *:not(.back-top-left) {
  max-width: 1400px;
  margin: 0 auto;
}

.back-top-left {
  position: fixed !important;
  top: 20px !important;
  left: 20px !important;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  color: var(--text-sub);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  z-index: 1000;
  font-size: 14px;
}

.back-top-left:hover {
  background: rgba(255, 255, 255, 1);
  color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.header {
  text-align: center;
  margin-bottom: 32px;
}

.header h1 {
  font-size: 32px;
  margin-bottom: 12px;
  color: var(--text-main);
  font-weight: 800;
}

.subtitle {
  color: var(--text-sub);
  font-size: 14px;
}

.search-section {
  background: var(--card-bg);
  padding: 16px;
  border-radius: 24px;
  margin-bottom: 80px;
  box-shadow: var(--shadow-card);
  border: 1px solid rgba(255, 255, 255, 0.5);
  max-width: 1400px;
  margin-left: auto;
  margin-right: auto;
}

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.search-bar input {
  flex: 1;
  padding: 12px 16px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  font-size: 16px;
  transition: all 0.3s;
  background: var(--option-bg);
}

.search-bar input:focus {
  outline: none;
  border-color: var(--primary-color);
  background: white;
  box-shadow: 0 0 0 4px var(--primary-light);
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.filter-bar label {
  color: var(--text-main);
  font-weight: 600;
  font-size: 14px;
  white-space: nowrap;
}

.sort-label {
  margin-left: auto;
}

.filter-bar select {
  padding: 10px 14px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: white;
  color: var(--text-main);
  font-size: 14px;
  min-width: 140px;
  transition: all 0.3s;
  cursor: pointer;
}

.filter-bar select:hover {
  border-color: #cbd5e1;
}

.filter-bar select:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 4px var(--primary-light);
}

.filter-input {
  padding: 10px 14px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: white;
  color: var(--text-main);
  font-size: 14px;
  min-width: 200px;
  transition: all 0.3s;
}

.filter-input:hover {
  border-color: #cbd5e1;
}

.filter-input:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 4px var(--primary-light);
}

.filter-input::placeholder {
  color: #94a3b8;
  font-style: italic;
}

button {
  font-family: inherit;
}

.btn-primary {
  background: var(--primary-color);
  color: white;
  padding: 12px 24px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.btn-primary:hover {
  background: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(16, 185, 129, 0.4);
}

.btn-secondary {
  background: #fff;
  color: var(--text-sub);
  padding: 12px 20px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: #f8fafc;
  color: var(--text-main);
}

.favorite-toggle {
  transition: all 0.3s;
}

.favorite-toggle.active {
  background: var(--primary-light);
  color: var(--primary-color);
  border-color: var(--primary-color);
}

.favorite-toggle.active:hover {
  background: #d1fae5;
}

.btn-batch {
  background: #eff6ff;
  color: #3b82f6;
  border-color: #dbeafe;
}

.btn-batch:hover {
  background: #dbeafe;
  color: #2563eb;
  border-color: #3b82f6;
}

.btn-interactions {
  background: var(--accent-color);
  color: white;
  padding: 12px 24px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
  margin-left: auto;
}

.btn-interactions:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(59, 130, 246, 0.4);
}

.btn-add {
  background: var(--primary-color);
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  margin-left: auto;
}

.btn-icon {
  width: 18px;
  height: 18px;
}

/* 顶部分页信息 */
.top-pagination {
  margin-top: 20px;
  margin-bottom: 32px;
  padding-top: 16px;
  border-top: 1px solid #e2e8f0;
}

.top-pagination .page-info {
  text-align: center;
  color: var(--text-sub);
  font-size: 14px;
  font-weight: 600;
}

/* 列表网格 - 固定4列布局 */
.knowledge-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 80px;
  max-width: 1400px;
  margin-left: auto;
  margin-right: auto;
}

/* 响应式：3列 */
@media (max-width: 1200px) {
  .knowledge-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

/* 响应式：2列 */
@media (max-width: 768px) {
  .knowledge-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
}

/* 响应式：1列 */
@media (max-width: 480px) {
  .knowledge-grid {
    grid-template-columns: 1fr;
  }
}

.knowledge-card {
  position: relative;
  background: transparent;
  box-shadow: none;
  border: none;
  border-radius: 0;
  transition: z-index 0s 0.3s;
  z-index: 1;
}

.knowledge-card:has(.expanded) {
  z-index: 100;
  transition: z-index 0s;
}

.card-main {
  background: var(--card-bg);
  border-radius: 24px;
  box-shadow: var(--shadow-card);
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid rgba(255, 255, 255, 0.5);
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
  z-index: 2;
}

.card-main:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-hover);
  border-color: rgba(16, 185, 129, 0.35);
}

/* 当卡片hover时，详细面板也跟随移动 */
.knowledge-card:hover .card-details-panel {
  transform: translateY(-8px) scaleX(0.8);
}

/* 当详细面板展开且卡片hover时，同时应用两个变换 */
.knowledge-card:hover .card-details-panel.expanded {
  transform: translateY(-8px) scaleX(1) !important;
}

.image-container {
  height: 220px;
  position: relative;
  background: #f1f5f9;
}

.image-container::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(15, 23, 42, 0) 45%, rgba(15, 23, 42, 0.15) 100%);
  pointer-events: none;
}

.item-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-image {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #94a3b8;
  gap: 12px;
}

.category-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  background: rgba(16, 185, 129, 0.9);
  backdrop-filter: blur(4px);
  color: white;
  padding: 6px 16px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border: 1px solid rgba(255, 255, 255, 0.7);
}

.favorite-btn {
  position: absolute;
  top: 16px;
  left: 16px;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.favorite-btn svg {
  width: 20px;
  height: 20px;
  color: #94a3b8;
  transition: all 0.3s;
}

.favorite-btn:hover {
  transform: scale(1.1);
  background: white;
}

.favorite-btn:hover svg {
  color: #ef4444;
}

.favorite-btn.active svg {
  color: #ef4444;
  fill: #ef4444;
}

.card-content {
  padding: 26px;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-content h3 {
  font-size: 22px;
  font-weight: 800;
  color: var(--text-main);
  margin: 0;
  line-height: 1.4;
}

/* 详情面板 - 桌面端样式 */
.card-details-panel {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 100%;
  background: linear-gradient(135deg, #ffffff 0%, #f8fffe 100%);
  box-shadow: 0 10px 30px rgba(16, 185, 129, 0.15), 0 0 0 1px rgba(16, 185, 129, 0.1);
  border: 2px solid rgba(16, 185, 129, 0.3);
  z-index: 1;
  opacity: 0;
  pointer-events: none;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
  overflow-y: auto;
  transform: scaleX(0.8);
 }

 /* 默认4列布局方向控制 */
 /* 第1、2列向右展开 */
 .knowledge-card:nth-child(4n+1) .card-details-panel,
 .knowledge-card:nth-child(4n+2) .card-details-panel {
   left: 95%;
   right: auto;
   transform-origin: left center;
   border-radius: 0 24px 24px 0;
   border-left: none;
   border-right: 1px solid rgba(16, 185, 129, 0.2);
 }

 /* 第3、4列向左展开 */
 .knowledge-card:nth-child(4n+3) .card-details-panel,
 .knowledge-card:nth-child(4n+4) .card-details-panel {
   right: 95%;
   left: auto;
   transform-origin: right center;
   border-radius: 24px 0 0 24px;
   border-right: none;
   border-left: 1px solid rgba(16, 185, 129, 0.2);
 }

 /* 3列布局适配 (max-width: 1200px) */
 @media (max-width: 1200px) {
   /* 第1、2列向右展开 */
   .knowledge-card:nth-child(3n+1) .card-details-panel,
   .knowledge-card:nth-child(3n+2) .card-details-panel {
     left: 95%;
     right: auto;
     transform-origin: left center;
     border-radius: 0 24px 24px 0;
     border-left: none;
     border-right: 1px solid rgba(16, 185, 129, 0.2);
   }

   /* 第3列向左展开 */
   .knowledge-card:nth-child(3n+3) .card-details-panel {
     right: 95%;
     left: auto;
     transform-origin: right center;
     border-radius: 24px 0 0 24px;
     border-right: none;
     border-left: 1px solid rgba(16, 185, 129, 0.2);
   }
 }

 .card-details-panel.expanded {
  opacity: 1;
  pointer-events: auto;
  transform: scaleX(1);
  width: 110%;
}

.details-wrapper {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .knowledge-card {
    overflow: visible;
    z-index: auto !important;
  }

  .card-main {
    transform: none !important;
    border-radius: 24px 24px 0 0;
    border-bottom: none;
    box-shadow: none;
    z-index: 2;
  }

  .knowledge-card:has(.expanded) .card-main {
    border-radius: 24px 24px 0 0;
  }

  .card-details-panel {
    position: static;
    width: 100% !important;
    height: auto;
    opacity: 1;
    transform: none !important;
    border-radius: 0 0 24px 24px;
    border: 1px solid rgba(255, 255, 255, 0.5);
    border-top: none;
    background: #f8fafc;
    transition: none; /* 使用 grid 动画 */
    overflow: hidden;
    display: grid;
    grid-template-rows: 0fr;
    padding: 0;
    border-width: 0;
    margin-top: -1px;
    box-shadow: var(--shadow-card);
  }

  .card-details-panel.expanded {
    grid-template-rows: 1fr;
    border-width: 1px;
    padding-bottom: 16px;
  }

  .details-wrapper {
    overflow: hidden;
    padding: 0 24px;
  }

  .card-details-panel.expanded .details-wrapper {
    padding: 24px;
  }
}

.toggle-btn {
  width: 100%;
  padding: 10px;
  background: var(--option-bg);
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  color: var(--primary-color);
  cursor: pointer;
  transition: all 0.2s;
  font-weight: 600;
  margin-top: auto;
  text-align: center;
}

.toggle-btn:hover {
  background: var(--primary-light);
  border-color: var(--primary-color);
}

.toggle-btn.expanded {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.info-section {
  padding: 16px;
  background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
  border-radius: 16px;
  border: 1px solid rgba(16, 185, 129, 0.2);
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.08);
}

.info-section h4 {
  font-size: 14px;
  color: var(--text-main);
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 700;
}

.section-icon {
  width: 16px;
  height: 16px;
  color: var(--primary-color);
}

.info-section p {
  margin: 0;
  color: var(--text-sub);
  line-height: 1.6;
  font-size: 13px;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: auto;
  padding-top: 12px;
  border-top: 1px solid #f1f5f9;
}

.tag {
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 4px;
  box-shadow: 0 2px 6px rgba(15, 23, 42, 0.06);
}

.tag.suitable {
  background: var(--primary-light);
  color: var(--primary-dark);
}

.tag.taboo {
  background: #fff1f2;
  color: #e11d48;
}

.tag.season {
  background: #eff6ff;
  color: #2563eb;
}

.tag-icon {
  width: 14px;
  height: 14px;
}

.admin-actions {
  display: flex;
  gap: 8px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid #f1f5f9;
}

.btn-edit,
.btn-delete {
  flex: 1;
  padding: 8px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.2s;
}

.btn-edit {
  background: #eff6ff;
  color: #3b82f6;
}

.btn-edit:hover {
  background: #dbeafe;
}

.btn-delete {
  background: #fef2f2;
  color: #ef4444;
}

.btn-delete:hover {
  background: #fee2e2;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 64px 0;
  color: var(--text-sub);
}

.empty-icon {
  width: 64px;
  height: 64px;
  color: #cbd5e1;
  margin-bottom: 16px;
}

.placeholder-icon {
  width: 48px;
  height: 48px;
  opacity: 0.5;
}

/* 分页 */
.pagination {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 80px;
  align-items: center;
  flex-wrap: wrap;
}

.pagination-btn {
  background: #fff;
  color: var(--text-sub);
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 10px 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-btn:hover:not(:disabled) {
  background: #f8fafc;
  color: var(--text-main);
}

.page-numbers {
  display: flex;
  gap: 8px;
  align-items: center;
}

.page-number {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  background: white;
  color: var(--text-sub);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #e2e8f0;
}

.page-number.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.page-ellipsis {
  color: var(--text-sub);
  font-weight: 600;
  padding: 0 6px;
}

.page-info {
  color: var(--text-sub);
  font-size: 13px;
  font-weight: 600;
}

/* 模态框 */
.modal-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  border-radius: 24px;
  padding: 40px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  max-width: 600px;
  width: 90%;
  max-height: 85vh;
  overflow-y: auto;
  position: relative;
}

.modal-content h3 {
  font-size: 24px;
  font-weight: 700;
  color: var(--text-main);
  margin-bottom: 24px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  position: sticky;
  top: 0;
  background: white;
  z-index: 10;
  padding-bottom: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.modal-header h3 {
  margin: 0;
  display: flex;
  align-items: center;
}

.close-btn {
  border: none;
  background: #f8fafc;
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--text-sub);
  cursor: pointer;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #eef2f7;
  color: var(--text-main);
}

.close-btn svg {
  width: 16px;
  height: 16px;
}

.form-group label {
  color: var(--text-main);
  font-weight: 600;
  margin-bottom: 8px;
}

.form-group input,
.form-group textarea {
  border-radius: 12px;
  border: 2px solid #e2e8f0;
  padding: 12px;
  transition: all 0.3s;
}

.form-group input:focus,
.form-group textarea:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 4px var(--primary-light);
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
}

.form-group input[type="file"] {
  padding: 8px;
  font-size: 14px;
}

.preview-image {
  max-width: 200px;
  max-height: 200px;
  margin-top: 12px;
  border-radius: 12px;
  object-fit: cover;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

/* 相生相克弹窗 */
.interactions-modal {
  max-width: 800px;
}

.interactions-list {
  max-height: 60vh;
  overflow-y: auto;
  padding-right: 8px;
}

.interaction-card {
  border-radius: 16px;
  border: 2px solid #e2e8f0;
  padding: 20px;
  margin-bottom: 16px;
  transition: all 0.3s;
}

.interaction-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.interaction-card.positive {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-color: #86efac;
}

.interaction-card.negative {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border-color: #fca5a5;
}

.interaction-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.items-row {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.item-name {
  background: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 15px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  color: var(--text-main);
}

.relation-icon {
  font-weight: 700;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.severity-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}

.severity-badge.轻度 {
  background: #dbeafe;
  color: #1e40af;
}

.severity-badge.中度 {
  background: #fef3c7;
  color: #92400e;
}

.severity-badge.重度 {
  background: #fee2e2;
  color: #991b1b;
}

.interaction-body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-row {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.info-row strong {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-main);
  font-size: 14px;
}

.info-row p {
  margin: 0;
  color: var(--text-sub);
  line-height: 1.6;
  font-size: 14px;
  padding-left: 22px;
}

.info-row.recommendation {
  background: rgba(255, 255, 255, 0.6);
  padding: 12px;
  border-radius: 12px;
  border: 1px dashed rgba(0, 0, 0, 0.1);
}

.info-row.recommendation p {
  padding-left: 0;
  font-weight: 500;
}

.info-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.loading-state {
  text-align: center;
  padding: 40px;
  color: var(--text-sub);
}

.loading-state p {
  font-size: 16px;
  margin: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .search-bar {
    flex-direction: column;
  }

  .filter-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .btn-interactions, .btn-add {
    width: 100%;
    margin-left: 0;
    justify-content: center;
  }

  .knowledge-page {
    padding: 80px 16px 32px;
  }

  .header h1 {
    font-size: 24px;
  }
}
</style>
