@echo off
echo ========================================
echo Railway MySQL Database Import Tool
echo ========================================
echo.
echo Step 1: Get password from Railway
echo Go to Railway MySQL service -^> Connect -^> Public Network -^> Click "show" next to password
echo.
echo Step 2: Copy the FULL mysql command from Railway (with password included)
echo Click "show" next to "Raw mysql command" and copy everything
echo.
echo Step 3: Paste it here and add at the end: ^< lingsu_health.sql
echo.
echo Example:
echo mysql -h centerbeam.proxy.rlwy.net -u root -pYOURPASSWORD --port 35901 railway ^< lingsu_health.sql
echo.
echo ========================================
echo Or press Ctrl+C to cancel
echo ========================================
pause
echo.
echo Please paste the command from Railway:
pause
