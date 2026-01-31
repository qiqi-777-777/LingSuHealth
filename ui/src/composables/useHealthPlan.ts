import { ref, computed } from 'vue';

// Define types
export interface Task {
  id: string;
  label: string;
  done: boolean;
  source: 'library' | 'custom';
  section?: string;
}

export interface PlanSection {
  key: string;
  label: string;
  tasks: Task[];
}

export interface LibraryGroup {
  key: string;
  label: string;
  tasks: { id: string; label: string; section: string }[];
}

// State needs to be outside the function to be shared (singleton pattern) if we want the same state across components,
// or inside if we want separate states. 
// In this case, Dashboard and PlanModal should share the same state.
// So I will define the state outside the function.

const dayPlanSections = ref<PlanSection[]>([
  {
    key: 'morning',
    label: '晨',
    tasks: [
      { id: 'morning-water', label: '温水醒脾', done: false, source: 'library' },
      { id: 'morning-stretch', label: '舒展拉伸5分钟', done: false, source: 'library' },
      { id: 'morning-breakfast', label: '早餐清淡少油', done: false, source: 'library' }
    ]
  },
  {
    key: 'noon',
    label: '午',
    tasks: [
      { id: 'noon-walk', label: '饭后慢走10分钟', done: false, source: 'library' },
      { id: 'noon-water', label: '补充温热饮水', done: false, source: 'library' }
    ]
  },
  {
    key: 'night',
    label: '晚',
    tasks: [
      { id: 'night-footbath', label: '泡脚舒缓10分钟', done: false, source: 'library' },
      { id: 'night-screen', label: '提前1小时放下屏幕', done: false, source: 'library' }
    ]
  }
]);

const weekPlan = ref<Task[]>([
  { id: 'week-exercise', label: '周内三次轻运动', done: false, source: 'library' },
  { id: 'week-sleep', label: '本周规律作息5天', done: false, source: 'library' },
  { id: 'week-meditation', label: '周末一次放松冥想', done: false, source: 'library' }
]);

const taskLibraryGroups: LibraryGroup[] = [
  {
    key: 'morning',
    label: '晨',
    tasks: [
      { id: 'morning-water', label: '温水醒脾', section: 'morning' },
      { id: 'morning-stretch', label: '舒展拉伸5分钟', section: 'morning' },
      { id: 'morning-breakfast', label: '早餐清淡少油', section: 'morning' },
      { id: 'morning-breath', label: '腹式呼吸3分钟', section: 'morning' }
    ]
  },
  {
    key: 'noon',
    label: '午',
    tasks: [
      { id: 'noon-walk', label: '饭后慢走10分钟', section: 'noon' },
      { id: 'noon-water', label: '补充温热饮水', section: 'noon' },
      { id: 'noon-posture', label: '久坐伸展2分钟', section: 'noon' }
    ]
  },
  {
    key: 'night',
    label: '晚',
    tasks: [
      { id: 'night-footbath', label: '泡脚舒缓10分钟', section: 'night' },
      { id: 'night-screen', label: '提前1小时放下屏幕', section: 'night' },
      { id: 'night-relax', label: '轻音乐放松5分钟', section: 'night' }
    ]
  },
  {
    key: 'week',
    label: '周计划',
    tasks: [
      { id: 'week-exercise', label: '周内三次轻运动', section: 'week' },
      { id: 'week-sleep', label: '本周规律作息5天', section: 'week' },
      { id: 'week-meditation', label: '周末一次放松冥想', section: 'week' },
      { id: 'week-meal', label: '周内两次清淡晚餐', section: 'week' }
    ]
  }
];

const selectedLibraryIds = ref<string[]>([
  ...dayPlanSections.value.flatMap((section) => section.tasks.map((task) => task.id)),
  ...weekPlan.value.map((task) => task.id)
]);

const smsReminderEnabled = ref(false);
const reminderPhone = ref('');
const reminderTime = ref('20:00');
const reminderStatus = ref('');

export function useHealthPlan() {
  const todayTotal = computed(() =>
    dayPlanSections.value.reduce((count, section) => count + section.tasks.length, 0)
  );

  const todayDone = computed(() =>
    dayPlanSections.value.reduce(
      (count, section) => count + section.tasks.filter((task) => task.done).length,
      0
    )
  );

  const weekTotal = computed(() => weekPlan.value.length);
  const weekDone = computed(() => weekPlan.value.filter((task) => task.done).length);
  const todayRemaining = computed(() => Math.max(todayTotal.value - todayDone.value, 0));

  function isLibraryTaskSelected(taskId: string) {
    return selectedLibraryIds.value.includes(taskId);
  }

  function addLibraryTask(task: { id: string; label: string; section: string }) {
    if (task.section === 'week') {
      if (weekPlan.value.some((item) => item.id === task.id)) return;
      weekPlan.value.push({ id: task.id, label: task.label, done: false, source: 'library' });
      return;
    }
    const section = dayPlanSections.value.find((item) => item.key === task.section);
    if (!section || section.tasks.some((item) => item.id === task.id)) return;
    section.tasks.push({ id: task.id, label: task.label, done: false, source: 'library' });
  }

  function removeLibraryTask(task: { id: string; label: string; section: string }) {
    if (task.section === 'week') {
      weekPlan.value = weekPlan.value.filter((item) => item.id !== task.id);
      return;
    }
    const section = dayPlanSections.value.find((item) => item.key === task.section);
    if (!section) return;
    section.tasks = section.tasks.filter((item) => item.id !== task.id);
  }

  function toggleLibraryTask(task: { id: string; label: string; section: string }) {
    if (isLibraryTaskSelected(task.id)) {
      selectedLibraryIds.value = selectedLibraryIds.value.filter((id) => id !== task.id);
      removeLibraryTask(task);
    } else {
      selectedLibraryIds.value = [...selectedLibraryIds.value, task.id];
      addLibraryTask(task);
    }
  }

  function addCustomTask(text: string, sectionKey: string) {
    const trimmedText = text.trim();
    if (!trimmedText) return;
    const id = `custom-${sectionKey}-${Date.now()}`;
    if (sectionKey === 'week') {
      weekPlan.value.push({ id, label: trimmedText, done: false, source: 'custom' });
    } else {
      const section = dayPlanSections.value.find((item) => item.key === sectionKey);
      if (!section) return;
      section.tasks.push({ id, label: trimmedText, done: false, source: 'custom' });
    }
  }

  function removeCustomTask(sectionKey: string, taskId: string) {
    const section = dayPlanSections.value.find((item) => item.key === sectionKey);
    if (!section) return;
    section.tasks = section.tasks.filter((task) => task.id !== taskId);
  }

  function removeCustomWeekTask(taskId: string) {
    weekPlan.value = weekPlan.value.filter((task) => task.id !== taskId);
  }

  async function sendReminderSms() {
    try {
      await fetch('http://localhost:8080/api/sms/send-reminder', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          phoneNumber: reminderPhone.value.trim(),
          taskName: '养生任务提醒',
          taskTime: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
        })
      });
    } catch (error) {
      console.error('发送短信失败:', error);
    }
  }

  function scheduleReminder() {
    const now = new Date();
    const timeStr = reminderTime.value || '20:00';
    const [hoursStr, minutesStr] = timeStr.split(':');
    const hours = parseInt(hoursStr || '20', 10);
    const minutes = parseInt(minutesStr || '0', 10);

    const reminderDate = new Date();
    reminderDate.setHours(hours, minutes, 0, 0);

    if (reminderDate <= now) {
      reminderDate.setDate(reminderDate.getDate() + 1);
    }

    const delay = reminderDate.getTime() - now.getTime();

    setTimeout(async () => {
      if (smsReminderEnabled.value) {
        await sendReminderSms();
        scheduleReminder();
      }
    }, delay);
  }

  async function saveReminder() {
    if (!smsReminderEnabled.value) {
      reminderStatus.value = '已关闭短信提醒';
      return;
    }
    if (!reminderPhone.value.trim()) {
      reminderStatus.value = '请填写手机号';
      return;
    }

    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(reminderPhone.value.trim())) {
      reminderStatus.value = '请输入正确的手机号';
      return;
    }

    try {
      reminderStatus.value = '正在设置提醒...';
      const response = await fetch('http://localhost:8080/api/sms/send-reminder', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          phoneNumber: reminderPhone.value.trim(),
          taskName: '养生任务提醒',
          taskTime: reminderTime.value || '20:00'
        })
      });

      const data = await response.json();

      if (response.ok) {
        reminderStatus.value = `✓ 已设置 ${reminderTime.value || '20:00'} 短信提醒`;
        scheduleReminder();
      } else {
        reminderStatus.value = `✗ ${data.error || '设置失败'}`;
      }
    } catch (error) {
      console.error('设置提醒失败:', error);
      reminderStatus.value = '✗ 网络错误，请检查后端服务';
    }
  }

  return {
    dayPlanSections,
    weekPlan,
    taskLibraryGroups,
    selectedLibraryIds,
    smsReminderEnabled,
    reminderPhone,
    reminderTime,
    reminderStatus,
    todayTotal,
    todayDone,
    weekTotal,
    weekDone,
    todayRemaining,
    isLibraryTaskSelected,
    toggleLibraryTask,
    addCustomTask,
    removeCustomTask,
    removeCustomWeekTask,
    saveReminder
  };
}
