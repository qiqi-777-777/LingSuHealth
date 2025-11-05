/*
 Navicat Premium Dump SQL

 Source Server         : lingsu_health1
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : lingsu_health

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 03/11/2025 23:22:03
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for health_checkins
-- ----------------------------
DROP TABLE IF EXISTS `health_checkins`;
/* 统一的初始化脚本（清理重复/错误注释后保留这一份） */
CREATE TABLE `health_checkins` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `checkin_date` date NOT NULL COMMENT '打卡日期',
  `sleep_hours` decimal(4,2) NOT NULL COMMENT '睡眠时长（小时）',
  `sleep_time` time NOT NULL COMMENT '入睡时间',
  `symptoms` varchar(255) DEFAULT NULL COMMENT '症状列表JSON',
  `mood` int DEFAULT NULL COMMENT '心情指数（0-4）',
  `exercise_minutes` int DEFAULT NULL COMMENT '运动时长（分钟）',
  `diet_notes` varchar(255) DEFAULT NULL COMMENT '饮食记录',
  `followed_plan` tinyint(1) NOT NULL COMMENT '是否按昨日方案执行',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`, `checkin_date`)  -- 非唯一索引，允许同日多次打卡
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康打卡记录表';

-- ----------------------------
-- Records of health_checkins
-- ----------------------------

-- ----------------------------
-- Table structure for user_profiles
-- ----------------------------
DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `gender` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '性别（可选）',
  `birth_date` date NULL DEFAULT NULL,
  `age` int NULL DEFAULT NULL,
  `height` decimal(5, 2) NULL DEFAULT NULL,
  `weight` decimal(5, 2) NULL DEFAULT NULL,
  `bmi` decimal(4, 2) NULL DEFAULT NULL,
  `allergies` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `medical_history` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `medications` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_profiles
-- ----------------------------
INSERT INTO `user_profiles` VALUES (1, 1, 'root', '3058922645@qq.com', '15103600393', 'male', '2004-11-13', 20, 170.00, 56.00, 19.38, '', '', '', '2025-11-02 15:23:34', '2025-11-02 15:58:19');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的哈希值(加密处理后的)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_users_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'root', NULL, 'root', '$2a$10$ZWYh2uOcQugI7DvkKNomFO3l4Di.IMUUgHAQuLxOoIhR1du187EOu');

SET FOREIGN_KEY_CHECKS = 1;
-- 示例数据：插入最近 7 天的打卡记录（user_id=1）
DELETE FROM `health_checkins`
WHERE `user_id` = 1
  AND `checkin_date` BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND CURDATE();

INSERT INTO `health_checkins`
(`user_id`,`checkin_date`,`sleep_hours`,`sleep_time`,`symptoms`,`mood`,`exercise_minutes`,`diet_notes`,`followed_plan`)
VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 7.5, '23:10:00', '["失眠","食欲不振"]', 1, 40, '清淡饮食', 0),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 6.0, '00:05:00', '["疲劳"]',           1, 20, '少油少盐', 0),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 8.0, '22:45:00', '["无症状"]',         2, 60, '蛋白质补充', 0),
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 7.0, '23:30:00', '["头痛"]',           2, 30, '多喝水', 0),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 6.5, '00:20:00', '["腹胀","疲劳"]',     1, 25, '少食多餐', 0),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 8.2, '22:50:00', '["无症状"]',         3, 45, '均衡饮食', 0),
(1, CURDATE(),                         7.8, '23:05:00', '["失眠","食欲不振"]',   2, 50, '注意作息', 0);
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- Table structure for assessment_records
-- ----------------------------
DROP TABLE IF EXISTS `assessment_records`;
CREATE TABLE `assessment_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `answers_json` text NOT NULL COMMENT '测评答案JSON（包含十个问题的答案）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_created` (`user_id`, `created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='体质测评记录表';

-- ----------------------------
-- Records of assessment_records
-- ----------------------------
