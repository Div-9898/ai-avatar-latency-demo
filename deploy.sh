#!/bin/bash

# ✅ AWS Deployment Script for DUIX AI Avatar
# Supports multiple deployment methods: App Runner, ECS, and Docker

set -e  # Exit on any error

# Configuration
APP_NAME="duix-ai-avatar-latency"
AWS_REGION="${AWS_REGION:-us-east-1}"
ENVIRONMENT="${ENVIRONMENT:-production}"
GITHUB_REPO="${GITHUB_REPO:-https://github.com/your-org/duix-ai-avatar-latency-demo}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Run 'aws configure' first."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi
    
    # Check Docker (optional)
    if command -v docker &> /dev/null; then
        log_success "Docker found - container deployment available"
    else
        log_warning "Docker not found - container deployment unavailable"
    fi
    
    log_success "Prerequisites check completed"
}

# Install dependencies
install_dependencies() {
    log_info "Installing production dependencies..."
    npm ci --only=production --no-audit --no-fund
    log_success "Dependencies installed"
}

# Build application
build_application() {
    log_info "Building application..."
    npm run build
    log_success "Application built"
}

# Deploy using AWS App Runner (Recommended)
deploy_app_runner() {
    log_info "Deploying to AWS App Runner..."
    
    # Create CloudFormation stack
    STACK_NAME="${APP_NAME}-stack"
    
    log_info "Creating CloudFormation stack: $STACK_NAME"
    
    aws cloudformation deploy \
        --template-file cloudformation-template.yml \
        --stack-name "$STACK_NAME" \
        --parameter-overrides \
            ApplicationName="$APP_NAME" \
            Environment="$ENVIRONMENT" \
            SourceCodeUrl="$GITHUB_REPO" \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "$AWS_REGION" \
        --tags \
            Application="$APP_NAME" \
            Environment="$ENVIRONMENT" \
            DeployedBy="$(whoami)" \
            DeployedAt="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    
    # Get the application URL
    APP_URL=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' \
        --output text)
    
    log_success "App Runner deployment completed!"
    log_success "Application URL: $APP_URL"
    
    # Wait for service to be ready
    log_info "Waiting for service to be ready..."
    sleep 30
    
    # Health check
    if curl -f "$APP_URL/health" &> /dev/null; then
        log_success "Health check passed!"
    else
        log_warning "Health check failed - service may still be starting"
    fi
}

# Deploy using Docker to ECS (Alternative)
deploy_ecs() {
    log_info "Deploying to Amazon ECS..."
    
    # Build Docker image
    log_info "Building Docker image..."
    docker build -t "$APP_NAME:latest" .
    
    # Create ECR repository if it doesn't exist
    ECR_REPO_URI=$(aws ecr describe-repositories \
        --repository-names "$APP_NAME" \
        --region "$AWS_REGION" \
        --query 'repositories[0].repositoryUri' \
        --output text 2>/dev/null || echo "")
    
    if [ -z "$ECR_REPO_URI" ]; then
        log_info "Creating ECR repository..."
        ECR_REPO_URI=$(aws ecr create-repository \
            --repository-name "$APP_NAME" \
            --region "$AWS_REGION" \
            --query 'repository.repositoryUri' \
            --output text)
    fi
    
    # Login to ECR
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "$ECR_REPO_URI"
    
    # Tag and push image
    docker tag "$APP_NAME:latest" "$ECR_REPO_URI:latest"
    docker push "$ECR_REPO_URI:latest"
    
    log_success "Docker image pushed to ECR: $ECR_REPO_URI:latest"
    log_info "You can now deploy this image to ECS using the AWS Console or CLI"
}

# Test deployment locally
test_local() {
    log_info "Testing deployment locally..."
    
    # Build and run with Docker Compose
    if command -v docker-compose &> /dev/null; then
        docker-compose up --build -d
        
        # Wait for service to start
        sleep 10
        
        # Health check
        if curl -f "http://localhost:3000/health" &> /dev/null; then
            log_success "Local deployment test passed!"
            log_info "Application running at: http://localhost:3000"
        else
            log_error "Local deployment test failed"
            docker-compose logs
            exit 1
        fi
        
        # Stop the test deployment
        docker-compose down
    else
        log_warning "Docker Compose not available - skipping local test"
    fi
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    # Add cleanup logic here if needed
}

# Main deployment function
main() {
    echo "🚀 DUIX AI Avatar AWS Deployment Script"
    echo "========================================"
    
    # Parse command line arguments
    DEPLOYMENT_TYPE="${1:-app-runner}"
    
    case "$DEPLOYMENT_TYPE" in
        "app-runner")
            log_info "Deployment type: AWS App Runner (Recommended)"
            ;;
        "ecs")
            log_info "Deployment type: Amazon ECS with Docker"
            ;;
        "test")
            log_info "Deployment type: Local testing"
            ;;
        *)
            log_error "Invalid deployment type. Use: app-runner, ecs, or test"
            echo "Usage: $0 [app-runner|ecs|test]"
            exit 1
            ;;
    esac
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Execute deployment steps
    check_prerequisites
    install_dependencies
    build_application
    
    case "$DEPLOYMENT_TYPE" in
        "app-runner")
            deploy_app_runner
            ;;
        "ecs")
            deploy_ecs
            ;;
        "test")
            test_local
            ;;
    esac
    
    log_success "Deployment completed successfully! 🎉"
    
    # Display useful information
    echo ""
    echo "📊 Deployment Information:"
    echo "========================="
    echo "Application: $APP_NAME"
    echo "Environment: $ENVIRONMENT"
    echo "AWS Region: $AWS_REGION"
    echo "Deployment Type: $DEPLOYMENT_TYPE"
    echo ""
    echo "📋 Next Steps:"
    echo "=============="
    echo "1. Monitor your application in AWS Console"
    echo "2. Check CloudWatch logs for any issues"
    echo "3. Set up custom domain (optional)"
    echo "4. Configure monitoring and alerts"
    echo ""
    echo "🔗 Useful Links:"
    echo "==============="
    echo "AWS App Runner Console: https://console.aws.amazon.com/apprunner/home?region=$AWS_REGION"
    echo "CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home?region=$AWS_REGION#logsV2:log-groups"
    echo "CloudFormation: https://console.aws.amazon.com/cloudformation/home?region=$AWS_REGION"
}

# Run main function
main "$@" 