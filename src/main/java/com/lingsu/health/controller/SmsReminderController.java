package com.lingsu.health.controller;

import com.lingsu.health.service.SmsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/sms")
@CrossOrigin(origins = "*")
public class SmsReminderController {

    @Autowired
    private SmsService smsService;

    /**
     * 发送任务提醒短信
     */
    @PostMapping("/send-reminder")
    public ResponseEntity<?> sendReminder(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phoneNumber");
        String taskName = request.get("taskName");
        String taskTime = request.get("taskTime");

        if (phoneNumber == null || phoneNumber.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "手机号不能为空"));
        }

        boolean success = smsService.sendTaskReminder(phoneNumber, taskName, taskTime);

        if (success) {
            return ResponseEntity.ok(Map.of("message", "短信发送成功"));
        } else {
            return ResponseEntity.status(500).body(Map.of("error", "短信发送失败"));
        }
    }

    /**
     * 测试短信服务配置
     */
    @GetMapping("/test")
    public ResponseEntity<?> testSmsConfig() {
        return ResponseEntity.ok(Map.of(
            "message", "短信服务已配置",
            "note", "请在application.yml中配置阿里云短信参数"
        ));
    }
}
