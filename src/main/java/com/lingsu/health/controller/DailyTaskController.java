package com.lingsu.health.controller;

import com.lingsu.health.service.DailyTaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class DailyTaskController {

    private final DailyTaskService dailyTaskService;

    /**
     * 获取今日任务
     */
    @GetMapping("/today")
    public Map<String, Object> getTodayTasks(Principal principal) {
        return dailyTaskService.getTodayTasks(principal.getName());
    }

    /**
     * 完成任务
     */
    @PostMapping("/{taskId}/complete")
    public Map<String, Object> completeTask(@PathVariable Long taskId, Principal principal) {
        return dailyTaskService.completeTask(principal.getName(), taskId);
    }

    /**
     * 取消完成任务
     */
    @PostMapping("/{taskId}/uncomplete")
    public Map<String, Object> uncompleteTask(@PathVariable Long taskId, Principal principal) {
        return dailyTaskService.uncompleteTask(principal.getName(), taskId);
    }

    /**
     * 获取周进度统计
     */
    @GetMapping("/weekly-progress")
    public Map<String, Object> getWeeklyProgress(Principal principal) {
        return dailyTaskService.getWeeklyProgress(principal.getName());
    }

    // =============================================
    // 7天计划相关API
    // =============================================

    /**
     * 生成7天养生计划
     */
    @PostMapping("/generate-7day-plan")
    public Map<String, Object> generate7DayPlan(Principal principal) {
        return dailyTaskService.generate7DayPlan(principal.getName());
    }

    /**
     * 获取当前7天计划
     */
    @GetMapping("/7day-plan")
    public Map<String, Object> get7DayPlan(Principal principal) {
        return dailyTaskService.get7DayPlan(principal.getName());
    }

    /**
     * 更新任务进度
     */
    @PutMapping("/{taskId}/progress")
    public Map<String, Object> updateTaskProgress(
            @PathVariable Long taskId,
            @RequestBody Map<String, Integer> request,
            Principal principal) {
        Integer progress = request.getOrDefault("progress", 0);
        return dailyTaskService.updateTaskProgress(principal.getName(), taskId, progress);
    }

    /**
     * 获取计划历史
     */
    @GetMapping("/plan-history")
    public Map<String, Object> getPlanHistory(
            @RequestParam(defaultValue = "10") int limit,
            Principal principal) {
        return dailyTaskService.getPlanHistory(principal.getName(), limit);
    }
}
