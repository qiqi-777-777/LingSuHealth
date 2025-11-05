# LingSu Health - 灵素健康养生平台

基于中医体质理论的智能健康管理平台，提供个性化养生方案和健康打卡服务。

## 📋 项目简介

LingSu Health 是一个前后端分离的健康养生平台，集成了中医体质测评、每日健康打卡、AI 智能问答、个性化养生方案等功能。

## 🎯 主要功能

- **体质测评**：基于中医九种体质理论的智能测评系统
- **每日打卡**：记录睡眠、运动、饮食、症状等健康数据
- **健康仪表盘**：数据可视化展示，健康趋势分析
- **个性化养生方案**：根据体质提供饮食、运动、作息等建议
- **AI 智能助手**：基于 DeepSeek API 的健康问答
- **季节养生**：结合二十四节气的养生建议
- **知识库**：中医养生知识库（待完善）

## 🛠️ 技术栈

### 后端
- **框架**：Spring Boot 3.x
- **数据库**：MySQL 8.0
- **ORM**：MyBatis Plus
- **构建工具**：Maven
- **JDK**：Java 17

### 前端
- **框架**：Vue 3
- **语言**：TypeScript
- **构建工具**：Vite
- **路由**：Vue Router
- **状态管理**：Pinia
- **HTTP 客户端**：Axios
- **图表库**：Chart.js

## 📦 项目结构

```
LingSuHealth/
├── src/                          # 后端源码
│   ├── main/
│   │   ├── java/
│   │   │   └── com/lingsu/health/
│   │   │       ├── controller/   # 控制器
│   │   │       ├── service/      # 业务逻辑
│   │   │       ├── entity/       # 实体类
│   │   │       ├── mapper/       # 数据访问层
│   │   │       ├── dto/          # 数据传输对象
│   │   │       └── config/       # 配置类
│   │   └── resources/
│   │       ├── mapper/           # MyBatis XML
│   │       └── application.yml   # 配置文件
│   └── test/                     # 测试代码
├── ui/                           # 前端源码
│   ├── src/
│   │   ├── views/                # 页面组件
│   │   ├── router/               # 路由配置
│   │   ├── services/             # API 服务
│   │   └── stores/               # 状态管理
│   └── public/                   # 静态资源
├── deploy/                       # 部署脚本和配置
│   ├── nginx.conf               # Nginx 配置
│   ├── lingsu-health.service    # Systemd 服务
│   ├── deploy.sh                # 快速部署脚本
│   └── backup.sh                # 数据库备份脚本
├── lingsu_health.sql            # 数据库初始化脚本
└── pom.xml                      # Maven 配置
```

## 🚀 快速开始

### 开发环境要求

- JDK 17+
- Node.js 20+
- MySQL 8.0+
- Maven 3.6+

### 本地开发

#### 1. 克隆项目

```bash
git clone https://github.com/your-username/LingSuHealth.git
cd LingSuHealth
```

#### 2. 配置数据库

```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE lingsu_health CHARACTER SET utf8mb4;

# 导入数据
mysql -u root -p lingsu_health < lingsu_health.sql
```

#### 3. 配置后端

```bash
# 复制配置模板
cp src/main/resources/application.yml.template src/main/resources/application.yml

# 编辑配置文件，修改数据库密码和 API Key
vim src/main/resources/application.yml
```

#### 4. 启动后端

```bash
# 方式一：使用 Maven
mvn spring-boot:run

# 方式二：使用 IDE
# 在 IDEA 中运行 LingSuHealthApplication.java
```

#### 5. 启动前端

```bash
cd ui
npm install
npm run dev
```

访问 `http://localhost:5173` 即可使用。

## 🌐 生产部署

详细部署指南请查看 [部署指南.md](./部署指南.md)

### 快速部署（服务器上）

```bash
# 1. 克隆代码到服务器
git clone https://github.com/your-username/LingSuHealth.git /opt/lingsu-health

# 2. 配置数据库和配置文件
# （参考部署指南）

# 3. 运行快速部署脚本
cd /opt/lingsu-health
chmod +x deploy/deploy.sh
sudo bash deploy/deploy.sh
```

## 📊 数据库设计

### 主要表结构

- `users` - 用户表
- `user_profiles` - 用户档案表
- `health_checkins` - 健康打卡记录表
- `assessment_records` - 体质测评记录表
- `knowledge_categories` - 知识库分类表（规划中）
- `knowledge_articles` - 知识库文章表（规划中）
- `knowledge_images` - 知识库图片表（规划中）

详细表结构请查看 [lingsu_health.sql](./lingsu_health.sql)

## 🔧 配置说明

### 后端配置 (application.yml)

```yaml
server:
  port: 8080                    # 后端端口

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/lingsu_health
    username: root              # 数据库用户名
    password: 123456            # 数据库密码

deepseek:
  api:
    key: sk-xxx                 # DeepSeek API Key
    url: https://api.deepseek.com/v1/chat/completions
```

### 前端配置 (api.ts)

```typescript
const API_BASE_URL = '/api';    // 生产环境通过 Nginx 代理
// const API_BASE_URL = 'http://localhost:8080';  // 开发环境
```

## 📝 API 文档

### 主要接口

| 接口 | 方法 | 说明 |
|-----|------|------|
| `/auth/login` | POST | 用户登录 |
| `/auth/register` | POST | 用户注册 |
| `/profiles/me` | GET | 获取用户档案 |
| `/checkins` | POST | 健康打卡 |
| `/assessments/latest` | GET | 获取最新测评结果 |
| `/plan/daily` | GET | 获取每日养生方案 |
| `/assistant/qa` | POST | AI 问答 |
| `/season/current` | GET | 获取当前节气养生建议 |

## 🔒 安全建议

1. **不要将敏感信息提交到 Git**
   - `application.yml` 中的数据库密码
   - DeepSeek API Key
   - 其他密钥和凭证

2. **生产环境建议**
   - 使用强密码
   - 配置 HTTPS（Let's Encrypt）
   - 配置防火墙规则
   - 定期备份数据库
   - 限制数据库远程访问

3. **API Key 保护**
   - 使用环境变量
   - 不要硬编码在前端
   - 定期轮换密钥

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 开源协议

本项目采用 MIT 协议，详见 [LICENSE](./LICENSE) 文件。

## 📞 联系方式

- 作者：[Your Name]
- Email：3058922645@qq.com
- GitHub：https://github.com/your-username/LingSuHealth

## 🙏 致谢

- [Spring Boot](https://spring.io/projects/spring-boot)
- [Vue.js](https://vuejs.org/)
- [DeepSeek](https://www.deepseek.com/)
- [Element Plus](https://element-plus.org/)（如果使用）
- 所有为开源社区做出贡献的开发者

## 📈 未来规划

- [ ] 完善知识库功能，支持图片和注解
- [ ] 添加用户社区功能
- [ ] 支持多端同步（移动端 App）
- [ ] 引入更多 AI 能力（图像识别、语音交互）
- [ ] 数据统计和报表功能增强
- [ ] 支持多语言（国际化）

---

**如果这个项目对你有帮助，请给个 ⭐️ Star 支持一下！**

