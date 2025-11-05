package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
    // 直接使用 BaseMapper 的 CRUD，无需 XML
}