@echo off
REM ✅ Simple Windows Deployment Script for DUIX AI Avatar

echo 🚀 DUIX AI Avatar Deployment
echo ===============================

REM Check if argument provided
if "%1"=="test" goto test
if "%1"=="start" goto start
if "%1"=="aws" goto aws

echo Usage: deploy.bat [test^|start^|aws]
echo.
echo   test  - Test the application locally
echo   start - Start the production server
echo   aws   - Show AWS deployment instructions
goto end

:test
echo [INFO] Testing DUIX AI Avatar locally...
echo [INFO] Installing dependencies...
call npm install
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    goto end
)

REM Set development environment for testing
set NODE_ENV=development
set PORT=3000
set HOST=0.0.0.0

echo [INFO] Starting test server in development mode...
start /B node server.js
timeout /t 8 /nobreak >nul

echo [INFO] Testing health endpoint...
curl -f http://localhost:3000/health
if errorlevel 1 (
    echo [ERROR] Health check failed
    taskkill /f /im node.exe >nul 2>&1
    goto end
)

echo [INFO] Testing latency endpoint...
powershell -Command "$body = @{ clientSendTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() } | ConvertTo-Json; Invoke-WebRequest -Uri 'http://localhost:3000/api/measure-latency' -Method POST -Body $body -ContentType 'application/json'"

echo.
echo [SUCCESS] ✅ Local test completed successfully!
echo [INFO] Application running at: http://localhost:3000
echo [INFO] Open your browser to test the AI Avatar interface
echo [INFO] Press any key to stop the server...
pause >nul
taskkill /f /im node.exe >nul 2>&1
goto end

:start
echo [INFO] Starting DUIX AI Avatar in production mode...
REM Set production environment
set NODE_ENV=production
set PORT=3000
set HOST=0.0.0.0
set DUIX_APP_ID=1377185422953811968
set DUIX_APP_KEY=4f3725b2-7d48-4ea7-8640-d1a11eb00f8c

call npm install
node server.js
goto end

:aws
echo [INFO] AWS Deployment Instructions:
echo.
echo 1. Install AWS CLI: https://aws.amazon.com/cli/
echo 2. Configure credentials: aws configure
echo 3. Run PowerShell script: .\deploy.ps1 app-runner
echo.
echo Alternative - Manual CloudFormation:
echo aws cloudformation deploy --template-file cloudformation-template.yml --stack-name duix-ai-avatar-latency --capabilities CAPABILITY_NAMED_IAM
echo.
echo For more details, see DEPLOY.md
goto end

:end
echo.
echo Deployment script completed.
pause 