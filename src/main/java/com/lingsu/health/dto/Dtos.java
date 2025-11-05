package com.lingsu.health.dto;

import java.util.List;
import java.util.Map;

public class Dtos {
    public static class AssessmentReport {
        public String constitution; // 体质类型
        public String summary;      // 中西结合简述
    }

    public static class PlanItem {
        public String category;     // 分类（饮食建议/运动方案等）
        public String title;        // 计划项名称
        public String detail;       // 详细说明
    }

    public static class CheckinSummary {
        public int totalCheckins;   // 总打卡次数
        public int consecutiveDays; // 连续打卡天数
        public int weeklyGoal;      // 周目标
        public int completionRate;  // 完成率
        public String trend;        // 趋势描述
        public List<Map<String, String>> history; // 历史记录
        
        // Getter和Setter方法
        public int getTotalCheckins() { return totalCheckins; }
        public void setTotalCheckins(int totalCheckins) { this.totalCheckins = totalCheckins; }
        
        public int getConsecutiveDays() { return consecutiveDays; }
        public void setConsecutiveDays(int consecutiveDays) { this.consecutiveDays = consecutiveDays; }
        
        public int getWeeklyGoal() { return weeklyGoal; }
        public void setWeeklyGoal(int weeklyGoal) { this.weeklyGoal = weeklyGoal; }
        
        public int getCompletionRate() { return completionRate; }
        public void setCompletionRate(int completionRate) { this.completionRate = completionRate; }
        
        public String getTrend() { return trend; }
        public void setTrend(String trend) { this.trend = trend; }
        
        public List<Map<String, String>> getHistory() { return history; }
        public void setHistory(List<Map<String, String>> history) { this.history = history; }
    }

    public static class KnowledgeItem {
        public String name;         // 食材/药材名称
        public String tcmEffect;    // 中医功效
        public String westernNutrition; // 现代营养
        public String suitable;     // 适合体质
        public String taboo;        // 禁忌
    }

    public static class QAResponse {
        public String answer;
        public List<String> sources; // 参考条目/知识库来源
    }

    public static class SeasonTip {
        public String season;       // 节气/季节
        public String suggestion;   // 养生建议
        public String detailSuggestion;
        public String principle;
        public String recommendedFoods;
        public String taboos;
    }

    public static class DashboardMetrics {
        public double sleepQuality;
        public double activityScore;
        public double constitutionStability;
    }
}