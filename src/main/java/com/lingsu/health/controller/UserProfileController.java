package com.lingsu.health.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.entity.User;
import com.lingsu.health.entity.UserProfile;
import com.lingsu.health.mapper.UserMapper;
import com.lingsu.health.service.UserProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * 用户资料控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserProfileController {
    
    private final UserProfileService userProfileService;
    private final UserMapper userMapper;
    
    /**
     * 从请求中获取当前用户ID
     */
    private Long getCurrentUserId(HttpServletRequest request) {
        try {
            // 从请求头获取用户名
            String username = request.getHeader("X-Username");
            if (username == null || username.trim().isEmpty()) {
                log.warn("请求头中未找到用户名信息");
                return null;
            }
            
            // 根据用户名查询用户信息
            QueryWrapper<User> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("username", username.trim());
            User user = userMapper.selectOne(queryWrapper);
            
            if (user == null) {
                log.warn("未找到用户名为 {} 的用户", username);
                return null;
            }
            
            log.info("成功获取用户信息: username={}, userId={}", username, user.getId());
            return user.getId().longValue();
            
        } catch (Exception e) {
            log.error("获取用户ID失败", e);
            return null;
        }
    }
    
    /**
     * 获取用户资料
     */
    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@RequestParam(required = false) String username, HttpServletRequest request) {
        try {
            Optional<UserProfile> profileOpt;
            
            if (username != null && !username.isEmpty()) {
                profileOpt = userProfileService.getUserProfileByUsername(username);
            } else {
                // 从请求中获取当前用户ID
                Long currentUserId = getCurrentUserId(request);
                if (currentUserId == null) {
                    return ResponseEntity.ok(Map.of("profile", null, "message", "用户未登录"));
                }
                profileOpt = userProfileService.getUserProfile(currentUserId);
            }
            
            if (profileOpt.isPresent()) {
                UserProfile profile = profileOpt.get();
                Map<String, Object> result = new HashMap<>();
                result.put("profile", profile);
                result.put("bmiStatus", userProfileService.getBmiStatus(profile.getBmi()));
                return ResponseEntity.ok(result);
            } else {
                return ResponseEntity.ok(Map.of("profile", null, "message", "用户资料不存在"));
            }
            
        } catch (Exception e) {
            log.error("获取用户资料失败", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "获取用户资料失败: " + e.getMessage()));
        }
    }
    
    /**
     * 更新用户资料
     */
    /**
     * 测试端点：检查数据库中的用户资料数据
     */
    @GetMapping("/profile/debug")
    public ResponseEntity<?> debugUserProfile() {
        try {
            Long currentUserId = 1L;
            Optional<UserProfile> existingProfile = userProfileService.getUserProfile(currentUserId);
            
            Map<String, Object> debugInfo = new HashMap<>();
            debugInfo.put("userId", currentUserId);
            debugInfo.put("hasExistingProfile", existingProfile.isPresent());
            
            if (existingProfile.isPresent()) {
                UserProfile profile = existingProfile.get();
                debugInfo.put("existingProfile", Map.of(
                    "id", profile.getId(),
                    "username", profile.getUsername(),
                    "email", profile.getEmail(),
                    "gender", profile.getGender(),
                    "birthDate", profile.getBirthDate(),
                    "createdAt", profile.getCreatedAt(),
                    "updatedAt", profile.getUpdatedAt()
                ));
            }
            
            return ResponseEntity.ok(debugInfo);
            
        } catch (Exception e) {
            log.error("调试用户资料失败", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "调试失败: " + e.getMessage()));
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateUserProfile(@RequestBody UserProfile profile, HttpServletRequest request) {
        try {
            // 从请求中获取当前用户ID
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "用户未登录，请先登录"));
            }
            
            profile.setUserId(currentUserId);
            
            log.info("接收到的用户资料数据: username={}, email={}, gender={}, birthDate={}", 
                profile.getUsername(), profile.getEmail(), profile.getGender(), profile.getBirthDate());
            
            // 检查数据库中是否已存在该用户的资料
            Optional<UserProfile> existingProfile = userProfileService.getUserProfile(currentUserId);
            log.info("数据库中现有资料: {}", existingProfile.isPresent() ? "存在" : "不存在");
            
            // 检查用户名是否已被其他用户使用
            if (profile.getUsername() != null && !userProfileService.isUsernameAvailable(profile.getUsername(), currentUserId)) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "用户名已被使用"));
            }
            
            // 检查邮箱是否已被其他用户使用
            if (profile.getEmail() != null && !profile.getEmail().trim().isEmpty() 
                && !userProfileService.isEmailAvailable(profile.getEmail(), currentUserId)) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "邮箱已被使用"));
            }
            
            // 保存用户资料
            UserProfile savedProfile = userProfileService.saveUserProfile(profile);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "用户资料保存成功");
            response.put("profile", savedProfile);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("保存用户资料失败", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "保存用户资料失败: " + (e.getMessage() != null ? e.getMessage() : "未知错误")));
        }
    }
    
    /**
     * 检查用户名是否可用
     */
    @GetMapping("/check-username")
    public ResponseEntity<?> checkUsername(@RequestParam String username) {
        try {
            // TODO: 从JWT token或session中获取当前用户ID
            Long currentUserId = 1L; // 临时硬编码
            
            boolean available = userProfileService.isUsernameAvailable(username, currentUserId);
            return ResponseEntity.ok(Map.of("available", available));
            
        } catch (Exception e) {
            log.error("检查用户名失败", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "检查用户名失败: " + e.getMessage()));
        }
    }
    
    /**
     * 检查邮箱是否可用
     */
    @GetMapping("/check-email")
    public ResponseEntity<?> checkEmail(@RequestParam String email) {
        try {
            // TODO: 从JWT token或session中获取当前用户ID
            Long currentUserId = 1L; // 临时硬编码
            
            boolean available = userProfileService.isEmailAvailable(email, currentUserId);
            return ResponseEntity.ok(Map.of("available", available));
            
        } catch (Exception e) {
            log.error("检查邮箱失败", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "检查邮箱失败: " + e.getMessage()));
        }
    }
}