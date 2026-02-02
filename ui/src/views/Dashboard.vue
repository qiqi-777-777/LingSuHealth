<template>
  <div class="dashboard-container" @click="handleClickOutside">
    <!-- 顶部导航栏 -->
    <DashboardHeader
      :username="username"
      :user-email="userEmail"
      :show-user-menu="showUserMenu"
      @toggle-user-menu="toggleUserMenu"
      @edit-profile="editProfile"
      @change-password="changePassword"
      @logout="logout"
      @navigate="navigateTo"
    />

    <!-- 主要内容区域 -->
    <main class="main-content">
      <div class="dashboard-grid">
        <!-- Left Column -->
        <div class="left-column">
          <!-- Hero 区域 (AI 交互 + 3个按钮) -->
          <HeroSection
            :username="username"
            :today-done="todayDone"
            :today-total="todayTotal"
            :week-done="weekDone"
            :week-total="weekTotal"
            :has-today-checkin="hasTodayCheckin"
            @navigate="navigateTo"
            @open-plan-modal="openPlanModal"
          />

          <!-- 功能卡片 (第二组) -->
          <FeatureCards
            :today-done="todayDone"
            :today-total="todayTotal"
            :week-done="weekDone"
            :week-total="weekTotal"
            @navigate="navigateTo"
            @open-plan-modal="openPlanModal"
          />

          <!-- 功能描述 (下方区域) -->
          <FeatureDescription />
        </div>

        <!-- Right Column -->
        <div class="right-column">
          <!-- Top: Two Widgets -->
          <div class="side-widgets-row">
            <div class="widget-wrapper compact">
              <SolarTermWidget />
            </div>
            <div class="widget-wrapper compact">
              <SmartSuggestionCard />
            </div>
          </div>

          <!-- Bottom: Onboarding Section (Compact) -->
          <OnboardingSection layout="compact" />
        </div>
      </div>

      <!-- 黑色框框区域 -->
      <MarketingSection />
    </main>

    <!-- Plan Modal Component -->
    <PlanModal v-model="showPlanModal" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuth } from '../composables/useAuth';
import PlanModal from '../components/dashboard/PlanModal.vue';
import { useHealthPlan } from '../composables/useHealthPlan';
import { checkTodayCheckin } from '../services/api';

// Import new components
import DashboardHeader from '../components/dashboard/DashboardHeader.vue';
import HeroSection from '../components/dashboard/HeroSection.vue';
import FeatureCards from '../components/dashboard/FeatureCards.vue';
import FeatureDescription from '../components/dashboard/FeatureDescription.vue';
import MarketingSection from '../components/dashboard/MarketingSection.vue';
import OnboardingSection from '../components/dashboard/OnboardingSection.vue';
import SolarTermWidget from '../components/SolarTermWidget.vue';
import SmartSuggestionCard from '../components/dashboard/SmartSuggestionCard.vue';

defineOptions({ name: 'DashboardView' });

const router = useRouter();
const showUserMenu = ref(false);
const username = ref('');
const userEmail = ref('');
const showPlanModal = ref(false);
const hasTodayCheckin = ref<boolean | null>(null);

const { todayDone, todayTotal, weekDone, weekTotal } = useHealthPlan();

function openPlanModal() {
  showPlanModal.value = true;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

async function loadTodayCheckinStatus() {
  try {
    const data: unknown = await checkTodayCheckin();
    if (typeof data === 'boolean') {
      hasTodayCheckin.value = data;
      return;
    }
    if (!isRecord(data)) {
      hasTodayCheckin.value = false;
      return;
    }

    if (typeof data.exists === 'boolean') {
      hasTodayCheckin.value = data.exists;
      return;
    }
    if (typeof data.checked === 'boolean') {
      hasTodayCheckin.value = data.checked;
      return;
    }
    if (typeof data.hasCheckin === 'boolean') {
      hasTodayCheckin.value = data.hasCheckin;
      return;
    }

    if (typeof data.success === 'boolean' && isRecord(data.data) && typeof data.data.hasCheckin === 'boolean') {
      hasTodayCheckin.value = data.data.hasCheckin;
      return;
    }
    hasTodayCheckin.value = false;
  } catch {
    hasTodayCheckin.value = null;
  }
}

onMounted(() => {
  username.value = localStorage.getItem('username') || '用户';
  userEmail.value = localStorage.getItem('userEmail') || 'user@example.com';
  void loadTodayCheckinStatus();
});

onUnmounted(() => {
  // Cleanup if needed
});

function navigateTo(path: string) {
  router.push(path);
}

function toggleUserMenu() {
  showUserMenu.value = !showUserMenu.value;
}

function editProfile() {
  showUserMenu.value = false;
  router.push('/profile');
}

function changePassword() {
  showUserMenu.value = false;
  router.push('/change-password');
}

function logout() {
  const { logout: performLogout } = useAuth();
  showUserMenu.value = false;
  performLogout();
}

function handleClickOutside(event: Event) {
  const target = event.target as HTMLElement;
  const userMenuContainer = document.querySelector('.user-menu-container');
  if (userMenuContainer && !userMenuContainer.contains(target)) {
    showUserMenu.value = false;
  }
}
</script>

<style scoped>
.dashboard-grid {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 60px;
  max-width: 1400px;
  margin: 0 auto 60px;
  padding-top: 40px;
  /* Removed align-items: stretch to allow natural height */
}

.left-column {
  display: flex;
  flex-direction: column;
  gap: 20px;
  /* Removed height: 100% to allow content to dictate height */
}

/* Ensure children of left-column expand horizontally but not vertically forced */
.left-column :deep(.hero-quick-actions),
.left-column :deep(.feature-cards-container) {
  width: 100%;
}

.right-column {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.side-widgets-row {
  display: flex;
  gap: 20px;
  width: 100%;
  align-items: stretch; /* 让子元素高度一致 */
}

.widget-wrapper.compact {
  flex: 1;
  min-width: 0;
  height: 240px; /* 设置固定高度 */
}

.feature-cards-inner {
  display: flex;
  /* Remove default grid styling if present in child, handled here */
}

.dashboard-container {
  min-height: 100vh;
  /* 引入 Assessment 模块风格变量 */
  --primary-color: #10b981;
  --primary-dark: #059669;
  --primary-light: #ecfdf5;
  --accent-color: #3b82f6;
  --text-main: #0f172a;
  --text-sub: #475569;
  --bg-page: #f8fafc;
  --card-bg: #ffffff;
  --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);

  background: var(--bg-page);
  background-image: 
    radial-gradient(at 0% 0%, rgba(56, 189, 248, 0.12) 0px, transparent 50%),
    radial-gradient(at 100% 0%, rgba(16, 185, 129, 0.12) 0px, transparent 50%),
    radial-gradient(at 100% 100%, rgba(245, 158, 11, 0.05) 0px, transparent 50%);
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  padding: 80px 40px 40px 40px; /* Reduced top padding to account for header but keep space */
  max-width: 1600px;
  margin: 0 auto;
  width: 100%;
  position: relative;
  z-index: 1;
}

@media (max-width: 768px) {
  .main-content {
    padding: 100px 20px 20px 20px;
  }
}
</style>
