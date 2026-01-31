package com.lingsu.health.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.UserMapper;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserMapper userMapper;

    public UserController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @GetMapping
    public List<User> list() {
        return userMapper.selectList(null);
    }

    @PostMapping
    public String add(@RequestBody User u) {
        userMapper.insert(u);
        return "OK";
    }

    /**
     * 获取用户主题偏好
     */
    @GetMapping("/theme-preference")
    public Map<String, Object> getThemePreference(HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            String username = request.getHeader("X-Username");
            if (username == null || username.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return response;
            }

            QueryWrapper<User> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("username", username.trim());
            User user = userMapper.selectOne(queryWrapper);

            if (user == null) {
                response.put("success", false);
                response.put("message", "用户不存在");
                return response;
            }

            String theme = user.getThemePreference();
            if (theme == null || theme.isEmpty()) {
                theme = "light"; // 默认浅色主题
            }

            response.put("success", true);
            response.put("theme", theme);
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "获取主题偏好失败: " + e.getMessage());
            return response;
        }
    }

    /**
     * 保存用户主题偏好
     */
    @PostMapping("/theme-preference")
    public Map<String, Object> saveThemePreference(@RequestBody Map<String, String> payload, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            String username = request.getHeader("X-Username");
            if (username == null || username.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return response;
            }

            String theme = payload.get("theme");
            if (theme == null || (!theme.equals("light") && !theme.equals("dark"))) {
                response.put("success", false);
                response.put("message", "无效的主题值");
                return response;
            }

            QueryWrapper<User> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("username", username.trim());
            User user = userMapper.selectOne(queryWrapper);

            if (user == null) {
                response.put("success", false);
                response.put("message", "用户不存在");
                return response;
            }

            user.setThemePreference(theme);
            userMapper.updateById(user);

            response.put("success", true);
            response.put("message", "主题偏好已保存");
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "保存主题偏好失败: " + e.getMessage());
            return response;
        }
    }
}