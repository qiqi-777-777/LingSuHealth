#!/bin/bash

# 健康分修复脚本
# 用途：自动执行SQL脚本并重启后端服务

echo "=========================================="
echo "健康分修复脚本"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 数据库配置（从application.yml读取或使用默认值）
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-lingsu_health}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-123456}

echo -e "${YELLOW}步骤1: 检查MySQL连接${NC}"
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}错误: 未找到mysql命令，请先安装MySQL客户端${NC}"
    exit 1
fi

# 测试数据库连接
if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null; then
    echo -e "${GREEN}✓ 数据库连接成功${NC}"
else
    echo -e "${RED}✗ 数据库连接失败，请检查配置${NC}"
    echo "数据库: $DB_HOST:$DB_PORT/$DB_NAME"
    echo "用户名: $DB_USER"
    exit 1
fi

echo ""
echo -e "${YELLOW}步骤2: 执行SQL脚本${NC}"
if [ ! -f "add_health_score_to_checkins.sql" ]; then
    echo -e "${RED}错误: 未找到SQL脚本文件 add_health_score_to_checkins.sql${NC}"
    exit 1
fi

# 执行SQL脚本
if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < add_health_score_to_checkins.sql 2>/dev/null; then
    echo -e "${GREEN}✓ SQL脚本执行成功${NC}"
else
    echo -e "${YELLOW}⚠ SQL脚本执行可能失败（如果字段已存在则忽略此警告）${NC}"
fi

# 验证字段是否存在
echo ""
echo -e "${YELLOW}步骤3: 验证字段是否添加成功${NC}"
FIELD_EXISTS=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW COLUMNS FROM health_checkins LIKE 'health_score';" 2>/dev/null | grep -c "health_score")

if [ "$FIELD_EXISTS" -gt 0 ]; then
    echo -e "${GREEN}✓ health_score 字段已存在${NC}"
else
    echo -e "${RED}✗ health_score 字段不存在，请手动检查${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}步骤4: 检查后端服务${NC}"

# 检查是否有正在运行的Spring Boot进程
SPRING_PID=$(ps aux | grep "spring-boot:run\|lingsu-health.*\.jar" | grep -v grep | awk '{print $2}')

if [ -n "$SPRING_PID" ]; then
    echo "发现正在运行的后端服务 (PID: $SPRING_PID)"
    read -p "是否需要重启后端服务？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在停止后端服务..."
        kill $SPRING_PID
        sleep 2
        echo -e "${GREEN}✓ 后端服务已停止${NC}"
        echo ""
        echo -e "${YELLOW}请手动重启后端服务：${NC}"
        echo "  方式1: mvn spring-boot:run"
        echo "  方式2: java -jar target/lingsu-health-0.0.1-SNAPSHOT.jar"
    fi
else
    echo "未发现正在运行的后端服务"
    echo -e "${YELLOW}请启动后端服务：${NC}"
    echo "  方式1: mvn spring-boot:run"
    echo "  方式2: java -jar target/lingsu-health-0.0.1-SNAPSHOT.jar"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}修复脚本执行完成！${NC}"
echo "=========================================="
echo ""
echo "后续步骤："
echo "1. 确保后端服务已重启"
echo "2. 打开前端页面进行测试"
echo "3. 进行多次打卡，验证健康分是否独立计算"
echo "4. 查看健康趋势图是否正常显示"
echo ""
echo "详细测试步骤请参考: 测试健康分修复.md"
echo ""
