package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 健康计划实体（7天养生计划）
 */
@Data
@TableName("health_plans")
public class HealthPlan {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("plan_name")
    private String planName;

    @TableField("start_date")
    private LocalDate startDate;

    @TableField("end_date")
    private LocalDate endDate;

    private String constitution;

    private String status; // active/completed/cancelled

    @TableField("total_tasks")
    private Integer totalTasks;

    @TableField("completed_tasks")
    private Integer completedTasks;

    @TableField("ai_summary")
    private String aiSummary;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;

    /**
     * 计算完成进度百分比
     */
    public int getProgressPercent() {
        if (totalTasks == null || totalTasks == 0) {
            return 0;
        }
        return (completedTasks != null ? completedTasks : 0) * 100 / totalTasks;
    }

    /**
     * 判断计划是否已过期
     */
    public boolean isExpired() {
        return endDate != null && LocalDate.now().isAfter(endDate);
    }

    /**
     * 判断是否是今天的任务日
     */
    public boolean isActiveToday() {
        LocalDate today = LocalDate.now();
        return startDate != null && endDate != null &&
                !today.isBefore(startDate) && !today.isAfter(endDate);
    }
}
