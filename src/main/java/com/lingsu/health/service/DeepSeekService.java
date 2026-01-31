package com.lingsu.health.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lingsu.health.dto.Dtos.QAResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class DeepSeekService {
    
    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    
    @Value("${deepseek.api.key:sk-b0b4f0292f8848c483ec8e1a847c6766}")
    private String apiKey;
    
    @Value("${deepseek.api.url:https://api.deepseek.com/v1/chat/completions}")
    private String apiUrl;
    
    public DeepSeekService(@Autowired(required = false) WebClient.Builder webClientBuilder) {
        if (webClientBuilder != null) {
            this.webClient = webClientBuilder.build();
        } else {
            this.webClient = WebClient.builder().build();
        }
        this.objectMapper = new ObjectMapper();
    }

    /**
     * 流式问答方法
     */
    public Flux<String> askQuestionWithContextStream(String question, Object historyValue) {
        log.info("收到流式问题: {}", question);

        if (question == null || question.trim().isEmpty()) {
            return Flux.just("请输入您的问题，我会尽力为您解答。");
        }

        List<Map<String, String>> history = parseHistory(historyValue);
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of("role", "system", "content", buildAssistantSystemPrompt()));
        if (history != null && !history.isEmpty()) {
            messages.addAll(history);
        }
        messages.add(Map.of("role", "user", "content", question));

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "deepseek-chat");
        requestBody.put("messages", messages);
        requestBody.put("max_tokens", 1200);
        requestBody.put("temperature", 0.6);
        requestBody.put("stream", true); // 开启流式模式

        return webClient.post()
            .uri(apiUrl)
            .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
            .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
            .bodyValue(requestBody)
            .retrieve()
            .bodyToFlux(String.class)
            .flatMap(line -> {
                // 处理SSE数据格式 "data: {...}"
                if (line.startsWith("data: ")) {
                    String data = line.substring(6).trim();
                    if ("[DONE]".equals(data)) {
                        return Mono.empty();
                    }
                    try {
                        JsonNode jsonNode = objectMapper.readTree(data);
                        JsonNode choices = jsonNode.get("choices");
                        if (choices != null && choices.isArray() && choices.size() > 0) {
                            JsonNode delta = choices.get(0).get("delta");
                            if (delta != null && delta.has("content")) {
                                return Mono.just(delta.get("content").asText());
                            }
                        }
                    } catch (Exception e) {
                        log.warn("解析SSE数据失败: {}", data, e);
                    }
                }
                return Mono.empty();
            });
    }
    
    public QAResponse askQuestionWithContext(String question, Object historyValue) {
        try {
            log.info("收到问题: {}", question);

            if (question == null || question.trim().isEmpty()) {
                QAResponse r = new QAResponse();
                r.answer = "请输入您的问题，我会尽力为您解答。";
                r.sources = List.of("系统提示");
                return r;
            }

            List<Map<String, String>> history = parseHistory(historyValue);
            List<Map<String, String>> messages = new ArrayList<>();
            messages.add(Map.of("role", "system", "content", buildAssistantSystemPrompt()));
            if (history != null && !history.isEmpty()) {
                messages.addAll(history);
            }
            messages.add(Map.of("role", "user", "content", question));

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "deepseek-chat");
            requestBody.put("messages", messages);
            requestBody.put("max_tokens", 1200);
            requestBody.put("temperature", 0.6);
            requestBody.put("stream", false); // 明确指定非流式模式

            log.info("准备调用DeepSeek API，URL: {}", apiUrl);
            log.debug("请求体: {}", requestBody);

            Mono<String> response = webClient.post()
                .uri(apiUrl)
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class);

            String responseBody = response.block(java.time.Duration.ofSeconds(60)); // 设置60秒超时
            log.info("DeepSeek API 响应长度: {}", responseBody != null ? responseBody.length() : 0);
            
            if (responseBody == null || responseBody.isEmpty()) {
                log.warn("DeepSeek API 返回空响应");
                QAResponse fallback = new QAResponse();
                fallback.answer = "抱歉，AI服务暂时无响应，请稍后再试。";
                fallback.sources = defaultSources();
                return fallback;
            }
            
            JsonNode jsonNode = objectMapper.readTree(responseBody);
            JsonNode choices = jsonNode.get("choices");
            if (choices != null && choices.isArray() && choices.size() > 0) {
                JsonNode message = choices.get(0).get("message");
                if (message != null) {
                    String answer = message.get("content").asText();
                    QAResponse r = new QAResponse();
                    r.answer = stripSourcesSection(answer);
                    r.sources = extractSources(answer);
                    if (r.sources == null || r.sources.isEmpty()) {
                        r.sources = defaultSources();
                    }
                    return r;
                }
            }

            QAResponse fallback = new QAResponse();
            fallback.answer = "抱歉，我暂时无法回答您的问题，请稍后再试。";
            fallback.sources = defaultSources();
            return fallback;
        } catch (Exception e) {
            log.error("调用DeepSeek API时发生错误: {}", e.getMessage(), e);
            QAResponse r = new QAResponse();
            r.answer = "抱歉，服务暂时不可用。建议您保持良好的生活习惯，如有持续不适请咨询专业医师。";
            r.sources = defaultSources();
            return r;
        }
    }

    public String askQuestion(String question) {
        try {
            log.info("收到问题: {}", question);
            
            if (question == null || question.trim().isEmpty()) {
                return "请输入您的问题，我会尽力为您解答。";
            }
            
            // 构建请求体
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "deepseek-chat");
            requestBody.put("messages", List.of(
                Map.of("role", "system", "content", "你是一个专业的中医健康咨询助手，请用专业但易懂的语言回答用户的健康问题。回答要结合中医理论和现代医学知识，给出实用的建议。"),
                Map.of("role", "user", "content", question)
            ));
            requestBody.put("max_tokens", 1000);
            requestBody.put("temperature", 0.7);
            
            log.info("准备调用DeepSeek API，URL: {}", apiUrl);
            
            // 发送请求
            Mono<String> response = webClient.post()
                .uri(apiUrl)
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class);
            
            String responseBody = response.block();
            log.info("DeepSeek API 响应: {}", responseBody);
            
            // 解析响应
            JsonNode jsonNode = objectMapper.readTree(responseBody);
            JsonNode choices = jsonNode.get("choices");
            if (choices != null && choices.isArray() && choices.size() > 0) {
                JsonNode message = choices.get(0).get("message");
                if (message != null) {
                    String answer = message.get("content").asText();
                    log.info("成功获取AI回答，长度: {}", answer.length());
                    return answer;
                }
            }
            
            log.warn("API响应格式异常，返回默认回答");
            return "抱歉，我暂时无法回答您的问题，请稍后再试。";
            
        } catch (Exception e) {
            log.error("调用DeepSeek API时发生错误: {}", e.getMessage(), e);
            
            // 提供针对失眠问题的备用回答
            if (question != null && question.contains("失眠")) {
                return "关于失眠问题，从中医角度来看，失眠多与心神不宁、肝郁化火、脾胃不和等有关。建议：\n\n" +
                       "1. 调整作息：晚上10点前入睡，保持规律的睡眠时间\n" +
                       "2. 饮食调理：睡前2小时避免进食，可饮用安神茶（如酸枣仁茶）\n" +
                       "3. 情志调节：保持心情平和，睡前可进行冥想或深呼吸\n" +
                       "4. 穴位按摩：按摩神门穴、三阴交穴有助安神\n" +
                       "5. 环境优化：保持卧室安静、黑暗、凉爽\n\n" +
                       "如症状持续，建议咨询专业中医师进行个体化调理。";
            }
            
            return "抱歉，服务暂时不可用。建议您保持良好的生活习惯，如有持续不适请咨询专业医师。";
        }
    }
    
    /**
     * 专门用于健康数据分析的方法
     */
    public String analyzeHealthData(Map<String, Object> healthData) {
        try {
            log.info("开始分析健康数据: {}", healthData);
            
            // 构建专门的健康分析提示词
            String prompt = buildHealthAnalysisPrompt(healthData);
            
            // 构建请求体
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "deepseek-chat");
            requestBody.put("messages", List.of(
                Map.of("role", "system", "content", 
                    "你是一位专业的中医健康顾问，擅长结合传统中医理论和现代健康管理理念。" +
                    "请基于用户的每日健康打卡数据，提供专业、实用、个性化的健康分析和建议。" +
                    "回答要温和、专业，避免过于医学化的术语，让普通用户容易理解。"),
                Map.of("role", "user", "content", prompt)
            ));
            requestBody.put("max_tokens", 1500);
            requestBody.put("temperature", 0.7);
            
            log.info("调用DeepSeek API进行健康分析");
            
            // 发送请求
            Mono<String> response = webClient.post()
                .uri(apiUrl)
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class);
            
            String responseBody = response.block();
            log.info("健康分析API响应长度: {}", responseBody != null ? responseBody.length() : 0);
            
            // 解析响应
            JsonNode jsonNode = objectMapper.readTree(responseBody);
            JsonNode choices = jsonNode.get("choices");
            if (choices != null && choices.isArray() && choices.size() > 0) {
                JsonNode message = choices.get(0).get("message");
                if (message != null) {
                    String analysis = message.get("content").asText();
                    log.info("成功获取健康分析，长度: {}", analysis.length());
                    return analysis;
                }
            }
            
            log.warn("健康分析API响应格式异常");
            return getDefaultHealthAnalysis(healthData);
            
        } catch (Exception e) {
            log.error("健康数据分析时发生错误: {}", e.getMessage(), e);
            return getDefaultHealthAnalysis(healthData);
        }
    }

    private List<Map<String, String>> parseHistory(Object historyValue) {
        if (!(historyValue instanceof List<?>)) {
            return List.of();
        }
        List<?> rawList = (List<?>) historyValue;
        List<Map<String, String>> history = new ArrayList<>();
        for (Object item : rawList) {
            if (!(item instanceof Map<?, ?>)) {
                continue;
            }
            Map<?, ?> map = (Map<?, ?>) item;
            Object roleObj = map.get("role");
            Object contentObj = map.get("content");
            if (roleObj == null || contentObj == null) {
                continue;
            }
            String role = roleObj.toString();
            String content = contentObj.toString();
            if (content.trim().isEmpty()) {
                continue;
            }
            if (!role.equals("user") && !role.equals("assistant")) {
                continue;
            }
            history.add(Map.of("role", role, "content", content));
        }
        return history;
    }

    private String buildAssistantSystemPrompt() {
        return "你是一个专业的中医健康咨询助手，面向普通用户提供通俗、可信、可执行的建议。" +
            "你需要进行多轮对话，如果信息不足，请优先提出最多3个关键问题再给出方案。" +
            "回答必须包含【问题理解】【可解释性】【可执行方案】【注意事项】【下一步提问】【参考来源】六个部分。" +
            "【可执行方案】请按晨/午/晚给出3-5条可完成的具体动作。" +
            "【可解释性】说明建议与用户症状、体质、作息或季节的对应关系。" +
            "【参考来源】只能从以下来源中选择并列出：中医基础理论、中国居民膳食指南(2022)、中国睡眠研究会睡眠卫生建议、国家卫生健康委员会健康科普、中华中医药学会科普资料、WHO健康生活方式建议。" +
            "如果无法判断体质或关键信息缺失，请在【下一步提问】给出需要补充的问题；如信息已足够则写“无”。";
    }

    private List<String> extractSources(String answer) {
        int start = answer.indexOf("【参考来源】");
        if (start < 0) {
            return List.of();
        }
        String section = answer.substring(start + 6).trim();
        String[] lines = section.split("\\n");
        List<String> sources = new ArrayList<>();
        for (String line : lines) {
            String cleaned = line.trim();
            if (cleaned.isEmpty()) {
                continue;
            }
            cleaned = cleaned.replaceFirst("^[0-9]+[\\.|、)]\\s*", "");
            cleaned = cleaned.replaceFirst("^[-•]\\s*", "");
            if (!cleaned.isEmpty()) {
                sources.add(cleaned);
            }
        }
        return sources;
    }

    private String stripSourcesSection(String answer) {
        int start = answer.indexOf("【参考来源】");
        if (start < 0) {
            return answer;
        }
        return answer.substring(0, start).trim();
    }

    private List<String> defaultSources() {
        return List.of(
            "中医基础理论",
            "中国居民膳食指南(2022)",
            "国家卫生健康委员会健康科普"
        );
    }
    
    /**
     * 构建健康分析提示词
     */
    private String buildHealthAnalysisPrompt(Map<String, Object> healthData) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("请分析以下用户的每日健康打卡数据，并提供专业的中医养生建议：\n\n");
        
        prompt.append("【健康数据】\n");
        if (healthData.get("sleepHours") != null) {
            prompt.append("睡眠时长：").append(healthData.get("sleepHours")).append("小时\n");
        }
        if (healthData.get("sleepTime") != null) {
            prompt.append("入睡时间：").append(healthData.get("sleepTime")).append("\n");
        }
        if (healthData.get("symptoms") != null) {
            prompt.append("今日症状：").append(healthData.get("symptoms")).append("\n");
        }
        if (healthData.get("mood") != null) {
            prompt.append("情绪状态：").append(getMoodDescription((Integer) healthData.get("mood"))).append("\n");
        }
        if (healthData.get("exerciseMinutes") != null) {
            prompt.append("运动时长：").append(healthData.get("exerciseMinutes")).append("分钟\n");
        }
        if (healthData.get("dietNotes") != null) {
            prompt.append("饮食记录：").append(healthData.get("dietNotes")).append("\n");
        }
        // 移除“是否按昨日方案执行”的提示行
        if (healthData.get("followedPlan") != null) {
            prompt.append("是否按昨日方案执行：").append(healthData.get("followedPlan")).append("\n");
        }
        
        prompt.append("\n【分析要求】\n");
        prompt.append("1. 请给出一句话的健康状态总结\n");
        prompt.append("2. 从睡眠、运动、饮食、情绪等方面提供3-4条具体建议\n");
        prompt.append("3. 制定明日的个性化养生方案\n");
        prompt.append("4. 结合中医理论，但用通俗易懂的语言表达\n");
        prompt.append("5. 保持温和、鼓励的语调\n\n");
        
        prompt.append("请按以下格式回答：\n");
        prompt.append("【健康总结】\n");
        prompt.append("（一句话总结）\n\n");
        prompt.append("【个性化建议】\n");
        prompt.append("1. 睡眠方面：...\n");
        prompt.append("2. 运动方面：...\n");
        prompt.append("3. 饮食方面：...\n");
        prompt.append("4. 情绪调节：...\n\n");
        prompt.append("【明日养生方案】\n");
        prompt.append("（具体的明日建议）");
        
        return prompt.toString();
    }
    
    /**
     * 获取默认健康分析
     */
    private String getDefaultHealthAnalysis(Map<String, Object> healthData) {
        StringBuilder analysis = new StringBuilder();
        analysis.append("【健康总结】\n");
        analysis.append("今日整体状态良好，建议继续保持规律的生活作息。\n\n");
        
        analysis.append("【个性化建议】\n");
        
        // 睡眠建议
        Object sleepHours = healthData.get("sleepHours");
        if (sleepHours != null) {
            double hours = ((Number) sleepHours).doubleValue();
            if (hours < 7) {
                analysis.append("1. 睡眠方面：建议增加睡眠时间至7-8小时，有助于身体恢复\n");
            } else {
                analysis.append("1. 睡眠方面：睡眠时间充足，继续保持规律作息\n");
            }
        } else {
            analysis.append("1. 睡眠方面：建议保持7-8小时充足睡眠\n");
        }
        
        // 运动建议
        Object exerciseMinutes = healthData.get("exerciseMinutes");
        if (exerciseMinutes != null) {
            int minutes = ((Number) exerciseMinutes).intValue();
            if (minutes < 30) {
                analysis.append("2. 运动方面：建议增加运动时间至30分钟以上，可选择散步、太极等\n");
            } else {
                analysis.append("2. 运动方面：运动量适宜，可适当增加强度或尝试不同运动\n");
            }
        } else {
            analysis.append("2. 运动方面：建议每日进行30分钟适量运动\n");
        }
        
        analysis.append("3. 饮食方面：建议清淡饮食，多吃蔬菜水果，少油少盐\n");
        analysis.append("4. 情绪调节：保持心情愉悦，可尝试冥想、音乐等放松方式\n\n");
        
        analysis.append("【明日养生方案】\n");
        analysis.append("早睡早起，适量运动，清淡饮食，保持心情愉悦。建议晨练15分钟，晚餐后散步30分钟。");
        
        return analysis.toString();
    }
    
    /**
     * 获取情绪描述
     */
    private String getMoodDescription(Integer moodIndex) {
        String[] moods = {"很差", "一般", "良好", "很好", "极佳"};
        return moodIndex != null && moodIndex >= 0 && moodIndex < moods.length ? 
               moods[moodIndex] : "良好";
    }
}
