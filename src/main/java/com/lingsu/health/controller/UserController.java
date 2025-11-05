package com.lingsu.health.controller;

import com.lingsu.health.entity.User;
import com.lingsu.health.mapper.UserMapper;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
}