package com.lingsu.health.controller;

import com.lingsu.health.dto.Dtos.SeasonTip;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.Month;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/season")
public class SeasonController {
    
    private static final Map<String, SeasonTip> seasonTips = new HashMap<>();
    
    static {
        // 春季节气
        seasonTips.put("立春", createSeasonTip("立春", "阳气生发，宜早起散步", 
            "春季阳气开始生发，万物复苏。此时应顺应自然，早睡早起，多到户外活动，让身体感受春天的生机。饮食上宜清淡，多食绿色蔬菜，如菠菜、韭菜等，有助于疏肝理气。避免过度进补，以免阻碍阳气生发。",
            "温补肝肾，调理脾胃", "韭菜、菠菜、春笋、豆芽", "避免过食酸味，少吃辛辣"));
            
        seasonTips.put("雨水", createSeasonTip("雨水", "湿气渐重，健脾祛湿", 
            "雨水节气后，湿气加重，容易困脾。应注意健脾祛湿，可多食用薏米、红豆等祛湿食物。保持室内通风干燥，避免久坐湿地。适当运动，促进气血流通，但不宜大汗淋漓。",
            "健脾祛湿，温中散寒", "薏米、红豆、山药、茯苓", "少食生冷，避免久居湿地"));
            
        seasonTips.put("惊蛰", createSeasonTip("惊蛰", "春雷始鸣，养肝护脾", 
            "惊蛰时节，春雷始鸣，万物萌动。肝气旺盛，易伤脾胃。饮食宜清淡甘甜，多食梨、银耳等润燥食物。保持心情舒畅，避免情绪波动过大。适合进行柔和的运动，如太极拳、瑜伽等。",
            "养肝护脾，润燥清热", "梨、银耳、蜂蜜、枸杞", "忌食辛辣燥热，少怒多笑"));
            
        seasonTips.put("春分", createSeasonTip("春分", "阴阳平衡，调和气血", 
            "春分时节，昼夜等长，阴阳平衡。此时人体也应保持平衡状态，饮食不宜过热过寒，作息要规律。多食用平性食物，如小米、莲子等。适合进行中等强度的运动，保持身心和谐。",
            "调和阴阳，平补气血", "小米、莲子、百合、大枣", "避免大寒大热，保持情绪平和"));

        // 夏季节气
        seasonTips.put("立夏", createSeasonTip("立夏", "心火渐旺，清热养心", 
            "立夏后，心火渐旺，应注意清热养心。饮食宜清淡，多食用苦味食物如苦瓜、莲子心等，有助于清心火。避免过度劳累，保持心情愉悦。适合早晚运动，避免中午烈日。",
            "清热养心，健脾祛湿", "苦瓜、莲子、绿豆、冬瓜", "少食辛热，避免过劳"));
            
        seasonTips.put("小满", createSeasonTip("小满", "湿热渐盛，清热利湿", 
            "小满时节，湿热渐盛，容易出现皮肤病和消化不良。应清热利湿，多食用薏米、冬瓜等食物。保持皮肤清洁干燥，穿着透气的衣物。适量运动，但要及时补充水分。",
            "清热利湿，健脾和胃", "薏米、冬瓜、丝瓜、绿豆", "忌食油腻，保持清洁"));

        // 秋季节气  
        seasonTips.put("立秋", createSeasonTip("立秋", "燥气渐盛，润燥养肺", 
            "立秋后，燥气渐盛，容易伤肺。应注意润燥养肺，多食用梨、百合、银耳等滋阴润燥的食物。保持室内湿度适宜，避免过度干燥。适合进行有氧运动，增强肺功能。",
            "润燥养肺，滋阴清热", "梨、百合、银耳、蜂蜜", "少食辛辣，多饮温水"));
            
        seasonTips.put("处暑", createSeasonTip("处暑", "暑热渐消，调理脾胃", 
            "处暑时节，暑热渐消，但燥气加重。脾胃功能逐渐恢复，可适当进补。多食用健脾润燥的食物，如山药、莲藕等。注意保暖，特别是腹部和足部。",
            "健脾润燥，调理肠胃", "山药、莲藕、芝麻、核桃", "避免贪凉，注意保暖"));
            
        seasonTips.put("白露", createSeasonTip("白露", "秋燥明显，滋阴润燥", 
            "白露时节，秋燥明显，容易出现口干、皮肤干燥等症状。应重点滋阴润燥，多食用梨、百合、银耳等食物。保持充足睡眠，避免熬夜。适当增加室内湿度。",
            "滋阴润燥，养肺护肤", "梨、百合、银耳、蜂蜜", "少食辛辣，多饮水"));
            
        seasonTips.put("秋分", createSeasonTip("秋分", "昼夜等长，平补阴阳", 
            "秋分时节，昼夜等长，阴阳平衡。此时应平补阴阳，既要润燥，又要温补。饮食宜温润，如莲藕、山药等。保持情绪稳定，适度运动。",
            "平补阴阳，润燥温补", "莲藕、山药、百合、核桃", "避免大寒大热，保持平和"));
            
        seasonTips.put("寒露", createSeasonTip("寒露", "寒气渐重，温润并重", 
            "寒露时节，寒气渐重，燥邪仍存。应温润并重，既要防燥又要防寒。多食用温润食物，如芝麻、核桃、蜂蜜等。注意足部保暖，避免受凉。",
            "温润并重，防燥防寒", "芝麻、核桃、蜂蜜、大枣", "足部保暖，避免受凉"));
            
        seasonTips.put("霜降", createSeasonTip("霜降", "深秋时节，温补润燥", 
            "霜降是秋季最后一个节气，天气渐冷，燥气仍盛。应温补润燥，多食用温性滋润的食物，如柿子、梨、蜂蜜等。加强锻炼，增强体质，为冬季做准备。",
            "温补润燥，增强体质", "柿子、梨、蜂蜜、核桃", "防寒保暖，适度锻炼"));

        // 冬季节气
        seasonTips.put("立冬", createSeasonTip("立冬", "阳气潜藏，温补肾阳", 
            "立冬后，阳气潜藏，应温补肾阳。多食用温热性食物，如羊肉、生姜、桂圆等。早睡晚起，保存体力。适合进行温和的运动，避免大汗淋漓消耗阳气。",
            "温补肾阳，固本培元", "羊肉、生姜、桂圆、核桃", "少食生冷，早睡晚起"));
            
        seasonTips.put("小雪", createSeasonTip("小雪", "寒气渐重，温阳散寒", 
            "小雪时节，寒气渐重，应温阳散寒。多食用温热食物，如牛肉、韭菜、生姜等。注意保暖，特别是头部、颈部和足部。室内保持适宜温度，避免过度干燥。",
            "温阳散寒，补益精血", "牛肉、韭菜、生姜、红枣", "防寒保暖，避风寒"));
    }
    
    @GetMapping("/tips")
    public SeasonTip tips(@RequestParam(defaultValue = "立冬") String season) {
        SeasonTip tip = seasonTips.get(season);
        if (tip == null) {
            // 如果没有找到对应节气，返回当前节气
            String currentSeason = getCurrentSeason();
            tip = seasonTips.get(currentSeason);
        }
        return tip != null ? tip : seasonTips.get("立冬");
    }
    
    @GetMapping("/current")
    public SeasonTip getCurrentSeasonTip() {
        String currentSeason = getCurrentSeason();
        return seasonTips.get(currentSeason);
    }
    
    private static SeasonTip createSeasonTip(String season, String shortSuggestion, String detailSuggestion, 
                                           String principle, String foods, String taboos) {
        SeasonTip tip = new SeasonTip();
        tip.season = season;
        tip.suggestion = shortSuggestion;
        tip.detailSuggestion = detailSuggestion;
        tip.principle = principle;
        tip.recommendedFoods = foods;
        tip.taboos = taboos;
        return tip;
    }
    
    private String getCurrentSeason() {
        LocalDate now = LocalDate.now();
        Month month = now.getMonth();
        int day = now.getDayOfMonth();
        
        // 精确的二十四节气判断逻辑（基于公历日期）
        // 春季节气
        if (month == Month.FEBRUARY && day >= 4) return "立春";
        if (month == Month.FEBRUARY && day >= 19) return "雨水";
        if (month == Month.MARCH && day >= 6) return "惊蛰";
        if (month == Month.MARCH && day >= 21) return "春分";
        
        // 夏季节气
        if (month == Month.MAY && day >= 6) return "立夏";
        if (month == Month.MAY && day >= 21) return "小满";
        
        // 秋季节气
        if (month == Month.AUGUST && day >= 8) return "立秋";
        if (month == Month.AUGUST && day >= 23) return "处暑";
        if (month == Month.SEPTEMBER && day >= 8) return "白露";
        if (month == Month.SEPTEMBER && day >= 23) return "秋分";
        if (month == Month.OCTOBER && day >= 8) return "寒露";
        if (month == Month.OCTOBER && day >= 23) return "霜降";
        
        // 冬季节气
        if (month == Month.NOVEMBER && day >= 8) return "立冬";
        if (month == Month.NOVEMBER && day >= 22) return "小雪";
        
        // 特殊处理：霜降跨月份（10月23日-11月7日）
        if (month == Month.NOVEMBER && day < 8) return "霜降";
        
        // 根据月份返回大致节气
        switch (month) {
            case JANUARY: case FEBRUARY: return "立春";
            case MARCH: case APRIL: return "春分";
            case MAY: case JUNE: return "立夏";
            case JULY: case AUGUST: return "立秋";
            case SEPTEMBER: return "秋分";
            case OCTOBER: return "霜降";
            case NOVEMBER: return "立冬";
            case DECEMBER: return "小雪";
            default: return "霜降";
        }
    }
}