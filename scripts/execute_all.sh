#!/bin/bash

echo "========================================"
echo "数据库迁移脚本 - 一键执行"
echo "========================================"
echo ""

read -p "请输入 MySQL 用户名 (默认: root): " DB_USER
DB_USER=${DB_USER:-root}

read -p "请输入数据库名 (默认: lingsu_health): " DB_NAME
DB_NAME=${DB_NAME:-lingsu_health}

echo ""
echo "========================================"
echo "第 1 步：备份数据库"
echo "========================================"
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
echo "备份文件: $BACKUP_FILE"
mysqldump -u $DB_USER -p $DB_NAME > $BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "❌ 备份失败！"
    exit 1
fi
echo "✅ 备份成功！"
echo ""

echo "========================================"
echo "第 2 步：修改 users 表类型"
echo "========================================"
mysql -u $DB_USER -p $DB_NAME < migrate_users_id_to_bigint.sql
if [ $? -ne 0 ]; then
    echo "❌ 执行失败！正在回滚..."
    mysql -u $DB_USER -p $DB_NAME < $BACKUP_FILE
    exit 1
fi
echo "✅ 执行成功！"
echo ""

echo "========================================"
echo "第 3 步：创建每日任务表"
echo "========================================"
mysql -u $DB_USER -p $DB_NAME < create_daily_tasks_table.sql
if [ $? -ne 0 ]; then
    echo "❌ 执行失败！正在回滚..."
    mysql -u $DB_USER -p $DB_NAME < $BACKUP_FILE
    exit 1
fi
echo "✅ 执行成功！"
echo ""

echo "========================================"
echo "第 4 步：健康闭环优化（可选）"
echo "========================================"
read -p "是否执行健康闭环优化？(Y/N，默认: Y): " CONTINUE
CONTINUE=${CONTINUE:-Y}
if [ "$CONTINUE" = "Y" ] || [ "$CONTINUE" = "y" ]; then
    mysql -u $DB_USER -p $DB_NAME < health_loop_optimization.sql
    if [ $? -ne 0 ]; then
        echo "❌ 执行失败！正在回滚..."
        mysql -u $DB_USER -p $DB_NAME < $BACKUP_FILE
        exit 1
    fi
    echo "✅ 执行成功！"
else
    echo "⏭️ 跳过健康闭环优化"
fi
echo ""

echo "========================================"
echo "第 5 步：验证结果"
echo "========================================"
mysql -u $DB_USER -p $DB_NAME < test_migration.sql
echo ""

echo "========================================"
echo "✅ 所有步骤执行完成！"
echo "========================================"
echo "备份文件保存在: $BACKUP_FILE"
echo "如需回滚，请执行:"
echo "mysql -u $DB_USER -p $DB_NAME < $BACKUP_FILE"
echo ""
