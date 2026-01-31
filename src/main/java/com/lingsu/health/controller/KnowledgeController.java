package com.lingsu.health.controller;

import com.lingsu.health.entity.IngredientInteraction;
import com.lingsu.health.entity.KnowledgeItem;
import com.lingsu.health.service.IngredientInteractionService;
import com.lingsu.health.service.KnowledgeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/knowledge")
public class KnowledgeController {
    
    @Autowired
    private KnowledgeService knowledgeService;
    
    @Autowired
    private IngredientInteractionService interactionService;
    
    /**
     * 搜索知识库
     */
    @GetMapping("/search")
    public List<KnowledgeItem> search(@RequestParam(required = false) String keyword) {
        return knowledgeService.search(keyword);
    }
    
    /**
     * 获取所有知识库条目
     */
    @GetMapping("/all")
    public List<KnowledgeItem> findAll() {
        return knowledgeService.findAll();
    }
    
    /**
     * 按分类查询
     */
    @GetMapping("/category/{category}")
    public List<KnowledgeItem> findByCategory(@PathVariable String category) {
        return knowledgeService.findByCategory(category);
    }
    
    /**
     * 获取所有分类
     */
    @GetMapping("/categories")
    public List<String> getCategories() {
        return knowledgeService.getAllCategories();
    }
    
    /**
     * 根据ID获取
     */
    @GetMapping("/{id}")
    public ResponseEntity<KnowledgeItem> findById(@PathVariable Long id) {
        KnowledgeItem item = knowledgeService.findById(id);
        if (item == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(item);
    }
    
    /**
     * 创建知识库条目
     */
    @PostMapping
    public KnowledgeItem create(@RequestBody KnowledgeItem item) {
        return knowledgeService.create(item);
    }
    
    /**
     * 更新知识库条目
     */
    @PutMapping("/{id}")
    public KnowledgeItem update(@PathVariable Long id, @RequestBody KnowledgeItem item) {
        return knowledgeService.update(id, item);
    }
    
    /**
     * 删除知识库条目
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        knowledgeService.delete(id);
        return ResponseEntity.ok().build();
    }
    
    /**
     * 上传图片
     */
    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            String imageUrl = knowledgeService.uploadImage(file);
            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", imageUrl);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 获取所有相生相克关系
     */
    @GetMapping("/interactions")
    public List<IngredientInteraction> getAllInteractions() {
        return interactionService.findAll();
    }
    
    /**
     * 根据食材/药材ID查询相关的相生相克关系
     */
    @GetMapping("/interactions/item/{itemId}")
    public List<IngredientInteraction> getInteractionsByItemId(@PathVariable Long itemId) {
        return interactionService.findByItemId(itemId);
    }
    
    /**
     * 根据食材/药材名称查询相关的相生相克关系
     */
    @GetMapping("/interactions/name/{itemName}")
    public List<IngredientInteraction> getInteractionsByItemName(@PathVariable String itemName) {
        return interactionService.findByItemName(itemName);
    }
}