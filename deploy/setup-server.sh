#!/bin/bash

# 服务器初始化脚本
# 一键安装所有依赖和配置服务器环境
# 使用方法：curl -sSL https://raw.githubusercontent.com/your-username/LingSuHealth/main/deploy/setup-server.sh | bash

set -e

echo "======================================"
echo "  LingSu Health 服务器初始化脚本"
echo "======================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    exit 1
fi

# 获取用户输入
read -p "请输入 MySQL root 密码: " MYSQL_ROOT_PASSWORD
read -p "请输入 MySQL 应用用户名 [lingshu_user]: " MYSQL_USER
MYSQL_USER=${MYSQL_USER:-lingshu_user}
read -p "请输入 MySQL 应用密码: " MYSQL_PASSWORD
read -p "请输入 GitHub 仓库地址 (https://github.com/username/repo.git): " GITHUB_REPO
read -p "请输入域名（留空使用 IP）: " DOMAIN_NAME

echo ""
echo -e "${GREEN}[1/8] 更新系统...${NC}"
apt update && apt upgrade -y

echo ""
echo -e "${GREEN}[2/8] 安装 Java 17...${NC}"
apt install openjdk-17-jdk -y
java -version

echo ""
echo -e "${GREEN}[3/8] 安装 MySQL 8.0...${NC}"
apt install mysql-server -y
systemctl start mysql
systemctl enable mysql

# 配置 MySQL
echo -e "${GREEN}配置 MySQL...${NC}"
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS lingsu_health CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON lingsu_health.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo ""
echo -e "${GREEN}[4/8] 安装 Node.js 20...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install nodejs -y
node -v
npm -v

echo ""
echo -e "${GREEN}[5/8] 安装 Nginx...${NC}"
apt install nginx -y
systemctl start nginx
systemctl enable nginx

echo ""
echo -e "${GREEN}[6/8] 安装 Git 和 Maven...${NC}"
apt install git maven -y

echo ""
echo -e "${GREEN}[7/8] 克隆项目代码...${NC}"
mkdir -p /opt/lingsu-health
cd /opt/lingsu-health

if [ -z "$GITHUB_REPO" ]; then
    echo -e "${YELLOW}跳过克隆代码，请手动上传项目文件${NC}"
else
    git clone $GITHUB_REPO .
fi

echo ""
echo -e "${GREEN}[8/8] 配置服务...${NC}"

# 创建前端目录
mkdir -p /var/www/lingsu-health

# 配置 application.yml
if [ -f "src/main/resources/application.yml.template" ]; then
    cp src/main/resources/application.yml.template src/main/resources/application.yml
    sed -i "s/YOUR_MYSQL_USERNAME/$MYSQL_USER/g" src/main/resources/application.yml
    sed -i "s/YOUR_MYSQL_PASSWORD/$MYSQL_PASSWORD/g" src/main/resources/application.yml
    echo -e "${YELLOW}请编辑 src/main/resources/application.yml 添加 DeepSeek API Key${NC}"
fi

# 配置 Systemd 服务
if [ -f "deploy/lingsu-health.service" ]; then
    cp deploy/lingsu-health.service /etc/systemd/system/
    systemctl daemon-reload
fi

# 配置 Nginx
if [ -f "deploy/nginx.conf" ]; then
    if [ -z "$DOMAIN_NAME" ]; then
        SERVER_IP=$(hostname -I | awk '{print $1}')
        sed -i "s/your-domain.com/$SERVER_IP/g" deploy/nginx.conf
    else
        sed -i "s/your-domain.com/$DOMAIN_NAME/g" deploy/nginx.conf
    fi
    cp deploy/nginx.conf /etc/nginx/sites-available/lingsu-health
    ln -sf /etc/nginx/sites-available/lingsu-health /etc/nginx/sites-enabled/
    nginx -t && systemctl restart nginx
fi

# 配置防火墙
echo -e "${GREEN}配置防火墙...${NC}"
apt install ufw -y
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# 导入数据库
if [ -f "lingsu_health.sql" ]; then
    echo -e "${GREEN}导入数据库...${NC}"
    mysql -u $MYSQL_USER -p$MYSQL_PASSWORD lingsu_health < lingsu_health.sql
fi

echo ""
echo "======================================"
echo -e "${GREEN}  ✅ 服务器初始化完成！${NC}"
echo "======================================"
echo ""
echo "下一步操作："
echo "1. 编辑配置文件添加 DeepSeek API Key:"
echo "   vim /opt/lingsu-health/src/main/resources/application.yml"
echo ""
echo "2. 构建并启动服务:"
echo "   cd /opt/lingsu-health"
echo "   bash deploy/deploy.sh"
echo ""
echo "3. (可选) 配置 HTTPS:"
echo "   apt install certbot python3-certbot-nginx -y"
echo "   certbot --nginx -d $DOMAIN_NAME"
echo ""
echo "访问地址:"
if [ -z "$DOMAIN_NAME" ]; then
    echo "  http://$(hostname -I | awk '{print $1}')"
else
    echo "  http://$DOMAIN_NAME"
fi
echo ""

