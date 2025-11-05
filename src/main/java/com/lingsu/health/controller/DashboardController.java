package com.lingsu.health.controller;

import com.lingsu.health.dto.Dtos.DashboardMetrics;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {
    @GetMapping("/metrics")
    public DashboardMetrics metrics() {
        DashboardMetrics m = new DashboardMetrics();
        m.sleepQuality = 78.5;
        m.activityScore = 66.2;
        m.constitutionStability = 81.0;
        return m;
    }
}