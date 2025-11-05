#!/bin/bash

# LingSu Health 快速部署脚本
# 使用方法：bash deploy.sh

set -e  # 遇到错误立即退出

echo "======================================"
echo "  LingSu Health 项目部署脚本"
echo "======================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_DIR="/opt/lingsu-health"
FRONTEND_DIR="/var/www/lingsu-health"
SERVICE_NAME="lingsu-health"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    echo "使用方法: sudo bash deploy.sh"
    exit 1
fi

echo -e "${GREEN}[1/6] 拉取最新代码...${NC}"
cd $PROJECT_DIR
git pull origin main
echo ""

echo -e "${GREEN}[2/6] 构建后端...${NC}"
mvn clean package -DskipTests
echo ""

echo -e "${GREEN}[3/6] 重启后端服务...${NC}"
systemctl restart $SERVICE_NAME
sleep 3
if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}✓ 后端服务启动成功${NC}"
else
    echo -e "${RED}✗ 后端服务启动失败，请检查日志${NC}"
    echo "查看日志命令: journalctl -u $SERVICE_NAME -f"
    exit 1
fi
echo ""

echo -e "${GREEN}[4/6] 构建前端...${NC}"
cd $PROJECT_DIR/ui
npm install
npm run build
echo ""

echo -e "${GREEN}[5/6] 部署前端静态文件...${NC}"
mkdir -p $FRONTEND_DIR
cp -r dist/* $FRONTEND_DIR/
echo ""

echo -e "${GREEN}[6/6] 重启 Nginx...${NC}"
nginx -t && systemctl restart nginx
echo ""

echo "======================================"
echo -e "${GREEN}  🎉 部署完成！${NC}"
echo "======================================"
echo ""
echo "后端服务状态:"
systemctl status $SERVICE_NAME --no-pager
echo ""
echo "访问地址:"
echo "  前端: http://$(hostname -I | awk '{print $1}')"
echo "  后端: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "常用命令:"
echo "  查看后端日志: journalctl -u $SERVICE_NAME -f"
echo "  查看 Nginx 日志: tail -f /var/log/nginx/error.log"
echo "  重启后端: systemctl restart $SERVICE_NAME"
echo "  重启 Nginx: systemctl restart nginx"
echo ""

