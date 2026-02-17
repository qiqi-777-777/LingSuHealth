package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.entity.*;
import com.lingsu.health.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DailyTaskService {

    private final DailyTaskMapper dailyTaskMapper;
    private final HealthCheckinMapper healthCheckinMapper;
    private final HealthTrendMapper healthTrendMapper;
    private final AssessmentRecordMapper assessmentRecordMapper;
    private final UserMapper userMapper;
    private final PlanService planService;
    private final HealthPlanMapper healthPlanMapper;

    /**
     * 获取用户今日任务
     */
    public Map<String, Object> getTodayTasks(String username) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        LocalDate today = LocalDate.now();
        List<DailyTask> tasks = dailyTaskMapper.findByUserAndDate(user.getId(), today);

        // 如果今日没有任务，自动生成
        if (tasks.isEmpty()) {
            tasks = generateDailyTasks(user.getId());
        }

        // 计算完成进度
        long completed = tasks.stream().filter(t -> Boolean.TRUE.equals(t.getIsCompleted())).count();
        int progress = tasks.isEmpty() ? 0 : (int) (completed * 100 / tasks.size());

        return Map.of(
                "success", true,
                "tasks", tasks,
                "date", today.toString(),
                "totalCount", tasks.size(),
                "completedCount", completed,
                "progress", progress);
    }

    /**
     * 生成每日任务
     */
    private List<DailyTask> generateDailyTasks(Long userId) {
        List<DailyTask> tasks = new ArrayList<>();
        LocalDate today = LocalDate.now();

        // 1. 分析健康趋势
        Map<String, Object> trendAnalysis = analyzeHealthTrend(userId);
        String intensity = calculateIntensityLevel(trendAnalysis);

        // 2. 获取体质类型
        String constitution = getConstitution(userId);

        // 3. 基于体质和趋势生成任务
        tasks.addAll(generateConstitutionTasks(userId, today, constitution, intensity));
        tasks.addAll(generateTrendBasedTasks(userId, today, trendAnalysis, intensity));

        // 4. 保存任务到数据库
        for (DailyTask task : tasks) {
            dailyTaskMapper.insert(task);
        }

        return tasks;
    }

    /**
     * 分析健康趋势（最近7天）
     */
    private Map<String, Object> analyzeHealthTrend(Long userId) {
        LocalDate startDate = LocalDate.now().minusDays(7);

        List<HealthTrend> trends = healthTrendMapper.selectList(
                new QueryWrapper<HealthTrend>()
                        .eq("user_id", userId)
                        .ge("record_date", startDate)
                        .orderByAsc("record_date"));

        Map<String, Object> analysis = new HashMap<>();

        if (trends.size() < 2) {
            analysis.put("hasTrend", false);
            analysis.put("sleepTrend", "稳定");
            analysis.put("exerciseTrend", "稳定");
            analysis.put("overallTrend", "稳定");
            return analysis;
        }

        analysis.put("hasTrend", true);

        // 计算睡眠趋势
        double avgSleepFirst = trends.subList(0, trends.size() / 2).stream()
                .mapToInt(HealthTrend::getSleepQualityScore).average().orElse(50);
        double avgSleepLast = trends.subList(trends.size() / 2, trends.size()).stream()
                .mapToInt(HealthTrend::getSleepQualityScore).average().orElse(50);
        analysis.put("sleepTrend",
                avgSleepLast > avgSleepFirst + 5 ? "上升" : (avgSleepLast < avgSleepFirst - 5 ? "下降" : "稳定"));
        analysis.put("avgSleepScore", (avgSleepFirst + avgSleepLast) / 2);

        // 计算运动趋势
        double avgExerciseFirst = trends.subList(0, trends.size() / 2).stream()
                .mapToInt(HealthTrend::getExerciseScore).average().orElse(50);
        double avgExerciseLast = trends.subList(trends.size() / 2, trends.size()).stream()
                .mapToInt(HealthTrend::getExerciseScore).average().orElse(50);
        analysis.put("exerciseTrend",
                avgExerciseLast > avgExerciseFirst + 5 ? "上升" : (avgExerciseLast < avgExerciseFirst - 5 ? "下降" : "稳定"));
        analysis.put("avgExerciseScore", (avgExerciseFirst + avgExerciseLast) / 2);

        // 计算情绪趋势
        double avgMoodFirst = trends.subList(0, trends.size() / 2).stream()
                .mapToInt(HealthTrend::getMoodScore).average().orElse(50);
        double avgMoodLast = trends.subList(trends.size() / 2, trends.size()).stream()
                .mapToInt(HealthTrend::getMoodScore).average().orElse(50);
        analysis.put("moodTrend",
                avgMoodLast > avgMoodFirst + 5 ? "上升" : (avgMoodLast < avgMoodFirst - 5 ? "下降" : "稳定"));

        // 综合趋势
        double overallAvg = (avgSleepLast + avgExerciseLast + avgMoodLast) / 3;
        analysis.put("overallScore", overallAvg);
        analysis.put("overallTrend", overallAvg >= 70 ? "良好" : (overallAvg >= 50 ? "一般" : "需关注"));

        return analysis;
    }

    /**
     * 根据趋势计算强度级别
     */
    private String calculateIntensityLevel(Map<String, Object> trendAnalysis) {
        if (!(boolean) trendAnalysis.getOrDefault("hasTrend", false)) {
            return "适度";
        }

        double overallScore = (double) trendAnalysis.getOrDefault("overallScore", 50.0);
        String overallTrend = (String) trendAnalysis.getOrDefault("overallTrend", "一般");

        if ("良好".equals(overallTrend) && overallScore >= 75) {
            return "强化"; // 状态好，可以加强
        } else if ("需关注".equals(overallTrend) || overallScore < 40) {
            return "轻度"; // 状态差，减轻强度
        } else {
            return "适度";
        }
    }

    /**
     * 获取用户体质
     */
    private String getConstitution(Long userId) {
        AssessmentRecord record = assessmentRecordMapper.selectOne(
                new QueryWrapper<AssessmentRecord>()
                        .eq("user_id", userId)
                        .orderByDesc("created_at")
                        .last("LIMIT 1"));

        if (record == null) {
            return "平和质";
        }

        // 使用PlanService的方法解析体质（通过反射或公开方法）
        // 这里简化处理，返回默认值
        return "平和质";
    }

    /**
     * 基于体质生成任务
     */
    private List<DailyTask> generateConstitutionTasks(Long userId, LocalDate date, String constitution,
            String intensity) {
        List<DailyTask> tasks = new ArrayList<>();

        // 通用任务模板
        Map<String, List<Map<String, Object>>> constitutionTasks = new HashMap<>();

        // 平和质
        constitutionTasks.put("平和质", List.of(
                Map.of("category", "饮食", "title", "均衡饮食", "description", "三餐规律，多食蔬果", "target", 3),
                Map.of("category", "运动", "title", "有氧运动", "description", "慢跑或快走", "target", 30),
                Map.of("category", "作息", "title", "规律作息", "description", "23:00前入睡", "target", 1)));

        // 气虚质
        constitutionTasks.put("气虚质", List.of(
                Map.of("category", "饮食", "title", "补气饮食", "description", "食用黄芪、山药、红枣等补气食物", "target", 2),
                Map.of("category", "运动", "title", "轻柔运动", "description", "八段锦或太极拳", "target", 20),
                Map.of("category", "作息", "title", "充足睡眠", "description", "保证8小时睡眠，午休30分钟", "target", 1),
                Map.of("category", "茶饮", "title", "黄芪红枣茶", "description", "每日一杯，补气养血", "target", 1)));

        // 阳虚质
        constitutionTasks.put("阳虚质", List.of(
                Map.of("category", "饮食", "title", "温阳饮食", "description", "食用羊肉、生姜、韭菜等温热食物", "target", 2),
                Map.of("category", "运动", "title", "温和运动", "description", "阳光下慢跑或快走", "target", 30),
                Map.of("category", "作息", "title", "保暖泡脚", "description", "睡前温水泡脚15-20分钟", "target", 1)));

        // 阴虚质
        constitutionTasks.put("阴虚质", List.of(
                Map.of("category", "饮食", "title", "滋阴饮食", "description", "食用银耳、百合、梨等滋阴食物", "target", 2),
                Map.of("category", "运动", "title", "静态运动", "description", "瑜伽或太极拳", "target", 25),
                Map.of("category", "作息", "title", "早睡养阴", "description", "22:00前入睡", "target", 1),
                Map.of("category", "茶饮", "title", "枸杞菊花茶", "description", "每日一杯，滋阴明目", "target", 1)));

        List<Map<String, Object>> taskTemplates = constitutionTasks.getOrDefault(constitution,
                constitutionTasks.get("平和质"));

        int priority = taskTemplates.size();
        for (Map<String, Object> template : taskTemplates) {
            DailyTask task = new DailyTask();
            task.setUserId(userId);
            task.setTaskDate(date);
            task.setCategory((String) template.get("category"));
            task.setTitle((String) template.get("title"));
            task.setDescription((String) template.get("description"));
            task.setTargetValue((Integer) template.get("target"));
            task.setIntensity(intensity);
            task.setFrequency("每日");
            task.setSource("体质");
            task.setPriority(priority--);
            task.setIsCompleted(false);
            task.setActualValue(0);
            tasks.add(task);
        }

        return tasks;
    }

    /**
     * 基于趋势生成调整任务
     */
    private List<DailyTask> generateTrendBasedTasks(Long userId, LocalDate date,
            Map<String, Object> trendAnalysis, String intensity) {
        List<DailyTask> tasks = new ArrayList<>();

        if (!(boolean) trendAnalysis.getOrDefault("hasTrend", false)) {
            return tasks;
        }

        // 睡眠趋势下降 -> 添加改善睡眠任务
        if ("下降".equals(trendAnalysis.get("sleepTrend"))) {
            DailyTask task = new DailyTask();
            task.setUserId(userId);
            task.setTaskDate(date);
            task.setCategory("作息");
            task.setTitle("改善睡眠");
            task.setDescription("睡前1小时放下手机，用热水泡脚，做深呼吸放松");
            task.setTargetValue(1);
            task.setIntensity(intensity);
            task.setFrequency("每日");
            task.setSource("趋势");
            task.setPriority(10);
            task.setIsCompleted(false);
            tasks.add(task);
        }

        // 运动趋势下降 -> 添加轻量运动任务
        if ("下降".equals(trendAnalysis.get("exerciseTrend"))) {
            DailyTask task = new DailyTask();
            task.setUserId(userId);
            task.setTaskDate(date);
            task.setCategory("运动");
            task.setTitle("恢复性运动");
            task.setDescription("进行15分钟轻度拉伸或散步，逐步恢复运动习惯");
            task.setTargetValue(15);
            task.setIntensity("轻度");
            task.setFrequency("每日");
            task.setSource("趋势");
            task.setPriority(9);
            task.setIsCompleted(false);
            tasks.add(task);
        }

        // 情绪趋势下降 -> 添加情绪管理任务
        if ("下降".equals(trendAnalysis.get("moodTrend"))) {
            DailyTask task = new DailyTask();
            task.setUserId(userId);
            task.setTaskDate(date);
            task.setCategory("情绪");
            task.setTitle("情绪调节");
            task.setDescription("进行5分钟冥想或深呼吸，听轻音乐放松心情");
            task.setTargetValue(1);
            task.setIntensity(intensity);
            task.setFrequency("每日");
            task.setSource("趋势");
            task.setPriority(8);
            task.setIsCompleted(false);
            tasks.add(task);
        }

        return tasks;
    }

    /**
     * 完成任务
     */
    public Map<String, Object> completeTask(String username, Long taskId) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        int updated = dailyTaskMapper.markComplete(taskId, user.getId());
        return Map.of("success", updated > 0, "message", updated > 0 ? "任务已完成" : "任务不存在");
    }

    /**
     * 取消完成任务
     */
    public Map<String, Object> uncompleteTask(String username, Long taskId) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        int updated = dailyTaskMapper.markIncomplete(taskId, user.getId());
        return Map.of("success", updated > 0, "message", updated > 0 ? "已取消完成" : "任务不存在");
    }

    /**
     * 获取周进度统计
     */
    public Map<String, Object> getWeeklyProgress(String username) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(6);

        int totalTasks = dailyTaskMapper.countTotalInRange(user.getId(), weekStart, today);
        int completedTasks = dailyTaskMapper.countCompletedInRange(user.getId(), weekStart, today);

        int progressPercent = totalTasks > 0 ? (completedTasks * 100 / totalTasks) : 0;

        // 获取每日详情
        List<DailyTask> weekTasks = dailyTaskMapper.findRecentTasks(user.getId(), weekStart);
        Map<String, Map<String, Object>> dailyStats = new LinkedHashMap<>();

        for (int i = 0; i <= 6; i++) {
            LocalDate date = weekStart.plusDays(i);
            String dateStr = date.toString();
            long dayTotal = weekTasks.stream().filter(t -> t.getTaskDate().equals(date)).count();
            long dayCompleted = weekTasks.stream()
                    .filter(t -> t.getTaskDate().equals(date) && Boolean.TRUE.equals(t.getIsCompleted()))
                    .count();
            dailyStats.put(dateStr, Map.of(
                    "total", dayTotal,
                    "completed", dayCompleted,
                    "progress", dayTotal > 0 ? (int) (dayCompleted * 100 / dayTotal) : 0));
        }

        return Map.of(
                "success", true,
                "totalTasks", totalTasks,
                "completedTasks", completedTasks,
                "progressPercent", progressPercent,
                "dailyStats", dailyStats);
    }

    // =============================================
    // 7天计划相关方法
    // =============================================

    /**
     * 生成7天养生计划
     */
    @Transactional
    public Map<String, Object> generate7DayPlan(String username) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        LocalDate today = LocalDate.now();

        // 检查是否已有活跃计划
        HealthPlan existingPlan = healthPlanMapper.findActivePlan(user.getId(), today);
        if (existingPlan != null) {
            return Map.of(
                    "success", false,
                    "message", "当前已有进行中的计划",
                    "plan", existingPlan);
        }

        // 获取体质类型
        String constitution = getConstitution(user.getId());

        // 创建新计划
        HealthPlan plan = new HealthPlan();
        plan.setUserId(user.getId());
        plan.setPlanName("7天养生计划");
        plan.setStartDate(today);
        plan.setEndDate(today.plusDays(6));
        plan.setConstitution(constitution);
        plan.setStatus("active");
        plan.setTotalTasks(0);
        plan.setCompletedTasks(0);
        healthPlanMapper.insert(plan);

        // 生成7天的任务
        List<DailyTask> allTasks = new ArrayList<>();
        Map<String, Object> trendAnalysis = analyzeHealthTrend(user.getId());

        for (int day = 0; day < 7; day++) {
            LocalDate taskDate = today.plusDays(day);
            String intensity = calculateDayIntensity(day, trendAnalysis);

            List<DailyTask> dayTasks = generateDayTasks(user.getId(), plan.getId(), taskDate, constitution, intensity,
                    day);
            allTasks.addAll(dayTasks);
        }

        // 更新计划的任务总数
        plan.setTotalTasks(allTasks.size());
        healthPlanMapper.updateById(plan);

        // 组织返回数据
        Map<LocalDate, List<DailyTask>> tasksByDate = new LinkedHashMap<>();
        for (DailyTask task : allTasks) {
            tasksByDate.computeIfAbsent(task.getTaskDate(), k -> new ArrayList<>()).add(task);
        }

        return Map.of(
                "success", true,
                "message", "7天计划生成成功",
                "plan", plan,
                "constitution", constitution,
                "tasksByDate", tasksByDate,
                "totalTasks", allTasks.size());
    }

    /**
     * 获取当前7天计划
     */
    public Map<String, Object> get7DayPlan(String username) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        LocalDate today = LocalDate.now();

        // 先标记过期计划
        healthPlanMapper.markExpiredPlansCompleted(today);

        // 获取活跃计划
        HealthPlan plan = healthPlanMapper.findActivePlan(user.getId(), today);
        if (plan == null) {
            // 没有活跃计划，检查是否有最近的计划
            HealthPlan latestPlan = healthPlanMapper.findLatestPlan(user.getId());
            return Map.of(
                    "success", true,
                    "hasPlan", false,
                    "message", "暂无进行中的计划",
                    "lastPlan", latestPlan != null ? latestPlan : Map.of());
        }

        // 更新完成任务数
        healthPlanMapper.updateCompletedTasks(plan.getId());
        plan = healthPlanMapper.selectById(plan.getId()); // 重新获取更新后的数据

        // 获取计划内的所有任务
        List<DailyTask> tasks = dailyTaskMapper.selectList(
                new QueryWrapper<DailyTask>()
                        .eq("plan_id", plan.getId())
                        .orderByAsc("task_date")
                        .orderByDesc("priority"));

        // 按日期分组
        Map<String, List<DailyTask>> tasksByDate = new LinkedHashMap<>();
        for (DailyTask task : tasks) {
            String dateKey = task.getTaskDate().toString();
            tasksByDate.computeIfAbsent(dateKey, k -> new ArrayList<>()).add(task);
        }

        // 计算每日完成情况
        Map<String, Map<String, Object>> dailyProgress = new LinkedHashMap<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = plan.getStartDate().plusDays(i);
            String dateKey = date.toString();
            List<DailyTask> dayTasks = tasksByDate.getOrDefault(dateKey, List.of());
            long completed = dayTasks.stream().filter(t -> Boolean.TRUE.equals(t.getIsCompleted())).count();

            dailyProgress.put(dateKey, Map.of(
                    "date", dateKey,
                    "dayOfWeek", date.getDayOfWeek().getValue(),
                    "total", dayTasks.size(),
                    "completed", completed,
                    "progress", dayTasks.isEmpty() ? 0 : (int) (completed * 100 / dayTasks.size()),
                    "isToday", date.equals(today),
                    "isPast", date.isBefore(today)));
        }

        return Map.of(
                "success", true,
                "hasPlan", true,
                "plan", plan,
                "tasksByDate", tasksByDate,
                "dailyProgress", dailyProgress,
                "progressPercent", plan.getProgressPercent());
    }

    /**
     * 更新任务进度
     */
    public Map<String, Object> updateTaskProgress(String username, Long taskId, Integer progress) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        DailyTask task = dailyTaskMapper.selectById(taskId);
        if (task == null || !task.getUserId().equals(user.getId())) {
            return Map.of("success", false, "message", "任务不存在");
        }

        // 更新进度
        task.setActualValue(progress);
        if (task.getTargetValue() != null && progress >= task.getTargetValue()) {
            task.setIsCompleted(true);
        }
        dailyTaskMapper.updateById(task);

        // 如果有关联计划，更新计划完成数
        if (task.getPlanId() != null) {
            healthPlanMapper.updateCompletedTasks(task.getPlanId());
        }

        return Map.of(
                "success", true,
                "message", "进度已更新",
                "task", task);
    }

    /**
     * 获取计划历史
     */
    public Map<String, Object> getPlanHistory(String username, int limit) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        List<HealthPlan> plans = healthPlanMapper.findPlanHistory(user.getId(), limit);
        return Map.of(
                "success", true,
                "plans", plans);
    }

    // =============================================
    // 辅助方法
    // =============================================

    /**
     * 根据天数计算强度
     */
    private String calculateDayIntensity(int dayIndex, Map<String, Object> trendAnalysis) {
        // 第1-2天：适应期，轻度
        if (dayIndex < 2) {
            return "轻度";
        }
        // 第3-5天：提升期
        else if (dayIndex < 5) {
            String baseLine = calculateIntensityLevel(trendAnalysis);
            return "轻度".equals(baseLine) ? "适度" : baseLine;
        }
        // 第6-7天：巩固期
        else {
            return calculateIntensityLevel(trendAnalysis);
        }
    }

    /**
     * 生成单日任务
     */
    private List<DailyTask> generateDayTasks(Long userId, Long planId, LocalDate date,
            String constitution, String intensity, int dayIndex) {
        List<DailyTask> tasks = new ArrayList<>();

        // 基础任务（体质相关）
        List<DailyTask> constitutionTasks = generateConstitutionTasks(userId, date, constitution, intensity);
        for (DailyTask task : constitutionTasks) {
            task.setPlanId(planId);
            dailyTaskMapper.insert(task);
            tasks.add(task);
        }

        // 根据天数添加特色任务
        if (dayIndex == 0) {
            // 第1天：添加入门任务
            DailyTask welcomeTask = new DailyTask();
            welcomeTask.setUserId(userId);
            welcomeTask.setPlanId(planId);
            welcomeTask.setTaskDate(date);
            welcomeTask.setCategory("学习");
            welcomeTask.setTitle("了解您的体质");
            welcomeTask.setDescription("阅读" + constitution + "的养生要点，了解适合自己的调理方向");
            welcomeTask.setTargetValue(1);
            welcomeTask.setIntensity("轻度");
            welcomeTask.setFrequency("每日");
            welcomeTask.setSource("计划");
            welcomeTask.setPriority(10);
            welcomeTask.setIsCompleted(false);
            welcomeTask.setActualValue(0);
            dailyTaskMapper.insert(welcomeTask);
            tasks.add(welcomeTask);
        } else if (dayIndex == 6) {
            // 第7天：添加总结任务
            DailyTask summaryTask = new DailyTask();
            summaryTask.setUserId(userId);
            summaryTask.setPlanId(planId);
            summaryTask.setTaskDate(date);
            summaryTask.setCategory("总结");
            summaryTask.setTitle("本周养生回顾");
            summaryTask.setDescription("回顾本周执行情况，记录身体变化，为下周计划做准备");
            summaryTask.setTargetValue(1);
            summaryTask.setIntensity("轻度");
            summaryTask.setFrequency("每周");
            summaryTask.setSource("计划");
            summaryTask.setPriority(10);
            summaryTask.setIsCompleted(false);
            summaryTask.setActualValue(0);
            dailyTaskMapper.insert(summaryTask);
            tasks.add(summaryTask);
        }

        return tasks;
    }
}
