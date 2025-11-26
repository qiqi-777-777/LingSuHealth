package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lingsu.health.entity.HealthCheckin;
import com.lingsu.health.mapper.HealthCheckinMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class HealthCheckinService {
    
    private final HealthCheckinMapper healthCheckinMapper;
    
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
    
            // 检查今日是否已打卡
            QueryWrapper<HealthCheckin> existsWrapper = new QueryWrapper<>();
            existsWrapper.eq("user_id", userId)
                         .eq("checkin_date", checkin.getCheckinDate());
            if (healthCheckinMapper.selectCount(existsWrapper) > 0) {
                log.warn("用户 {} 今日已打卡，禁止重复提交", userId);
                throw new IllegalArgumentException("今日已打卡，每天只能打卡一次");
            }
    
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
            
            // 保存新记录
            healthCheckinMapper.insert(checkin);
            log.info("为用户 {} 创建新打卡记录成功，ID: {}", userId, checkin.getId());
            
            return checkin;
        } catch (IllegalArgumentException e) {
            log.error("打卡数据验证失败，用户ID: {}, 错误: {}", userId, e.getMessage());
            throw e; // 重新抛出参数异常，让控制器处理
        } catch (Exception e) {
            log.error("保存打卡数据失败，用户ID: {}, 数据: {}, 错误详情: ", userId, checkinData, e);
            throw new RuntimeException("保存打卡数据失败: " + e.getMessage(), e);
        }
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
}