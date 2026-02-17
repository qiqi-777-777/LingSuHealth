package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.WeeklyReport;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface WeeklyReportMapper extends BaseMapper<WeeklyReport> {

    /**
     * 获取用户最新周报
     */
    @Select("SELECT * FROM weekly_reports WHERE user_id = #{userId} ORDER BY week_start DESC LIMIT 1")
    WeeklyReport findLatestReport(@Param("userId") Long userId);

    /**
     * 获取用户指定周的周报
     */
    @Select("SELECT * FROM weekly_reports WHERE user_id = #{userId} AND week_start = #{weekStart}")
    WeeklyReport findByWeek(@Param("userId") Long userId, @Param("weekStart") LocalDate weekStart);

    /**
     * 获取用户周报历史列表
     */
    @Select("SELECT * FROM weekly_reports WHERE user_id = #{userId} ORDER BY week_start DESC LIMIT #{limit}")
    List<WeeklyReport> findReportHistory(@Param("userId") Long userId, @Param("limit") int limit);

    /**
     * 检查用户本周是否已生成周报
     */
    @Select("SELECT COUNT(*) > 0 FROM weekly_reports WHERE user_id = #{userId} " +
            "AND week_start >= #{weekStart} AND week_start <= #{weekEnd}")
    boolean existsForWeek(@Param("userId") Long userId,
            @Param("weekStart") LocalDate weekStart,
            @Param("weekEnd") LocalDate weekEnd);
}
