package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.HealthPlan;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface HealthPlanMapper extends BaseMapper<HealthPlan> {

    /**
     * 获取用户当前活跃的计划
     */
    @Select("SELECT * FROM health_plans WHERE user_id = #{userId} AND status = 'active' " +
            "AND start_date <= #{today} AND end_date >= #{today} " +
            "ORDER BY created_at DESC LIMIT 1")
    HealthPlan findActivePlan(@Param("userId") Long userId, @Param("today") LocalDate today);

    /**
     * 获取用户最新的计划
     */
    @Select("SELECT * FROM health_plans WHERE user_id = #{userId} ORDER BY created_at DESC LIMIT 1")
    HealthPlan findLatestPlan(@Param("userId") Long userId);

    /**
     * 获取用户历史计划列表
     */
    @Select("SELECT * FROM health_plans WHERE user_id = #{userId} ORDER BY start_date DESC LIMIT #{limit}")
    List<HealthPlan> findPlanHistory(@Param("userId") Long userId, @Param("limit") int limit);

    /**
     * 更新计划完成任务数
     */
    @Update("UPDATE health_plans SET completed_tasks = " +
            "(SELECT COUNT(*) FROM user_daily_tasks WHERE plan_id = #{planId} AND is_completed = 1), " +
            "updated_at = NOW() WHERE id = #{planId}")
    int updateCompletedTasks(@Param("planId") Long planId);

    /**
     * 标记过期计划为已完成
     */
    @Update("UPDATE health_plans SET status = 'completed', updated_at = NOW() " +
            "WHERE status = 'active' AND end_date < #{today}")
    int markExpiredPlansCompleted(@Param("today") LocalDate today);
}
