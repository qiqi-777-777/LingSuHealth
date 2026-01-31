package com.lingsu.health.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lingsu.health.dto.Dtos.CheckinSummary;
import com.lingsu.health.entity.HealthCheckin;
import com.lingsu.health.entity.HealthTrend;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.HealthTrendMapper;
import com.lingsu.health.mapper.UserMapper;
import com.lingsu.health.service.HealthCheckinService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/checkin")
@RequiredArgsConstructor
public class CheckinController {
    
    private final HealthCheckinService healthCheckinService;
    private final UserMapper userMapper;
    private final HealthTrendMapper healthTrendMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();
    
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
            
            // 添加分析报告数据
            resp.put("summary", checkin.getAnalysisSummary());
            resp.put("tomorrowPlan", checkin.getAnalysisTomorrowPlan());
            
            try {
                if (checkin.getAnalysisSuggestions() != null) {
                    resp.put("suggestions", objectMapper.readValue(checkin.getAnalysisSuggestions(), List.class));
                } else {
                    resp.put("suggestions", new ArrayList<>());
                }
                
                if (checkin.getAnalysisRisks() != null) {
                    resp.put("risks", objectMapper.readValue(checkin.getAnalysisRisks(), List.class));
                } else {
                    resp.put("risks", new ArrayList<>());
                }
                
                if (checkin.getAnalysisTomorrowTasks() != null) {
                    resp.put("tomorrowTasks", objectMapper.readValue(checkin.getAnalysisTomorrowTasks(), List.class));
                } else {
                    resp.put("tomorrowTasks", new ArrayList<>());
                }
            } catch (Exception e) {
                log.error("解析分析报告JSON数据失败", e);
                resp.put("suggestions", new ArrayList<>());
                resp.put("risks", new ArrayList<>());
                resp.put("tomorrowTasks", new ArrayList<>());
            }
            
            // 获取健康分（直接从checkin对象获取）
            resp.put("healthScore", checkin.getHealthScore() != null ? checkin.getHealthScore() : 0);
            
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
            
            // 构建历史记录列表
            List<Map<String, Object>> historyList = new ArrayList<>();
            ObjectMapper mapper = new ObjectMapper();

            for (HealthCheckin hc : recentCheckins) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", hc.getId());
                item.put("date", hc.getCheckinDate().toString());
                item.put("sleepHours", hc.getSleepHours());
                item.put("sleepTime", hc.getSleepTime() != null ? hc.getSleepTime().toString() : null);
                item.put("exerciseMinutes", hc.getExerciseMinutes());
                item.put("mood", hc.getMood());
                item.put("dietNotes", hc.getDietNotes());
                
                try {
                    if (hc.getSymptoms() != null && !hc.getSymptoms().isEmpty()) {
                        item.put("symptoms", mapper.readValue(hc.getSymptoms(), List.class));
                    } else {
                        item.put("symptoms", new ArrayList<>());
                    }
                } catch (Exception e) {
                    item.put("symptoms", new ArrayList<>());
                }

                // 添加分析报告数据
                item.put("summary", hc.getAnalysisSummary());
                item.put("tomorrowPlan", hc.getAnalysisTomorrowPlan());
                try {
                    if (hc.getAnalysisSuggestions() != null) item.put("suggestions", mapper.readValue(hc.getAnalysisSuggestions(), List.class));
                    if (hc.getAnalysisRisks() != null) item.put("risks", mapper.readValue(hc.getAnalysisRisks(), List.class));
                    if (hc.getAnalysisTomorrowTasks() != null) item.put("tomorrowTasks", mapper.readValue(hc.getAnalysisTomorrowTasks(), List.class));
                } catch (Exception e) {
                    log.warn("解析历史记录JSON失败: {}", e.getMessage());
                }

                // 直接从打卡记录获取健康分
                item.put("healthScore", hc.getHealthScore() != null ? hc.getHealthScore() : 0);
                
                historyList.add(item);
            }
            // 按日期倒序排列
            historyList.sort((a, b) -> ((String)b.get("date")).compareTo((String)a.get("date")));
            
            summary.setHistory(historyList);
            
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
        
        // 获取健康趋势数据（包含健康分）
        LocalDate startDate = LocalDate.now().minusDays(days - 1);
        List<HealthTrend> healthTrends = healthTrendMapper.getRecentTrends(currentUserId, startDate);
        Map<LocalDate, HealthTrend> trendMap = new HashMap<>();
        for (HealthTrend ht : healthTrends) {
            trendMap.put(ht.getTrendDate(), ht);
        }

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
            item.put("sleepTime", hc.getSleepTime() != null ? hc.getSleepTime().toString() : null);
            item.put("exerciseMinutes", hc.getExerciseMinutes());
            item.put("symptoms", symptomsList);
            item.put("mood", hc.getMood());
            item.put("dietNotes", hc.getDietNotes());
            
            // 直接从打卡记录获取健康分
            item.put("healthScore", hc.getHealthScore() != null ? hc.getHealthScore() : 0);
            
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
                // 返回今日打卡数据，方便前端回显
                response.put("checkinData", buildCheckinDataMap(todayCheckin));
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
    
    /**
     * 更新今日打卡记录
     */
    @PutMapping("/today")
    public Map<String, Object> updateTodayCheckin(@RequestBody Map<String, Object> payload, HttpServletRequest request) {
        try {
            if (payload == null || payload.isEmpty()) {
                throw new IllegalArgumentException("打卡数据不能为空");
            }
            
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("success", false);
                resp.put("message", "用户未登录，请先登录");
                return resp;
            }
            
            HealthCheckin checkin = healthCheckinService.updateTodayCheckin(currentUserId, payload);
            
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", true);
            resp.put("checkinId", checkin.getId());
            resp.put("message", "打卡记录已更新");
            
            log.info("更新打卡请求处理成功，用户: {}", currentUserId);
            return resp;
        } catch (IllegalArgumentException e) {
            log.error("更新打卡数据验证失败: {}", e.getMessage());
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "数据验证失败: " + e.getMessage());
            return resp;
        } catch (Exception e) {
            log.error("处理更新打卡请求失败，错误详情: ", e);
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "更新失败，请稍后重试");
            return resp;
        }
    }
    
    /**
     * 删除指定日期的打卡记录
     */
    @DeleteMapping("/{date}")
    public Map<String, Object> deleteCheckin(@PathVariable String date, HttpServletRequest request) {
        try {
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("success", false);
                resp.put("message", "用户未登录，请先登录");
                return resp;
            }
            
            boolean deleted = healthCheckinService.deleteCheckinByDate(currentUserId, date);
            
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", deleted);
            resp.put("message", deleted ? "删除成功" : "未找到该日期的打卡记录");
            
            log.info("删除打卡记录，用户: {}, 日期: {}, 结果: {}", currentUserId, date, deleted);
            return resp;
        } catch (Exception e) {
            log.error("删除打卡记录失败，错误详情: ", e);
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "删除失败，请稍后重试");
            return resp;
        }
    }
    
    /**
     * 删除指定ID的打卡记录
     */
    @DeleteMapping("/id/{id}")
    public Map<String, Object> deleteCheckinById(@PathVariable Long id, HttpServletRequest request) {
        try {
            Long currentUserId = getCurrentUserId(request);
            if (currentUserId == null) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("success", false);
                resp.put("message", "用户未登录，请先登录");
                return resp;
            }
            
            boolean deleted = healthCheckinService.deleteCheckinById(currentUserId, id);
            
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", deleted);
            resp.put("message", deleted ? "删除成功" : "未找到该打卡记录或无权限删除");
            
            log.info("删除打卡记录，用户: {}, 记录ID: {}, 结果: {}", currentUserId, id, deleted);
            return resp;
        } catch (Exception e) {
            log.error("删除打卡记录失败，错误详情: ", e);
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", "删除失败，请稍后重试");
            return resp;
        }
    }
    
    /**
     * 构建打卡数据Map用于返回前端
     */
    private Map<String, Object> buildCheckinDataMap(HealthCheckin checkin) {
        Map<String, Object> data = new HashMap<>();
        data.put("sleepHours", checkin.getSleepHours() != null ? checkin.getSleepHours().doubleValue() : 8);
        data.put("sleepTime", checkin.getSleepTime() != null ? checkin.getSleepTime().toString() : "23:00");
        data.put("mood", checkin.getMood() != null ? checkin.getMood() : 2);
        data.put("exerciseMinutes", checkin.getExerciseMinutes() != null ? checkin.getExerciseMinutes() : 30);
        data.put("dietNotes", checkin.getDietNotes() != null ? checkin.getDietNotes() : "");
        
        // 解析症状
        List<String> symptomsList = new ArrayList<>();
        try {
            if (checkin.getSymptoms() != null && !checkin.getSymptoms().isEmpty()) {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                symptomsList = mapper.readValue(
                    checkin.getSymptoms(),
                    new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {}
                );
            }
        } catch (Exception ignored) {}
        data.put("symptoms", symptomsList);
        
        return data;
    }
}