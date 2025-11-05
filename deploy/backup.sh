#!/bin/bash

# 数据库备份脚本
# 建议添加到 crontab 定时执行
# 示例：每天凌晨 2 点备份
# 0 2 * * * /opt/lingsu-health/deploy/backup.sh

set -e

# 配置
DB_NAME="lingsu_health"
DB_USER="lingshu_user"
DB_PASSWORD="your_password"  # 修改为实际密码
BACKUP_DIR="/backup/lingsu-health"
KEEP_DAYS=7  # 保留最近7天的备份

# 创建备份目录
mkdir -p $BACKUP_DIR

# 生成备份文件名
BACKUP_FILE="$BACKUP_DIR/lingsu_health_$(date +%Y%m%d_%H%M%S).sql"

# 执行备份
echo "开始备份数据库..."
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE

# 压缩备份文件
gzip $BACKUP_FILE
echo "备份完成: ${BACKUP_FILE}.gz"

# 删除旧备份（保留最近N天）
find $BACKUP_DIR -name "*.sql.gz" -mtime +$KEEP_DAYS -delete
echo "已删除 $KEEP_DAYS 天前的旧备份"

# 显示当前备份文件
echo ""
echo "当前备份文件:"
ls -lh $BACKUP_DIR

