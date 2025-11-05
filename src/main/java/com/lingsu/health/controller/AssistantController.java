package com.lingsu.health.controller;

import com.lingsu.health.dto.Dtos.QAResponse;
import com.lingsu.health.service.DeepSeekService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/assistant")
@RequiredArgsConstructor
public class AssistantController {
    
    private final DeepSeekService deepSeekService;
    
    @PostMapping("/ask")
    public QAResponse ask(@RequestBody Map<String, String> request) {
        try {
            String question = request.get("q");
            if (question == null || question.trim().isEmpty()) {
                QAResponse r = new QAResponse();
                r.answer = "请输入您的问题。";
                r.sources = List.of("系统提示");
                return r;
            }
            
            log.info("收到问题: {}", question);
            
            // 调用DeepSeek API获取回答
            String answer = deepSeekService.askQuestion(question);
            
            QAResponse r = new QAResponse();
            r.answer = answer;
            r.sources = List.of("中医健康知识库");
            
            return r;
            
        } catch (Exception e) {
            log.error("处理问答请求失败", e);
            QAResponse r = new QAResponse();
            r.answer = "系统繁忙，请稍后再试。";
            r.sources = List.of("系统错误");
            return r;
        }
    }
}