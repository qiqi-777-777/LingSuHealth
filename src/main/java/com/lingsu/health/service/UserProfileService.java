package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.entity.UserProfile;
import com.lingsu.health.mapper.UserProfileMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.Optional;

/**
 * 用户资料服务类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserProfileService {
    
    private final UserProfileMapper userProfileMapper;
    
    /**
     * 根据用户ID获取用户资料
     */
    public Optional<UserProfile> getUserProfile(Long userId) {
        UserProfile profile = userProfileMapper.selectOne(
            new QueryWrapper<UserProfile>().eq("user_id", userId)
        );
        return Optional.ofNullable(profile);
    }
    
    /**
     * 根据用户名获取用户资料
     */
    public Optional<UserProfile> getUserProfileByUsername(String username) {
        UserProfile profile = userProfileMapper.selectOne(
            new QueryWrapper<UserProfile>().eq("username", username)
        );
        return Optional.ofNullable(profile);
    }
    
    /**
     * 创建或更新用户资料
     */
    @Transactional
    public UserProfile saveUserProfile(UserProfile profile) {
        // 自动计算年龄
        if (profile.getBirthDate() != null) {
            int age = Period.between(profile.getBirthDate(), LocalDate.now()).getYears();
            profile.setAge(age);
        }
        
        // 自动计算BMI
        if (profile.getHeight() != null && profile.getWeight() != null 
            && profile.getHeight().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal heightInMeters = profile.getHeight().divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
            BigDecimal bmi = profile.getWeight().divide(
                heightInMeters.multiply(heightInMeters), 2, RoundingMode.HALF_UP);
            profile.setBmi(bmi);
        }
        
        // 设置时间戳
        LocalDateTime now = LocalDateTime.now();
        
        // 检查是否已存在该用户的资料
        Optional<UserProfile> existingProfile = getUserProfile(profile.getUserId());
        
        if (existingProfile.isPresent()) {
            // 更新现有记录
            UserProfile existing = existingProfile.get();
            profile.setId(existing.getId()); // 设置正确的ID
            profile.setCreatedAt(existing.getCreatedAt()); // 保持原创建时间
            profile.setUpdatedAt(now);
            userProfileMapper.updateById(profile);
            log.info("更新用户资料: userId={}, id={}", profile.getUserId(), profile.getId());
        } else {
            // 新建记录
            profile.setCreatedAt(now);
            profile.setUpdatedAt(now);
            userProfileMapper.insert(profile);
            log.info("创建用户资料: userId={}", profile.getUserId());
        }
        
        return profile;
    }
    
    /**
     * 检查用户名是否可用
     */
    public boolean isUsernameAvailable(String username, Long excludeUserId) {
        QueryWrapper<UserProfile> wrapper = new QueryWrapper<UserProfile>()
            .eq("username", username);
        
        if (excludeUserId != null) {
            wrapper.ne("user_id", excludeUserId);
        }
        
        return userProfileMapper.selectCount(wrapper) == 0;
    }
    
    /**
     * 检查邮箱是否可用
     */
    public boolean isEmailAvailable(String email, Long excludeUserId) {
        QueryWrapper<UserProfile> wrapper = new QueryWrapper<UserProfile>()
            .eq("email", email);
        
        if (excludeUserId != null) {
            wrapper.ne("user_id", excludeUserId);
        }
        
        return userProfileMapper.selectCount(wrapper) == 0;
    }
    
    /**
     * 删除用户资料
     */
    @Transactional
    public void deleteUserProfile(Long userId) {
        userProfileMapper.delete(
            new QueryWrapper<UserProfile>().eq("user_id", userId)
        );
    }
    
    /**
     * 获取BMI状态描述
     */
    public String getBmiStatus(BigDecimal bmi) {
        if (bmi == null) {
            return "未知";
        }
        
        double bmiValue = bmi.doubleValue();
        if (bmiValue < 18.5) {
            return "偏瘦";
        } else if (bmiValue < 24) {
            return "正常";
        } else if (bmiValue < 28) {
            return "偏胖";
        } else {
            return "肥胖";
        }
    }
}