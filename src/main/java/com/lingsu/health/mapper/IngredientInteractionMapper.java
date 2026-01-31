package com.lingsu.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lingsu.health.entity.IngredientInteraction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface IngredientInteractionMapper extends BaseMapper<IngredientInteraction> {
    
    /**
     * 根据食材/药材ID查询相关的相生相克关系
     */
    @Select("SELECT * FROM ingredient_interactions " +
            "WHERE item1_id = #{itemId} OR item2_id = #{itemId}")
    List<IngredientInteraction> findByItemId(@Param("itemId") Long itemId);
    
    /**
     * 根据食材/药材名称查询相关的相生相克关系
     */
    @Select("SELECT * FROM ingredient_interactions " +
            "WHERE item1_name = #{itemName} OR item2_name = #{itemName}")
    List<IngredientInteraction> findByItemName(@Param("itemName") String itemName);
}
