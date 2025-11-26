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

 Date: 26/11/2025 00:16:55
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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '体质测评记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of assessment_records
-- ----------------------------
INSERT INTO `assessment_records` VALUES (1, 1, '[{\"questionIndex\":0,\"answerIndex\":1,\"question\":\"您的体型如何？\",\"answer\":\"偏瘦\"},{\"questionIndex\":1,\"answerIndex\":1,\"question\":\"您的睡眠质量如何？\",\"answer\":\"偶尔入睡困难或早醒\"},{\"questionIndex\":2,\"answerIndex\":1,\"question\":\"您的日常精力状态？\",\"answer\":\"下午容易犯困，需咖啡/茶提神\"},{\"questionIndex\":3,\"answerIndex\":0,\"question\":\"您的排便规律吗？\",\"answer\":\"每天1次，规律顺畅\"},{\"questionIndex\":4,\"answerIndex\":0,\"question\":\"您的饮食习惯？\",\"answer\":\"三餐规律，少油少糖\"},{\"questionIndex\":5,\"answerIndex\":2,\"question\":\"您每周运动几次？\",\"answer\":\"几乎不运动，能坐不站\"},{\"questionIndex\":6,\"answerIndex\":2,\"question\":\"您的情绪状态？\",\"answer\":\"经常压力大，易发脾气\"},{\"questionIndex\":7,\"answerIndex\":4,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"以上都没有\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":2,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"运动跟练计划\"}]', '2025-11-06 00:07:52', '2025-11-06 00:07:52');
INSERT INTO `assessment_records` VALUES (2, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":1,\"question\":\"您的睡眠质量如何？\",\"answer\":\"偶尔入睡困难或早醒\"},{\"questionIndex\":2,\"answerIndex\":0,\"question\":\"您的日常精力状态？\",\"answer\":\"白天精神饱满，不易累\"},{\"questionIndex\":3,\"answerIndex\":0,\"question\":\"您的排便规律吗？\",\"answer\":\"每天1次，规律顺畅\"},{\"questionIndex\":4,\"answerIndex\":0,\"question\":\"您的饮食习惯？\",\"answer\":\"三餐规律，少油少糖\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":1,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"久坐后腰酸背痛\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":1,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"饮食记录+推荐\"}]', '2025-11-17 15:01:48', '2025-11-17 15:01:48');
INSERT INTO `assessment_records` VALUES (3, 1, '[{\"questionIndex\":0,\"answerIndex\":0,\"question\":\"您的体型如何？\",\"answer\":\"匀称\"},{\"questionIndex\":1,\"answerIndex\":2,\"question\":\"您的睡眠质量如何？\",\"answer\":\"经常失眠或睡不醒\"},{\"questionIndex\":2,\"answerIndex\":2,\"question\":\"您的日常精力状态？\",\"answer\":\"经常感到疲惫，睡不够\"},{\"questionIndex\":3,\"answerIndex\":2,\"question\":\"您的排便规律吗？\",\"answer\":\"经常便秘或腹泻\"},{\"questionIndex\":4,\"answerIndex\":1,\"question\":\"您的饮食习惯？\",\"answer\":\"外卖为主，口味偏重\"},{\"questionIndex\":5,\"answerIndex\":1,\"question\":\"您每周运动几次？\",\"answer\":\"1-2次，轻度活动\"},{\"questionIndex\":6,\"answerIndex\":1,\"question\":\"您的情绪状态？\",\"answer\":\"偶尔焦虑/烦躁\"},{\"questionIndex\":7,\"answerIndex\":0,\"question\":\"您平时是否容易感到以下不适？（可多选）\",\"answer\":\"肩颈僵硬\"},{\"questionIndex\":8,\"answerIndex\":1,\"question\":\"您的健康目标？\",\"answer\":\"改善睡眠\"},{\"questionIndex\":9,\"answerIndex\":3,\"question\":\"您更希望通过哪种方式开启健康生活？\",\"answer\":\"冥想/呼吸练习\"}]', '2025-11-25 22:11:56', '2025-11-25 22:11:56');

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_date`(`user_id` ASC, `checkin_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康打卡记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of health_checkins
-- ----------------------------
INSERT INTO `health_checkins` VALUES (1, 1, '2025-10-30', 7.50, '23:10:00', '[\"失眠\",\"食欲不振\"]', 1, 40, '清淡饮食', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (2, 1, '2025-10-31', 6.00, '00:05:00', '[\"疲劳\"]', 1, 20, '少油少盐', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (3, 1, '2025-11-01', 8.00, '22:45:00', '[\"无症状\"]', 2, 60, '蛋白质补充', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (4, 1, '2025-11-02', 7.00, '23:30:00', '[\"头痛\"]', 2, 30, '多喝水', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (5, 1, '2025-11-03', 6.50, '00:20:00', '[\"腹胀\",\"疲劳\"]', 1, 25, '少食多餐', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (6, 1, '2025-11-04', 8.20, '22:50:00', '[\"无症状\"]', 3, 45, '均衡饮食', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (7, 1, '2025-11-05', 7.80, '23:05:00', '[\"失眠\",\"食欲不振\"]', 2, 50, '注意作息', 0, '2025-11-05 22:18:13', '2025-11-05 22:18:13');
INSERT INTO `health_checkins` VALUES (8, 1, '2025-11-25', 9.00, '23:00:00', '[\"食欲不振\",\"腹胀\"]', 1, 30, '', 0, NULL, NULL);

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康趋势数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of health_trends
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '中西医知识库表' ROW_FORMAT = Dynamic;

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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_users_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'root', NULL, 'root', '$2a$10$ZWYh2uOcQugI7DvkKNomFO3l4Di.IMUUgHAQuLxOoIhR1du187EOu');
INSERT INTO `users` VALUES (2, 'wzq', NULL, 'wzq', '$2a$10$Tlg0UMP4UgDwXazCaUboKeIEBk/Vxonbx1V1w5DJPZ76XUPpFWH1G');

SET FOREIGN_KEY_CHECKS = 1;
