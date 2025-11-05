package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.HealthCheckin;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface HealthCheckinMapper extends BaseMapper<HealthCheckin> {
    
    /**
     * 获取用户最近N天的打卡记录
     */
    List<HealthCheckin> getRecentCheckins(@Param("userId") Long userId, 
                                         @Param("startDate") LocalDate startDate);
    
    /**
     * 获取用户连续打卡天数
     */
    int getConsecutiveDays(@Param("userId") Long userId, 
                          @Param("startDate") LocalDate startDate);
}