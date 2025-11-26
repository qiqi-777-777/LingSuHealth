package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("knowledge_items")
public class KnowledgeItem {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String name;          // 食材/药材名称
    private String category;      // 分类（食材/药材/茶饮等）
    private String imageUrl;      // 图片路径
    private String tcmEffect;     // 中医功效
    private String westernNutrition; // 现代营养成分
    private String suitable;      // 适合体质
    private String taboo;         // 禁忌
    private String usageMethod;   // 使用方法
    private String season;        // 适宜季节
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

