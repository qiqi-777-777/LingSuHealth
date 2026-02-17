package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("knowledge_tags")
public class KnowledgeTag {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String name; // 标签名称
    private String dimension; // 所属维度 (population/symptom/season/goal)
    private String description; // 标签描述
    private Long parentId; // 父标签ID
    private Integer priority; // 排序权重
    private Boolean isEnabled; // 是否启用
    private Boolean isSensitive; // 是否敏感
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
