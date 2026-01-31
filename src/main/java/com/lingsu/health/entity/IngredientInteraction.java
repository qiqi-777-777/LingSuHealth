package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ingredient_interactions")
public class IngredientInteraction {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long item1Id;              // 第一个食材/药材ID
    private String item1Name;          // 第一个食材/药材名称
    private Long item2Id;              // 第二个食材/药材ID
    private String item2Name;          // 第二个食材/药材名称
    private String relationshipType;   // 关系类型（相生/相克）
    private String effectDescription;  // 效果描述
    private String severityLevel;      // 严重程度（轻度/中度/重度/有益）
    private String scientificBasis;    // 科学依据或中医理论依据
    private String recommendation;     // 建议（如何搭配或避免）
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
