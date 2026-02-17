package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("user_daily_tasks")
public class DailyTask {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("plan_id")
    private Long planId; // 所属计划ID

    @TableField("task_date")
    private LocalDate taskDate;

    private String category; // 饮食/运动/作息/情绪
    private String title;
    private String description;
    private String frequency; // 每日/隔日/每周
    private String intensity; // 轻度/中度/适度/强化

    @TableField("target_value")
    private Integer targetValue;

    @TableField("actual_value")
    private Integer actualValue;

    @TableField("is_completed")
    private Boolean isCompleted;

    private Integer priority;
    private String source; // AI/体质/趋势

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
