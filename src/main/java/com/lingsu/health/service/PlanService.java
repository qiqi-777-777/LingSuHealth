package com.lingsu.health.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lingsu.health.dto.Dtos.PlanItem;
import com.lingsu.health.entity.AssessmentRecord;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.AssessmentRecordMapper;
import com.lingsu.health.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PlanService {

    private final AssessmentRecordMapper assessmentRecordMapper;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;
    private final DeepSeekService deepSeekService;
    private final com.lingsu.health.mapper.HealthCheckinMapper healthCheckinMapper;

    /**
     * 根据用户名获取个性化养生方案
     */
    public Map<String, Object> generatePersonalizedPlan(String username) {
        // 获取用户
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (user == null) {
            return Map.of(
                "hasAssessment", false,
                "message", "用户不存在"
            );
        }

        // 获取最新的测评记录
        AssessmentRecord latestRecord = assessmentRecordMapper.selectOne(
            new QueryWrapper<AssessmentRecord>()
                .eq("user_id", user.getId())
                .orderByDesc("created_at")
                .last("LIMIT 1")
        );

        if (latestRecord == null) {
            return Map.of(
                "hasAssessment", false,
                "message", "未找到体质测评记录"
            );
        }

        // 解析测评答案
        String constitution = analyzeConstitutionFromRecord(latestRecord);
        
        // 生成个性化方案
        List<PlanItem> items = generatePlanItems(constitution);

        return Map.of(
            "hasAssessment", true,
            "constitution", constitution,
            "items", items
        );
    }

    /**
     * 从测评记录中分析体质类型
     */
    private String analyzeConstitutionFromRecord(AssessmentRecord record) {
        try {
            String answersJson = record.getAnswersJson();
            List<Map<String, Object>> answers = objectMapper.readValue(
                answersJson, 
                new TypeReference<List<Map<String, Object>>>() {}
            );

            // 统计各种体质倾向的得分
            int[] scores = new int[9]; // 9种体质类型

            for (Map<String, Object> answer : answers) {
                Integer questionIndex = (Integer) answer.get("questionIndex");
                Integer answerIndex = (Integer) answer.get("answerIndex");

                if (questionIndex != null && answerIndex != null) {
                    calculateConstitutionScore(questionIndex, answerIndex, scores);
                }
            }

            // 找出得分最高的体质类型
            String[] constitutionTypes = {
                "平和质", "气虚质", "阳虚质", "阴虚质",
                "痰湿质", "湿热质", "血瘀质", "气郁质", "特禀质"
            };

            int maxScore = 0;
            int maxIndex = 0;
            for (int i = 0; i < scores.length; i++) {
                if (scores[i] > maxScore) {
                    maxScore = scores[i];
                    maxIndex = i;
                }
            }

            return constitutionTypes[maxIndex];
        } catch (Exception e) {
            return "平和质"; // 默认返回平和质
        }
    }

    /**
     * 计算体质得分（与 AssessmentController 保持一致）
     */
    private void calculateConstitutionScore(int questionIndex, int answerIndex, int[] scores) {
        switch (questionIndex) {
            case 0: // 体型
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[1] += 2;
                else if (answerIndex == 2) scores[4] += 2;
                else if (answerIndex == 3) scores[0] += 1;
                break;
            case 1: // 睡眠质量
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[7] += 1;
                else if (answerIndex == 2) scores[3] += 2;
                else if (answerIndex == 3) scores[1] += 1;
                break;
            case 2: // 精力状态
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[1] += 1;
                else if (answerIndex == 2) scores[1] += 2;
                else if (answerIndex == 3) scores[4] += 1;
                break;
            case 3: // 排便
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[4] += 1;
                else if (answerIndex == 2) scores[5] += 1;
                else if (answerIndex == 3) scores[7] += 1;
                break;
            case 4: // 饮食习惯
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[5] += 1;
                else if (answerIndex == 2) scores[7] += 1;
                else if (answerIndex == 3) scores[4] += 1;
                break;
            case 5: // 运动
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[1] += 1;
                else if (answerIndex == 2) scores[1] += 2;
                break;
            case 6: // 情绪
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[7] += 1;
                else if (answerIndex == 2) scores[7] += 2;
                else if (answerIndex == 3) scores[7] += 2;
                break;
            case 7: // 不适症状（多选题）
                if (answerIndex == 0) scores[6] += 1; // 肩颈僵硬-血瘀
                else if (answerIndex == 1) scores[1] += 1; // 腰酸背痛-气虚
                else if (answerIndex == 2) scores[2] += 1; // 手脚冰凉-阳虚
                else if (answerIndex == 3) scores[3] += 1; // 口渴口干-阴虚
                else if (answerIndex == 4) scores[0] += 1; // 都没有-平和
                break;
            case 8: // 健康目标
            case 9: // 方式偏好
                // 这两题不直接影响体质判定
                break;
        }
    }

    /**
     * 根据体质类型生成个性化方案
     */
    private List<PlanItem> generatePlanItems(String constitution) {
        List<PlanItem> items = new ArrayList<>();

        switch (constitution) {
            case "平和质":
                items.add(createPlanItem("饮食建议", "均衡膳食", 
                    "保持三餐规律，多食五谷杂粮、新鲜蔬果。推荐：小米粥、山药、莲子、红枣等性味平和的食物。"));
                items.add(createPlanItem("运动方案", "适度运动", 
                    "每周3-5次，每次30-45分钟。推荐：慢跑、游泳、太极拳、瑜伽等有氧运动。"));
                items.add(createPlanItem("作息调理", "规律作息", 
                    "晚上11点前入睡，保证7-8小时睡眠。早睡早起，顺应自然节律。"));
                items.add(createPlanItem("情绪管理", "保持愉悦", 
                    "培养兴趣爱好，保持积极乐观的心态。可以尝试冥想、听音乐等放松方式。"));
                items.add(createPlanItem("茶饮推荐", "玫瑰花茶", 
                    "每日一杯玫瑰花茶，疏肝理气，保持心情舒畅。"));
                break;

            case "气虚质":
                items.add(createPlanItem("饮食建议", "补气健脾", 
                    "多食补气食物：人参、黄芪、山药、大枣、鸡肉、牛肉。避免生冷、油腻食物。"));
                items.add(createPlanItem("运动方案", "轻柔运动", 
                    "避免剧烈运动，推荐：散步、八段锦、太极拳，每次20-30分钟。"));
                items.add(createPlanItem("作息调理", "充足睡眠", 
                    "保证充足睡眠，每天8-9小时。午休30分钟。避免熬夜和过度劳累。"));
                items.add(createPlanItem("情绪管理", "减压放松", 
                    "避免过度思虑，保持心态平和。可进行深呼吸练习。"));
                items.add(createPlanItem("茶饮推荐", "黄芪红枣茶", 
                    "黄芪10g、红枣5颗泡水，每日一杯，补气养血。"));
                items.add(createPlanItem("穴位按摩", "足三里穴", 
                    "每天按摩足三里穴3-5分钟，增强体质，补益气血。"));
                break;

            case "阳虚质":
                items.add(createPlanItem("饮食建议", "温阳散寒", 
                    "多食温热食物：羊肉、生姜、韭菜、核桃、肉桂。避免生冷寒凉食物。"));
                items.add(createPlanItem("运动方案", "温和运动", 
                    "选择阳光充足时运动，推荐：慢跑、快走、广场舞，每次30分钟。"));
                items.add(createPlanItem("作息调理", "保暖充足", 
                    "注重保暖，特别是腹部、腰部、足部。睡前泡脚15-20分钟。"));
                items.add(createPlanItem("情绪管理", "积极乐观", 
                    "多晒太阳，保持积极心态。避免长时间待在阴冷环境。"));
                items.add(createPlanItem("茶饮推荐", "生姜红糖茶", 
                    "生姜3片、红糖适量泡水，每日早晨一杯，温阳散寒。"));
                items.add(createPlanItem("穴位按摩", "关元穴", 
                    "每天按摩关元穴（脐下三寸）5-10分钟，温补肾阳。"));
                break;

            case "阴虚质":
                items.add(createPlanItem("饮食建议", "滋阴润燥", 
                    "多食滋阴食物：银耳、百合、枸杞、梨、莲藕、鸭肉。避免辛辣燥热。"));
                items.add(createPlanItem("运动方案", "静态运动", 
                    "推荐：瑜伽、太极拳、慢走，避免剧烈运动。傍晚运动为佳。"));
                items.add(createPlanItem("作息调理", "滋阴养心", 
                    "晚上10点前入睡，午休30-60分钟。保持室内湿度适宜。"));
                items.add(createPlanItem("情绪管理", "静心安神", 
                    "避免急躁易怒，可练习冥想、听轻音乐。睡前喝温牛奶。"));
                items.add(createPlanItem("茶饮推荐", "枸杞菊花茶", 
                    "枸杞10g、菊花5朵泡水，每日一杯，滋阴明目。"));
                items.add(createPlanItem("穴位按摩", "三阴交穴", 
                    "每天按摩三阴交穴5分钟，滋阴养血。"));
                break;

            case "痰湿质":
                items.add(createPlanItem("饮食建议", "健脾化湿", 
                    "清淡饮食，多食：薏米、冬瓜、白萝卜、山楂、陈皮。避免油腻甜腻。"));
                items.add(createPlanItem("运动方案", "增加运动", 
                    "加大运动量，每周4-5次，每次40-60分钟。推荐：快走、跑步、游泳。"));
                items.add(createPlanItem("作息调理", "早睡早起", 
                    "避免久坐，保持环境干燥通风。晚饭后散步30分钟。"));
                items.add(createPlanItem("情绪管理", "保持活跃", 
                    "多参加社交活动，保持心情愉快。避免长时间卧床。"));
                items.add(createPlanItem("茶饮推荐", "薏米茶", 
                    "炒薏米15g泡水，每日一杯，健脾祛湿。"));
                items.add(createPlanItem("注意事项", "控制体重", 
                    "定期监测体重，合理控制饮食，增加运动消耗。"));
                break;

            case "湿热质":
                items.add(createPlanItem("饮食建议", "清热利湿", 
                    "清淡饮食，多食：绿豆、苦瓜、茯苓、薏米、冬瓜。避免辛辣油炸烧烤。"));
                items.add(createPlanItem("运动方案", "适量运动", 
                    "选择凉爽时段运动，推荐：游泳、快走，每次30-40分钟。"));
                items.add(createPlanItem("作息调理", "清热安神", 
                    "保持大便通畅，多饮水。避免熬夜，保持环境清凉。"));
                items.add(createPlanItem("情绪管理", "心平气和", 
                    "避免烦躁易怒，保持心态平和。可进行冥想练习。"));
                items.add(createPlanItem("茶饮推荐", "绿豆菊花茶", 
                    "绿豆20g煮水，加菊花5朵，每日一杯，清热解毒。"));
                items.add(createPlanItem("注意事项", "保持清洁", 
                    "注意个人卫生，勤洗澡，保持皮肤清洁干燥。"));
                break;

            case "血瘀质":
                items.add(createPlanItem("饮食建议", "活血化瘀", 
                    "多食：山楂、黑豆、黑木耳、红花、藏红花、醋。避免寒凉食物。"));
                items.add(createPlanItem("运动方案", "有氧运动", 
                    "加强运动促进血液循环，推荐：慢跑、游泳、舞蹈，每次30-40分钟。"));
                items.add(createPlanItem("作息调理", "保暖通畅", 
                    "注意保暖，避免受寒。保持心情舒畅，气血流通。"));
                items.add(createPlanItem("情绪管理", "舒畅气血", 
                    "保持乐观开朗，避免郁闷。多与人交流，参加集体活动。"));
                items.add(createPlanItem("茶饮推荐", "山楂红花茶", 
                    "山楂10g、红花3g泡水，每日一杯，活血化瘀。"));
                items.add(createPlanItem("穴位按摩", "血海穴", 
                    "每天按摩血海穴5分钟，促进血液循环。"));
                break;

            case "气郁质":
                items.add(createPlanItem("饮食建议", "疏肝解郁", 
                    "多食：柑橘、玫瑰花、茉莉花、金橘、佛手。避免油腻难消化食物。"));
                items.add(createPlanItem("运动方案", "舒缓运动", 
                    "推荐：瑜伽、太极拳、慢跑、爬山，释放压力，每次30-40分钟。"));
                items.add(createPlanItem("作息调理", "规律作息", 
                    "保证充足睡眠，睡前听轻音乐或冥想。避免熬夜。"));
                items.add(createPlanItem("情绪管理", "疏导情绪", 
                    "多与朋友交流，培养兴趣爱好。可练习深呼吸、冥想。"));
                items.add(createPlanItem("茶饮推荐", "玫瑰花茶", 
                    "玫瑰花5-8朵泡水，每日2-3杯，疏肝解郁，理气和血。"));
                items.add(createPlanItem("穴位按摩", "太冲穴", 
                    "每天按摩太冲穴（足背第一、二趾缝后方）5分钟，疏肝理气。"));
                break;

            case "特禀质":
                items.add(createPlanItem("饮食建议", "益气固表", 
                    "清淡饮食，多食：黄芪、防风、白术、灵芝。避免易过敏食物。"));
                items.add(createPlanItem("运动方案", "增强体质", 
                    "适度运动增强免疫力，推荐：慢跑、游泳、太极拳，每次30分钟。"));
                items.add(createPlanItem("作息调理", "规律生活", 
                    "保证充足睡眠，增强抵抗力。避免接触过敏原。"));
                items.add(createPlanItem("情绪管理", "保持平和", 
                    "保持心情愉快，避免过度紧张。可进行放松训练。"));
                items.add(createPlanItem("茶饮推荐", "黄芪茶", 
                    "黄芪10g泡水，每日一杯，益气固表，增强免疫力。"));
                items.add(createPlanItem("注意事项", "远离过敏原", 
                    "注意环境卫生，避免接触花粉、尘螨等过敏原。"));
                break;

            default:
                items.add(createPlanItem("饮食建议", "均衡饮食", "保持饮食均衡，多样化摄入营养。"));
                items.add(createPlanItem("运动方案", "适量运动", "每周3-5次，每次30分钟以上的有氧运动。"));
                items.add(createPlanItem("作息调理", "规律作息", "保证充足睡眠，早睡早起。"));
        }

        return items;
    }

    private PlanItem createPlanItem(String category, String title, String detail) {
        PlanItem item = new PlanItem();
        item.category = category;
        item.title = title;
        item.detail = detail;
        return item;
    }
    
    /**
     * AI动态生成个性化方案
     */
    public Map<String, Object> generateAIDynamicPlan(String username) {
        try {
            // 获取用户
            User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
            if (user == null) {
                return Map.of(
                    "success", false,
                    "message", "用户不存在"
                );
            }

            // 获取用户最近7天的打卡记录
            List<com.lingsu.health.entity.HealthCheckin> recentCheckins = healthCheckinMapper.selectList(
                new QueryWrapper<com.lingsu.health.entity.HealthCheckin>()
                    .eq("user_id", user.getId())
                    .orderByDesc("checkin_date")
                    .last("LIMIT 7")
            );

            if (recentCheckins.isEmpty()) {
                return Map.of(
                    "success", false,
                    "message", "暂无打卡记录，请先完成每日健康打卡"
                );
            }

            // 获取最新的测评记录（用于体质信息）
            AssessmentRecord latestRecord = assessmentRecordMapper.selectOne(
                new QueryWrapper<AssessmentRecord>()
                    .eq("user_id", user.getId())
                    .orderByDesc("created_at")
                    .last("LIMIT 1")
            );

            String constitution = latestRecord != null ? 
                analyzeConstitutionFromRecord(latestRecord) : "未测评";

            // 构建健康数据摘要
            Map<String, Object> healthSummary = buildHealthSummary(recentCheckins, constitution);

            // 调用AI生成个性化方案
            String aiAnalysis = deepSeekService.analyzeHealthData(healthSummary);

            // 解析AI返回的方案
            List<PlanItem> items = parseAIAnalysisToItems(aiAnalysis);

            return Map.of(
                "success", true,
                "constitution", constitution,
                "aiAnalysis", aiAnalysis,
                "items", items,
                "checkinDays", recentCheckins.size()
            );

        } catch (Exception e) {
            log.error("AI动态生成方案失败: {}", e.getMessage(), e);
            return Map.of(
                "success", false,
                "message", "生成方案失败: " + e.getMessage()
            );
        }
    }

    /**
     * 构建健康数据摘要
     */
    private Map<String, Object> buildHealthSummary(
        List<com.lingsu.health.entity.HealthCheckin> checkins,
        String constitution
    ) {
        Map<String, Object> summary = new HashMap<>();
        
        // 最新一次打卡数据
        com.lingsu.health.entity.HealthCheckin latest = checkins.get(0);
        summary.put("sleepHours", latest.getSleepHours());
        summary.put("sleepTime", latest.getSleepTime());
        summary.put("symptoms", latest.getSymptoms());
        summary.put("mood", latest.getMood());
        summary.put("exerciseMinutes", latest.getExerciseMinutes());
        summary.put("dietNotes", latest.getDietNotes());
        summary.put("constitution", constitution);
        
        // 计算平均值
        double avgSleep = checkins.stream()
            .filter(c -> c.getSleepHours() != null)
            .mapToDouble(c -> c.getSleepHours().doubleValue())
            .average()
            .orElse(0.0);
        
        double avgExercise = checkins.stream()
            .filter(c -> c.getExerciseMinutes() != null)
            .mapToDouble(c -> c.getExerciseMinutes().doubleValue())
            .average()
            .orElse(0.0);
        
        summary.put("avgSleepHours", String.format("%.1f", avgSleep));
        summary.put("avgExerciseMinutes", String.format("%.0f", avgExercise));
        summary.put("checkinDays", checkins.size());
        
        return summary;
    }

    /**
     * 解析AI分析结果为方案项
     */
    private List<PlanItem> parseAIAnalysisToItems(String aiAnalysis) {
        List<PlanItem> items = new ArrayList<>();
        
        try {
            // 提取健康总结
            String summary = extractSection(aiAnalysis, "【健康总结】", "【个性化建议】");
            if (summary != null && !summary.trim().isEmpty()) {
                items.add(createPlanItem("健康总结", "今日状态", summary.trim()));
            }
            
            // 提取个性化建议
            String suggestions = extractSection(aiAnalysis, "【个性化建议】", "【明日养生方案】");
            if (suggestions != null) {
                String[] lines = suggestions.split("\\n");
                for (String line : lines) {
                    line = line.trim();
                    if (line.isEmpty() || !line.matches("^\\d+\\..*")) {
                        continue;
                    }
                    
                    // 解析建议项
                    String[] parts = line.split("：", 2);
                    if (parts.length == 2) {
                        String category = parts[0].replaceFirst("^\\d+\\.\\s*", "").trim();
                        String detail = parts[1].trim();
                        items.add(createPlanItem("个性化建议", category, detail));
                    }
                }
            }
            
            // 提取明日方案
            String tomorrowPlan = extractSection(aiAnalysis, "【明日养生方案】", null);
            if (tomorrowPlan != null && !tomorrowPlan.trim().isEmpty()) {
                items.add(createPlanItem("明日方案", "养生计划", tomorrowPlan.trim()));
            }
            
        } catch (Exception e) {
            log.error("解析AI分析结果失败: {}", e.getMessage());
            // 如果解析失败，返回原始分析文本
            items.add(createPlanItem("AI分析", "健康建议", aiAnalysis));
        }
        
        return items;
    }

    /**
     * 提取文本中的特定章节
     */
    private String extractSection(String text, String startMarker, String endMarker) {
        int start = text.indexOf(startMarker);
        if (start < 0) {
            return null;
        }
        
        start += startMarker.length();
        
        int end = endMarker != null ? text.indexOf(endMarker, start) : text.length();
        if (end < 0) {
            end = text.length();
        }
        
        return text.substring(start, end).trim();
    }
}

