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
    public QAResponse ask(@RequestBody Map<String, Object> request) {
        try {
            Object qValue = request.get("q");
            String question = qValue == null ? null : qValue.toString();
            if (question == null || question.trim().isEmpty()) {
                QAResponse r = new QAResponse();
                r.answer = "请输入您的问题。";
                r.sources = List.of("系统提示");
                return r;
            }
            
            log.info("收到问题: {}", question);
            
            Object historyValue = request.get("history");
            QAResponse response = deepSeekService.askQuestionWithContext(question, historyValue);
            if (response == null || response.answer == null || response.answer.trim().isEmpty()) {
                QAResponse r = new QAResponse();
                r.answer = "抱歉，我暂时无法回答您的问题，请稍后再试。";
                r.sources = List.of("系统提示");
                return r;
            }
            return response;
            
        } catch (Exception e) {
            log.error("处理问答请求失败", e);
            QAResponse r = new QAResponse();
            r.answer = "系统繁忙，请稍后再试。";
            r.sources = List.of("系统错误");
            return r;
        }
    }
    
    @PostMapping("/quick-consult")
    public Map<String, String> quickConsult(@RequestBody Map<String, String> request) {
        try {
            String query = request.get("query");
            if (query == null || query.trim().isEmpty()) {
                return Map.of("advice", "请输入您的症状描述。");
            }
            
            log.info("快速咨询: {}", query);
            
            // 构建专门的快速咨询提示词
            String prompt = String.format(
                "用户症状：%s\n\n" +
                "请作为中医养生专家，用一句话（不超过30字）给出简洁的养生建议。" +
                "格式：建议您[具体建议]。" +
                "注意：只给建议，不要解释原因。",
                query
            );
            
            QAResponse response = deepSeekService.askQuestionWithContext(prompt, null);
            
            if (response != null && response.answer != null && !response.answer.trim().isEmpty()) {
                // 提取建议内容，限制长度
                String advice = response.answer.trim();
                if (advice.length() > 50) {
                    advice = advice.substring(0, 50) + "...";
                }
                return Map.of("advice", advice);
            } else {
                return Map.of("advice", "建议您注意休息，保持良好作息。如症状持续，请及时就医。");
            }
            
        } catch (Exception e) {
            log.error("快速咨询失败", e);
            return Map.of("advice", "系统繁忙，请稍后再试。");
        }
    }
}
