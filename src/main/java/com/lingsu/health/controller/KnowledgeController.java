package com.lingsu.health.controller;

import com.lingsu.health.dto.Dtos.KnowledgeItem;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/knowledge")
public class KnowledgeController {
    @GetMapping("/search")
    public List<KnowledgeItem> search(@RequestParam String keyword) {
        KnowledgeItem i = new KnowledgeItem();
        i.name = "枸杞"; i.tcmEffect = "滋补肝肾，益精明目";
        i.westernNutrition = "含多糖、类胡萝卜素与微量元素";
        i.suitable = "阴虚体质"; i.taboo = "感冒发烧、糖尿病患者谨慎";
        return List.of(i);
    }
}