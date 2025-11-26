# 多阶段构建 - 构建阶段
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app
# 先复制依赖文件，利用Docker缓存
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
# 下载依赖（这层会被缓存）
RUN mvn dependency:go-offline -B
# 复制源代码并构建
COPY src ./src
RUN mvn clean package -DskipTests -B

# 运行阶段 - 使用更小的JRE镜像
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# 从构建阶段复制jar包
COPY --from=builder /app/target/LingSuHealth-0.0.1-SNAPSHOT.jar app.jar
# 暴露端口
EXPOSE 8080
# 使用环境变量优化JVM
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]


