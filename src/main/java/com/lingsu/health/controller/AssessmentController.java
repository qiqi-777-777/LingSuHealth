package com.lingsu.health.controller;

import com.lingsu.health.dto.Dtos.FusionAssessmentReport;
import com.lingsu.health.entity.AssessmentRecord;
import com.lingsu.health.entity.HealthCheckin;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.AssessmentRecordMapper;
import com.lingsu.health.mapper.HealthCheckinMapper;
import com.lingsu.health.mapper.UserMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/assessment")
@RequiredArgsConstructor
public class AssessmentController {

    private final AssessmentRecordMapper assessmentRecordMapper;
    private final HealthCheckinMapper healthCheckinMapper;
    private final UserMapper userMapper;

    @PostMapping("/report")
    public FusionAssessmentReport generateReport(@RequestBody Map<String, Object> requestData,
                                           HttpServletRequest request) {
        FusionAssessmentReport report = new FusionAssessmentReport();

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> answers = (List<Map<String, Object>>) requestData.get("answers");
        if (answers == null || answers.isEmpty()) {
            report.constitution = "平和质";
            report.summary = "未提供足够的信息进行体质分析，建议完成完整的体质测评。";
            report.riskTips = List.of("问卷信息不足，建议完成完整测评");
            report.portrait = buildPortrait("平和质", List.of(), null);
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
        List<HealthCheckin> recentCheckins = getRecentCheckins(userId);
        DailyStats stats = analyzeDailyStats(recentCheckins);
        report.portrait = buildPortrait(constitution, recentCheckins, stats);
        report.riskTips = buildRiskTips(constitution, stats, recentCheckins);
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
        switch (questionIndex) {
            case 0:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[1] += 2;
                else if (answerIndex == 2) scores[4] += 2;
                else if (answerIndex == 3) scores[0] += 1;
                break;
            case 1:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[7] += 1;
                else if (answerIndex == 2) scores[3] += 2;
                else if (answerIndex == 3) scores[1] += 1;
                break;
            case 2:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[1] += 1;
                else if (answerIndex == 2) scores[1] += 2;
                else if (answerIndex == 3) scores[4] += 1;
                break;
            case 3:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[4] += 1;
                else if (answerIndex == 2) scores[5] += 1;
                else if (answerIndex == 3) scores[7] += 1;
                break;
            case 4:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[5] += 1;
                else if (answerIndex == 2) scores[7] += 1;
                else if (answerIndex == 3) scores[4] += 1;
                break;
            case 5:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[1] += 1;
                else if (answerIndex == 2) scores[1] += 2;
                break;
            case 6:
                if (answerIndex == 0) scores[0] += 2;
                else if (answerIndex == 1) scores[7] += 1;
                else if (answerIndex == 2) scores[7] += 2;
                else if (answerIndex == 3) scores[7] += 2;
                break;
            case 7:
                if (answerIndex == 0) scores[6] += 1;
                else if (answerIndex == 1) scores[1] += 1;
                else if (answerIndex == 2) scores[2] += 1;
                else if (answerIndex == 3) scores[3] += 1;
                else if (answerIndex == 4) scores[0] += 1;
                break;
            case 8:
            case 9:
                break;
        }
    }

    private List<HealthCheckin> getRecentCheckins(Long userId) {
        if (userId == null) {
            return List.of();
        }
        LocalDate startDate = LocalDate.now().minusDays(6);
        return healthCheckinMapper.getRecentCheckins(userId, startDate);
    }

    private DailyStats analyzeDailyStats(List<HealthCheckin> recentCheckins) {
        DailyStats stats = new DailyStats();
        if (recentCheckins == null || recentCheckins.isEmpty()) {
            return stats;
        }
        double sleepSum = 0;
        int sleepCount = 0;
        int sleepTimeCount = 0;
        int lateCount = 0;
        double moodSum = 0;
        int moodCount = 0;
        int moodLowDays = 0;
        int sleepShortDays = 0;
        int sleepLongDays = 0;
        Map<String, Integer> dietCounts = new HashMap<>();
        LocalTime lateThreshold = LocalTime.of(23, 0);
        LocalTime earlyThreshold = LocalTime.of(6, 0);

        for (HealthCheckin checkin : recentCheckins) {
            if (checkin.getSleepHours() != null) {
                double sleepHours = checkin.getSleepHours().doubleValue();
                sleepSum += sleepHours;
                sleepCount++;
                if (sleepHours < 6.5) {
                    sleepShortDays++;
                } else if (sleepHours > 9) {
                    sleepLongDays++;
                }
            }
            if (checkin.getSleepTime() != null) {
                sleepTimeCount++;
                if (checkin.getSleepTime().isAfter(lateThreshold) || checkin.getSleepTime().isBefore(earlyThreshold)) {
                    lateCount++;
                }
            }
            if (checkin.getMood() != null) {
                moodSum += checkin.getMood();
                moodCount++;
                if (checkin.getMood() <= 1) {
                    moodLowDays++;
                }
            }
            if (checkin.getDietNotes() != null && !checkin.getDietNotes().isEmpty()) {
                String note = checkin.getDietNotes();
                String label = classifyDietLabel(note);
                if (label != null) {
                    dietCounts.put(label, dietCounts.getOrDefault(label, 0) + 1);
                }
            }
        }

        if (sleepCount > 0) {
            stats.sleepAvg = roundOneDecimal(sleepSum / sleepCount);
        }
        if (sleepTimeCount > 0) {
            stats.sleepLateRate = roundTwoDecimal((double) lateCount / sleepTimeCount);
        }
        if (moodCount > 0) {
            stats.moodAvg = roundOneDecimal(moodSum / moodCount);
        }
        stats.dietLabel = pickTopLabel(dietCounts);
        stats.checkinCount = recentCheckins.size();
        stats.sleepLateDays = lateCount;
        stats.sleepShortDays = sleepShortDays;
        stats.sleepLongDays = sleepLongDays;
        stats.moodLowDays = moodLowDays;
        return stats;
    }

    private Map<String, Object> buildPortrait(String constitution, List<HealthCheckin> recentCheckins, DailyStats stats) {
        Map<String, Object> portrait = new HashMap<>();
        portrait.put("constitution", constitution);
        int checkinCount = recentCheckins != null ? recentCheckins.size() : 0;
        portrait.put("checkinCount", checkinCount);
        portrait.put("daysWindow", 7);
        if (stats != null) {
            portrait.put("sleepAvg", stats.sleepAvg);
            portrait.put("sleepLateRate", stats.sleepLateRate);
            portrait.put("moodAvg", stats.moodAvg);
            portrait.put("dietLabel", stats.dietLabel);
            portrait.put("sleepShortDays", stats.sleepShortDays);
            portrait.put("sleepLongDays", stats.sleepLongDays);
            portrait.put("sleepLateDays", stats.sleepLateDays);
            portrait.put("moodLowDays", stats.moodLowDays);
            portrait.put("sleepStatus", buildSleepStatus(stats.sleepAvg));
            portrait.put("moodStatus", buildMoodStatus(stats.moodAvg));
            portrait.put("dietStatus", buildDietStatus(stats.dietLabel));
        }
        Map<String, Integer> symptomSummary = buildSymptomSummary(recentCheckins);
        portrait.put("symptoms", symptomSummary);
        portrait.put("topSymptoms", buildTopSymptoms(symptomSummary, 3));
        return portrait;
    }

    private List<String> buildRiskTips(String constitution, DailyStats stats, List<HealthCheckin> recentCheckins) {
        List<String> tips = new ArrayList<>();
        if (recentCheckins == null || recentCheckins.isEmpty()) {
            tips.add("近期暂无打卡数据，建议完成每日打卡以获得更准确的风险提示。");
        }
        if (stats != null) {
            if (stats.sleepAvg != null && stats.sleepAvg < 6.5) {
                addTip(tips, "近7天平均睡眠不足，建议保证每日7-8小时睡眠。");
            } else if (stats.sleepAvg != null && stats.sleepAvg > 9) {
                addTip(tips, "近7天平均睡眠偏长，建议适当调整作息提升日间精神。");
            }
            if (stats.sleepLateRate != null && stats.sleepLateRate >= 0.4) {
                addTip(tips, "入睡时间偏晚，建议尽量在23点前入睡。");
            }
            if (stats.moodAvg != null && stats.moodAvg <= 1.5) {
                addTip(tips, "情绪评分偏低，建议安排放松活动与规律作息。");
            }
            if (stats.dietLabel != null) {
                switch (stats.dietLabel) {
                    case "偏油":
                        addTip(tips, "饮食偏油，建议减少油炸与高脂食物。");
                        break;
                    case "偏甜":
                        addTip(tips, "饮食偏甜，建议减少含糖饮料与甜品。");
                        break;
                    case "偏辣":
                        addTip(tips, "饮食偏辣，建议适当降低辛辣刺激。");
                        break;
                    case "偏咸":
                        addTip(tips, "饮食偏咸，建议控制盐分摄入。");
                        break;
                    default:
                        break;
                }
            }
        }
        Map<String, Integer> symptomSummary = buildSymptomSummary(recentCheckins);
        String topSymptom = pickTopSymptom(symptomSummary);
        if (topSymptom != null) {
            addTip(tips, "近期多次出现“" + topSymptom + "”症状，建议关注并适当调整作息与饮食。");
        }
        String constitutionTip = buildConstitutionTip(constitution);
        if (constitutionTip != null && !constitutionTip.isEmpty()) {
            addTip(tips, constitutionTip);
        }
        if (tips.isEmpty()) {
            tips.add("近期健康状况平稳，建议继续保持规律作息与均衡饮食。");
        }
        return tips;
    }

    private String buildConstitutionTip(String constitution) {
        switch (constitution) {
            case "气虚质":
                return "气虚体质建议循序渐进运动，避免过度劳累。";
            case "阳虚质":
                return "阳虚体质注意保暖，少吃生冷食物。";
            case "阴虚质":
                return "阴虚体质注意滋阴润燥，避免熬夜。";
            case "痰湿质":
                return "痰湿体质建议控制油腻甜食，增加运动。";
            case "湿热质":
                return "湿热体质建议清淡饮食，避免辛辣油腻。";
            case "血瘀质":
                return "血瘀体质建议适量有氧运动促进循环。";
            case "气郁质":
                return "气郁体质建议保持心情舒畅，多做舒缓运动。";
            case "特禀质":
                return "特禀体质注意远离过敏原，规律作息。";
            default:
                return "平和体质建议继续保持良好生活习惯。";
        }
    }

    private Map<String, Integer> buildSymptomSummary(List<HealthCheckin> recentCheckins) {
        Map<String, Integer> counts = new HashMap<>();
        if (recentCheckins == null || recentCheckins.isEmpty()) {
            return counts;
        }
        ObjectMapper mapper = new ObjectMapper();
        for (HealthCheckin checkin : recentCheckins) {
            if (checkin.getSymptoms() == null || checkin.getSymptoms().isEmpty()) {
                continue;
            }
            try {
                List<String> symptoms = mapper.readValue(checkin.getSymptoms(), new TypeReference<List<String>>() {});
                for (String symptom : symptoms) {
                    if (symptom == null || symptom.isEmpty()) {
                        continue;
                    }
                    counts.put(symptom, counts.getOrDefault(symptom, 0) + 1);
                }
            } catch (Exception ignored) {
            }
        }
        return counts;
    }

    private String classifyDietLabel(String note) {
        String text = note.trim();
        if (text.isEmpty()) {
            return null;
        }
        if (text.contains("清淡") || text.contains("少油") || text.contains("低脂") || text.contains("少盐")) {
            return "清淡";
        }
        if (text.contains("油腻") || text.contains("油炸") || text.contains("肥") || text.contains("油")) {
            return "偏油";
        }
        if (text.contains("甜") || text.contains("糖")) {
            return "偏甜";
        }
        if (text.contains("辣") || text.contains("辛")) {
            return "偏辣";
        }
        if (text.contains("咸") || text.contains("盐")) {
            return "偏咸";
        }
        return "其他";
    }

    private String pickTopLabel(Map<String, Integer> counts) {
        if (counts == null || counts.isEmpty()) {
            return null;
        }
        String topLabel = null;
        int maxCount = 0;
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            if (entry.getValue() > maxCount) {
                maxCount = entry.getValue();
                topLabel = entry.getKey();
            }
        }
        return topLabel;
    }

    private List<Map<String, Object>> buildTopSymptoms(Map<String, Integer> counts, int limit) {
        if (counts == null || counts.isEmpty()) {
            return List.of();
        }
        List<Map.Entry<String, Integer>> entries = new ArrayList<>(counts.entrySet());
        entries.sort(Comparator.comparing(Map.Entry<String, Integer>::getValue).reversed());
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < entries.size() && i < limit; i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("symptom", entries.get(i).getKey());
            item.put("count", entries.get(i).getValue());
            result.add(item);
        }
        return result;
    }

    private String pickTopSymptom(Map<String, Integer> counts) {
        if (counts == null || counts.isEmpty()) {
            return null;
        }
        String top = null;
        int max = 0;
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            if (entry.getValue() > max) {
                max = entry.getValue();
                top = entry.getKey();
            }
        }
        if (max >= 2) {
            return top;
        }
        return null;
    }

    private String buildSleepStatus(Double sleepAvg) {
        if (sleepAvg == null) {
            return "未知";
        }
        if (sleepAvg < 6.5) {
            return "不足";
        }
        if (sleepAvg > 9) {
            return "偏长";
        }
        return "正常";
    }

    private String buildMoodStatus(Double moodAvg) {
        if (moodAvg == null) {
            return "未知";
        }
        if (moodAvg <= 1.5) {
            return "偏低";
        }
        if (moodAvg >= 3) {
            return "良好";
        }
        return "一般";
    }

    private String buildDietStatus(String dietLabel) {
        if (dietLabel == null) {
            return "无记录";
        }
        if ("清淡".equals(dietLabel)) {
            return "清淡";
        }
        if ("其他".equals(dietLabel)) {
            return "其他";
        }
        return "偏重";
    }

    private void addTip(List<String> tips, String tip) {
        if (tip == null || tip.isEmpty()) {
            return;
        }
        if (!tips.contains(tip)) {
            tips.add(tip);
        }
    }

    private Double roundOneDecimal(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private Double roundTwoDecimal(double value) {
        return Math.round(value * 100.0) / 100.0;
    }

    private static class DailyStats {
        private Double sleepAvg;
        private Double sleepLateRate;
        private Double moodAvg;
        private String dietLabel;
        private Integer checkinCount;
        private Integer sleepLateDays;
        private Integer sleepShortDays;
        private Integer sleepLongDays;
        private Integer moodLowDays;
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
