# 灵溯健康管理系统 (LingSuHealth)

## 📖 项目简介

灵溯健康管理系统是一个基于中医养生理念的智能健康管理平台，结合现代AI技术为用户提供个性化的健康管理方案。系统支持健康打卡、体质评估、节气养生、知识库管理等功能，帮助用户建立科学的健康生活习惯。

## ✨ 核心功能

- **🏥 健康打卡** - 每日健康数据记录（睡眠、运动、饮食、心情等）
- **📊 仪表盘** - 可视化健康数据趋势分析
- **🧪 体质评估** - 基于中医理论的体质测评
- **🤖 AI健康助手** - 集成DeepSeek AI提供智能健康建议
- **📚 知识库** - 中医养生知识库（食材、药材、养生方法等）
- **📅 健康计划** - 个性化健康管理方案制定
- **🌿 节气养生** - 二十四节气养生指导
- **👤 个人资料** - 用户信息管理与健康档案

## 🛠️ 技术栈

### 后端技术
- **框架**: Spring Boot 3.1.12
- **数据库**: MySQL 8.0
- **ORM**: MyBatis-Plus 3.5.7
- **安全**: Spring Security (密码加密)
- **文档**: SpringDoc OpenAPI 2.5.0
- **AI集成**: DeepSeek API (通过WebFlux调用)
- **开发工具**: Lombok, Spring DevTools

### 前端技术
- **框架**: Vue 3.5
- **语言**: TypeScript 5.9
- **构建工具**: Vite 7.1
- **路由**: Vue Router 4.6
- **状态管理**: Pinia 3.0
- **HTTP客户端**: Axios 1.13
- **图表库**: Chart.js 4.5 + vue-chartjs 5.3

### 部署技术
- **容器化**: Docker + Docker Compose
- **Web服务器**: Nginx
- **数据库**: MySQL 8.0 容器化部署

## 📋 环境要求

### 开发环境
- **JDK**: 17+
- **Maven**: 3.6+
- **Node.js**: 20.19+ 或 22.12+
- **MySQL**: 8.0+
- **IDE**: IntelliJ IDEA / VS Code

### 生产环境
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

## 🚀 快速开始

### 方式一：本地开发环境部署

#### 1. 克隆项目
```bash
git clone <repository-url>
cd LingSuHealth
```

#### 2. 配置数据库
```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE lingsu_health DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 导入初始化SQL
mysql -u root -p lingsu_health < lingsu_health.sql
```

#### 3. 配置后端
编辑 `src/main/resources/application.yml`：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/lingsu_health?useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 你的数据库密码

deepseek:
  api:
    key: sk-b0b4f0292f8848c483ec8e1a847c6766
    url: https://api.deepseek.com/v1/chat/completions
```

#### 4. 启动后端
```bash
# 使用Maven
./mvnw spring-boot:run

# 或使用IDE直接运行 LingSuHealthApplication
```

后端服务将在 `http://localhost:8080` 启动

#### 5. 启动前端
```bash
cd ui
npm install
npm run dev
```

前端服务将在 `http://localhost:5173` 启动

### 方式二：Docker Compose 一键部署

#### 1. 配置环境变量
创建 `.env` 文件（可选）：
```env
MYSQL_ROOT_PASSWORD=123456
MYSQL_DATABASE=lingsu_health
DEEPSEEK_API_KEY=你的API密钥
```

#### 2. 构建前端
```bash
cd ui
npm install
npm run build
cd ..
```

#### 3. 启动所有服务
```bash
docker-compose up -d
```

服务访问地址：
- 前端: http://localhost
- 后端API: http://localhost:8080
- MySQL: localhost:3306

#### 4. 查看日志
```bash
docker-compose logs -f
```

#### 5. 停止服务
```bash
docker-compose down
```

## 📁 项目结构

```
LingSuHealth/
├── src/main/java/com/lingsu/health/    # 后端Java代码
│   ├── controller/                      # REST API控制器
│   │   ├── AssessmentController.java   # 体质评估
│   │   ├── AuthController.java         # 认证登录
│   │   ├── CheckinController.java      # 健康打卡
│   │   ├── DashboardController.java    # 仪表盘
│   │   ├── KnowledgeController.java    # 知识库
│   │   ├── PlanController.java         # 健康计划
│   │   ├── SeasonController.java       # 节气管理
│   │   └── UserController.java         # 用户管理
│   ├── service/                         # 业务逻辑层
│   │   ├── DeepSeekService.java        # AI服务
│   │   ├── HealthCheckinService.java   # 打卡服务
│   │   ├── KnowledgeService.java       # 知识库服务
│   │   ├── PlanService.java            # 计划服务
│   │   └── UserProfileService.java     # 用户服务
│   ├── mapper/                          # MyBatis数据访问层
│   ├── entity/                          # 实体类
│   ├── config/                          # 配置类
│   └── LingSuHealthApplication.java    # 主应用入口
├── src/main/resources/
│   ├── application.yml                  # 应用配置
│   └── mapper/                          # MyBatis XML映射
├── ui/                                  # 前端Vue项目
│   ├── src/
│   │   ├── views/                       # 页面组件
│   │   │   ├── Dashboard.vue           # 仪表盘
│   │   │   ├── Checkin.vue             # 打卡页面
│   │   │   ├── Assessment.vue          # 评估页面
│   │   │   ├── Knowledge.vue           # 知识库
│   │   │   ├── Plan.vue                # 计划管理
│   │   │   ├── Season.vue              # 节气养生
│   │   │   ├── Assistant.vue           # AI助手
│   │   │   ├── Profile.vue             # 个人资料
│   │   │   └── Login.vue               # 登录页面
│   │   ├── services/                    # API服务
│   │   ├── router/                      # 路由配置
│   │   └── stores/                      # 状态管理
│   └── package.json
├── deploy/                              # 部署配置
│   └── nginx.conf                       # Nginx配置
├── docker-compose.yml                   # Docker编排文件
├── Dockerfile                           # Docker镜像构建
├── lingsu_health.sql                    # 数据库初始化脚本
└── pom.xml                              # Maven配置
```

## 🔌 API文档

### 访问Swagger文档
启动后端服务后，访问：
```
http://localhost:8080/swagger-ui/index.html
```

### 主要API端点

#### 认证相关
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录

#### 健康打卡
- `GET /api/checkin/recent` - 获取最近7天打卡记录
- `POST /api/checkin` - 提交打卡数据
- `GET /api/checkin/calendar/{year}/{month}` - 获取月度打卡日历

#### 仪表盘
- `GET /api/dashboard/metrics` - 获取健康指标汇总

#### 体质评估
- `POST /api/assessment` - 提交体质评估
- `GET /api/assessment/recent` - 获取最近评估结果

#### 知识库
- `GET /api/knowledge` - 搜索知识库
- `GET /api/knowledge/categories` - 获取分类列表
- `POST /api/knowledge` - 添加知识条目

#### 节气养生
- `GET /api/seasons/current` - 获取当前节气
- `GET /api/seasons/{seasonName}` - 获取指定节气信息

#### AI助手
- `POST /api/assistant/chat` - AI对话

## ⚙️ 配置说明

### 数据库配置
位置: `src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/lingsu_health
    username: root
    password: 你的密码
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### AI服务配置
```yaml
deepseek:
  api:
    key: sk-b0b4f0292f8848c483ec8e1a847c6766
    url: https://api.deepseek.com/v1/chat/completions
```

### 文件上传配置
```yaml
spring:
  servlet:
    multipart:
      max-file-size: 100MB
      max-request-size: 100MB
```

### 前端API地址配置
位置: `ui/src/services/api.ts`

```typescript
const API_BASE_URL = 'http://localhost:8080/api'
```

## 👥 默认账号

系统初始化后的默认账号：
- 用户名: `admin`
- 密码: 请查看数据库初始化脚本

## 📊 数据库表说明

### 核心数据表
- `users` - 用户基本信息
- `user_profiles` - 用户详细资料
- `health_checkins` - 健康打卡记录
- `assessment_records` - 体质评估记录
- `health_trends` - 健康趋势数据
- `knowledge_items` - 知识库条目
- `seasons` - 二十四节气信息
- `health_plans` - 健康计划

## 🔧 开发指南

### 后端开发
```bash
# 编译项目
./mvnw clean compile

# 运行测试
./mvnw test

# 打包
./mvnw clean package

# 跳过测试打包
./mvnw clean package -DskipTests
```

### 前端开发
```bash
cd ui

# 安装依赖
npm install

# 开发模式
npm run dev

# 类型检查
npm run type-check

# 代码检查
npm run lint

# 格式化代码
npm run format

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

## 🐛 常见问题

### 1. 后端启动失败
**问题**: 数据库连接失败
**解决**: 
- 检查MySQL服务是否启动
- 确认 `application.yml` 中的数据库配置正确
- 确保数据库 `lingsu_health` 已创建

### 2. 前端无法访问API
**问题**: 跨域错误或404
**解决**:
- 确认后端服务已启动 (http://localhost:8080)
- 检查前端 API 配置地址是否正确
- 确认后端CORS配置已启用

### 3. Docker部署失败
**问题**: 容器启动失败
**解决**:
- 检查端口是否被占用 (3306, 8080, 80)
- 确保前端已构建 `npm run build`
- 查看容器日志 `docker-compose logs -f`

### 4. AI助手无响应
**问题**: DeepSeek API调用失败
**解决**:
- 检查 API Key 是否正确配置
- 确认网络连接正常
- 检查 API 配额是否充足

## 📝 开发规范

### 代码风格
- Java: 遵循阿里巴巴Java开发规范
- TypeScript/Vue: 使用ESLint + Prettier

### 提交规范
```
feat: 新功能
fix: 修复Bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建/工具链相关
```

## 🔐 安全建议

1. **生产环境部署前务必修改**:
   - 数据库密码
   - DeepSeek API密钥
   - JWT密钥（如果使用）

2. **建议启用HTTPS**:
   - 配置SSL证书
   - 修改Nginx配置支持HTTPS

3. **数据备份**:
   - 定期备份MySQL数据
   - 备份上传的图片文件

## 📄 开源协议

本项目采用 [MIT License](LICENSE)

## 👨‍💻 贡献指南

欢迎提交Issue和Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📞 联系方式

- 项目主页: [GitHub Repository]
- 问题反馈: [Issues]

---

**祝您使用愉快！ 💚 健康生活从灵溯开始**
