@echo off
setlocal

title Ordera - Command Center

:main_menu
cls
echo ====================================================
echo          Ordera Multi-Tenant Restaurant System
echo ====================================================
echo.

:: 1. Check Python
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto python_fail

:: 2. Check Virtual Environment
if not exist "venv\" goto create_venv
goto check_dependencies

:create_venv
echo [INFO] Creating virtual environment...
python -m venv venv
if %ERRORLEVEL% NEQ 0 goto venv_fail
goto check_dependencies

:check_dependencies
echo [INFO] Syncing backend dependencies...
if not exist "venv\Scripts\activate.bat" goto venv_broken

call venv\Scripts\activate.bat
pip install -r backend/requirements.txt
if %ERRORLEVEL% NEQ 0 goto pip_fail

:prompt_mode
echo.
echo Please select startup mode:
echo [1] Local Development (SQLite - Quickest)
echo [2] Production Sync (Docker - PostgreSQL + Redis)
echo [3] Refresh ^& Rebuild (Fix connection issues)
echo [Q] Quit
echo.
set /p choice="Enter choice: "

if /i "%choice%"=="Q" exit /b
if "%choice%"=="1" goto start_local
if "%choice%"=="2" goto start_docker
if "%choice%"=="3" goto refresh_all

echo Invalid choice.
goto prompt_mode

:start_docker
echo.
echo [INFO] Checking for Docker...

:: Try V2
docker compose version >nul 2>&1
if %ERRORLEVEL% EQU 0 goto run_v2

:: Try V1
docker-compose version >nul 2>&1
if %ERRORLEVEL% EQU 0 goto run_v1

:: Fail
goto docker_not_found

:run_v2
echo [INFO] Starting Production Stack (Docker Compose V2)...
:: Use --build to ensure code changes are picked up
docker compose up -d --build
goto check_docker_result

:run_v1
echo [INFO] Starting Production Stack (Docker Compose V1)...
:: Use --build to ensure code changes are picked up
docker-compose up -d --build
goto check_docker_result

:check_docker_result
if %ERRORLEVEL% NEQ 0 goto docker_runtime_fail
echo [SUCCESS] Docker services are running in the background.
goto start_frontend

:start_local
echo.
echo [INFO] Starting Local Backend Server...
:: Set PYTHONPATH to backend folder so absolute imports work
set PYTHONPATH=%cd%\backend
:: Launch backend in a separate window
start "Ordera Backend" cmd /k "cd backend && ..\venv\Scripts\activate.bat && python -m uvicorn main:app --host 0.0.0.0 --port 8000"
echo [INFO] Waiting for backend to warm up...
timeout /t 3 /nobreak >nul
goto start_frontend

:start_frontend
echo.
echo [INFO] Launching Frontend (Flutter Chrome)...
cd frontend
start "Ordera Frontend" cmd /c "flutter run -d chrome"
cd ..

echo.
echo ====================================================
echo ✅ Ordera is starting up!
echo.
echo Backend URL: http://localhost:8000
echo Frontend: Starting in Chrome...
echo.
echo You can close this window now.
echo ====================================================
echo.
pause
exit /b

:refresh_all
echo [INFO] Clearing local databases...
del /q ordera*.db 2>nul
echo [INFO] Resetting Docker volumes...
docker-compose down -v
echo [INFO] Rebuilding...
goto start_docker

:python_fail
echo [ERROR] Python is not installed or not in PATH.
pause
exit /b

:venv_fail
echo [ERROR] Failed to create virtual environment.
pause
exit /b

:venv_broken
echo [ERROR] Virtual environment folder is missing or broken.
pause
exit /b

:pip_fail
echo [ERROR] Failed to install backend dependencies.
pause
exit /b

:docker_not_found
echo.
echo [ERROR] Docker command not found.
echo Please ensure Docker Desktop is installed and running.
echo.
pause
goto prompt_mode

:docker_runtime_fail
echo.
echo [ERROR] Docker Compose failed to start the containers.
echo.
pause
goto prompt_mode
