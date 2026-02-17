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

 Date: 03/02/2026 22:35:09
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for assessment_records
-- ----------------------------
DROP TABLE IF EXISTS `assessment_records`;
CREATE TABLE `assessment_records`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `answers_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '测评答案JSON（包含十个问题的答案）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_created`(`user_id` ASC, `created_at` DESC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '体质测评记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of assessment_records
-- ----------------------------
INSERT INTO `assessment_records` VALUES (1, 1, '[{\"questionIndex\":0,\"answerIndex\":1,\"question\":\"您的体型如何？\",\"answer\":\"偏瘦\"},{\"questionIndex\":1,\"answerIndex\":1,\"question\":\"您的睡眠质量如何？\",\"answer\":\"偶尔入睡困难或早醒\"},{\"questionIndex\":2,\"answerIndex\":1,\"question\":\"您的日常精力状态？\",\"answer\":\"下午容易犯困，需咖啡/茶提神\"},{\"questionIndex\":3,\"answerIndex\":0,\"question\":\"您的排便规律吗？\",\"answer\":\"每天1次，规律顺畅\"},{\"questionIndex\":4,\"answerIndex\":0,\"question\":\"您的饮食习惯？\",\"answer\":\"三餐规律，少油少糖\"},{\"questionIndex\":5,\"answerIndex\":2,\"question\":\"您每周运动几次？\",\"answer\":\"几乎不运动，能坐不站\"},{\"questionIndex\":6,\"answerIndex\":2,\"question\":\"您的情绪状态？\",\"answer\":\"经常压力大，易发脾气\"},{\"questionIndex\":7,\"answerIndex\":4,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"以上都没有\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":2,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"运动跟练计划\"}]', '2025-11-06 00:07:52', '2025-11-06 00:07:52');
INSERT INTO `assessment_records` VALUES (2, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":1,\"question\":\"您的睡眠质量如何？\",\"answer\":\"偶尔入睡困难或早醒\"},{\"questionIndex\":2,\"answerIndex\":0,\"question\":\"您的日常精力状态？\",\"answer\":\"白天精神饱满，不易累\"},{\"questionIndex\":3,\"answerIndex\":0,\"question\":\"您的排便规律吗？\",\"answer\":\"每天1次，规律顺畅\"},{\"questionIndex\":4,\"answerIndex\":0,\"question\":\"您的饮食习惯？\",\"answer\":\"三餐规律，少油少糖\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":1,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"饮食记录+推荐\"}]', '2025-11-17 15:01:48', '2025-11-17 15:01:48');
INSERT INTO `assessment_records` VALUES (3, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":2,\"question\":\"您的睡眠质量如何？\",\"answer\":\"经常失眠或睡不醒\"},{\"questionIndex\":2,\"answerIndex\":2,\"question\":\"您的日常精力状态？\",\"answer\":\"经常感到疲惫，睡不够\"},{\"questionIndex\":3,\"answerIndex\":2,\"question\":\"您的排便规律吗？\",\"answer\":\"经常便秘或腹泻\"},{\"questionIndex\":4,\"answerIndex\":1,\"question\":\"您的饮食习惯？\",\"answer\":\"外卖为主，口味偏重\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":0,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"肩颈僵硬\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2025-11-25 22:11:56', '2025-11-25 22:11:56');
INSERT INTO `assessment_records` VALUES (4, 1, '[{\"questionIndex\":0,\"answerIndex\":1,\"question\":\"您的体型如何？\",\"answer\":\"偏瘦\"},{\"questionIndex\":1,\"answerIndex\":2,\"question\":\"您的睡眠质量如何？\",\"answer\":\"经常失眠或睡不醒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":1,\"question\":\"您的排便规律吗？\",\"answer\":\"偶尔便秘或腹泻\"},{\"questionIndex\":4,\"answerIndex\":2,\"question\":\"您的饮食习惯？\",\"answer\":\"经常节食或暴饮暴食\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":2,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"容易手脚冰凉\"},{\"questionIndex\":8,\"answerIndex\":4,\"question\":\"您的健康目标？\",\"answer\":\"保持轻盈状态\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2025-12-31 10:49:45', '2025-12-31 10:49:45');
INSERT INTO `assessment_records` VALUES (5, 1, '[{\"questionIndex\":0,\"answerIndex\":3,\"question\":\"您的体型如何？\",\"answer\":\"肌肉线条明显\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":2,\"question\":\"您每周运动几次？\",\"answer\":\"几乎不运动，能坐不站\"},{\"questionIndex\":6,\"answerIndex\":2,\"question\":\"您的情绪状态？\",\"answer\":\"经常压力大，易发脾气\"},{\"questionIndex\":7,\"answerIndex\":2,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"容易手脚冰凉\"},{\"questionIndex\":8,\"answerIndex\":4,\"question\":\"您的健康目标？\",\"answer\":\"保持轻盈状态\"},{\"questionIndex\":9,\"answerIndex\":4,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"一站式健康方案\"}]', '2025-12-31 10:50:30', '2025-12-31 10:50:30');
INSERT INTO `assessment_records` VALUES (6, 1, '[{\"questionIndex\":0,\"answerIndex\":3,\"question\":\"您的体型如何？\",\"answer\":\"肌肉线条明显\"},{\"questionIndex\":1,\"answerIndex\":0,\"question\":\"您的睡眠质量如何？\",\"answer\":\"睡得快、起得早，精神好\"},{\"questionIndex\":2,\"answerIndex\":0,\"question\":\"您的日常精力状态？\",\"answer\":\"白天精神饱满，不易累\"},{\"questionIndex\":3,\"answerIndex\":0,\"question\":\"您的排便规律吗？\",\"answer\":\"每天1次，规律顺畅\"},{\"questionIndex\":4,\"answerIndex\":0,\"question\":\"您的饮食习惯？\",\"answer\":\"三餐规律，少油少糖\"},{\"questionIndex\":5,\"answerIndex\":0,\"question\":\"您每周运动几次？\",\"answer\":\"3次以上，每次30分钟以上\"},{\"questionIndex\":6,\"answerIndex\":0,\"question\":\"您的情绪状态？\",\"answer\":\"情绪稳定，很少焦虑\"},{\"questionIndex\":7,\"answerIndex\":0,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"肩颈僵硬\"},{\"questionIndex\":8,\"answerIndex\":0,\"question\":\"您的健康目标？\",\"answer\":\"控制体重\"},{\"questionIndex\":9,\"answerIndex\":0,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"每日记录挑战\"}]', '2025-12-31 10:59:36', '2025-12-31 10:59:36');
INSERT INTO `assessment_records` VALUES (7, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":0,\"question\":\"您的睡眠质量如何？\",\"answer\":\"睡得快、起得早，精神好\"},{\"questionIndex\":2,\"answerIndex\":0,\"question\":\"您的日常精力状态？\",\"answer\":\"白天精神饱满，不易累\"},{\"questionIndex\":3,\"answerIndex\":0,\"question\":\"您的排便规律吗？\",\"answer\":\"每天1次，规律顺畅\"},{\"questionIndex\":4,\"answerIndex\":0,\"question\":\"您的饮食习惯？\",\"answer\":\"三餐规律，少油少糖\"},{\"questionIndex\":5,\"answerIndex\":0,\"question\":\"您每周运动几次？\",\"answer\":\"3次以上，每次30分钟以上\"},{\"questionIndex\":6,\"answerIndex\":0,\"question\":\"您的情绪状态？\",\"answer\":\"情绪稳定，很少焦虑\"},{\"questionIndex\":7,\"answerIndex\":0,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"肩颈僵硬\"},{\"questionIndex\":8,\"answerIndex\":0,\"question\":\"您的健康目标？\",\"answer\":\"控制体重\"},{\"questionIndex\":9,\"answerIndex\":0,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"每日记录挑战\"}]', '2025-12-31 11:12:13', '2025-12-31 11:12:13');
INSERT INTO `assessment_records` VALUES (8, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":1,\"question\":\"您的睡眠质量如何？\",\"answer\":\"偶尔入睡困难或早醒\"},{\"questionIndex\":2,\"answerIndex\":1,\"question\":\"您的日常精力状态？\",\"answer\":\"下午容易犯困，需咖啡/茶提神\"},{\"questionIndex\":3,\"answerIndex\":2,\"question\":\"您的排便规律吗？\",\"answer\":\"经常便秘或腹泻\"},{\"questionIndex\":4,\"answerIndex\":2,\"question\":\"您的饮食习惯？\",\"answer\":\"经常节食或暴饮暴食\"},{\"questionIndex\":5,\"answerIndex\":2,\"question\":\"您每周运动几次？\",\"answer\":\"几乎不运动，能坐不站\"},{\"questionIndex\":6,\"answerIndex\":2,\"question\":\"您的情绪状态？\",\"answer\":\"经常压力大，易发脾气\"},{\"questionIndex\":7,\"answerIndex\":2,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"容易手脚冰凉\"},{\"questionIndex\":8,\"answerIndex\":2,\"question\":\"您的健康目标？\",\"answer\":\"增强体力\"},{\"questionIndex\":9,\"answerIndex\":2,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"运动跟练计划\"}]', '2026-01-22 16:41:15', '2026-01-22 16:41:15');
INSERT INTO `assessment_records` VALUES (9, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":1,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"饮食记录+推荐\"}]', '2026-01-22 18:29:12', '2026-01-22 18:29:12');
INSERT INTO `assessment_records` VALUES (10, 1, '[{\"questionIndex\":0,\"answerIndex\":1,\"question\":\"您的体型如何？\",\"answer\":\"偏瘦\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":3,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"经常感到口渴或口干\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":1,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"饮食记录+推荐\"}]', '2026-01-22 18:38:32', '2026-01-22 18:38:32');
INSERT INTO `assessment_records` VALUES (11, 1, '[{\"questionIndex\":0,\"answerIndex\":2,\"question\":\"您的体型如何？\",\"answer\":\"偏胖\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2026-01-22 19:24:19', '2026-01-22 19:24:19');
INSERT INTO `assessment_records` VALUES (12, 1, '[{\"questionIndex\":0,\"answerIndex\":1,\"question\":\"您的体型如何？\",\"answer\":\"偏瘦\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":1,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"饮食记录+推荐\"}]', '2026-01-22 19:56:21', '2026-01-22 19:56:21');
INSERT INTO `assessment_records` VALUES (13, 1, '[{\"questionIndex\":0,\"answerIndex\":3,\"question\":\"您的体型如何？\",\"answer\":\"肌肉线条明显\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2026-01-22 19:57:58', '2026-01-22 19:57:58');
INSERT INTO `assessment_records` VALUES (14, 1, '[{\"questionIndex\":0,\"answerIndex\":2,\"question\":\"您的体型如何？\",\"answer\":\"偏胖\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2026-01-22 20:53:51', '2026-01-22 20:53:51');
INSERT INTO `assessment_records` VALUES (15, 1, '[{\"questionIndex\":0,\"answerIndex\":3,\"question\":\"您的体型如何？\",\"answer\":\"肌肉线条明显\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2026-01-26 14:15:31', '2026-01-26 14:15:31');
INSERT INTO `assessment_records` VALUES (16, 1, '[{\"questionIndex\":0,\"answerIndex\":3,\"question\":\"您的体型如何？\",\"answer\":\"肌肉线条明显\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"},{\"questionIndex\":10,\"answerIndex\":3,\"question\":\"您对温度的敏感度？\",\"answer\":\"手心脚心发热\"},{\"questionIndex\":11,\"answerIndex\":3,\"question\":\"您的出汗情况？\",\"answer\":\"出汗正常\"},{\"questionIndex\":12,\"answerIndex\":1,\"question\":\"您的饮水习惯？\",\"answer\":\"口干但不想喝水\"},{\"questionIndex\":13,\"answerIndex\":1,\"question\":\"您的食欲如何？\",\"answer\":\"食欲差，吃一点就饱\"},{\"questionIndex\":14,\"answerIndex\":3,\"question\":\"您的面色如何？\",\"answer\":\"晦暗有斑\"},{\"questionIndex\":15,\"answerIndex\":3,\"question\":\"您的声音特点？\",\"answer\":\"正常\"},{\"questionIndex\":16,\"answerIndex\":3,\"question\":\"您的呼吸情况？\",\"answer\":\"急促\"},{\"questionIndex\":17,\"answerIndex\":3,\"question\":\"您的记忆力和专注力？\",\"answer\":\"反应迟钝\"},{\"questionIndex\":18,\"answerIndex\":3,\"question\":\"您平时的身体抵抗力？\",\"answer\":\"有过敏史\"},{\"questionIndex\":19,\"answerIndex\":3,\"question\":\"您是否有以下胃部不适？\",\"answer\":\"无明显不适\"},{\"questionIndex\":20,\"answerIndex\":1,\"question\":\"您是否有以下眼部感觉？\",\"answer\":\"视物模糊\"},{\"questionIndex\":21,\"answerIndex\":3,\"question\":\"您的舌象大概是？（照镜子观察）\",\"answer\":\"舌紫暗，有瘀点\"},{\"questionIndex\":22,\"answerIndex\":3,\"question\":\"您的小便情况？\",\"answer\":\"正常\"},{\"questionIndex\":23,\"answerIndex\":3,\"question\":\"您的皮肤状态？\",\"answer\":\"容易过敏瘙痒\"},{\"questionIndex\":24,\"answerIndex\":3,\"question\":\"（女性）您的月经情况？/（男性）您的性功能？\",\"answer\":\"不规律\"}]', '2026-01-26 14:16:42', '2026-01-26 14:16:42');
INSERT INTO `assessment_records` VALUES (17, 1, '[{\"questionIndex\":0,\"answerIndex\":3,\"question\":\"您的体型如何？\",\"answer\":\"肌肉线条明显\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2026-01-26 16:48:25', '2026-01-26 16:48:25');
INSERT INTO `assessment_records` VALUES (18, 1, '[{\"questionIndex\":0,\"answerIndex\":1,\"question\":\"您的体型如何？\",\"answer\":\"偏瘦\"},{\"questionIndex\":1,\"answerIndex\":3,\"question\":\"您的睡眠质量如何？\",\"answer\":\"作息紊乱，昼夜颠倒\"},{\"questionIndex\":2,\"answerIndex\":3,\"question\":\"您的日常精力状态？\",\"answer\":\"一动就累，懒得动\"},{\"questionIndex\":3,\"answerIndex\":3,\"question\":\"您的排便规律吗？\",\"answer\":\"不规律，很少关注\"},{\"questionIndex\":4,\"answerIndex\":3,\"question\":\"您的饮食习惯？\",\"answer\":\"爱吃零食，饮料不断\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":3,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"经常感到口渴或口干\"},{\"questionIndex\":8,\"answerIndex\":3,\"question\":\"您的健康目标？\",\"answer\":\"调节情绪\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2026-01-26 16:48:43', '2026-01-26 16:48:43');

-- ----------------------------
-- Table structure for health_checkins
-- ----------------------------
DROP TABLE IF EXISTS `health_checkins`;
CREATE TABLE `health_checkins`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `checkin_date` date NOT NULL COMMENT '打卡日期',
  `sleep_hours` decimal(4, 2) NOT NULL COMMENT '睡眠时长（小时）',
  `sleep_time` time NOT NULL COMMENT '入睡时间',
  `symptoms` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '症状列表JSON',
  `mood` int NULL DEFAULT NULL COMMENT '心情指数（0-4）',
  `exercise_minutes` int NULL DEFAULT NULL COMMENT '运动时长（分钟）',
  `diet_notes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '饮食记录',
  `followed_plan` tinyint(1) NOT NULL COMMENT '是否按昨日方案执行',
  `health_score` int NULL DEFAULT 0 COMMENT '综合健康分(0-100)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `analysis_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '健康分析总结',
  `analysis_suggestions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '个性化建议JSON',
  `analysis_risks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '风险提示JSON',
  `analysis_tomorrow_plan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '明日养生方案',
  `analysis_tomorrow_tasks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '明日重点任务JSON',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_date`(`user_id` ASC, `checkin_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康打卡记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of health_checkins
-- ----------------------------
INSERT INTO `health_checkins` VALUES (1, 1, '2025-10-30', 7.50, '23:10:00', '[\"失眠\",\"食欲不振\"]', 1, 40, '清淡饮食', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (2, 1, '2025-10-31', 6.00, '00:05:00', '[\"疲劳\"]', 1, 20, '少油少盐', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (3, 1, '2025-11-01', 8.00, '22:45:00', '[\"无症状\"]', 2, 60, '蛋白质补充', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (4, 1, '2025-11-02', 7.00, '23:30:00', '[\"头痛\"]', 2, 30, '多喝水', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (5, 1, '2025-11-03', 6.50, '00:20:00', '[\"腹胀\",\"疲劳\"]', 1, 25, '少食多餐', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (6, 1, '2025-11-04', 8.20, '22:50:00', '[\"无症状\"]', 3, 45, '均衡饮食', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (7, 1, '2025-11-05', 7.80, '23:05:00', '[\"失眠\",\"食欲不振\"]', 2, 50, '注意作息', 0, 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (8, 1, '2025-11-25', 9.00, '23:00:00', '[\"食欲不振\",\"腹胀\"]', 1, 30, '', 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (9, 1, '2025-12-31', 7.50, '23:00:00', '[\"失眠\"]', 2, 30, '', 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (10, 1, '2026-01-16', 8.00, '23:00:00', '[]', 4, 30, '', 0, 92, NULL, '2026-01-26 19:33:31', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `health_checkins` VALUES (35, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体状态非常平稳，气血调和，是中医所说的“阴平阳秘”的理想状态，请继续保持。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡，8小时睡眠，符合“子时大睡”的养生原则，有助于肝胆排毒和阴血滋养。建议继续保持这个“生物钟”，让身体形成稳定的节律。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动是疏通经络、运行气血的好习惯。建议可以尝试在早晨（阳气升发时）进行，如八段锦或快走，能更好地提振一天的阳气。\"},{\"title\":\"**饮食方面**\",\"content\":\"从数据看，您的饮食记录为空。中医讲究“饮食有节”，建议三餐定时，尤其要重视早餐（辰时，胃经当令），为一天的活动提供“水谷精微”（能量来源）。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是健康的重要基石，中医认为“肝主疏泄”，心情舒畅则气机调达。可以多接触自然，听听舒缓音乐，巩固这份平和。\"}]', '[]', '基于您良好的基础，明日方案旨在“锦上添花”，强化养生效果：\n*   **晨起**：在7-9点（胃经旺盛时）吃一顿温暖的早餐，如小米粥、山药粥，健脾养胃。\n*   **上午**：将30分钟运动安排在早餐后1小时进行，以和缓的有氧运动为主，助消化、生阳气。\n*   **午后**：适当小憩或闭目养神15分钟，养护心气。\n*   **傍晚**：减少思虑，可进行一些放松的阅读或与家人交流，让心神安宁。', '[\"**07:30-08:00** 吃一顿温暖的早餐，唤醒脾胃之气。\",\"**早餐后1小时（约09:30）** 进行30分钟和缓运动，如快走或八段锦。\",\"**午餐后（约13:00）** 静坐或慢走10分钟，帮助脾胃运化，避免“食后即卧”。\",\"**睡前30分钟（22:30）** 用温水泡脚10分钟，引气血下行，助您安然入眠。\",\"您已经建立了非常健康的生活框架，细微的调整会让身心状态更上一层楼。请带着轻松的心情，享受明日的健康生活。\"]');
INSERT INTO `health_checkins` VALUES (36, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体状态非常平稳，气血调和，是中医所说的“阴平阳秘”的理想状态，请继续保持。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您的睡眠时长和入睡时间都很好，符合“子时养肝”的规律。建议可以尝试在睡前用温水泡脚15分钟，微微出汗即可，这能引气血下行，帮助心肾相交，让睡眠质量更上一层楼。\"},{\"title\":\"**运动方面**\",\"content\":\"30分钟的运动量恰到好处，有助于气血流通。建议可以尝试将部分运动换成中国传统导引术，如八段锦或太极拳，这类运动更注重“调息”与“调身”，能更好地疏通经络、培补元气。\"},{\"title\":\"**饮食方面**\",\"content\":\"从数据看，您的饮食记录为空，这是一个可以优化的关键点。中医讲究“五谷为养”，建议明日开始，可以简单记录三餐的主食、蔬菜和蛋白质摄入，确保饮食均衡，脾胃（后天之本）才能得到充分滋养。\"},{\"title\":\"**情绪调节**\",\"content\":\"“良好”的情绪是健康的基石。可以尝试在白天闲暇时，有意识地做3-5次深呼吸，吸气时想象清气充满胸腔，呼气时想象浊气排出体外，这有助于维持肝气条达，让好情绪更稳固。\"}]', '[]', '基于您稳定的基础，明日的方案旨在“精益求精”。重点放在 **“健脾”** 和 **“养神”** 上。具体为：早餐食用温热的小米粥以健脾和胃；午餐后缓行以助运化；傍晚练习一段八段锦中的“调理脾胃须单举”招式；晚间用温水泡脚并提前进入放松状态。', '[\"**07:30** 起床后，喝一杯温水，唤醒沉睡的脾胃之气。\",\"**12:30** 午餐后，切勿立即坐下，慢走或站立10分钟，帮助脾胃运化食物。\",\"**18:00** 练习八段锦10分钟，重点感受“调理脾胃须单举”这一式对躯干的拉伸。\",\"**22:30** 开始用40℃左右温水泡脚15分钟，同时听听舒缓的音乐或闭目养神。\",\"**23:00** 准时上床，将手机放远，可进行5分钟的腹式深呼吸助眠。\"]');
INSERT INTO `health_checkins` VALUES (37, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体健康状态非常平稳，作息规律，身心和谐，是中医所推崇的“阴平阳秘”的良好状态。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡、睡足8小时的习惯非常好，顺应了“子时（23-1点）养胆，丑时（1-3点）养肝”的规律，有助于肝胆排毒和气血修复。继续保持。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动是激活阳气、疏通经络的好方法。建议可以尝试在早晨（阳气生发之时）或傍晚（气血流注于肾经之时）进行，效果更佳。\"},{\"title\":\"**饮食方面**\",\"content\":\"饮食记录为空，无法具体分析。中医讲究“五谷为养”，建议三餐规律，食物多样，尤其注意早餐要温热、易消化，以养护脾胃之气。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是千金难买的健康基石。中医认为“肝主疏泄”，心情舒畅则肝气条达，气血运行顺畅。可以多接触自然，听听舒缓音乐来维持这种状态。\"}]', '[]', '基于您稳定的基础，明日方案旨在“锦上添花”，进一步巩固和提升您的健康水平：\n*   **晨起养阳**：在您原有运动基础上，尝试在日出后（约7-8点）进行户外散步或慢跑15分钟，充分吸收自然界升发的阳气。\n*   **饮食增色**：有意识地在午餐或晚餐中加入一些黄色食物（如小米、南瓜、山药），中医认为黄色入脾，能更好地健脾养胃。\n*   **午后养心**：午后1-3点（心经当令），可闭目养神或小憩15分钟，有助于滋养心血，缓解午后疲劳。', '[\"07:30 起床后，喝一杯温水，唤醒脾胃，为一天消化吸收做好准备。\",\"12:30 午餐后，不要立刻坐下，慢走或站立10分钟，帮助脾胃运化，避免食积。\",\"13:00 午后小憩或闭目养神15分钟，养心安神，为下午储备精力。\",\"22:30 睡前半小时，放下手机，可以听听轻音乐或进行5分钟腹式呼吸，让心神和身体都平静下来，准备进入优质睡眠。\",\"您已经建立了非常健康的生活节奏，请继续保持这份从容与规律，身体会回报您更多的活力与平和。\"]');
INSERT INTO `health_checkins` VALUES (38, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体状态非常平稳，各项数据都显示您正维持着良好的生活节律，气血运行顺畅，是“阴平阳秘”的理想状态。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡、睡足8小时的习惯非常好，这顺应了中医“子时养胆，丑时养肝”的规律，有助于肝胆排毒和阴血修复。继续保持，这是您健康的基石。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动是“动则生阳”的好方法，能有效推动气血循环。建议可以尝试在运动中加入一些柔和的伸展，如八段锦或瑜伽，以“刚柔并济”，更好地疏通经络。\"},{\"title\":\"**饮食方面**\",\"content\":\"您的饮食记录为空白，这是关键的调理入口。建议您开始简单记录三餐，观察饮食是否均衡。中医讲究“五谷为养”，明日可侧重增加一些黄色食物（如小米、南瓜）来养护脾胃这个“后天之本”。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪良好”是千金难买的健康法宝，中医认为“恬淡虚无，真气从之”。建议您可以将这种良好情绪与深呼吸结合，在午后静坐片刻，有意识地让气机下沉，能更好地涵养心神。\"}]', '[]', '基于您稳定的状态，明日方案旨在“锦上添花”，强化脾胃功能并进一步滋养气血。建议饮食上注重“黄色入脾”，午餐可安排小米粥或南瓜羹；运动上可将30分钟拆分为晨起15分钟舒展筋骨，傍晚15分钟散步，以顺应阳气“生发”与“收藏”的节奏；并尝试在午后（13:00-15:00，心经当令时）闭目养神10分钟，以静养心。', '[\"07:30 起床后，喝一杯温水，慢慢咽下，唤醒脾胃之气。\",\"12:30 午餐时，请有意识地先吃几口主食（米饭/馒头），保护胃气。\",\"15:00 下午工作间隙，离开座位，远眺窗外绿色植物2分钟，舒缓肝经。\",\"22:30 开始洗漱，准备进入睡眠程序，让身心逐渐“收”回来。\",\"您做得很好，请继续保持这份对自己身体的细心关照。养生如细雨润物，贵在坚持，您已经走在非常正确的道路上了。\"]');
INSERT INTO `health_checkins` VALUES (39, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体状态非常平稳，各项数据都显示您正维持着良好的生活节律，气血运行顺畅。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡、睡足8小时的习惯非常符合中医“子时养肝”的理念，有助于肝血归藏和身体修复。继续保持这个“黄金作息”是您健康的重要基石。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动是激活阳气、促进气血流通的好方法。建议可以尝试在早晨（阳气升发时）或傍晚（气血平和时）进行，让运动与自然节律更同步。\"},{\"title\":\"**饮食方面**\",\"content\":\"您今日的饮食记录为空，无法提供具体分析。中医讲究“饮食有节”，建议您可以开始简单记录三餐，这能帮助我们更好地判断您的脾胃运化情况和营养均衡度。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是千金难买的健康财富。中医认为“恬淡虚无，真气从之”，保持这份平和愉悦的心态，就是最好的“养神”之法。\"}]', '[]', '基于您稳定的基础，明日的方案旨在“锦上添花”，进一步优化细节：\n*   **饮食观察**：开始记录三餐的主要食物，关注食物的性味（如寒热温凉）和身体吃完后的感受（是否舒服、有无饱胀）。\n*   **运动微调**：如果条件允许，尝试将30分钟运动安排在日出后（如早晨7-9点），此时阳气生发，运动效果事半功倍，能更好地提振一天的精神。\n*   **强化养神**：利用您情绪良好的优势，在午间（11点-13点，心经当令）或傍晚，安排5-10分钟的静坐或深呼吸，主动为心神“充电”，巩固情绪防线。', '[\"**07:30** 起床后，喝一杯温水（约200ml），慢慢饮下，唤醒沉睡的脾胃，为一天消化吸收打好基础。\",\"**午餐后** 稍事休息，然后慢走或站立10分钟，所谓“饭后百步走，活到九十九”，有助于脾胃运化，避免食积。\",\"**21:30** 开始营造睡眠氛围，用温水泡脚10分钟（水位没过脚踝），引气血下行，有助于心肾相交，促进深度睡眠。\",\"**22:30** 远离手机、电脑等电子屏幕，可以听一段舒缓的音乐或进行5分钟正念冥想，让心神逐渐安宁下来，准备进入“子时”的黄金睡眠。\",\"您已经做得很棒了，这些细微的调整是为了让您的健康状态更加精益求精。请继续保持，我们明天见！\"]');
INSERT INTO `health_checkins` VALUES (40, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您目前整体状态平稳，作息规律，气血调和，是维持健康的好基础。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡，8小时睡眠，基本符合中医“子时（23点-1点）养肝血”的规律，非常好。建议继续保持，让肝胆在最佳时间得到充分修复。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动有助于气血流通。考虑到您没有特殊症状，可以尝试在运动中加入一些舒缓拉伸，如八段锦或瑜伽，这能更好地疏通经络，达到“动中有静”的平衡。\"},{\"title\":\"**饮食方面**\",\"content\":\"打卡中未记录具体饮食。从中医“四季养生”角度看，当前季节（请用户自行对应春夏秋冬）饮食宜注重（例如：春季养肝，可适当吃些绿色蔬菜；夏季清心，可吃些瓜类；秋季润肺，可吃些白色食物；冬季补肾，可吃些根茎类）。建议明日饮食记录可更具体些。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是健康的基石。中医认为“肝主疏泄”，情绪舒畅则肝气调达。可以尝试在午后或傍晚，当您感觉思绪较多时，进行几分钟的深呼吸，有助于清心宁神。\"}]', '[]', '基于您良好的基础，明日方案旨在“微调以增效”。重点是在规律作息中，加入一个“午间养心”的小环节，并丰富饮食记录，以便后续更有针对性地提供建议。', '[\"**07:30** 起床后，喝一杯温水（约200ml），慢慢饮下，唤醒脾胃阳气，为一天消化吸收做好准备。\",\"**12:30 午餐后** 不要立刻坐下，慢走或站立10分钟，所谓“饭后百步走，活到九十九”，有助于脾胃运化，避免食积。\",\"**13:00-13:15** （或午休时段）闭目养神15分钟，即使睡不着，“眼闭则血归肝”，能有效补充精力，养护心神。\",\"**22:30** 开始睡前准备，远离手机、电脑等屏幕。可以用温水泡脚5-10分钟，引气血下行，有助于心肾相交，提升睡眠质量。\",\"您做得很好，请继续保持这份对自己健康的细心关照。微小的习惯坚持，会带来长久的平衡与活力。\"]');
INSERT INTO `health_checkins` VALUES (41, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体状态非常平稳，作息规律，身心和谐，是中医所说的“阴平阳秘”的理想状态。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡，8小时睡眠，完全符合“子时大睡”的黄金法则，非常棒。建议继续保持，让肝胆在夜间得到充分修复，这是养肝血、排毒素的关键。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动有助于气血流通。可以尝试将部分运动时间安排在早晨（如日出后），顺应阳气升发的自然规律，能更好地提振一天的精神。\"},{\"title\":\"**饮食方面**\",\"content\":\"您的饮食记录为空，这是维持健康的重要一环。建议开始简单记录，重点是观察三餐是否规律、食物是否均衡（五色五味），这能帮助您了解自己的“脾胃运化”情况，即消化吸收功能。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是千金难买的健康基石。中医认为“恬淡虚无，真气从之”，保持这种平和愉悦的心态，本身就是最好的养生。\"}]', '[]', '基于您良好的基础，明日的方案旨在“锦上添花”，进一步优化气血循环与能量储备。核心是 **“借天时，养脾胃”** ：利用早晨阳气生发时适度活动，利用白天脾胃功能旺盛时规律进食，利用夜间阴气收藏时安心静卧。', '[\"**07:30** 起床后，喝一杯温水（可加一片生姜），唤醒沉睡的脾胃阳气，促进肠道蠕动。\",\"**12:30 午餐后** 切勿立即坐下或午睡，慢走或站立10分钟，所谓“饭后百步走，活到九十九”，有助于脾胃运化，避免食积。\",\"**21:30** 开始减少用脑，远离手机电脑等屏幕蓝光。蓝光类似“小火”，会干扰身体准备进入“阴静”状态的信号。\",\"**22:30** 用温水泡脚15分钟（水位过脚踝），引气血下行，有助于放松身心，为接下来的优质睡眠“预热”。\",\"您已经做得非常出色，这些细微的调整会让您的健康根基更加稳固。请继续保持这份对自己身体的关爱与觉察。\"]');
INSERT INTO `health_checkins` VALUES (42, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您的整体状态非常平稳，气血调和，是中医里“阴平阳秘”的理想状态，请继续保持这份良好的生活节奏。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡、睡足8小时的习惯非常好，顺应了“子时（23点-1点）养胆，丑时（1点-3点）养肝”的规律，有助于肝胆排毒和气血修复。建议继续保持，这是您健康的基石。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动能有效推动气血运行，疏通经络。建议可以尝试在运动中加入一些拉伸或舒缓的动作，如八段锦的“两手托天理三焦”，能更好地调和全身气机。\"},{\"title\":\"**饮食方面**\",\"content\":\"数据中未记录具体饮食。从中医“四季养生”角度看，当前时节（假设为春夏之交）饮食宜“省酸增甘，以养脾气”。建议明日可适当增加一些黄色或甘味的食物，如小米、山药、南瓜，来温和滋养脾胃。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是千金难买的“神安”。中医认为“恬淡虚无，真气从之”，保持这份平和愉悦的心态，本身就是最好的养生。\"}]', '[]', '基于您稳定的基础，明日方案旨在“微调”以达“优化”。重点放在 **“健脾”** 和 **“午间养心”** 上：\n*   **早餐**：可安排小米山药粥，健脾养胃。\n*   **午间**（11:00-13:00，心经当令）：尝试闭目静坐10分钟，哪怕不睡着，也有助于心气血的养护。\n*   **下午**：将部分运动时间改为户外散步，接触自然阳光和新鲜空气，吸收“阳气”以生发活力。\n*   **傍晚**：饮食避免过于油腻，减轻脾胃夜间负担。', '[\"07:30 起床后，喝一杯温水，唤醒脾胃之气。\",\"11:30 午餐时，细嚼慢咽，感受食物本味，脾胃更欢喜。\",\"13:00 午饭后，不急坐下，靠墙站立或慢走5分钟，助消化、防积食。\",\"21:30 开始营造睡眠氛围，用温水泡脚10分钟，引气血下行，助安眠。\",\"您已经做得非常出色，明日的微调是为了让身体这台精密的仪器运行得更加顺畅、长久。请带着轻松的心情去实践。\"]');
INSERT INTO `health_checkins` VALUES (43, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您目前整体状态非常平稳，作息规律，身心和谐，是中医里“阴平阳秘”的理想状态。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡，8小时睡眠，非常符合中医“子时（23点-1点）养肝血”的黄金法则。继续保持这个节奏，能让肝气顺畅，第二天精力更充沛。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动有助于气血流通。建议可以尝试在运动中加入一些舒缓拉伸，如八段锦或瑜伽，这能更好地疏通经络，达到“动以养阳，静以养阴”的平衡。\"},{\"title\":\"**饮食方面**\",\"content\":\"您的饮食记录为空。从中医“脾胃为后天之本”的角度，建议您可以开始简单记录三餐，观察饮食是否规律、均衡。例如，早餐是否在辰时（7-9点，胃经当令）完成，这对养护脾胃之气至关重要。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是千金难买的健康基石。中医认为“肝主疏泄”，心情舒畅则肝气条达。可以每天花5分钟静坐，关注呼吸，这能帮助您更好地涵养心神，巩固这个好状态。\"}]', '[]', '基于您良好的基础，明日的方案侧重于“微调”和“巩固”。重点在**强化脾胃功能**和**深化放松**。建议早餐尝试温暖易消化的粥品（如小米粥）来唤醒脾胃；将30分钟运动中的后10分钟改为散步或拉伸，让身体从“动”自然过渡到“静”；睡前尝试用温水泡脚10分钟，引气血下行，助您睡得更好。', '[\"**07:30-08:00** 喝一杯温水，然后吃一顿温暖的早餐（如小米粥），顺应胃经当令的时辰，开启元气满满的一天。\",\"**午餐后（约13:00）** 慢走或站立10分钟，避免久坐，有助于脾胃运化食物，防止午后困倦。\",\"**运动结束后** 花5分钟做简单的拉伸，重点伸展四肢，让运动带来的气血顺畅布散全身。\",\"**睡前30分钟（22:30）** 用40℃左右的温水泡脚10分钟，微微出汗即可，有助于引火归元，放松身心，为高质量睡眠做准备。\",\"您做得非常好，请继续保持这份对自己健康的细心关照。养生即养习惯，细微之处见真章。\"]');
INSERT INTO `health_checkins` VALUES (44, 1, '2026-02-02', 8.00, '23:00:00', '[]', 2, 30, '', 0, 84, NULL, NULL, '您目前整体状态平稳，作息规律，气血调和，是维持健康的良好基础。', '[{\"title\":\"**睡眠方面**\",\"content\":\"您23点入睡，8小时睡眠，基本符合“子时（23点-1点）养肝血”的规律，非常好。可以尝试将入睡时间再提前15-30分钟，更深度地顺应“阳入于阴”的自然节律，让睡眠质量更上一层楼。\"},{\"title\":\"**运动方面**\",\"content\":\"每日30分钟运动有助于气血流通。建议可以尝试将部分运动时间安排在早晨（如7-9点，胃经当令时），此时阳气升发，运动能更好地激发一天的活力，起到“升阳”的效果。\"},{\"title\":\"**饮食方面**\",\"content\":\"饮食记录为空，这是关键信息。中医讲究“饮食有节”，建议您开始简单记录三餐，关注食物的“性味”（如寒热温凉）和是否规律，这是调和脾胃、滋养气血的根本。\"},{\"title\":\"**情绪调节**\",\"content\":\"“情绪状态良好”是千金难买的健康法宝。中医认为“肝主疏泄”，情绪舒畅则肝气调达，气血畅通。可以继续保持，并有意识地在午后（如15-17点，膀胱经当令时）稍作静坐或深呼吸，帮助身体顺利排解一天的压力浊气。\"}]', '[]', '基于您良好的基础，明日方案旨在“微调以增效”。重点是在保持现有作息运动的同时，**引入饮食观察与晨间升阳**。早晨进行温和运动（如快走、拉伸），三餐注意定时、适量，并观察饭后身体的感受（如是否饱胀、精力如何），为后续个性化调理积累信息。', '[\"**07:30** 起床后，喝一杯温水（可加一片生姜），唤醒脾胃阳气。\",\"**08:00** 进行15-20分钟的晨间拉伸或快走，顺应阳气升发，提振精神。\",\"**午餐后**（约13:00） 慢走或站立10分钟，帮助脾胃运化，避免“饭后即卧伤气”。\",\"**22:30** 开始远离手机、电脑等屏幕，用温水泡脚10分钟或听舒缓音乐，让心神和身体提前进入放松状态，为优质睡眠做准备。\",\"您已经做得很棒了，这些细微的调整是为了让身体这台精密的仪器运行得更加顺畅、持久。请继续保持这份对自己健康的关爱。\"]');

-- ----------------------------
-- Table structure for health_trends
-- ----------------------------
DROP TABLE IF EXISTS `health_trends`;
CREATE TABLE `health_trends`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `trend_date` date NOT NULL COMMENT '趋势日期',
  `health_score` int NOT NULL COMMENT '健康得分',
  `sleep_quality_score` int NOT NULL COMMENT '睡眠质量得分',
  `mood_score` int NOT NULL COMMENT '情绪得分',
  `exercise_score` int NOT NULL COMMENT '运动得分',
  `diet_score` int NOT NULL COMMENT '饮食得分',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_user_trend_date`(`user_id` ASC, `trend_date` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_trend_date`(`trend_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康趋势数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of health_trends
-- ----------------------------
INSERT INTO `health_trends` VALUES (1, 1, '2026-01-16', 92, 100, 100, 100, 60, NULL);
INSERT INTO `health_trends` VALUES (5, 1, '2026-01-30', 84, 100, 70, 100, 60, NULL);
INSERT INTO `health_trends` VALUES (6, 1, '2026-02-02', 84, 100, 70, 100, 60, NULL);

-- ----------------------------
-- Table structure for ingredient_interactions
-- ----------------------------
DROP TABLE IF EXISTS `ingredient_interactions`;
CREATE TABLE `ingredient_interactions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item1_id` bigint NOT NULL COMMENT '第一个食材/药材ID',
  `item1_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '第一个食材/药材名称',
  `item2_id` bigint NOT NULL COMMENT '第二个食材/药材ID',
  `item2_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '第二个食材/药材名称',
  `relationship_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关系类型（相生/相克）',
  `effect_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '效果描述',
  `severity_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '严重程度（轻度/中度/重度）',
  `scientific_basis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '科学依据或中医理论依据',
  `recommendation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '建议（如何搭配或避免）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_item1_id`(`item1_id` ASC) USING BTREE,
  INDEX `idx_item2_id`(`item2_id` ASC) USING BTREE,
  INDEX `idx_relationship_type`(`relationship_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '食材药材相生相克关系表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ingredient_interactions
-- ----------------------------
INSERT INTO `ingredient_interactions` VALUES (1, 1, '枸杞', 5, '菊花', '相生', '枸杞滋补肝肾，菊花清肝明目，两者搭配使用能够增强养肝明目的功效，适合长期用眼、肝肾阴虚的人群。常用于缓解眼睛疲劳、视力模糊、头晕目眩等症状。', '有益', '中医理论：枸杞甘平，入肝肾经；菊花辛甘微寒，入肝肺经。二者配伍，一补一清，补而不滞，清而不伤，共同起到滋养肝肾、清热明目的作用。现代研究表明，枸杞多糖和菊花黄酮类化合物具有协同抗氧化作用。', '建议泡茶饮用：枸杞10-15克，菊花5-8朵，温水冲泡。特别适合长时间使用电脑、手机的人群日常保健。', '2025-11-25 22:18:13', '2025-11-25 22:18:13');
INSERT INTO `ingredient_interactions` VALUES (2, 3, '红枣', 4, '生姜', '相克', '红枣性温味甘，具有补中益气、养血安神的功效；生姜性温味辛，具有发汗解表、温中止呕的作用。两者同时大量食用可能导致体内燥热加重，容易出现口干舌燥、咽喉肿痛、便秘等上火症状。', '中度', '中医理论：红枣与生姜皆性温，同食会加重体内的热性，导致燥热内盛。现代营养学认为，生姜中的姜辣素与红枣中的糖分结合，可能刺激胃黏膜，增加胃肠负担，对于本身胃热较重或阴虚火旺的人群尤其不利。', '如需同时使用，建议控制用量：红枣不超过5颗，生姜2-3片即可。阴虚火旺、内热较重者应避免同时食用。可以分开使用，或者搭配一些性凉的食材如薄荷、绿茶来平衡。', '2025-11-25 22:18:13', '2025-11-25 22:18:13');
INSERT INTO `ingredient_interactions` VALUES (3, 26, '当归', 8, '绿茶', '相克', '当归是常用的补血活血药材，而绿茶含有大量的鞣酸和茶碱。鞣酸会与当归中的有效成分结合，形成难以吸收的沉淀物，大大降低当归的药效。同时，茶碱的利尿作用会加速当归成分的排出，影响补血效果。', '中度', '现代药理学研究表明，茶叶中的鞣酸（单宁酸）会与当归中的铁离子、多糖等活性成分发生化学反应，生成不易被人体吸收的络合物。此外，绿茶的碱性成分会改变胃肠道的pH值，影响当归有效成分的溶出和吸收。', '服用当归及含当归的中药时，应避免同时饮用绿茶、红茶等茶饮。建议服药前后2小时内不要喝茶。如需饮品，可选择温开水或淡盐水。日常保健时，也应避免当归与茶叶长期同食。', '2025-11-25 22:18:13', '2025-11-25 22:18:13');

-- ----------------------------
-- Table structure for knowledge_item_tags
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_item_tags`;
CREATE TABLE `knowledge_item_tags`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_id` bigint NOT NULL COMMENT '知识条目ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  `is_primary` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否主标签',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_item_tag`(`item_id` ASC, `tag_id` ASC) USING BTREE,
  INDEX `idx_tag`(`tag_id` ASC) USING BTREE,
  CONSTRAINT `fk_item_tags_item` FOREIGN KEY (`item_id`) REFERENCES `knowledge_items` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_tags_tag` FOREIGN KEY (`tag_id`) REFERENCES `knowledge_tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 563 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识条目标签关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_item_tags
-- ----------------------------
INSERT INTO `knowledge_item_tags` VALUES (1, 3, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (2, 10, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (3, 41, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (4, 42, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (5, 68, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (6, 76, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (7, 94, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (8, 98, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (9, 99, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (10, 100, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (11, 101, 13, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (16, 2, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (17, 3, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (18, 6, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (19, 25, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (20, 27, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (21, 32, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (22, 35, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (23, 66, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (24, 68, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (25, 72, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (26, 73, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (27, 74, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (28, 85, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (29, 89, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (30, 101, 21, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (31, 2, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (32, 3, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (33, 8, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (34, 9, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (35, 11, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (36, 12, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (37, 14, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (38, 16, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (39, 17, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (40, 22, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (41, 25, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (42, 27, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (43, 32, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (44, 43, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (45, 54, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (46, 56, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (47, 58, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (48, 60, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (49, 61, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (50, 63, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (51, 65, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (52, 69, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (53, 73, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (54, 74, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (55, 78, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (56, 86, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (57, 89, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (58, 90, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (59, 92, 22, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (62, 7, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (63, 36, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (64, 40, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (65, 56, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (66, 82, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (67, 83, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (68, 84, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (69, 99, 23, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (77, 16, 19, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (78, 19, 19, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (79, 26, 19, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (80, 46, 19, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (81, 50, 19, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (82, 54, 19, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (84, 2, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (85, 5, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (86, 7, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (87, 8, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (88, 9, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (89, 31, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (90, 32, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (91, 35, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (92, 47, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (93, 55, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (94, 67, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (95, 72, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (96, 73, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (97, 76, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (98, 77, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (99, 80, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (100, 88, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (101, 95, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (102, 96, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (103, 97, 25, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (115, 5, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (116, 8, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (117, 15, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (118, 24, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (119, 33, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (120, 44, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (121, 45, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (122, 46, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (123, 47, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (124, 55, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (125, 59, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (126, 79, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (127, 93, 29, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (130, 5, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (131, 8, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (132, 9, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (133, 15, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (134, 24, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (135, 32, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (136, 36, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (137, 37, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (138, 41, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (139, 44, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (140, 45, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (141, 46, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (142, 47, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (143, 51, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (144, 53, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (145, 54, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (146, 55, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (147, 72, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (148, 77, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (149, 79, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (150, 80, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (151, 87, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (152, 88, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (153, 89, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (154, 90, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (155, 93, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (156, 97, 30, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (161, 1, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (162, 2, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (163, 4, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (164, 7, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (165, 10, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (166, 11, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (167, 12, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (168, 14, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (169, 16, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (170, 18, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (171, 20, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (172, 21, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (173, 22, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (174, 26, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (175, 28, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (176, 30, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (177, 31, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (178, 35, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (179, 38, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (180, 40, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (181, 41, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (182, 49, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (183, 54, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (184, 61, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (185, 62, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (186, 64, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (187, 66, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (188, 67, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (189, 71, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (190, 73, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (191, 74, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (192, 76, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (193, 78, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (194, 82, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (195, 83, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (196, 84, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (197, 85, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (198, 89, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (199, 90, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (200, 91, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (201, 94, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (202, 95, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (203, 96, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (204, 99, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (205, 100, 31, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (224, 1, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (225, 2, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (226, 4, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (227, 7, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (228, 10, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (229, 11, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (230, 12, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (231, 13, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (232, 14, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (233, 16, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (234, 17, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (235, 18, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (236, 20, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (237, 21, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (238, 22, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (239, 26, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (240, 28, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (241, 30, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (242, 31, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (243, 34, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (244, 35, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (245, 38, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (246, 40, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (247, 49, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (248, 62, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (249, 63, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (250, 64, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (251, 67, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (252, 71, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (253, 74, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (254, 75, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (255, 76, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (256, 81, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (257, 82, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (258, 83, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (259, 84, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (260, 91, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (261, 94, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (262, 95, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (263, 96, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (264, 99, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (265, 100, 32, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (287, 3, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (288, 10, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (289, 41, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (290, 42, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (291, 68, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (292, 94, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (293, 98, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (294, 99, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (295, 100, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (296, 101, 43, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (302, 8, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (303, 9, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (304, 14, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (305, 16, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (306, 17, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (307, 25, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (308, 27, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (309, 43, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (310, 54, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (311, 58, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (312, 60, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (313, 61, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (314, 63, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (315, 69, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (316, 73, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (317, 74, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (318, 78, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (319, 86, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (320, 89, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (321, 90, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (322, 92, 45, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (333, 3, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (334, 6, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (335, 25, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (336, 27, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (337, 32, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (338, 35, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (339, 66, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (340, 68, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (341, 72, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (342, 73, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (343, 74, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (344, 85, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (345, 89, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (346, 101, 46, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (348, 1, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (349, 3, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (350, 10, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (351, 16, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (352, 19, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (353, 23, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (354, 26, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (355, 46, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (356, 50, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (357, 66, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (358, 76, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (359, 100, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (360, 101, 53, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (363, 1, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (364, 5, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (365, 36, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (366, 38, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (367, 55, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (368, 57, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (369, 79, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (370, 85, 52, 1, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (378, 4, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (379, 11, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (380, 12, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (381, 13, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (382, 14, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (383, 17, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (384, 20, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (385, 21, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (386, 22, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (387, 24, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (388, 33, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (389, 62, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (390, 63, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (391, 64, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (392, 78, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (393, 81, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (394, 82, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (395, 91, 47, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (409, 4, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (410, 5, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (411, 6, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (412, 8, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (413, 9, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (414, 11, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (415, 12, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (416, 14, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (417, 17, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (418, 19, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (419, 20, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (420, 21, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (421, 24, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (422, 25, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (423, 28, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (424, 29, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (425, 32, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (426, 34, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (427, 40, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (428, 45, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (429, 47, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (430, 49, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (431, 52, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (432, 55, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (433, 58, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (434, 60, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (435, 62, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (436, 63, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (437, 64, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (438, 65, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (439, 67, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (440, 69, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (441, 72, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (442, 75, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (443, 76, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (444, 77, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (445, 79, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (446, 80, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (447, 81, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (448, 83, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (449, 88, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (450, 91, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (451, 92, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (452, 97, 48, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (472, 12, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (473, 14, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (474, 16, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (475, 19, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (476, 26, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (477, 46, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (478, 50, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (479, 56, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (480, 58, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (481, 60, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (482, 65, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (483, 92, 4, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (487, 3, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (488, 8, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (489, 10, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (490, 25, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (491, 27, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (492, 32, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (493, 35, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (494, 42, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (495, 66, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (496, 68, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (497, 73, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (498, 85, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (499, 89, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (500, 94, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (501, 98, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (502, 99, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (503, 100, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (504, 101, 5, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (518, 1, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (519, 2, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (520, 12, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (521, 18, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (522, 30, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (523, 38, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (524, 57, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (525, 75, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (526, 82, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (527, 86, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (528, 89, 9, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (533, 1, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (534, 3, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (535, 10, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (536, 23, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (537, 26, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (538, 66, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (539, 76, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (540, 100, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (541, 101, 7, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (548, 9, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (549, 25, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (550, 27, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (551, 43, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (552, 58, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (553, 61, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (554, 69, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (555, 73, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (556, 74, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (557, 86, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (558, 89, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (559, 90, 1, 0, '2026-02-03 21:40:04');
INSERT INTO `knowledge_item_tags` VALUES (560, 92, 1, 0, '2026-02-03 21:40:04');

-- ----------------------------
-- Table structure for knowledge_items
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_items`;
CREATE TABLE `knowledge_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '食材/药材名称',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类（食材/药材/茶饮等）',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片路径',
  `tcm_effect` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '中医功效',
  `western_nutrition` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '现代营养成分',
  `suitable` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适合体质',
  `taboo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '禁忌',
  `usage_method` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '使用方法',
  `season` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适宜季节',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '中西医知识库表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of knowledge_items
-- ----------------------------
INSERT INTO `knowledge_items` VALUES (1, '枸杞', '药材', '/uploads/knowledge/28af96fc-33ec-4090-ab43-f1c830f51d7b.png', '滋补肝肾，益精明目，养血，增强免疫力', '富含枸杞多糖、类胡萝卜素、维生素A、铁、锌等微量元素', '肝肾阴虚、腰膝酸软、头晕目眩、视力减退者', '外感发热、脾虚泄泻者慎用；过量可能导致上火', '泡水：10-15克/天；煲汤：20克；直接嚼服：5-10克', '四季皆宜，秋冬最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (2, '山药', '食材', '/uploads/knowledge/19ed4f15-8437-4f6f-9213-86e71095df59.png', '补脾养胃，生津益肺，补肾涩精', '富含淀粉、蛋白质、维生素C、钾、磷及黏液质', '脾胃虚弱、食少体倦、久泻久痢、肺虚咳嗽、肾虚遗精', '便秘、湿热重者少食', '煮粥：100克/次；炒食：200克；煲汤：150克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (3, '红枣', '食材', '/uploads/knowledge/457285d3-cdd5-49b8-8c08-14ca3bb86501.png', '补中益气，养血安神，缓和药性', '富含维生素C、维生素P、铁、钙、环磷酸腺苷', '气血不足、心悸失眠、脾胃虚弱者', '湿热内盛、痰湿偏盛、糖尿病患者慎食', '泡水：3-5颗；煲汤：5-8颗；煮粥：6-10颗', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (4, '生姜', '食材', '/uploads/knowledge/1d44d440-f477-4642-88d3-5f0d346be27c.png', '发汗解表，温中止呕，温肺止咳', '富含姜辣素、姜酮、姜醇，有抗炎、抗氧化作用', '风寒感冒、胃寒呕吐、寒痰咳嗽者', '阴虚火旺、内热较重者少食；晚上不宜多食', '煮水：3-5片；炒菜：适量；泡茶：2-3片', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (5, '菊花', '药材', '/uploads/knowledge/d3929684-57be-4dfb-9648-2675e413b39b.png', '疏散风热，清肝明目，清热解毒', '含黄酮类、氨基酸、维生素及微量元素', '风热感冒、目赤肿痛、眩晕头痛、疮痈肿毒', '脾胃虚寒、阳虚体质者慎用', '泡茶：5-10朵；煮水：10-15克', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (6, '黄芪', '药材', '/uploads/knowledge/cc548779-9092-4a32-8de2-0417de00363c.png', '补气升阳，固表止汗，利水消肿，托毒排脓', '含黄芪多糖、皂苷、黄酮类等，增强免疫力', '气虚乏力、中气下陷、久泻脱肛、自汗、水肿', '实证、热证、阴虚阳亢者禁用', '煎汤：10-15克；泡水：5-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (7, '蜂蜜', '食材', '/uploads/knowledge/75c7d661-7e5f-41df-bfaf-7f5e84b02cd4.png', '补中润燥，止痛解毒，润肺止咳', '含葡萄糖、果糖、多种维生素、矿物质及酶类', '体虚、便秘、燥咳、胃痛者', '1岁以下婴儿、糖尿病患者慎食', '温水冲服：20-30克/次；不宜高温冲泡', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (8, '绿茶', '茶饮', '/uploads/knowledge/3f8bee3a-ab9b-4750-a366-5c79e076cd63.jpg', '清热解毒，提神醒脑，消食化痰', '富含茶多酚、咖啡因、维生素C、氨基酸', '内热体质、需要提神者', '失眠、胃寒、贫血者慎饮；不宜空腹饮用', '冲泡：3-5克/次，80-85℃水温', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (9, '薏米', '食材', '/uploads/knowledge/85c0f2e4-d8e5-4288-9639-df69f8771eb5.jpg', '健脾渗湿，除痹止泻，清热排脓', '富含薏苡仁油、氨基酸、维生素B1', '脾虚湿盛、水肿、关节疼痛、肺痈肠痈', '孕妇慎用；津液不足、便秘者少食', '煮粥：30-50克；煲汤：50克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (10, '桂圆', '食材', '/uploads/knowledge/523283ac-b5ff-40a2-90b0-2bface833eae.png', '补益心脾，养血安神', '富含葡萄糖、蛋白质、铁、钾及多种维生素', '心脾两虚、气血不足、失眠健忘', '内有痰火、湿滞、消化不良者慎食', '泡水：5-8颗；煲汤：10-15颗', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (11, '丁香', '香料', '/uploads/knowledge/69f5cd95-60dd-4054-b40f-cacaa7141567.png', '温中降逆，温肾助阳', '含丁香油、鞣质、齐墩果酸', '脾胃虚寒、呃逆呕吐、肾阳不足', '热证、阴虚内热者禁用', '煎汤：3-6克；研末：1-2克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (12, '八角', '香料', '/uploads/knowledge/6d2782c2-bbe4-406c-90bf-079f627c815f.png', '温阳散寒，理气止痛', '含茴香油、茴香醚、茴香酮', '寒疝腹痛、腰膝冷痛', '阴虚火旺者慎用', '煮汤：2-3粒；炖肉：3-5粒', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (13, '刀豆', '食材', '/uploads/knowledge/b2282dce-e990-481f-b2a1-a8382304f252.png', '温中下气，益肾补元', '含蛋白质、维生素、矿物质', '虚寒呃逆、肾虚腰痛', '热证、便秘者少食', '炒食：100克；煮汤：50克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (14, '小茴香', '香料', '/uploads/knowledge/3dc27a6a-d39e-4020-908e-202ea8e2e765.png', '散寒止痛，理气和胃', '含茴香油、茴香脑', '寒疝、少腹冷痛、胃寒呕吐', '阴虚火旺者忌用', '煎汤：3-6克；调味：适量', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (15, '小蒜', '食材', NULL, '通阳散结，行气导滞', '含蒜辣素、维生素C', '胸痹心痛、脘腹痞满', '气虚者慎用', '入菜：适量', '春夏季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (16, '山楂', '食材', '/uploads/knowledge/39b1ec36-7607-4b6a-be6e-f23514e2553a.png', '消食化积，活血散瘀', '含山楂酸、黄酮、维生素C', '食积不化、高血脂', '孕妇、胃酸过多者慎食', '泡水：3-5片；煮汤：10-15克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (17, '山奈', '香料', '/uploads/knowledge/a2fa9fb8-3d7f-4c22-a5ae-eb01a8aa4ef5.png', '温中除湿，行气消食', '含挥发油、山奈酚', '胸隔胀满、脘腹冷痛', '阴虚血燥者忌用', '入菜：少许', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (18, '山萸肉', '药材', '/uploads/knowledge/12fbab11-9aef-43ba-820d-8cde3eaef891.png', '补益肝肾，涩精固脱', '含山茱萸苷、熊果酸', '肝肾不足、腰膝酸软', '实热、小便不利者慎用', '煎汤：6-12克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (19, '川芎', '药材', '/uploads/knowledge/956d943c-932e-4374-ba8f-f377d0a3e723.jpg', '活血行气，祛风止痛', '含川芎嗪、阿魏酸', '血瘀气滞、头痛眩晕', '阴虚火旺、月经过多者慎用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (20, '花椒', '香料', '/uploads/knowledge/95617dd0-9ba5-4433-8bea-484db52c6982.png', '温中止痛，杀虫止痒', '含挥发油、花椒碱', '脘腹冷痛、呕吐泄泻', '阴虚火旺、孕妇慎用', '调味：少许；泡水：3-5粒', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (21, '肉桂', '香料', '/uploads/knowledge/ac338c67-eb1f-4fde-83ee-0bacc5814e52.png', '补火助阳，散寒止痛', '含桂皮醛、桂皮酸', '肾阳不足、畏寒肢冷', '阴虚火旺、孕妇禁用', '煎汤：2-5克；研末：1-2克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (22, '肉蔻', '香料', '/uploads/knowledge/45eb81f4-84c4-4a46-aba6-20661757d224.png', '温中行气，涩肠止泻', '含挥发油、肉豆蔻醚', '脾胃虚寒、久泻不止', '湿热泻痢者忌用', '煎汤：3-10克；研末：1-3克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (23, '白芍', '药材', '/uploads/knowledge/f875da33-3c4a-4e35-8d89-4fd53d1e348d.jpg', '养血调经，敛阴止汗', '含芍药苷、芍药内酯苷', '血虚萎黄、月经不调', '虚寒腹痛者慎用', '煎汤：6-15克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (24, '白芷', '药材', '/uploads/knowledge/5948dbe0-d228-4004-a7fb-164c9a4d1050.png', '解表散寒，祛风止痛', '含白芷素、欧前胡素', '风寒感冒、头痛鼻塞', '阴虚血热者慎用', '煎汤：3-10克', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (25, '白术', '药材', '/uploads/knowledge/08f54662-abfe-49e7-9f34-b5a95c4654d1.jpg', '健脾益气，燥湿利水', '含白术内酯、挥发油', '脾虚食少、腹胀泄泻', '阴虚燥渴者慎用', '煎汤：6-12克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (26, '当归', '药材', '/uploads/knowledge/0b2fdfbc-17b9-431e-b64e-ad53d6444016.png', '补血活血，调经止痛', '含挥发油、阿魏酸、多糖', '血虚萎黄、月经不调、痛经', '湿盛中满、大便溏泄者慎用', '煎汤：6-12克；泡酒：适量', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (27, '党参', '药材', '/uploads/knowledge/859f82b1-4530-45ef-a889-c21336c2e6b8.png', '补中益气，健脾益肺', '含党参多糖、皂苷、微量元素', '气虚乏力、脾肺虚弱', '实证、热证者慎用', '煎汤：10-30克；炖汤：15克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (28, '天麻', '药材', '/uploads/knowledge/c118ca05-5d62-4c6f-bc5a-57a5dfc8251e.png', '息风止痉，平肝潜阳', '含天麻素、天麻多糖', '头痛眩晕、肢体麻木', '血虚、阴虚者慎用', '煎汤：3-10克；研末：1-3克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (29, '半夏', '药材', '/uploads/knowledge/acb61cae-96ec-4760-a58e-72c41843e7fa.jpg', '燥湿化痰，降逆止呕', '含生物碱、多糖', '湿痰咳嗽、呕吐反胃', '阴虚燥咳、孕妇禁用', '煎汤：3-9克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (30, '何首乌', '药材', '/uploads/knowledge/9638473c-3c5e-4ad6-a927-991ddb4a8486.jpg', '补肝肾，益精血，乌须发', '含蒽醌类、卵磷脂', '肝肾不足、须发早白', '大便溏泄、湿痰重者慎用', '煎汤：10-30克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (31, '玉竹', '药材', '/uploads/knowledge/18ec353f-8781-4f8d-9ea0-fb7bed7bb8a4.png', '养阴润燥，生津止渴', '含玉竹多糖、玉竹粘液质', '肺胃阴伤、燥咳痰少', '痰湿气滞者慎用', '煎汤：6-12克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (32, '甘草', '药材', '/uploads/knowledge/d9c8e423-b401-4ee1-a23d-cde4f88e11ab.png', '补脾益气，清热解毒', '含甘草酸、甘草苷、黄酮', '脾胃虚弱、咳嗽痰多', '湿盛中满、水肿者慎用', '煎汤：2-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (33, '防风', '药材', '/uploads/knowledge/18e3ed20-3ea6-4bc2-b856-2c76f5a71993.jpg', '解表祛风，胜湿止痛', '含色原酮、香豆素', '风寒感冒、风湿痹痛', '阴血亏虚者慎用', '煎汤：5-10克', '春季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (34, '附子', '药材', '/uploads/knowledge/52352800-c4e4-46d4-b13b-2ba306dcca13.jpg', '回阳救逆，补火助阳', '含乌头碱、次乌头碱', '亡阳虚脱、肢冷脉微', '阴虚阳盛、孕妇禁用；有毒需炮制', '煎汤：3-15克', '冬季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (35, '五味子', '药材', '/uploads/knowledge/845dfbfe-8062-4f26-8385-b0af23e8ae94.jpg', '收敛固涩，益气生津', '含五味子醇、五味子酯', '久嗽虚喘、自汗盗汗', '外有表邪、内有实热者忌用', '煎汤：2-6克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (36, '决明子', '药材', '/uploads/knowledge/e8a5d855-da31-4349-bd7b-46c89293a78c.png', '清肝明目，润肠通便', '含大黄酚、大黄素', '目赤涩痛、肠燥便秘', '脾胃虚寒、大便溏泄者慎用', '煎汤：9-15克；泡茶：5克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (37, '车前子', '药材', '/uploads/knowledge/f2680e0e-ae74-4d15-bade-dec0fbd71ff7.jpg', '利水通淋，渗湿止泻', '含车前子多糖、黏液质', '水肿尿少、湿热泻痢', '肾虚遗精者慎用', '煎汤：9-15克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (38, '沙苑子', '药材', '/uploads/knowledge/d666c6ed-ce10-4cbc-a163-2f14bb7ccdc4.jpg', '补肾固精，养肝明目', '含脂肪油、黄酮', '肾虚腰痛、遗精早泄', '相火炽盛者慎用', '煎汤：9-15克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (39, '芡实', '食材', '/uploads/knowledge/087d59a9-769a-4951-a7e3-3b311a9ca680.png', '益肾固精，补脾止泻', '含淀粉、蛋白质、维生素', '遗精滑精、脾虚泄泻', '便秘者慎用', '煮粥：15-30克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (40, '苦杏仁', '药材', '/uploads/knowledge/a705ba91-42b1-47fd-bf38-7ee1f3bba22a.png', '止咳平喘，润肠通便', '含苦杏仁苷、脂肪油', '咳嗽气喘、肠燥便秘', '阴虚咳嗽、婴儿慎用；有小毒', '煎汤：5-10克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (41, '莲子', '食材', '/uploads/knowledge/b26dc390-3d19-47ab-a1dd-cc0e7bbef255.png', '补脾止泻，益肾固精', '含淀粉、蛋白质、钙、磷', '脾虚久泻、遗精、失眠', '大便燥结者少食', '煮粥：20克；煲汤：30克', '夏秋季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (42, '酸枣仁', '药材', '/uploads/knowledge/adf1bdea-f042-497e-b22c-da61669baced.png', '养心补肝，宁心安神', '含酸枣仁皂苷、黄酮', '虚烦不眠、惊悸多梦', '实邪郁火者慎用', '煎汤：10-15克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (43, '麦芽', '药材', '/uploads/knowledge/208b949c-8a09-4a1b-b22b-9349436424a0.png', '行气消食，健脾开胃', '含淀粉酶、维生素B', '食积不消、脘腹胀痛', '哺乳期妇女慎用（回乳）', '煎汤：10-15克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (44, '葶苈子', '药材', '/uploads/knowledge/7d4350fe-725b-46ba-9880-4772f2317855.jpg', '泻肺平喘，利水消肿', '含芥子苷、脂肪油', '痰涎壅肺、喘咳痰多', '肺虚喘咳者慎用', '煎汤：3-10克', '春夏季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (45, '玫瑰花', '茶饮', '/uploads/knowledge/eb42333e-0047-4626-8ca0-83ccadebe541.jpg', '行气解郁，和血止痛', '含挥发油、槲皮苷、维生素', '肝胃气痛、月经不调', '阴虚火旺者慎用', '泡茶：5-10朵', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (46, '月季花', '药材', '/uploads/knowledge/df409fdc-fe62-4e12-9a05-5827b6f542d5.jpg', '活血调经，疏肝解郁', '含挥发油、鞣质', '月经不调、痛经', '孕妇禁用', '泡茶：3-6克', '春夏季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (47, '金银花', '药材', '/uploads/knowledge/ade7e832-c046-4ed5-b5d6-1ad32cade83d.png', '清热解毒，疏散风热', '含绿原酸、黄酮类化合物', '温病发热、疮痈肿毒', '脾胃虚寒、气虚疮疡者慎用', '泡茶：10克；煎汤：10-20克', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (48, '洋金花', '药材', '/uploads/knowledge/7ce03183-fea1-4ff1-a909-651e2971b959.jpg', '平喘止咳，解痉定痛', '含东莨菪碱、莨菪碱', '哮喘、胃痛', '孕妇、青光眼患者禁用；有毒', '煎汤：0.3-0.6克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (49, '款冬花', '药材', '/uploads/knowledge/3f3b1b3e-99d2-4418-a153-b23c7c0f4f58.jpg', '润肺下气，止咳化痰', '含款冬二醇、芸香苷', '咳嗽气喘、痰中带血', '阴虚劳嗽者慎用', '煎汤：5-10克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (50, '红花', '药材', '/uploads/knowledge/4b77cbb5-46bd-4018-bcb8-f84cbb958684.jpg', '活血通经，散瘀止痛', '含红花黄色素、红花苷', '经闭痛经、跌打损伤', '孕妇、月经过多者禁用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (51, '槐花', '药材', '/uploads/knowledge/272e66a9-49e3-4e6f-86b4-cbb982afe73f.png', '凉血止血，清肝泻火', '含芦丁、槲皮素', '便血、痔血、高血压', '脾胃虚寒者慎用', '煎汤：10-15克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (52, '旋覆花', '药材', '/uploads/knowledge/a79848e5-fd55-4ed6-863f-1e47a49150a5.jpg', '降气化痰，降逆止呕', '含旋覆花内酯、槲皮素', '痰壅胸膈、噫气呕吐', '阴虚劳嗽者慎用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (53, '乌梅', '食材', '/uploads/knowledge/ef52f70e-081b-493d-b29a-2bc0547af951.png', '敛肺止咳，涩肠止泻', '含柠檬酸、苹果酸、维生素', '久咳、久泻、虚热烦渴', '感冒初起者忌用', '泡水：1-3颗；煎汤：6-12克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (54, '木瓜', '食材', '/uploads/knowledge/7d057d22-82e4-4252-9418-645b2533fc9a.png', '舒筋活络，和胃化湿', '含木瓜蛋白酶、维生素C', '风湿痹痛、脚气肿胀', '胃酸过多者少食', '煮汤：10-15克', '夏秋季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (55, '栀子', '药材', '/uploads/knowledge/17ae632f-fb94-4832-b047-f8a07af904de.png', '泻火除烦，清热利湿', '含栀子苷、藏红花素', '热病心烦、黄疸、目赤', '脾虚便溏者慎用', '煎汤：6-10克', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (56, '枳壳', '药材', '/uploads/knowledge/f8d3f9d4-87d5-4c58-bad2-04c95ac14d3d.jpg', '理气宽中，行滞消胀', '含柠檬烯、橙皮苷', '胸胁气滞、腹胀便秘', '孕妇慎用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (57, '枸杞子', '药材', '/uploads/knowledge/453edff8-6ef3-4098-8fc8-dc8bd7042827.png', '滋补肝肾，益精明目', '富含枸杞多糖、类胡萝卜素', '肝肾阴虚、腰膝酸软', '外感发热、脾虚泄泻者慎用', '泡水：10-15克；煲汤：20克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (58, '陈皮', '药材', '/uploads/knowledge/d113a4f3-f67a-47f5-bb95-4dc156f95eb1.jpg', '理气健脾，燥湿化痰', '含挥发油、橙皮苷', '脘腹胀满、呕吐、咳嗽痰多', '气虚、阴虚燥咳者慎用', '泡水：3-9克；煲汤：5克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (59, '青皮', '药材', '/uploads/knowledge/6cff152a-70ec-45a1-8833-22dab2566372.jpg', '疏肝破气，消积化滞', '含挥发油、橙皮苷', '肝郁气滞、胁肋胀痛', '气虚者慎用', '煎汤：3-10克', '春季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (60, '佛手', '药材', '/uploads/knowledge/7653f325-2345-43fc-be25-eb7d41217e7d.jpg', '疏肝理气，和胃止痛', '含挥发油、柠檬烯', '肝胃气滞、胸胁胀痛', '阴虚有热者慎用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (61, '沙棘', '食材', '/uploads/knowledge/c21e9a4e-a48a-4f5a-82ea-f57c148e9f05.png', '健脾消食，止咳化痰', '含维生素C、类胡萝卜素', '脾虚食少、咳嗽痰多', '胃酸过多者少食', '泡水：适量', '秋季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (62, '益智仁', '药材', '/uploads/knowledge/67f77ee0-8558-4583-a9c3-5ea5341b2c1c.png', '暖肾固精缩尿，温脾止泻', '含挥发油、益智酮', '肾虚遗尿、脾寒泄泻', '阴虚火旺者忌用', '煎汤：3-10克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (63, '砂仁', '药材', '/uploads/knowledge/58435256-9610-4216-8ebc-37cb68f7c0e8.png', '化湿开胃，温脾止泻', '含挥发油、龙脑', '湿阻中焦、脾胃虚寒', '阴虚有热者忌用', '煎汤：3-6克；后下', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (64, '草果', '香料', '/uploads/knowledge/fb4e2493-b805-4422-9fd3-36dbb989bbd2.png', '燥湿温中，除痰截疟', '含挥发油、草果酮', '寒湿内阻、脘腹胀痛', '阴虚血少者忌用', '煎汤：3-6克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (65, '香橼', '药材', '/uploads/knowledge/45658c2d-8c59-4378-b917-9fcf0024f81e.png', '疏肝理气，和中化痰', '含挥发油、柠檬酸', '肝胃气滞、胸胁胀痛', '阴虚血燥者慎用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (66, '木耳', '食材', '/uploads/knowledge/32dc5bb5-5f87-44f3-b922-97b3ca8c537b.jpg', '益气养血，润肺止咳', '含多糖、蛋白质、铁、钙', '气虚血亏、肺燥咳嗽', '脾胃虚寒者少食', '炒食：10克；煮汤：15克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (67, '银耳', '食材', '/uploads/knowledge/07964fd8-9b4e-4b7b-ad68-e9549d7c881d.jpg', '滋阴润肺，养胃生津', '含多糖、蛋白质、维生素D', '肺热咳嗽、口干津少', '外感风寒、大便溏泻者慎用', '煮汤：5-10克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (68, '灵芝', '药材', '/uploads/knowledge/399b91cb-97e3-4783-89ef-dd9ab6208809.jpg', '补气安神，止咳平喘', '含灵芝多糖、三萜类化合物', '心神不宁、失眠、虚劳咳喘', '实证者慎用', '煎汤：6-12克；泡酒：适量', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (69, '茯苓', '药材', '/uploads/knowledge/2cba8f5c-4c34-4088-b031-bce2ae2469f0.png', '利水渗湿，健脾宁心', '含茯苓多糖、三萜类化合物', '水肿、痰饮、脾虚泄泻', '阴虚而无湿热者慎用', '煎汤：10-15克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (70, '猪苓', '药材', '/uploads/knowledge/20efb07c-626d-42eb-942f-17156c0e0e54.jpg', '利水渗湿', '含猪苓多糖、麦角甾醇', '水肿、小便不利、泄泻', '无湿热者慎用', '煎汤：6-12克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (71, '人参', '药材', '/uploads/knowledge/ba823435-ee67-4764-a0fd-251c129910d4.jpg', '大补元气，复脉固脱', '含人参皂苷、多糖、氨基酸', '气虚欲脱、脾肺气虚', '实证、热证者忌用', '煎汤：3-9克；炖汤：5克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (72, '西洋参', '药材', '/uploads/knowledge/abceb55f-c4ad-4c7a-a8c1-f27570c8f543.png', '补气养阴，清热生津', '含人参皂苷、多糖', '气阴两虚、热病伤阴', '中阳衰微、胃湿寒者忌用', '泡水：3-6克；含服：2-3克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (73, '太子参', '药材', '/uploads/knowledge/49133bb4-2540-4e89-9e5e-8b7ac9e32978.jpg', '益气健脾，生津润肺', '含太子参多糖、皂苷', '脾虚体倦、肺虚咳嗽', '表实邪盛者慎用', '煎汤：10-30克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (74, '黄精', '药材', '/uploads/knowledge/30161758-cabb-49ff-b55c-bea2bc5301d9.png', '补气养阴，健脾润肺', '含黄精多糖、皂苷', '脾胃气虚、体倦乏力', '痰湿壅盛者慎用', '煎汤：10-30克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (75, '鹿茸', '药材', '/uploads/knowledge/b3ef6629-0131-4e0b-9dee-b38464c2ddd1.jpg', '壮肾阳，益精血，强筋骨', '含氨基酸、磷脂、激素', '肾阳虚衰、精血不足', '阴虚阳亢、实热者禁用', '研末：1-2克', '冬季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (76, '阿胶', '药材', '/uploads/knowledge/2141f4eb-3713-4649-80b2-c7d6e0dce06d.png', '补血滋阴，润燥止血', '含胶原蛋白、多肽、氨基酸', '血虚萎黄、眩晕心悸', '脾胃虚弱、消化不良者慎用', '烊化：3-9克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (77, '荷叶', '茶饮', '/uploads/knowledge/c3d6c940-24c2-487d-a656-9ef302ff3213.png', '清热解暑，升发清阳', '含荷叶碱、黄酮、有机酸', '暑热烦渴、水肿、高血脂', '体虚、气血虚弱者慎用', '泡茶：3-10克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (78, '紫苏叶', '药材', '/uploads/knowledge/a338a2e7-c7e1-4223-9445-2f170cfa9402.png', '解表散寒，行气和胃', '含紫苏醛、紫苏醇', '风寒感冒、气滞胸闷', '温病、气弱表虚者慎用', '煎汤：5-10克', '秋季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (79, '薄荷', '药材', '/uploads/knowledge/4ebd1fed-15ea-407a-a205-82cc310f9453.png', '疏散风热，清利头目', '含薄荷醇、薄荷酮', '风热感冒、头痛目赤', '阴虚血燥者慎用', '煎汤：3-6克；后下', '春夏季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (80, '淡竹叶', '药材', '/uploads/knowledge/ab6a191b-e72a-4f44-96b3-8f41b2150c1c.png', '清热泻火，除烦止渴', '含黄酮、多糖', '热病烦渴、口舌生疮', '肾亏尿频者慎用', '煎汤：6-10克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (81, '艾叶', '药材', '/uploads/knowledge/5d38d026-52cb-4ad4-9dae-47239361134d.jpg', '温经止血，散寒止痛', '含挥发油、鞣质', '虚寒性出血、宫冷不孕', '阴虚血热者忌用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (82, '核桃', '食材', '/uploads/knowledge/8b2ea57f-36c3-4f72-a3a4-5a71418c5f13.jpg', '补肾温肺，润肠通便', '富含不饱和脂肪酸、蛋白质', '肾虚、腰痛、便秘', '痰热咳嗽、腹泻者慎食', '生食：3-5个/天', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (83, '杏仁', '食材', '/uploads/knowledge/3e2559d4-a2e4-4264-bc70-6d095caecd60.png', '止咳平喘，润肠通便', '含蛋白质、脂肪、维生素E', '咳嗽气喘、肠燥便秘', '阴虚咳嗽者慎食', '煎汤：5-10克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (84, '松子', '食材', '/uploads/knowledge/2159a3be-4267-459d-87e0-5e98c866193f.jpg', '润肺止咳，润肠通便', '富含不饱和脂肪酸、维生素E', '肺燥咳嗽、肠燥便秘', '脾虚便溏者少食', '生食：10-15克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (85, '榛子', '食材', '/uploads/knowledge/331774f0-d01c-4097-abbc-cb1eddee99e9.jpg', '补脾益气，明目健行', '含不饱和脂肪酸、维生素E', '体虚乏力、食少', '痰湿重者少食', '生食：10-20克', '秋季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (86, '黑豆', '食材', '/uploads/knowledge/e9da67b2-230d-4a03-9232-77d73014c8b1.jpg', '补肾益阴，健脾利湿', '含蛋白质、脂肪、花青素', '肾虚、水肿、脚气', '小儿、胃热盛者慎食', '煮粥：30克；煲汤：50克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (87, '赤小豆', '食材', '/uploads/knowledge/28a377c3-49c8-4596-9bf1-fbb3c9b7ea17.jpg', '利水消肿，解毒排脓', '含蛋白质、皂角苷、膳食纤维', '水肿、脚气、黄疸', '尿多、体瘦者慎用', '煮粥：30克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (88, '绿豆', '食材', '/uploads/knowledge/b1ab5d44-c288-4759-993c-8ec1c6fa72dc.jpg', '清热解毒，消暑利水', '含蛋白质、维生素B、矿物质', '暑热烦渴、疮毒', '脾胃虚寒者少食', '煮汤：30-60克', '夏季最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (89, '豇豆', '食材', '/uploads/knowledge/785a3b6e-2eb8-49cd-8894-d66195f55b61.jpg', '健脾补肾，理中益气', '含蛋白质、维生素、矿物质', '脾胃虚弱、食少便溏', '气滞便结者慎食', '炒食：100克', '夏秋季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (90, '扁豆', '食材', '/uploads/knowledge/32102c19-c293-4dc9-b247-f7d945328749.png', '健脾化湿，消暑和中', '含蛋白质、维生素B、矿物质', '脾虚湿盛、暑湿吐泻', '寒热病者慎食', '炒食：50克；煮粥：30克', '夏秋季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (91, '桂皮', '香料', '/uploads/knowledge/88fabace-9fe2-4a23-aa81-eb0f58b71a71.png', '补火助阳，散寒止痛', '含桂皮醛、桂皮酸', '肾阳不足、畏寒肢冷', '阴虚火旺者禁用', '煎汤：2-5克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (92, '陈皮', '药材', '/uploads/knowledge/ba5aac77-6146-4fae-a427-271bb61f2fbf.jpg', '理气健脾，燥湿化痰', '含挥发油、橙皮苷', '脘腹胀满、呕吐', '气虚、阴虚者慎用', '泡水：3-9克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (93, '桑白皮', '药材', '/uploads/knowledge/a2590738-9650-46ad-ab70-1a6d62ff3e06.png', '泻肺平喘，利水消肿', '含桑皮素、黄酮', '肺热喘咳、水肿胀满', '肺虚无火者慎用', '煎汤：6-12克', '春夏季节', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (94, '百合', '食材', '/uploads/knowledge/1990fd10-8362-4bd8-9557-8970407c5673.png', '养阴润肺，清心安神', '含秋水仙碱、淀粉、蛋白质', '阴虚久咳、虚烦惊悸', '风寒咳嗽者慎用', '煮粥：15-30克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (95, '麦冬', '药材', '/uploads/knowledge/03c6a7b9-a0ce-4048-a551-bf8b009d0d10.png', '养阴生津，润肺清心', '含麦冬皂苷、多糖、氨基酸', '肺燥干咳、虚劳咳嗽', '脾胃虚寒者慎用', '煎汤：6-12克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (96, '天冬', '药材', '/uploads/knowledge/112f53c3-4ce5-473d-abdc-24e5fa636a25.png', '养阴润燥，清肺生津', '含天冬酰胺、天冬素', '肺燥干咳、虚劳咳嗽', '脾胃虚寒者慎用', '煎汤：6-12克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (97, '石斛', '药材', '/uploads/knowledge/71e22d7e-7496-4b84-a5b8-3ae138244254.png', '益胃生津，滋阴清热', '含石斛碱、多糖', '胃阴不足、口干烦渴', '湿温未化燥者慎用', '煎汤：6-12克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (98, '远志', '药材', '/uploads/knowledge/f8d195c0-c142-43bf-90ac-f20e5ca1f218.jpg', '安神益智，祛痰开窍', '含远志皂苷、远志酸', '心肾不交、失眠多梦', '胃溃疡者慎用', '煎汤：3-10克', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (99, '柏子仁', '药材', '/uploads/knowledge/77fa0b19-b36e-4a4e-80e2-a995aec6f36b.jpg', '养心安神，润肠通便', '含脂肪油、皂苷', '心悸失眠、肠燥便秘', '便溏、痰多者慎用', '煎汤：10-20克', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (100, '龙眼肉', '食材', '/uploads/knowledge/810cf175-d6e0-477b-8d06-e95786c86950.png', '补益心脾，养血安神', '含葡萄糖、蛋白质、铁', '心脾两虚、气血不足', '内有痰火者慎食', '泡水：5-8颗', '秋冬季节最佳', '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `knowledge_items` VALUES (101, '大枣', '食材', '/uploads/knowledge/513df7f3-d252-4601-a6b3-fb4258fd8719.png', '补中益气，养血安神', '含维生素C、环磷酸腺苷', '脾虚食少、气血不足', '湿热内盛者慎食', '煮粥：6-10颗', '四季皆宜', '2025-11-05 22:18:13', '2025-11-05 22:18:13');

-- ----------------------------
-- Table structure for knowledge_scene_recommendations
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_scene_recommendations`;
CREATE TABLE `knowledge_scene_recommendations`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '场景标题',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '推荐说明',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片',
  `tags_json` json NOT NULL COMMENT '场景对应的标签组合（含主辅标签）',
  `priority` int NULL DEFAULT 0 COMMENT '排序权重',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否激活',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '场景入口推荐配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_scene_recommendations
-- ----------------------------

-- ----------------------------
-- Table structure for knowledge_tag_synonyms
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_tag_synonyms`;
CREATE TABLE `knowledge_tag_synonyms`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tag_id` bigint NOT NULL COMMENT '关联标签ID',
  `synonym` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '同义词或别名',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tag_synonym`(`tag_id` ASC, `synonym` ASC) USING BTREE,
  INDEX `idx_synonym`(`synonym` ASC) USING BTREE,
  CONSTRAINT `fk_synonyms_tag` FOREIGN KEY (`tag_id`) REFERENCES `knowledge_tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库标签同义词' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_tag_synonyms
-- ----------------------------
INSERT INTO `knowledge_tag_synonyms` VALUES (1, 13, '睡不着', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (2, 13, '入睡困难', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (3, 19, '颈椎酸痛', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (4, 22, '胃不舒服', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (5, 22, '消化不良', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (6, 39, '减肥', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (7, 39, '瘦身', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tag_synonyms` VALUES (8, 44, '舒缓压力', '2026-02-03 17:33:11');

-- ----------------------------
-- Table structure for knowledge_tags
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_tags`;
CREATE TABLE `knowledge_tags`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `dimension` enum('population','symptom','season','goal') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所属维度',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签描述或使用说明',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父标签ID',
  `priority` int NULL DEFAULT 0 COMMENT '排序权重，值越大越靠前',
  `is_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  `is_sensitive` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否敏感/需谨慎展示',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dimension_name`(`dimension` ASC, `name` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_tags_parent` FOREIGN KEY (`parent_id`) REFERENCES `knowledge_tags` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 160 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库场景标签' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_tags
-- ----------------------------
INSERT INTO `knowledge_tags` VALUES (1, '儿童健康', 'population', '12岁及以下儿童常见调养需求', NULL, 90, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (2, '青春期学生', 'population', '正处于生长发育期的学生', NULL, 80, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (3, '大学生', 'population', '学习压力与作息不规律的高校人群', NULL, 75, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (4, '职场久坐族', 'population', '日常久坐、缺乏运动的办公人群', NULL, 95, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (5, '996人群', 'population', '高压工作、加班频繁的人群', NULL, 85, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (6, '夜班工作者', 'population', '倒班、熬夜类职业人群', NULL, 70, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (7, '孕产妈妈', 'population', '孕期及产后恢复阶段女性', NULL, 88, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (8, '备孕家庭', 'population', '准备怀孕的夫妻人群', NULL, 60, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (9, '中老年群体', 'population', '50岁以上需要综合调理的人群', NULL, 92, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (10, '银发族', 'population', '65岁以上关注慢性病与体能维护', NULL, 65, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (11, '慢病人群-高血压', 'population', '已确诊高血压的管理场景', NULL, 78, 0, 1, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (12, '慢病人群-糖尿病', 'population', '已确诊糖尿病的管理场景', NULL, 78, 0, 1, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (13, '失眠', 'symptom', '入睡困难/睡不着/睡眠浅', NULL, 100, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (14, '浅睡易醒', 'symptom', '易醒、睡眠不深', NULL, 85, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (15, '晨起疲惫', 'symptom', '起床后仍感到疲倦', NULL, 75, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (16, '焦虑紧张', 'symptom', '情绪紧绷、压力大', NULL, 90, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (17, '情绪低落', 'symptom', '心情差、动力不足', NULL, 85, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (18, '头痛头胀', 'symptom', '头部胀痛、偏头痛', NULL, 80, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (19, '肩颈僵硬', 'symptom', '肩颈部位酸痛僵硬', NULL, 95, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (20, '久坐腰痛', 'symptom', '腰部酸痛、久坐不适', NULL, 90, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (21, '乏力倦怠', 'symptom', '身体乏力、精力不足', NULL, 88, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (22, '胃胀消化不良', 'symptom', '胃部胀满、消化困难', NULL, 92, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (23, '便秘排便困难', 'symptom', '排便次数少或困难', NULL, 88, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (24, '食欲不振', 'symptom', '食欲差、不想吃饭', NULL, 70, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (25, '口干咽痛', 'symptom', '咽喉不适、干燥疼痛', NULL, 65, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (26, '易感冒', 'symptom', '季节交替易出现感冒', NULL, 72, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (27, '皮肤干燥瘙痒', 'symptom', '皮肤干、易痒', NULL, 68, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (28, '女性经期不适', 'symptom', '经期疼痛、情绪波动', NULL, 82, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (29, '春季养生', 'season', '春季调养重点，疏肝养阳', NULL, 80, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (30, '夏季防暑', 'season', '夏季清热解暑', NULL, 85, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (31, '秋季润燥', 'season', '秋季润肺护肤', NULL, 90, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (32, '冬季御寒', 'season', '冬季温补、增强抵抗力', NULL, 95, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (33, '雨水节气', 'season', '雨水节气调养建议', NULL, 60, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (34, '清明节气', 'season', '清明节气调养建议', NULL, 55, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (35, '夏至节气', 'season', '夏至节气调养建议', NULL, 55, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (36, '立秋节气', 'season', '立秋节气调养建议', NULL, 60, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (37, '立冬节气', 'season', '立冬节气调养建议', NULL, 70, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (38, '腊八前后', 'season', '腊八及严寒时节调理', NULL, 65, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (39, '减脂塑形', 'goal', '控制体脂、塑造体型', NULL, 98, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (40, '增肌提能', 'goal', '增加肌肉、提升体能', NULL, 85, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (41, '体重管理', 'goal', '体重控制/增减', NULL, 92, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (42, '控糖控压', 'goal', '血糖与血压控制', NULL, 94, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (43, '睡眠改善', 'goal', '提升睡眠质量', NULL, 96, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (44, '缓解压力情绪', 'goal', '情绪管理、心理舒缓', NULL, 93, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (45, '肠胃调理', 'goal', '呵护脾胃、改善消化', NULL, 95, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (46, '免疫力提升', 'goal', '增强免疫、防疫保健', NULL, 97, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (47, '体质调理-偏寒', 'goal', '阳虚怕冷体质调理', NULL, 80, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (48, '体质调理-偏热', 'goal', '阴虚内热体质调理', NULL, 78, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (49, '术后康复', 'goal', '术后及重大疾病恢复期', NULL, 72, 0, 1, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (50, '产后恢复', 'goal', '产后体质调理、营养补充', NULL, 88, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (51, '学生专注力', 'goal', '提升学习专注与记忆', NULL, 70, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (52, '护眼放松', 'goal', '视疲劳缓解与护眼', NULL, 68, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');
INSERT INTO `knowledge_tags` VALUES (53, '气血调养', 'goal', '补气养血、改善气色', NULL, 90, 1, 0, '2026-02-03 17:33:11', '2026-02-03 17:33:11');

-- ----------------------------
-- Table structure for user_daily_tasks
-- ----------------------------
DROP TABLE IF EXISTS `user_daily_tasks`;
CREATE TABLE `user_daily_tasks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `task_date` date NOT NULL COMMENT '任务日期',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类：饮食/运动/作息/情绪',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '详细说明',
  `frequency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '每日' COMMENT '频率：每日/隔日/每周',
  `intensity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '适度' COMMENT '强度：轻度/中度/适度/强化',
  `target_value` int NULL DEFAULT NULL COMMENT '目标值（分钟/次数等）',
  `actual_value` int NULL DEFAULT 0 COMMENT '实际完成值',
  `is_completed` tinyint(1) NULL DEFAULT 0 COMMENT '是否完成',
  `priority` int NULL DEFAULT 0 COMMENT '优先级',
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'AI' COMMENT '来源：AI/体质/趋势',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_date`(`user_id` ASC, `task_date` ASC) USING BTREE,
  INDEX `idx_date`(`task_date` ASC) USING BTREE,
  CONSTRAINT `fk_tasks_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户每日任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_daily_tasks
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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
  `theme_preference` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'light' COMMENT '主题偏好: light或dark',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_users_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'root', NULL, 'root', '$2a$10$ZWYh2uOcQugI7DvkKNomFO3l4Di.IMUUgHAQuLxOoIhR1du187EOu', 'dark');
INSERT INTO `users` VALUES (2, 'wzq', NULL, 'wzq', '$2a$10$Tlg0UMP4UgDwXazCaUboKeIEBk/Vxonbx1V1w5DJPZ76XUPpFWH1G', 'light');

SET FOREIGN_KEY_CHECKS = 1;
