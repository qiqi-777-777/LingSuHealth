package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.KnowledgeTag;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface KnowledgeTagMapper extends BaseMapper<KnowledgeTag> {

    /**
     * 获取所有启用的标签，按优先级排序
     */
    @Select("SELECT * FROM knowledge_tags WHERE is_enabled = 1 ORDER BY dimension, priority DESC, id")
    List<KnowledgeTag> findAllEnabled();

    /**
     * 按维度获取启用的标签
     */
    @Select("SELECT * FROM knowledge_tags WHERE dimension = #{dimension} AND is_enabled = 1 ORDER BY priority DESC, id")
    List<KnowledgeTag> findByDimension(@Param("dimension") String dimension);
}
