package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lingsu.health.entity.HealthCheckin;
import com.lingsu.health.entity.HealthTrend;
import com.lingsu.health.mapper.HealthCheckinMapper;
import com.lingsu.health.mapper.HealthTrendMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class HealthCheckinService {
    
    private final HealthCheckinMapper healthCheckinMapper;
    private final HealthTrendMapper healthTrendMapper;
    private final DeepSeekService deepSeekService;
    
    /**
     * 保存打卡记录
     */
    @Transactional
    public HealthCheckin saveCheckin(Long userId, Map<String, Object> checkinData) {
        try {
            HealthCheckin checkin = new HealthCheckin();
            checkin.setUserId(userId);
            checkin.setCheckinDate(LocalDate.now());
            log.info("为用户 {} 创建新的打卡记录", userId);
    
            // 安全地设置打卡数据，添加类型检查和异常处理
            if (checkinData.get("sleepHours") != null) {
                Object sleepHoursObj = checkinData.get("sleepHours");
                if (sleepHoursObj instanceof Number) {
                    checkin.setSleepHours(new BigDecimal(sleepHoursObj.toString()));
                } else {
                    log.warn("sleepHours 类型不正确: {}", sleepHoursObj.getClass());
                    throw new IllegalArgumentException("睡眠时长数据格式不正确");
                }
            } else {
                throw new IllegalArgumentException("睡眠时长不能为空");
            }
            
            if (checkinData.get("sleepTime") != null) {
                try {
                    String sleepTimeStr = checkinData.get("sleepTime").toString();
                    checkin.setSleepTime(LocalTime.parse(sleepTimeStr));
                } catch (Exception e) {
                    log.warn("sleepTime 解析失败: {}", checkinData.get("sleepTime"), e);
                    throw new IllegalArgumentException("入睡时间格式不正确");
                }
            } else {
                throw new IllegalArgumentException("入睡时间不能为空");
            }
            
            if (checkinData.get("symptoms") != null) {
                Object symptomsObj = checkinData.get("symptoms");
                if (symptomsObj instanceof List) {
                    // 如果是数组，转换为JSON字符串
                    try {
                        ObjectMapper mapper = new ObjectMapper();
                        checkin.setSymptoms(mapper.writeValueAsString(symptomsObj));
                    } catch (Exception e) {
                        log.warn("症状数据JSON序列化失败: {}", symptomsObj, e);
                        checkin.setSymptoms("[]"); // 设置为空数组
                    }
                } else {
                    // 如果已经是字符串，直接使用
                    checkin.setSymptoms(symptomsObj.toString());
                }
            } else {
                checkin.setSymptoms("[]"); // 默认空数组
            }
            
            if (checkinData.get("mood") != null) {
                Object moodObj = checkinData.get("mood");
                if (moodObj instanceof Number) {
                    checkin.setMood(((Number) moodObj).intValue());
                } else {
                    log.warn("mood 类型不正确: {}", moodObj.getClass());
                    throw new IllegalArgumentException("情绪状态数据格式不正确");
                }
            } else {
                throw new IllegalArgumentException("情绪状态不能为空");
            }
            
            if (checkinData.get("exerciseMinutes") != null) {
                Object exerciseObj = checkinData.get("exerciseMinutes");
                if (exerciseObj instanceof Number) {
                    checkin.setExerciseMinutes(((Number) exerciseObj).intValue());
                } else {
                    log.warn("exerciseMinutes 类型不正确: {}", exerciseObj.getClass());
                    throw new IllegalArgumentException("运动时长数据格式不正确");
                }
            } else {
                throw new IllegalArgumentException("运动时长不能为空");
            }
            
            if (checkinData.get("dietNotes") != null) {
                checkin.setDietNotes(checkinData.get("dietNotes").toString());
            } else {
                checkin.setDietNotes("");
            }
            
            // 移除followedPlan必填校验，统一默认false
            checkin.setFollowedPlan(false);
            
            // 调用AI进行健康分析
            try {
                String analysisResult = deepSeekService.analyzeHealthData(checkinData);
                parseAndSetAnalysisData(checkin, analysisResult);
            } catch (Exception e) {
                log.error("AI健康分析失败", e);
                if (checkin.getAnalysisSummary() == null) {
                    checkin.setAnalysisSummary("暂无分析");
                }
            }
            
            // 保存新记录
            healthCheckinMapper.insert(checkin);
            log.info("为用户 {} 创建新打卡记录成功，ID: {}", userId, checkin.getId());
            
            // 计算并保存健康趋势数据（会设置healthScore字段）
            saveHealthTrend(userId, checkin);
            
            // 更新记录以保存健康分
            healthCheckinMapper.updateById(checkin);
            log.info("为用户 {} 更新健康分成功，健康分: {}", userId, checkin.getHealthScore());
            
            return checkin;
        } catch (IllegalArgumentException e) {
            log.error("打卡数据验证失败，用户ID: {}, 错误: {}", userId, e.getMessage());
            throw e; // 重新抛出参数异常，让控制器处理
        } catch (Exception e) {
            log.error("保存打卡数据失败，用户ID: {}, 数据: {}, 错误详情: ", userId, checkinData, e);
            throw new RuntimeException("保存打卡数据失败: " + e.getMessage(), e);
        }
    }

    private void parseAndSetAnalysisData(HealthCheckin checkin, String analysis) {
        if (analysis == null || analysis.isEmpty()) return;

        // 提取总结
        String summary = extractSection(analysis, "【健康总结】", "【个性化建议】");
        checkin.setAnalysisSummary(summary);
        
        // 提取建议
        String suggestionsRaw = extractSection(analysis, "【个性化建议】", "【明日养生方案】");
        List<Map<String, String>> suggestions = parseSuggestions(suggestionsRaw);
        try {
            checkin.setAnalysisSuggestions(new ObjectMapper().writeValueAsString(suggestions));
        } catch (Exception e) {
            log.error("建议序列化失败", e);
        }
        
        // 提取明日方案
        String tomorrowPlan = extractSection(analysis, "【明日养生方案】", null);
        checkin.setAnalysisTomorrowPlan(tomorrowPlan);
        
        // 提取风险
        checkin.setAnalysisRisks("[]");
        
        // 明日任务
        checkin.setAnalysisTomorrowTasks("[]");
    }
    
    private String extractSection(String text, String startTag, String endTag) {
        int start = text.indexOf(startTag);
        if (start == -1) return "";
        start += startTag.length();
        
        int end = (endTag != null) ? text.indexOf(endTag, start) : text.length();
        if (end == -1) end = text.length();
        
        return text.substring(start, end).trim();
    }
    
    private List<Map<String, String>> parseSuggestions(String raw) {
        List<Map<String, String>> list = new ArrayList<>();
        if (raw == null || raw.isEmpty()) return list;
        
        String[] lines = raw.split("\n");
        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty()) continue;
            
            // 匹配 "1. 睡眠方面：..."
            if (line.matches("^\\d+[.、].*[:：].*")) {
                int colonIdx = line.indexOf("：");
                if (colonIdx == -1) colonIdx = line.indexOf(":");
                
                int dotIdx = line.indexOf(".");
                if (dotIdx == -1) dotIdx = line.indexOf("、");
                
                if (colonIdx > dotIdx) {
                    String title = line.substring(dotIdx + 1, colonIdx).trim();
                    String content = line.substring(colonIdx + 1).trim();
                    Map<String, String> map = new HashMap<>();
                    map.put("title", title);
                    map.put("content", content);
                    list.add(map);
                }
            }
        }
        return list;
    }
    
    /**
     * 获取用户最近的打卡记录
     */
    public List<HealthCheckin> getRecentCheckins(Long userId, int days) {
        LocalDate startDate = LocalDate.now().minusDays(days - 1);
        return healthCheckinMapper.getRecentCheckins(userId, startDate);
    }
    
    /**
     * 获取连续打卡天数
     */
    public int getConsecutiveDays(Long userId) {
        // 简单实现：从今天开始往前数连续的打卡天数
        LocalDate today = LocalDate.now();
        int consecutiveDays = 0;
        
        for (int i = 0; i < 365; i++) { // 最多查一年
            LocalDate checkDate = today.minusDays(i);
            QueryWrapper<HealthCheckin> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId)
                       .eq("checkin_date", checkDate);
            
            if (healthCheckinMapper.selectCount(queryWrapper) > 0) {
                consecutiveDays++;
            } else {
                break;
            }
        }
        
        return consecutiveDays;
    }
    
    /**
     * 检查今日是否已打卡
     */
    public boolean hasCheckedInToday(Long userId) {
        QueryWrapper<HealthCheckin> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                   .eq("checkin_date", LocalDate.now());
        return healthCheckinMapper.selectCount(queryWrapper) > 0;
    }
    
    /**
     * 获取今日打卡记录
     */
    public HealthCheckin getTodayCheckin(Long userId) {
        QueryWrapper<HealthCheckin> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                   .eq("checkin_date", LocalDate.now())
                   .orderByDesc("created_at")
                   .last("LIMIT 1");
        return healthCheckinMapper.selectOne(queryWrapper);
    }
    
    /**
     * 更新今日打卡记录
     */
    @Transactional
    public HealthCheckin updateTodayCheckin(Long userId, Map<String, Object> checkinData) {
        try {
            // 获取今日打卡记录
            HealthCheckin checkin = getTodayCheckin(userId);
            if (checkin == null) {
                throw new IllegalArgumentException("今日未打卡，无法修改");
            }
            
            log.info("为用户 {} 更新今日打卡记录，ID: {}", userId, checkin.getId());
            
            // 更新打卡数据
            if (checkinData.get("sleepHours") != null) {
                Object sleepHoursObj = checkinData.get("sleepHours");
                if (sleepHoursObj instanceof Number) {
                    checkin.setSleepHours(new BigDecimal(sleepHoursObj.toString()));
                } else {
                    throw new IllegalArgumentException("睡眠时长数据格式不正确");
                }
            }
            
            if (checkinData.get("sleepTime") != null) {
                try {
                    String sleepTimeStr = checkinData.get("sleepTime").toString();
                    checkin.setSleepTime(LocalTime.parse(sleepTimeStr));
                } catch (Exception e) {
                    throw new IllegalArgumentException("入睡时间格式不正确");
                }
            }
            
            if (checkinData.get("symptoms") != null) {
                Object symptomsObj = checkinData.get("symptoms");
                if (symptomsObj instanceof List) {
                    try {
                        ObjectMapper mapper = new ObjectMapper();
                        checkin.setSymptoms(mapper.writeValueAsString(symptomsObj));
                    } catch (Exception e) {
                        checkin.setSymptoms("[]");
                    }
                } else {
                    checkin.setSymptoms(symptomsObj.toString());
                }
            }
            
            if (checkinData.get("mood") != null) {
                Object moodObj = checkinData.get("mood");
                if (moodObj instanceof Number) {
                    checkin.setMood(((Number) moodObj).intValue());
                } else {
                    throw new IllegalArgumentException("情绪状态数据格式不正确");
                }
            }
            
            if (checkinData.get("exerciseMinutes") != null) {
                Object exerciseObj = checkinData.get("exerciseMinutes");
                if (exerciseObj instanceof Number) {
                    checkin.setExerciseMinutes(((Number) exerciseObj).intValue());
                } else {
                    throw new IllegalArgumentException("运动时长数据格式不正确");
                }
            }
            
            if (checkinData.get("dietNotes") != null) {
                checkin.setDietNotes(checkinData.get("dietNotes").toString());
            }
            
            // 更新记录
            healthCheckinMapper.updateById(checkin);
            log.info("用户 {} 更新打卡记录成功，ID: {}", userId, checkin.getId());
            
            // 更新健康趋势数据
            saveHealthTrend(userId, checkin);
            
            return checkin;
        } catch (IllegalArgumentException e) {
            log.error("更新打卡数据验证失败，用户ID: {}, 错误: {}", userId, e.getMessage());
            throw e;
        } catch (Exception e) {
            log.error("更新打卡数据失败，用户ID: {}, 数据: {}, 错误详情: ", userId, checkinData, e);
            throw new RuntimeException("更新打卡数据失败: " + e.getMessage(), e);
        }
    }
    
    /**
     * 删除指定日期的打卡记录
     */
    @Transactional
    public boolean deleteCheckinByDate(Long userId, String dateStr) {
        try {
            LocalDate date = LocalDate.parse(dateStr);
            
            // 查找该日期的所有打卡记录
            QueryWrapper<HealthCheckin> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId)
                       .eq("checkin_date", date);
            List<HealthCheckin> checkins = healthCheckinMapper.selectList(queryWrapper);
            
            if (checkins == null || checkins.isEmpty()) {
                log.warn("未找到用户 {} 在 {} 的打卡记录", userId, dateStr);
                return false;
            }
            
            // 删除所有打卡记录
            for (HealthCheckin checkin : checkins) {
                healthCheckinMapper.deleteById(checkin.getId());
                log.info("删除用户 {} 在 {} 的打卡记录，ID: {}", userId, dateStr, checkin.getId());
            }
            
            // 同时删除对应的健康趋势数据
            QueryWrapper<HealthTrend> trendWrapper = new QueryWrapper<>();
            trendWrapper.eq("user_id", userId)
                       .eq("trend_date", date);
            healthTrendMapper.delete(trendWrapper);
            log.info("删除用户 {} 在 {} 的健康趋势数据", userId, dateStr);
            
            return true;
        } catch (Exception e) {
            log.error("删除打卡记录失败，用户ID: {}, 日期: {}, 错误详情: ", userId, dateStr, e);
            throw new RuntimeException("删除打卡记录失败: " + e.getMessage(), e);
        }
    }
    
    /**
     * 删除指定ID的打卡记录
     */
    @Transactional
    public boolean deleteCheckinById(Long userId, Long checkinId) {
        try {
            // 先查询记录，确保是该用户的记录
            HealthCheckin checkin = healthCheckinMapper.selectById(checkinId);
            
            if (checkin == null) {
                log.warn("未找到ID为 {} 的打卡记录", checkinId);
                return false;
            }
            
            // 验证记录所属用户
            if (!checkin.getUserId().equals(userId)) {
                log.warn("用户 {} 无权删除ID为 {} 的打卡记录（所属用户: {}）", userId, checkinId, checkin.getUserId());
                return false;
            }
            
            // 删除打卡记录
            healthCheckinMapper.deleteById(checkinId);
            log.info("删除用户 {} 的打卡记录，ID: {}, 日期: {}", userId, checkinId, checkin.getCheckinDate());
            
            return true;
        } catch (Exception e) {
            log.error("删除打卡记录失败，用户ID: {}, 记录ID: {}, 错误详情: ", userId, checkinId, e);
            throw new RuntimeException("删除打卡记录失败: " + e.getMessage(), e);
        }
    }
    
    /**
     * 计算并保存健康趋势数据
     * @return 计算出的健康分
     */
    private int saveHealthTrend(Long userId, HealthCheckin checkin) {
        try {
            // 计算各项得分
            int sleepScore = calculateSleepScore(checkin);
            int moodScore = calculateMoodScore(checkin);
            int exerciseScore = calculateExerciseScore(checkin);
            int dietScore = calculateDietScore(checkin);
            
            // 综合健康分 = 各项加权平均
            int healthScore = (int) (sleepScore * 0.3 + moodScore * 0.25 + exerciseScore * 0.25 + dietScore * 0.2);
            
            // 直接设置到checkin对象上
            checkin.setHealthScore(healthScore);
            
            // 同时保存到HealthTrend表（用于历史趋势分析）
            // 注意：一天可能有多条记录，我们只保存/更新一条趋势记录（取最新的）
            QueryWrapper<HealthTrend> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId)
                       .eq("trend_date", checkin.getCheckinDate());
            HealthTrend existingTrend = healthTrendMapper.selectOne(queryWrapper);
            
            if (existingTrend != null) {
                // 更新现有记录为最新的健康分
                existingTrend.setHealthScore(healthScore);
                existingTrend.setSleepQualityScore(sleepScore);
                existingTrend.setMoodScore(moodScore);
                existingTrend.setExerciseScore(exerciseScore);
                existingTrend.setDietScore(dietScore);
                healthTrendMapper.updateById(existingTrend);
                log.info("更新用户 {} 的健康趋势数据，健康分: {}", userId, healthScore);
            } else {
                // 创建新记录
                HealthTrend trend = new HealthTrend();
                trend.setUserId(userId);
                trend.setTrendDate(checkin.getCheckinDate());
                trend.setHealthScore(healthScore);
                trend.setSleepQualityScore(sleepScore);
                trend.setMoodScore(moodScore);
                trend.setExerciseScore(exerciseScore);
                trend.setDietScore(dietScore);
                healthTrendMapper.insert(trend);
                log.info("创建用户 {} 的健康趋势数据，健康分: {}", userId, healthScore);
            }
            return healthScore;
        } catch (Exception e) {
            log.error("保存健康趋势数据失败，用户ID: {}", userId, e);
            return 0;
        }
    }
    
    /**
     * 计算睡眠得分 (0-100)
     */
    private int calculateSleepScore(HealthCheckin checkin) {
        if (checkin.getSleepHours() == null) return 50;
        
        double hours = checkin.getSleepHours().doubleValue();
        LocalTime sleepTime = checkin.getSleepTime();
        
        int score = 50;
        
        // 睡眠时长评分：7-8小时最佳
        if (hours >= 7 && hours <= 8) {
            score = 100;
        } else if (hours >= 6 && hours < 7) {
            score = 80;
        } else if (hours > 8 && hours <= 9) {
            score = 85;
        } else if (hours >= 5 && hours < 6) {
            score = 60;
        } else if (hours > 9) {
            score = 70;
        } else {
            score = 40;
        }
        
        // 入睡时间评分：22:00-23:00 最佳
        if (sleepTime != null) {
            int hour = sleepTime.getHour();
            if (hour >= 22 && hour <= 23) {
                // 最佳时间，不扣分
            } else if (hour >= 21 || (hour >= 0 && hour <= 0)) {
                score -= 5;
            } else if (hour >= 1) {
                score -= 15; // 凌晨1点后入睡扣分较多
            }
        }
        
        return Math.max(0, Math.min(100, score));
    }
    
    /**
     * 计算情绪得分 (0-100)
     */
    private int calculateMoodScore(HealthCheckin checkin) {
        if (checkin.getMood() == null) return 50;
        
        // mood: 0=很差, 1=一般, 2=良好, 3=很好, 4=极佳
        int mood = checkin.getMood();
        return switch (mood) {
            case 0 -> 20;
            case 1 -> 50;
            case 2 -> 70;
            case 3 -> 85;
            case 4 -> 100;
            default -> 50;
        };
    }
    
    /**
     * 计算运动得分 (0-100)
     */
    private int calculateExerciseScore(HealthCheckin checkin) {
        if (checkin.getExerciseMinutes() == null) return 50;
        
        int minutes = checkin.getExerciseMinutes();
        
        // 30-60分钟最佳
        if (minutes >= 30 && minutes <= 60) {
            return 100;
        } else if (minutes >= 60 && minutes <= 90) {
            return 95;
        } else if (minutes >= 20 && minutes < 30) {
            return 80;
        } else if (minutes >= 10 && minutes < 20) {
            return 60;
        } else if (minutes > 90) {
            return 85; // 运动过量略扣分
        } else if (minutes > 0) {
            return 40;
        } else {
            return 20; // 完全不运动
        }
    }
    
    /**
     * 计算饮食得分 (0-100)
     */
    private int calculateDietScore(HealthCheckin checkin) {
        String dietNotes = checkin.getDietNotes();
        if (dietNotes == null || dietNotes.trim().isEmpty()) {
            return 60; // 未记录饮食给基础分
        }
        
        int score = 70; // 有记录给基础分
        
        // 根据关键词加减分
        String notes = dietNotes.toLowerCase();
        if (notes.contains("清淡") || notes.contains("蔬菜") || notes.contains("水果")) {
            score += 15;
        }
        if (notes.contains("蛋白") || notes.contains("鸡蛋") || notes.contains("牛奶")) {
            score += 10;
        }
        if (notes.contains("油炸") || notes.contains("烧烤") || notes.contains("外卖")) {
            score -= 15;
        }
        if (notes.contains("规律") || notes.contains("三餐")) {
            score += 10;
        }
        
        return Math.max(0, Math.min(100, score));
    }
}