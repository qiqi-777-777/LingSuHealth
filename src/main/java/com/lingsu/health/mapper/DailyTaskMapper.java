package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.DailyTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface DailyTaskMapper extends BaseMapper<DailyTask> {

    /**
     * 获取用户指定日期的任务
     */
    @Select("SELECT * FROM user_daily_tasks WHERE user_id = #{userId} AND task_date = #{date} ORDER BY priority DESC, id")
    List<DailyTask> findByUserAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    /**
     * 获取用户最近N天的任务
     */
    @Select("SELECT * FROM user_daily_tasks WHERE user_id = #{userId} AND task_date >= #{startDate} ORDER BY task_date DESC, priority DESC")
    List<DailyTask> findRecentTasks(@Param("userId") Long userId, @Param("startDate") LocalDate startDate);

    /**
     * 标记任务完成
     */
    @Update("UPDATE user_daily_tasks SET is_completed = 1, actual_value = target_value, updated_at = NOW() WHERE id = #{taskId} AND user_id = #{userId}")
    int markComplete(@Param("taskId") Long taskId, @Param("userId") Long userId);

    /**
     * 取消任务完成
     */
    @Update("UPDATE user_daily_tasks SET is_completed = 0, actual_value = 0, updated_at = NOW() WHERE id = #{taskId} AND user_id = #{userId}")
    int markIncomplete(@Param("taskId") Long taskId, @Param("userId") Long userId);

    /**
     * 统计用户某日期范围内的完成情况
     */
    @Select("SELECT COUNT(*) FROM user_daily_tasks WHERE user_id = #{userId} AND task_date BETWEEN #{startDate} AND #{endDate} AND is_completed = 1")
    int countCompletedInRange(@Param("userId") Long userId, @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    /**
     * 统计用户某日期范围内的总任务数
     */
    @Select("SELECT COUNT(*) FROM user_daily_tasks WHERE user_id = #{userId} AND task_date BETWEEN #{startDate} AND #{endDate}")
    int countTotalInRange(@Param("userId") Long userId, @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
