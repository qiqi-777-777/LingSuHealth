package com.lingsu.health.controller;

import com.lingsu.health.dto.Dtos.AssessmentReport;
import com.lingsu.health.entity.AssessmentRecord;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.AssessmentRecordMapper;
import com.lingsu.health.mapper.UserMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/assessment")
@RequiredArgsConstructor
public class AssessmentController {

    private final AssessmentRecordMapper assessmentRecordMapper;
    private final UserMapper userMapper;

    @PostMapping("/report")
    public AssessmentReport generateReport(@RequestBody Map<String, Object> requestData,
                                           HttpServletRequest request) {
        AssessmentReport report = new AssessmentReport();

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> answers = (List<Map<String, Object>>) requestData.get("answers");
        if (answers == null || answers.isEmpty()) {
            report.constitution = "平和质";
            report.summary = "未提供足够的信息进行体质分析，建议完成完整的体质测评。";
            return report;
        }

        // 入库：保存本次测评答案（JSON）
        Long userId = getCurrentUserId(request);
        if (userId != null) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                AssessmentRecord rec = new AssessmentRecord();
                rec.setUserId(userId);
                rec.setAnswersJson(mapper.writeValueAsString(answers));
                rec.setCreatedAt(LocalDateTime.now());
                rec.setUpdatedAt(LocalDateTime.now());
                assessmentRecordMapper.insert(rec);
            } catch (Exception e) {
                // 持久化失败不影响报告生成
            }
        }

        // 体质分析与总结
        String constitution = analyzeConstitution(answers);
        report.constitution = constitution;
        report.summary = generateSummary(constitution, answers);
        return report;
    }

    private Long getCurrentUserId(HttpServletRequest request) {
        try {
            String username = request.getHeader("X-Username");
            if (username == null || username.trim().isEmpty()) return null;
            User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", username.trim()));
            return user != null ? user.getId() : null;
        } catch (Exception e) {
            return null;
        }
    }
    
    private String analyzeConstitution(List<Map<String, Object>> answers) {
        // 统计各种体质倾向的得分
        int[] scores = new int[9]; // 9种体质类型
        
        for (Map<String, Object> answer : answers) {
            Integer questionIndex = (Integer) answer.get("questionIndex");
            Integer answerIndex = (Integer) answer.get("answerIndex");
            
            if (questionIndex != null && answerIndex != null) {
                // 根据问题和答案计算体质得分
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
    }
    
    private void calculateConstitutionScore(int questionIndex, int answerIndex, int[] scores) {
        // 简化的体质评分逻辑
        switch (questionIndex) {
            case 0: // 体型
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[4] += 2; // 痰湿质
                else if (answerIndex == 2) scores[1] += 2; // 气虚质
                else if (answerIndex == 3) scores[0] += 1; // 平和质
                break;
            case 1: // 面色
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[4] += 1; // 痰湿质
                else if (answerIndex == 2) scores[1] += 1; // 气虚质
                else if (answerIndex == 3) scores[6] += 1; // 血瘀质
                break;
            case 2: // 舌质
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[1] += 2; // 气虚质
                else if (answerIndex == 2) scores[3] += 2; // 阴虚质
                else if (answerIndex == 3) scores[6] += 1; // 血瘀质
                break;
            case 3: // 舌苔
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[4] += 2; // 痰湿质
                else if (answerIndex == 2) scores[3] += 1; // 阴虚质
                else if (answerIndex == 3) scores[5] += 2; // 湿热质
                break;
            case 4: // 口味偏好
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[3] += 1; // 阴虚质
                else if (answerIndex == 2) scores[4] += 1; // 痰湿质
                else if (answerIndex == 3) scores[4] += 1; // 痰湿质
                break;
            case 5: // 体温感受
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[2] += 2; // 阳虚质
                else if (answerIndex == 2) scores[3] += 2; // 阴虚质
                else if (answerIndex == 3) scores[7] += 1; // 气郁质
                break;
            case 6: // 睡眠质量
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[3] += 1; // 阴虚质
                else if (answerIndex == 2) scores[7] += 2; // 气郁质
                else if (answerIndex == 3) scores[3] += 2; // 阴虚质
                break;
            case 7: // 大便情况
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[3] += 1; // 阴虚质
                else if (answerIndex == 2) scores[4] += 1; // 痰湿质
                else if (answerIndex == 3) scores[5] += 2; // 湿热质
                break;
            case 8: // 小便情况
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[5] += 2; // 湿热质
                else if (answerIndex == 2) scores[2] += 1; // 阳虚质
                else if (answerIndex == 3) scores[3] += 1; // 阴虚质
                break;
            case 9: // 精力状态
                if (answerIndex == 0) scores[0] += 2; // 平和质
                else if (answerIndex == 1) scores[1] += 2; // 气虚质
                else if (answerIndex == 2) scores[1] += 2; // 气虚质
                else if (answerIndex == 3) scores[4] += 1; // 痰湿质
                break;
        }
    }
    
    private String generateSummary(String constitution, List<Map<String, Object>> answers) {
        switch (constitution) {
            case "平和质":
                return "您的体质相对平和，阴阳气血调和，脏腑功能正常。建议保持规律作息，均衡饮食，适量运动，保持心情愉悦。可多食用性味平和的食物，如小米、山药、莲子等。";
            case "气虚质":
                return "您可能存在气虚体质，表现为精力不足、容易疲劳。建议多食用补气食物如人参、黄芪、山药、大枣等，避免过度劳累，适当进行缓和的运动如太极拳、八段锦等。";
            case "阳虚质":
                return "您可能存在阳虚体质，表现为怕冷、手足不温。建议多食用温阳食物如羊肉、生姜、肉桂、核桃等，避免生冷食物，注意保暖，可进行温和的有氧运动。";
            case "阴虚质":
                return "您可能存在阴虚体质，表现为口干、怕热、失眠等。建议多食用滋阴食物如银耳、百合、枸杞、梨等，避免辛辣燥热食物，保持充足睡眠，适合做瑜伽等静态运动。";
            case "痰湿质":
                return "您可能存在痰湿体质，表现为体型偏胖、容易困倦。建议清淡饮食，多食用健脾化湿食物如薏米、冬瓜、白萝卜等，避免油腻甜腻食物，增加运动量，保持环境干燥。";
            case "湿热质":
                return "您可能存在湿热体质，表现为面部油腻、口苦口干。建议清热利湿，多食用绿豆、苦瓜、茯苓、薏米等，避免辛辣油腻食物，保持大便通畅，适合游泳等水上运动。";
            case "血瘀质":
                return "您可能存在血瘀体质，表现为面色暗沉、容易健忘。建议活血化瘀，多食用山楂、黑豆、红花茶等，避免寒凉食物，适当进行有氧运动促进血液循环。";
            case "气郁质":
                return "您可能存在气郁体质，表现为情绪波动、胸闷不舒。建议疏肝理气，多食用柑橘、玫瑰花茶、薄荷等，保持心情愉悦，多参加社交活动，适合做有氧运动释放压力。";
            case "特禀质":
                return "您可能存在特禀体质，容易过敏。建议避免接触过敏原，饮食宜清淡，多食用益气固表食物如黄芪、防风、白术等，增强体质，提高免疫力。";
            default:
                return "根据您的测评结果，建议保持健康的生活方式，均衡饮食，适量运动，如有需要请咨询专业中医师。";
        }
    }
}