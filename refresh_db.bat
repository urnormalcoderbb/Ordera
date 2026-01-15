@echo off
echo ====================================================
echo          Ordera Database ^& Cache Refresh
echo ====================================================
echo.

:: 1. Clear Local SQLite Databases
echo [1/3] Clearing local SQLite databases...
del /q ordera*.db 2>nul
echo Done.

:: 2. Clear Docker Volumes (PostgreSQL ^& Redis Cache)
echo [2/3] Resetting Docker containers and volumes...
docker-compose down -v
if %errorlevel% neq 0 (
    echo [SKIP] Docker is not running or no containers to stop.
) else (
    echo Docker volumes cleared.
)

:: 3. Restart Docker
echo [3/3] Restarting Docker Production Stack...
docker-compose up -d
if %errorlevel% neq 0 (
    echo [SKIP] Docker failed to start. Please check Docker Desktop.
) else (
    echo Docker services restarted fresh.
)

echo.
echo ====================================================
echo ✅ Refresh Complete! 
echo All databases are empty and ready for fresh signup.
echo ====================================================
echo.
pause
