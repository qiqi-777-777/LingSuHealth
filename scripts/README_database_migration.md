# 数据库迁移指南

## 问题说明
原始数据库中 `users` 表的 `id` 字段类型为 `INT`，但 Java 实体类使用 `Long` 类型，导致类型不匹配。
新增的 `user_daily_tasks` 表使用 `BIGINT` 作为 `user_id` 类型，无法创建外键约束。

## 解决方案
将 `users` 表的 `id` 字段从 `INT` 改为 `BIGINT`，统一所有相关表的类型。

## 迁移步骤

### 1. 备份数据库（重要！）
```bash
mysqldump -u root -p lingsu_health > backup_before_migration.sql
```

### 2. 执行迁移脚本
```bash
mysql -u root -p lingsu_health < scripts/migrate_users_id_to_bigint.sql
```

### 3. 创建每日任务表
```bash
mysql -u root -p lingsu_health < scripts/create_daily_tasks_table.sql
```

### 4. 验证迁移结果
```sql
-- 检查 users 表的 id 类型
DESCRIBE users;

-- 检查外键约束
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    REFERENCED_TABLE_NAME = 'users'
    AND TABLE_SCHEMA = 'lingsu_health';

-- 检查 user_daily_tasks 表
DESCRIBE user_daily_tasks;
```

## 影响范围
- `users` 表：id 字段从 INT 改为 BIGINT
- `user_profiles` 表：user_id 字段从 INT 改为 BIGINT（如需要）
- `health_checkins` 表：user_id 字段从 INT 改为 BIGINT（如需要）
- `health_trends` 表：user_id 字段从 INT 改为 BIGINT（如需要）
- `assessment_records` 表：user_id 字段从 INT 改为 BIGINT（如需要）
- 新增 `user_daily_tasks` 表

## 注意事项
1. 此迁移会临时删除外键约束，然后重新创建
2. 数据不会丢失，只是改变字段类型
3. 建议在低峰期执行
4. 执行前务必备份数据库
5. INT 到 BIGINT 的转换是安全的，不会丢失数据

## 回滚方案
如果迁移出现问题，可以使用备份恢复：
```bash
mysql -u root -p lingsu_health < backup_before_migration.sql
```
