package com.lingsu.health.service;

import com.lingsu.health.entity.IngredientInteraction;
import com.lingsu.health.mapper.IngredientInteractionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IngredientInteractionService {
    
    @Autowired
    private IngredientInteractionMapper interactionMapper;
    
    /**
     * 获取所有相生相克关系
     */
    public List<IngredientInteraction> findAll() {
        return interactionMapper.selectList(null);
    }
    
    /**
     * 根据食材/药材ID查询相关的相生相克关系
     */
    public List<IngredientInteraction> findByItemId(Long itemId) {
        return interactionMapper.findByItemId(itemId);
    }
    
    /**
     * 根据食材/药材名称查询相关的相生相克关系
     */
    public List<IngredientInteraction> findByItemName(String itemName) {
        return interactionMapper.findByItemName(itemName);
    }
    
    /**
     * 根据ID获取详情
     */
    public IngredientInteraction findById(Long id) {
        return interactionMapper.selectById(id);
    }
}
