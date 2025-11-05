// 此文件已被禁用 - 健康趋势功能已移除
// package com.lingsu.health.mapper;
//
// import com.baomidou.mybatisplus.core.mapper.BaseMapper;
// import com.lingsu.health.entity.HealthTrend;
// import org.apache.ibatis.annotations.Mapper;
// import org.apache.ibatis.annotations.Param;
// import org.apache.ibatis.annotations.Select;
//
// import java.time.LocalDate;
// import java.util.List;
//
// @Mapper
// public interface HealthTrendMapper extends BaseMapper<HealthTrend> {
//     
//     /**
//      * 获取用户最近N天的趋势数据
//      */
//     @Select("SELECT * FROM health_trends WHERE user_id = #{userId} " +
//             "AND trend_date >= #{startDate} ORDER BY trend_date ASC")
//     List<HealthTrend> getRecentTrends(@Param("userId") Long userId, 
//                                      @Param("startDate") LocalDate startDate);
// }