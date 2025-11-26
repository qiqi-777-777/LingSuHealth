package com.lingsu.health.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.dto.Dtos.CheckinSummary;
import com.lingsu.health.entity.HealthCheckin;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.UserMapper;
import com.lingsu.health.service.HealthCheckinService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/checkin")
@RequiredArgsConstructor
public class CheckinController {
    
    private final HealthCheckinService healthCheckinService;
    private final UserMapper userMapper;
    
    @PostMapping
    public Map<String, Object> checkin(@RequestBody Map<String, Object> payload, HttpServletRequest request) {
        try {
            // 验证请求数据
            if (payload == null || payload.isEmpty()) {
                throw new IllegalArgumentException("打卡数据不能为空");
            }
            
            // 从请求头或session中获取用户信息
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("success", false);
                resp.put("message", "用户未登录，请先登录");
                return resp;
            }
            
            // 保存打卡数据
            HealthCheckin checkin = healthCheckinService.saveCheckin(currentUserId, payload);
            
            // 返回打卡成功信息
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", true);
            resp.put("checkinId", checkin.getId());
            resp.put("message", "打卡成功，数据已保存");
            
            log.info("打卡请求处理成功，用户: {}", currentUserId);
            return resp;
        } catch (IllegalArgumentException e) {
            log.error("打卡数据验证失败: {}", e.getMessage());
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "数据验证失败: " + e.getMessage());
            return resp;
        } catch (Exception e) {
            log.error("处理打卡请求失败，错误详情: ", e);
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "打卡失败，请稍后重试");
            return resp;
        }
    }
    
    @GetMapping("/summary")
    public CheckinSummary summary(HttpServletRequest request) {
        try {
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                // 返回空摘要
                CheckinSummary defaultSummary = new CheckinSummary();
                defaultSummary.setTotalCheckins(0);
                defaultSummary.setConsecutiveDays(0);
                defaultSummary.setWeeklyGoal(7);
                defaultSummary.setCompletionRate(0);
                return defaultSummary;
            }
            
            CheckinSummary summary = new CheckinSummary();
            
            // 获取最近7天的打卡记录
            List<HealthCheckin> recentCheckins = healthCheckinService.getRecentCheckins(currentUserId, 7);
            summary.setTotalCheckins(recentCheckins.size());
            
            // 获取连续打卡天数
            int consecutiveDays = healthCheckinService.getConsecutiveDays(currentUserId);
            summary.setConsecutiveDays(consecutiveDays);
            
            // 设置基本统计信息
            summary.setWeeklyGoal(7);
            summary.setCompletionRate(Math.round((float) recentCheckins.size() / 7 * 100));
            
            return summary;
        } catch (Exception e) {
            log.error("获取打卡摘要失败", e);
            // 返回默认摘要
            CheckinSummary defaultSummary = new CheckinSummary();
            defaultSummary.setTotalCheckins(0);
            defaultSummary.setConsecutiveDays(0);
            defaultSummary.setWeeklyGoal(7);
            defaultSummary.setCompletionRate(0);
            return defaultSummary;
        }
    }
    
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
    
    @GetMapping("/trends")
    public Map<String, Object> trends(@RequestParam(defaultValue = "7") int days,
                                      HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        if (currentUserId == null) {
            return Map.of("trends", List.of());
        }
        List<HealthCheckin> recentCheckins = healthCheckinService.getRecentCheckins(currentUserId, days);

        List<Map<String, Object>> trends = new ArrayList<>();
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();

        for (HealthCheckin hc : recentCheckins) {
            List<String> symptomsList = new ArrayList<>();
            try {
                if (hc.getSymptoms() != null && !hc.getSymptoms().isEmpty()) {
                    symptomsList = mapper.readValue(
                        hc.getSymptoms(),
                        new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {}
                    );
                }
            } catch (Exception ignored) {}

            Map<String, Object> item = new HashMap<>();
            item.put("date", hc.getCheckinDate().toString());
            item.put("sleepHours", hc.getSleepHours() != null ? Double.valueOf(hc.getSleepHours().toString()) : null);
            item.put("exerciseMinutes", hc.getExerciseMinutes());
            item.put("symptoms", symptomsList);
            item.put("mood", hc.getMood());
            trends.add(item);
        }

        return Map.of("trends", trends);
    }
    
    /**
     * 检查今日是否已打卡
     */
    @GetMapping("/check-today")
    public Map<String, Object> checkTodayCheckin(HttpServletRequest request) {
        try {
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                return Map.of(
                    "hasCheckedIn", false,
                    "message", "用户未登录"
                );
            }
            
            boolean hasCheckedIn = healthCheckinService.hasCheckedInToday(currentUserId);
            Map<String, Object> response = new HashMap<>();
            response.put("hasCheckedIn", hasCheckedIn);
            
            if (hasCheckedIn) {
                HealthCheckin todayCheckin = healthCheckinService.getTodayCheckin(currentUserId);
                response.put("message", "今日已打卡");
                response.put("checkinTime", todayCheckin.getCreatedAt().toString());
            } else {
                response.put("message", "今日未打卡");
            }
            
            return response;
        } catch (Exception e) {
            log.error("检查今日打卡状态失败", e);
            return Map.of(
                "hasCheckedIn", false,
                "message", "检查失败"
            );
        }
    }
}