package com.lingsu.health.controller;

import com.lingsu.health.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/plan")
@RequiredArgsConstructor
public class PlanController {
    
    private final PlanService planService;

    @GetMapping("/daily")
    public Map<String, Object> dailyPlan(HttpServletRequest request) {
        String username = request.getHeader("X-Username");
        
        if (username == null || username.trim().isEmpty()) {
            return Map.of(
                "hasAssessment", false,
                "message", "未登录"
            );
        }
        
        return planService.generatePersonalizedPlan(username.trim());
    }
}