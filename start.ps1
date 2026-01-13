# Ordera Startup Script
# This script starts both the backend and frontend together

Write-Host "Starting Ordera Multi-Tenant Restaurant System..." -ForegroundColor Cyan

# Set the project root directory
$projectRoot = $PSScriptRoot

# Start Backend Server
Write-Host "`nStarting Backend Server..." -ForegroundColor Yellow
$env:PYTHONPATH = '.'
$backendProcess = Start-Process -FilePath "$projectRoot\venv\Scripts\uvicorn.exe" `
    -ArgumentList "backend.main:app", "--host", "0.0.0.0", "--port", "8000" `
    -WorkingDirectory $projectRoot `
    -PassThru `
    -WindowStyle Normal

Write-Host "Backend server started (PID: $($backendProcess.Id))" -ForegroundColor Green
Start-Sleep -Seconds 3

# Start Frontend
Write-Host "`nStarting Frontend (Flutter Chrome)..." -ForegroundColor Yellow
Start-Process -FilePath "flutter" `
    -ArgumentList "run", "-d", "chrome" `
    -WorkingDirectory "$projectRoot\frontend" `
    -NoNewWindow

Write-Host "`n✅ Ordera is starting up!" -ForegroundColor Green
Write-Host "Backend: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Frontend: Will open in Chrome automatically" -ForegroundColor Cyan
Write-Host "`nPress Ctrl+C to stop the backend server when done.`n" -ForegroundColor Yellow
