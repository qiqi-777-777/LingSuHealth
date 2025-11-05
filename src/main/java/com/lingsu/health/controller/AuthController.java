package com.lingsu.health.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.UserMapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserMapper userMapper;

    public AuthController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public static class Credentials {
        public String username;
        public String password;
    }

    public static class ChangePasswordRequest {
        public String username;
        public String currentPassword;
        public String newPassword;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Credentials c) {
        if (c == null || c.username == null || c.password == null) {
            return ResponseEntity.badRequest().body("用户名/密码不能为空");
        }
        User existing = userMapper.selectOne(new QueryWrapper<User>().eq("username", c.username));
        if (existing != null) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("用户名已存在");
        }
        User u = new User();
        u.setUsername(c.username);
        u.setPasswordHash(BCrypt.hashpw(c.password, BCrypt.gensalt()));
        // 可选：初始化展示字段
        u.setName(c.username);
        u.setAge(null);
        userMapper.insert(u);
        return ResponseEntity.ok("注册成功");
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Credentials c) {
        if (c == null || c.username == null || c.password == null) {
            return ResponseEntity.badRequest().body("用户名/密码不能为空");
        }
        User u = userMapper.selectOne(new QueryWrapper<User>().eq("username", c.username));
        if (u == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("用户不存在，请先注册");
        }
        boolean ok = BCrypt.checkpw(c.password, u.getPasswordHash());
        if (!ok) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("密码错误");
        }
        return ResponseEntity.ok("登录成功");
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request) {
        if (request == null || request.username == null || 
            request.currentPassword == null || request.newPassword == null) {
            return ResponseEntity.badRequest().body("请填写所有必要信息");
        }

        if (request.newPassword.length() < 6) {
            return ResponseEntity.badRequest().body("新密码至少需要6位");
        }

        if (request.currentPassword.equals(request.newPassword)) {
            return ResponseEntity.badRequest().body("新密码不能与当前密码相同");
        }

        // 查找用户
        User user = userMapper.selectOne(new QueryWrapper<User>().eq("username", request.username));
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("用户不存在");
        }

        // 验证当前密码
        boolean currentPasswordValid = BCrypt.checkpw(request.currentPassword, user.getPasswordHash());
        if (!currentPasswordValid) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("当前密码错误");
        }

        // 更新密码
        String newPasswordHash = BCrypt.hashpw(request.newPassword, BCrypt.gensalt());
        user.setPasswordHash(newPasswordHash);
        userMapper.updateById(user);

        return ResponseEntity.ok("密码修改成功");
    }
}