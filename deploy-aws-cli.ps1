# 🚀 Automated AWS App Runner Deployment Script
# This script will create/update your App Runner service using AWS CLI

param(
    [string]$ServiceName = "duix-ai-avatar-latency",
    [string]$Region = "us-east-1",
    [string]$GitHubRepo = "https://github.com/Div-9898/ai-avatar-latency-demo",
    [string]$Branch = "master"
)

# Colors for output
$GREEN = "Green"
$RED = "Red"
$YELLOW = "Yellow"
$BLUE = "Blue"

function Write-Info { param([string]$Message); Write-Host "[INFO] $Message" -ForegroundColor $BLUE }
function Write-Success { param([string]$Message); Write-Host "[SUCCESS] $Message" -ForegroundColor $GREEN }
function Write-Warning { param([string]$Message); Write-Host "[WARNING] $Message" -ForegroundColor $YELLOW }
function Write-Error { param([string]$Message); Write-Host "[ERROR] $Message" -ForegroundColor $RED }

Write-Host "🚀 AWS App Runner Automated Deployment" -ForegroundColor $GREEN
Write-Host "=======================================" -ForegroundColor $GREEN

# Add AWS CLI to PATH
$env:PATH += ";C:\Program Files\Amazon\AWSCLIV2"

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check AWS CLI
try {
    $awsVersion = aws --version 2>$null
    Write-Success "AWS CLI found: $awsVersion"
} catch {
    Write-Error "AWS CLI not found. Please install AWS CLI first."
    exit 1
}

# Check AWS credentials
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    Write-Success "AWS credentials configured for account: $($identity.Account)"
} catch {
    Write-Error "AWS credentials not configured. Run 'aws configure' first."
    exit 1
}

# Check if service exists
Write-Info "Checking if App Runner service exists..."
$existingService = $null
try {
    $existingService = aws apprunner list-services --region $Region --output json | ConvertFrom-Json
    $serviceExists = $existingService.ServiceSummaryList | Where-Object { $_.ServiceName -eq $ServiceName }
    
    if ($serviceExists) {
        Write-Warning "Service '$ServiceName' already exists. Checking status..."
        $serviceDetails = aws apprunner describe-service --service-arn $serviceExists.ServiceArn --region $Region --output json | ConvertFrom-Json
        $status = $serviceDetails.Service.Status
        Write-Info "Current service status: $status"
        
        if ($status -eq "CREATE_FAILED" -or $status -eq "DELETE_FAILED") {
            Write-Warning "Service is in failed state. Deleting and recreating..."
            aws apprunner delete-service --service-arn $serviceExists.ServiceArn --region $Region
            Write-Info "Waiting for service deletion..."
            Start-Sleep -Seconds 30
        }
    }
} catch {
    Write-Info "No existing service found or error checking. Proceeding with creation..."
}

# Create App Runner service configuration
$serviceConfig = @{
    ServiceName = $ServiceName
    SourceConfiguration = @{
        Repository = @{
            RepositoryUrl = $GitHubRepo
            SourceCodeVersion = @{
                Type = "BRANCH"
                Value = $Branch
            }
            CodeConfiguration = @{
                ConfigurationSource = "API"
                CodeConfigurationValues = @{
                    Runtime = "NODEJS_14"
                    BuildCommand = "npm ci --only=production"
                    StartCommand = "npm start"
                    RuntimeEnvironmentVariables = @{
                        NODE_ENV = "production"
                        PORT = "3000"
                        HOST = "0.0.0.0"
                        DUIX_APP_ID = "1377185422953811968"
                        DUIX_APP_KEY = "4f3725b2-7d48-4ea7-8640-d1a11eb00f8c"
                        ENABLE_SSL_VALIDATION = "true"
                        AWS_REGION = $Region
                    }
                }
            }
        }
        AutoDeploymentsEnabled = $true
    }
    InstanceConfiguration = @{
        Cpu = "0.25 vCPU"
        Memory = "0.5 GB"
    }
    HealthCheckConfiguration = @{
        Protocol = "HTTP"
        Path = "/health"
        IntervalSeconds = 20
        TimeoutSeconds = 10
        HealthyThreshold = 3
        UnhealthyThreshold = 5
    }
}

# Convert to JSON
$configJson = $serviceConfig | ConvertTo-Json -Depth 10

# Save configuration to temporary file
$tempFile = "apprunner-config.json"
$configJson | Out-File -FilePath $tempFile -Encoding UTF8

Write-Info "Creating App Runner service..."
Write-Info "Configuration saved to: $tempFile"

try {
    # Create the service
    $result = aws apprunner create-service --cli-input-json file://$tempFile --region $Region --output json | ConvertFrom-Json
    
    $serviceArn = $result.Service.ServiceArn
    $serviceUrl = $result.Service.ServiceUrl
    
    Write-Success "App Runner service created successfully!"
    Write-Success "Service ARN: $serviceArn"
    Write-Success "Service URL: $serviceUrl"
    
    Write-Info "Waiting for service to be ready..."
    Write-Info "This may take 5-10 minutes..."
    
    # Wait for service to be running
    $maxAttempts = 30
    $attempt = 0
    
    do {
        Start-Sleep -Seconds 20
        $attempt++
        
        $serviceStatus = aws apprunner describe-service --service-arn $serviceArn --region $Region --output json | ConvertFrom-Json
        $status = $serviceStatus.Service.Status
        
        Write-Info "Attempt $attempt/$maxAttempts - Service status: $status"
        
        if ($status -eq "RUNNING") {
            Write-Success "🎉 Service is now RUNNING!"
            Write-Success "🌐 Your application is available at: $serviceUrl"
            Write-Success "🔍 Health check: $serviceUrl/health"
            Write-Success "📊 Status endpoint: $serviceUrl/api/status"
            break
        } elseif ($status -eq "CREATE_FAILED") {
            Write-Error "Service creation failed. Check AWS Console for details."
            break
        }
        
    } while ($attempt -lt $maxAttempts)
    
    if ($attempt -ge $maxAttempts) {
        Write-Warning "Service is still not ready after $maxAttempts attempts."
        Write-Info "Check AWS Console for current status: https://console.aws.amazon.com/apprunner/"
    }
    
} catch {
    Write-Error "Failed to create App Runner service: $($_.Exception.Message)"
    Write-Info "Check the configuration file: $tempFile"
} finally {
    # Clean up temporary file
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
        Write-Info "Cleaned up temporary configuration file"
    }
}

Write-Host "`n🎯 Deployment Summary:" -ForegroundColor $GREEN
Write-Host "Service Name: $ServiceName" -ForegroundColor $BLUE
Write-Host "Region: $Region" -ForegroundColor $BLUE
Write-Host "Repository: $GitHubRepo" -ForegroundColor $BLUE
Write-Host "Branch: $Branch" -ForegroundColor $BLUE

if ($serviceUrl) {
    Write-Host "`n🌐 Application URLs:" -ForegroundColor $GREEN
    Write-Host "Main App: $serviceUrl" -ForegroundColor $BLUE
    Write-Host "Health Check: $serviceUrl/health" -ForegroundColor $BLUE
    Write-Host "API Status: $serviceUrl/api/status" -ForegroundColor $BLUE
}

Write-Host "`n📊 Next Steps:" -ForegroundColor $GREEN
Write-Host "1. Test your application at the provided URL" -ForegroundColor $YELLOW
Write-Host "2. Monitor logs in AWS CloudWatch" -ForegroundColor $YELLOW
Write-Host "3. Set up custom domain (optional)" -ForegroundColor $YELLOW
Write-Host "4. Configure monitoring and alerts" -ForegroundColor $YELLOW 