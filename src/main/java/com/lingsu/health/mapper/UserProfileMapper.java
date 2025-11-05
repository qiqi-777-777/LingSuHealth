package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.UserProfile;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户资料 Mapper 接口
 */
@Mapper
public interface UserProfileMapper extends BaseMapper<UserProfile> {
    // MyBatis Plus 提供了基础的 CRUD 操作，无需额外定义
}