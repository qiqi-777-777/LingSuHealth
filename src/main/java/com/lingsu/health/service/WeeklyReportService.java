package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lingsu.health.entity.*;
import com.lingsu.health.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.*;

/**
 * 周报服务 - 健康管理闭环 Step 5
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WeeklyReportService {

    private final WeeklyReportMapper weeklyReportMapper;
    private final HealthCheckinMapper healthCheckinMapper;
    private final HealthTrendMapper healthTrendMapper;
    private final DailyTaskMapper dailyTaskMapper;
    private final UserMapper userMapper;
    private final DeepSeekService deepSeekService;
    private final ObjectMapper objectMapper;

    /**
     * 生成周报
     */
    public Map<String, Object> generateWeeklyReport(String username) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        LocalDate today = LocalDate.now();
        // 计算上周的起止日期（周一到周日）
        LocalDate weekEnd = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
        LocalDate weekStart = weekEnd.minusDays(6);

        // 如果今天是周日或周一，允许生成上一周的周报
        if (today.getDayOfWeek() == DayOfWeek.MONDAY || today.getDayOfWeek() == DayOfWeek.SUNDAY) {
            // 使用上周的日期范围
        } else {
            // 其他日期，使用本周的数据
            weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            weekEnd = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
        }

        // 检查是否已存在该周的周报
        WeeklyReport existingReport = weeklyReportMapper.findByWeek(user.getId(), weekStart);
        if (existingReport != null) {
            return Map.of(
                    "success", true,
                    "message", "本周周报已存在",
                    "report", existingReport);
        }

        // 获取该周的打卡数据
        List<HealthCheckin> checkins = healthCheckinMapper.selectList(
                new QueryWrapper<HealthCheckin>()
                        .eq("user_id", user.getId())
                        .ge("checkin_date", weekStart)
                        .le("checkin_date", weekEnd)
                        .orderByAsc("checkin_date"));

        if (checkins.isEmpty()) {
            return Map.of(
                    "success", false,
                    "message", "本周暂无打卡记录，无法生成周报");
        }

        // 获取该周的趋势数据
        List<HealthTrend> trends = healthTrendMapper.selectList(
                new QueryWrapper<HealthTrend>()
                        .eq("user_id", user.getId())
                        .ge("record_date", weekStart)
                        .le("record_date", weekEnd));

        // 获取该周的任务完成情况
        int totalTasks = dailyTaskMapper.countTotalInRange(user.getId(), weekStart, weekEnd);
        int completedTasks = dailyTaskMapper.countCompletedInRange(user.getId(), weekStart, weekEnd);

        // 计算统计数据
        WeeklyReport report = new WeeklyReport();
        report.setUserId(user.getId());
        report.setWeekStart(weekStart);
        report.setWeekEnd(weekEnd);
        report.setCheckinDays(checkins.size());

        // 平均健康分
        double avgHealthScore = checkins.stream()
                .filter(c -> c.getHealthScore() != null)
                .mapToInt(HealthCheckin::getHealthScore)
                .average()
                .orElse(0.0);
        report.setAvgHealthScore(BigDecimal.valueOf(avgHealthScore).setScale(2, RoundingMode.HALF_UP));

        // 平均睡眠时长
        double avgSleepHours = checkins.stream()
                .filter(c -> c.getSleepHours() != null)
                .mapToDouble(c -> c.getSleepHours().doubleValue())
                .average()
                .orElse(0.0);
        report.setAvgSleepHours(BigDecimal.valueOf(avgSleepHours).setScale(2, RoundingMode.HALF_UP));

        // 从趋势数据计算评分
        if (!trends.isEmpty()) {
            double avgSleepScore = trends.stream()
                    .mapToInt(HealthTrend::getSleepQualityScore)
                    .average()
                    .orElse(50);
            report.setAvgSleepScore((int) avgSleepScore);

            double avgMoodScore = trends.stream()
                    .mapToInt(HealthTrend::getMoodScore)
                    .average()
                    .orElse(50);
            report.setAvgMoodScore((int) avgMoodScore);

            double avgExerciseScore = trends.stream()
                    .mapToInt(HealthTrend::getExerciseScore)
                    .average()
                    .orElse(50);
            report.setAvgExerciseScore((int) avgExerciseScore);
        }

        // 总运动时长
        int totalExercise = checkins.stream()
                .filter(c -> c.getExerciseMinutes() != null)
                .mapToInt(HealthCheckin::getExerciseMinutes)
                .sum();
        report.setTotalExerciseMinutes(totalExercise);

        // 任务完成率
        double completionRate = totalTasks > 0 ? (double) completedTasks * 100 / totalTasks : 0;
        report.setTaskCompletionRate(BigDecimal.valueOf(completionRate).setScale(2, RoundingMode.HALF_UP));

        // 计算健康趋势
        String healthTrend = calculateHealthTrend(checkins);
        report.setHealthTrend(healthTrend);

        // 生成亮点和改进项
        Map<String, List<String>> highlights = generateHighlights(checkins, completionRate, avgSleepHours,
                totalExercise);
        Map<String, List<String>> improvements = generateImprovements(checkins, completionRate, avgSleepHours,
                totalExercise);

        try {
            report.setHighlights(objectMapper.writeValueAsString(highlights));
            report.setImprovements(objectMapper.writeValueAsString(improvements));
        } catch (Exception e) {
            log.warn("序列化亮点/改进项失败", e);
        }

        // 生成AI总结和建议
        try {
            String aiSummary = generateAISummary(report, checkins);
            report.setSummary(aiSummary);

            String aiAdvice = generateNextWeekAdvice(report, improvements);
            report.setNextWeekAdvice(aiAdvice);
        } catch (Exception e) {
            log.warn("生成AI周报内容失败", e);
            report.setSummary("本周健康状况总体良好，请继续保持健康的生活习惯。");
            report.setNextWeekAdvice("建议继续坚持打卡，保持规律作息和适量运动。");
        }

        // 保存周报
        weeklyReportMapper.insert(report);

        return Map.of(
                "success", true,
                "message", "周报生成成功",
                "report", report);
    }

    /**
     * 获取最新周报
     */
    public Map<String, Object> getLatestReport(String username) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        WeeklyReport report = weeklyReportMapper.findLatestReport(user.getId());
        if (report == null) {
            return Map.of(
                    "success", true,
                    "hasReport", false,
                    "message", "暂无周报记录");
        }

        return Map.of(
                "success", true,
                "hasReport", true,
                "report", report);
    }

    /**
     * 获取周报历史列表
     */
    public Map<String, Object> getReportHistory(String username, int limit) {
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of("success", false, "message", "用户不存在");
        }

        List<WeeklyReport> reports = weeklyReportMapper.findReportHistory(user.getId(), limit);
        return Map.of(
                "success", true,
                "reports", reports);
    }

    // =============================================
    // 辅助方法
    // =============================================

    /**
     * 计算健康趋势
     */
    private String calculateHealthTrend(List<HealthCheckin> checkins) {
        if (checkins.size() < 2) {
            return "stable";
        }

        List<Integer> scores = checkins.stream()
                .filter(c -> c.getHealthScore() != null)
                .map(HealthCheckin::getHealthScore)
                .toList();

        if (scores.size() < 2) {
            return "stable";
        }

        // 比较前半周和后半周的平均分
        int mid = scores.size() / 2;
        double firstHalf = scores.subList(0, mid).stream().mapToInt(i -> i).average().orElse(50);
        double secondHalf = scores.subList(mid, scores.size()).stream().mapToInt(i -> i).average().orElse(50);

        if (secondHalf > firstHalf + 5) {
            return "improving";
        } else if (secondHalf < firstHalf - 5) {
            return "declining";
        } else {
            return "stable";
        }
    }

    /**
     * 生成亮点
     */
    private Map<String, List<String>> generateHighlights(List<HealthCheckin> checkins,
            double completionRate,
            double avgSleepHours,
            int totalExercise) {
        List<String> items = new ArrayList<>();

        if (checkins.size() >= 5) {
            items.add("本周坚持打卡 " + checkins.size() + " 天，执行力强！");
        }

        if (completionRate >= 80) {
            items.add("任务完成率达到 " + String.format("%.0f", completionRate) + "%，表现优秀！");
        }

        if (avgSleepHours >= 7.5) {
            items.add("平均睡眠 " + String.format("%.1f", avgSleepHours) + " 小时，睡眠充足！");
        }

        if (totalExercise >= 150) {
            items.add("本周运动 " + totalExercise + " 分钟，达到健康标准！");
        }

        // 检查情绪状态
        long goodMoodDays = checkins.stream()
                .filter(c -> c.getMood() != null && c.getMood() >= 3)
                .count();
        if (goodMoodDays >= 4) {
            items.add("本周心情良好的天数达 " + goodMoodDays + " 天！");
        }

        return Map.of("items", items);
    }

    /**
     * 生成改进项
     */
    private Map<String, List<String>> generateImprovements(List<HealthCheckin> checkins,
            double completionRate,
            double avgSleepHours,
            int totalExercise) {
        List<String> items = new ArrayList<>();

        if (checkins.size() < 4) {
            items.add("本周打卡天数较少，建议养成每日打卡习惯");
        }

        if (completionRate < 60) {
            items.add("任务完成率可以提升，建议从简单任务开始");
        }

        if (avgSleepHours < 7) {
            items.add("睡眠时长偏少，建议早睡保证7-8小时睡眠");
        }

        if (totalExercise < 90) {
            items.add("运动量偏少，建议增加每日运动时间");
        }

        // 检查情绪状态
        long lowMoodDays = checkins.stream()
                .filter(c -> c.getMood() != null && c.getMood() <= 1)
                .count();
        if (lowMoodDays >= 3) {
            items.add("本周情绪较低落天数较多，建议关注心理健康");
        }

        return Map.of("items", items);
    }

    /**
     * 生成AI周总结
     */
    private String generateAISummary(WeeklyReport report, List<HealthCheckin> checkins) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("请根据以下健康数据生成一段简短的周报总结（100字以内）：\n");
        prompt.append("- 打卡天数：").append(report.getCheckinDays()).append("天\n");
        prompt.append("- 平均健康分：").append(report.getAvgHealthScore()).append("\n");
        prompt.append("- 平均睡眠：").append(report.getAvgSleepHours()).append("小时\n");
        prompt.append("- 总运动时长：").append(report.getTotalExerciseMinutes()).append("分钟\n");
        prompt.append("- 任务完成率：").append(report.getTaskCompletionRate()).append("%\n");
        prompt.append("- 健康趋势：").append(report.getHealthTrend()).append("\n");

        try {
            // askQuestion 返回 String
            String response = deepSeekService.askQuestion(prompt.toString());
            if (response != null && !response.isEmpty()) {
                return response.trim();
            }
        } catch (Exception e) {
            log.warn("AI生成周报总结失败", e);
        }

        // 默认响应
        if ("improving".equals(report.getHealthTrend())) {
            return "本周健康状况持续改善，各项指标稳步提升。继续保持良好的生活习惯！";
        } else if ("declining".equals(report.getHealthTrend())) {
            return "本周健康状况有所下滑，建议关注睡眠和运动。适当调整生活节奏，保持积极心态。";
        } else {
            return "本周健康状况保持稳定。继续坚持健康的生活方式，循序渐进地改善各项指标。";
        }
    }

    /**
     * 生成下周建议
     */
    private String generateNextWeekAdvice(WeeklyReport report, Map<String, List<String>> improvements) {
        List<String> improvementItems = improvements.getOrDefault("items", List.of());

        if (improvementItems.isEmpty()) {
            return "继续保持当前的健康习惯，可以尝试增加一些新的养生项目。";
        }

        StringBuilder advice = new StringBuilder("下周建议重点关注：\n");
        for (int i = 0; i < Math.min(3, improvementItems.size()); i++) {
            advice.append(i + 1).append(". ").append(improvementItems.get(i)).append("\n");
        }

        return advice.toString().trim();
    }
}
