@echo off
chcp 65001 >nul
echo ========================================
echo 数据库迁移脚本 - 一键执行
echo ========================================
echo.

set /p DB_USER="请输入 MySQL 用户名 (默认: root): "
if "%DB_USER%"=="" set DB_USER=root

set /p DB_NAME="请输入数据库名 (默认: lingsu_health): "
if "%DB_NAME%"=="" set DB_NAME=lingsu_health

echo.
echo ========================================
echo 第 1 步：备份数据库
echo ========================================
set BACKUP_FILE=backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql
set BACKUP_FILE=%BACKUP_FILE: =0%
echo 备份文件: %BACKUP_FILE%
mysqldump -u %DB_USER% -p %DB_NAME% > %BACKUP_FILE%
if errorlevel 1 (
    echo ❌ 备份失败！
    pause
    exit /b 1
)
echo ✅ 备份成功！
echo.

echo ========================================
echo 第 2 步：修改 users 表类型
echo ========================================
mysql -u %DB_USER% -p %DB_NAME% < migrate_users_id_to_bigint.sql
if errorlevel 1 (
    echo ❌ 执行失败！正在回滚...
    mysql -u %DB_USER% -p %DB_NAME% < %BACKUP_FILE%
    pause
    exit /b 1
)
echo ✅ 执行成功！
echo.

echo ========================================
echo 第 3 步：创建每日任务表
echo ========================================
mysql -u %DB_USER% -p %DB_NAME% < create_daily_tasks_table.sql
if errorlevel 1 (
    echo ❌ 执行失败！正在回滚...
    mysql -u %DB_USER% -p %DB_NAME% < %BACKUP_FILE%
    pause
    exit /b 1
)
echo ✅ 执行成功！
echo.

echo ========================================
echo 第 4 步：健康闭环优化（可选）
echo ========================================
set /p CONTINUE="是否执行健康闭环优化？(Y/N，默认: Y): "
if "%CONTINUE%"=="" set CONTINUE=Y
if /i "%CONTINUE%"=="Y" (
    mysql -u %DB_USER% -p %DB_NAME% < health_loop_optimization.sql
    if errorlevel 1 (
        echo ❌ 执行失败！正在回滚...
        mysql -u %DB_USER% -p %DB_NAME% < %BACKUP_FILE%
        pause
        exit /b 1
    )
    echo ✅ 执行成功！
) else (
    echo ⏭️ 跳过健康闭环优化
)
echo.

echo ========================================
echo 第 5 步：验证结果
echo ========================================
mysql -u %DB_USER% -p %DB_NAME% < test_migration.sql
echo.

echo ========================================
echo ✅ 所有步骤执行完成！
echo ========================================
echo 备份文件保存在: %BACKUP_FILE%
echo 如需回滚，请执行:
echo mysql -u %DB_USER% -p %DB_NAME% ^< %BACKUP_FILE%
echo.
pause
