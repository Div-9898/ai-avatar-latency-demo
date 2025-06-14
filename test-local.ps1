# ✅ Simple Local Test Script for DUIX AI Avatar

Write-Host "🚀 Testing DUIX AI Avatar Locally" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Set development environment
$env:NODE_ENV = "development"
$env:PORT = "3000"

Write-Host "[INFO] Installing dependencies..." -ForegroundColor Blue
npm install

Write-Host "[INFO] Starting server in development mode..." -ForegroundColor Blue

# Start server in background
$job = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    $env:NODE_ENV = "development"
    $env:PORT = "3000"
    node server.js
}

# Wait for server to start
Write-Host "[INFO] Waiting for server to start..." -ForegroundColor Blue
Start-Sleep -Seconds 8

try {
    # Test health endpoint
    Write-Host "[INFO] Testing health endpoint..." -ForegroundColor Blue
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method GET -TimeoutSec 10
    
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "[SUCCESS] ✅ Health check passed!" -ForegroundColor Green
        
        # Test latency endpoint
        Write-Host "[INFO] Testing latency measurement..." -ForegroundColor Blue
        $body = @{ clientSendTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() } | ConvertTo-Json
        $latencyResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/measure-latency" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 10
        
        if ($latencyResponse.StatusCode -eq 200) {
            Write-Host "[SUCCESS] ✅ Latency measurement working!" -ForegroundColor Green
            
            # Parse and display latency info
            $latencyData = $latencyResponse.Content | ConvertFrom-Json
            Write-Host "[INFO] Network Latency: $($latencyData.measurements.networkLatency)ms" -ForegroundColor Yellow
            Write-Host "[INFO] Server Processing: $($latencyData.measurements.serverProcessingTime)ms" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "🎉 SUCCESS! Application is working correctly!" -ForegroundColor Green
        Write-Host "📱 Open your browser to: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "🤖 Test the AI Avatar interface with real-time latency measurement" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📋 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Install AWS CLI: https://aws.amazon.com/cli/" -ForegroundColor White
        Write-Host "2. Configure AWS: aws configure" -ForegroundColor White
        Write-Host "3. Deploy to AWS: .\deploy.ps1 app-runner" -ForegroundColor White
        Write-Host ""
        Write-Host "Press any key to stop the server..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    else {
        Write-Host "[ERROR] Health check failed with status: $($healthResponse.StatusCode)" -ForegroundColor Red
    }
}
catch {
    Write-Host "[ERROR] Test failed: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Stop the server
    Write-Host "[INFO] Stopping server..." -ForegroundColor Blue
    if ($job) {
        Stop-Job $job -ErrorAction SilentlyContinue
        Remove-Job $job -ErrorAction SilentlyContinue
    }
    
    # Kill any remaining Node.js processes
    Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Write-Host "[INFO] Test completed." -ForegroundColor Blue
} 