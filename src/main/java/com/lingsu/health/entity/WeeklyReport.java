package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 周报实体
 */
@Data
@TableName("weekly_reports")
public class WeeklyReport {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("week_start")
    private LocalDate weekStart;

    @TableField("week_end")
    private LocalDate weekEnd;

    @TableField("avg_health_score")
    private BigDecimal avgHealthScore;

    @TableField("avg_sleep_hours")
    private BigDecimal avgSleepHours;

    @TableField("avg_sleep_score")
    private Integer avgSleepScore;

    @TableField("avg_mood_score")
    private Integer avgMoodScore;

    @TableField("avg_exercise_score")
    private Integer avgExerciseScore;

    @TableField("total_exercise_minutes")
    private Integer totalExerciseMinutes;

    @TableField("task_completion_rate")
    private BigDecimal taskCompletionRate;

    @TableField("checkin_days")
    private Integer checkinDays;

    @TableField("health_trend")
    private String healthTrend; // improving/declining/stable

    private String summary;

    @TableField("next_week_advice")
    private String nextWeekAdvice;

    private String highlights; // JSON

    private String improvements; // JSON

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    /**
     * 获取健康趋势描述
     */
    public String getTrendDescription() {
        if ("improving".equals(healthTrend)) {
            return "健康状况持续改善 📈";
        } else if ("declining".equals(healthTrend)) {
            return "健康状况有所下降 📉";
        } else {
            return "健康状况保持稳定 ➡️";
        }
    }

    /**
     * 获取周报标题
     */
    public String getReportTitle() {
        if (weekStart != null && weekEnd != null) {
            return String.format("周报 %s ~ %s",
                    weekStart.toString(), weekEnd.toString());
        }
        return "健康周报";
    }
}
