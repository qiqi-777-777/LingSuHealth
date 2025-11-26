package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.entity.KnowledgeItem;
import com.lingsu.health.mapper.KnowledgeItemMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
public class KnowledgeService {
    
    @Autowired
    private KnowledgeItemMapper knowledgeItemMapper;
    
    private static final String UPLOAD_DIR = "uploads/knowledge/";
    
    public KnowledgeService() {
        // 创建上传目录
        try {
            Files.createDirectories(Paths.get(UPLOAD_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 搜索知识库
     */
    public List<KnowledgeItem> search(String keyword) {
        QueryWrapper<KnowledgeItem> qw = new QueryWrapper<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            qw.like("name", keyword)
              .or()
              .like("tcm_effect", keyword)
              .or()
              .like("western_nutrition", keyword)
              .or()
              .like("category", keyword);
        }
        return knowledgeItemMapper.selectList(qw);
    }
    
    /**
     * 按分类查询
     */
    public List<KnowledgeItem> findByCategory(String category) {
        QueryWrapper<KnowledgeItem> qw = new QueryWrapper<>();
        qw.eq("category", category);
        return knowledgeItemMapper.selectList(qw);
    }
    
    /**
     * 获取所有分类
     */
    public List<String> getAllCategories() {
        return knowledgeItemMapper.selectObjs(
            new QueryWrapper<KnowledgeItem>()
                .select("DISTINCT category")
                .isNotNull("category")
        ).stream().map(Object::toString).toList();
    }
    
    /**
     * 获取所有知识库条目
     */
    public List<KnowledgeItem> findAll() {
        return knowledgeItemMapper.selectList(null);
    }
    
    /**
     * 根据ID获取
     */
    public KnowledgeItem findById(Long id) {
        return knowledgeItemMapper.selectById(id);
    }
    
    /**
     * 创建知识库条目
     */
    public KnowledgeItem create(KnowledgeItem item) {
        knowledgeItemMapper.insert(item);
        return item;
    }
    
    /**
     * 更新知识库条目
     */
    public KnowledgeItem update(Long id, KnowledgeItem item) {
        item.setId(id);
        knowledgeItemMapper.updateById(item);
        return item;
    }
    
    /**
     * 删除知识库条目
     */
    public void delete(Long id) {
        KnowledgeItem item = knowledgeItemMapper.selectById(id);
        if (item != null && item.getImageUrl() != null) {
            // 删除图片文件
            deleteImageFile(item.getImageUrl());
        }
        knowledgeItemMapper.deleteById(id);
    }
    
    /**
     * 上传图片
     */
    public String uploadImage(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }
        
        // 获取原始文件名和扩展名
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null ? 
            originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
        
        // 生成唯一文件名
        String filename = UUID.randomUUID().toString() + extension;
        
        // 保存文件
        Path filepath = Paths.get(UPLOAD_DIR, filename);
        Files.write(filepath, file.getBytes());
        
        // 返回相对路径
        return "/uploads/knowledge/" + filename;
    }
    
    /**
     * 删除图片文件
     */
    private void deleteImageFile(String imageUrl) {
        try {
            if (imageUrl != null && imageUrl.startsWith("/uploads/knowledge/")) {
                String filename = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
                Path filepath = Paths.get(UPLOAD_DIR, filename);
                Files.deleteIfExists(filepath);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

