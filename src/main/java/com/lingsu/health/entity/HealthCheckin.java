package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 健康打卡记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("health_checkins")
public class HealthCheckin {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("checkin_date")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate checkinDate;
    
    @TableField("sleep_hours")
    private BigDecimal sleepHours;
    
    @TableField("sleep_time")
    @JsonFormat(pattern = "HH:mm")
    private LocalTime sleepTime;
    
    @TableField("symptoms")
    private String symptoms; // JSON字符串
    
    @TableField("mood")
    private Integer mood;
    
    @TableField("exercise_minutes")
    private Integer exerciseMinutes;
    
    @TableField("diet_notes")
    private String dietNotes;
    
    @TableField("followed_plan")
    private Boolean followedPlan;
    
    @TableField("health_score")
    private Integer healthScore;

    @TableField("analysis_summary")
    private String analysisSummary;

    @TableField("analysis_suggestions")
    private String analysisSuggestions; // JSON字符串

    @TableField("analysis_risks")
    private String analysisRisks; // JSON字符串

    @TableField("analysis_tomorrow_plan")
    private String analysisTomorrowPlan;

    @TableField("analysis_tomorrow_tasks")
    private String analysisTomorrowTasks; // JSON字符串
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}