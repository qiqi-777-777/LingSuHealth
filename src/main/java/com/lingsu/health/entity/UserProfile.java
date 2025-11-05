package com.lingsu.health.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 用户资料实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("user_profiles")
public class UserProfile {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("username")
    private String username;
    
    @TableField("email")
    private String email;
    
    @TableField("phone")
    private String phone;
    
    @TableField("gender")
    private String gender;
    
    @TableField("birth_date")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthDate;
    
    @TableField("age")
    private Integer age;
    
    @TableField("height")
    private BigDecimal height;
    
    @TableField("weight")
    private BigDecimal weight;
    
    @TableField("bmi")
    private BigDecimal bmi;
    
    @TableField("allergies")
    private String allergies;
    
    @TableField("medical_history")
    private String medicalHistory;
    
    @TableField("medications")
    private String medications;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
    
}