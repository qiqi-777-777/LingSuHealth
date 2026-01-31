package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 健康趋势数据实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("health_trends")
public class HealthTrend {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("trend_date")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate trendDate;
    
    @TableField("health_score")
    private Integer healthScore;
    
    @TableField("sleep_quality_score")
    private Integer sleepQualityScore;
    
    @TableField("mood_score")
    private Integer moodScore;
    
    @TableField("exercise_score")
    private Integer exerciseScore;
    
    @TableField("diet_score")
    private Integer dietScore;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}