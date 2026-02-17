package com.lingsu.health.controller;

import com.lingsu.health.service.WeeklyReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;

/**
 * 周报控制器 - 健康管理闭环 Step 5
 */
@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class WeeklyReportController {

    private final WeeklyReportService weeklyReportService;

    /**
     * 获取最新周报
     */
    @GetMapping("/weekly")
    public Map<String, Object> getWeeklyReport(Principal principal) {
        return weeklyReportService.getLatestReport(principal.getName());
    }

    /**
     * 生成周报
     */
    @PostMapping("/generate-weekly")
    public Map<String, Object> generateWeeklyReport(Principal principal) {
        return weeklyReportService.generateWeeklyReport(principal.getName());
    }

    /**
     * 获取周报历史列表
     */
    @GetMapping("/weekly/list")
    public Map<String, Object> getWeeklyReportList(
            @RequestParam(defaultValue = "10") int limit,
            Principal principal) {
        return weeklyReportService.getReportHistory(principal.getName(), limit);
    }
}
