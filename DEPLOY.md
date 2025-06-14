# 🚀 Quick AWS Deployment Guide

## Prerequisites

1. **AWS CLI** - [Download here](https://aws.amazon.com/cli/)
2. **AWS Account** with appropriate permissions
3. **Node.js 18+** - [Download here](https://nodejs.org/)
4. **Git** (if deploying from repository)

## 🎯 Option 1: AWS App Runner (Recommended - Easiest)

### Step 1: Configure AWS CLI
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, Region (us-east-1), and output format (json)
```

### Step 2: Deploy with PowerShell (Windows)
```powershell
# Run the deployment script
.\deploy.ps1 app-runner
```

### Step 3: Deploy with Bash (Linux/Mac)
```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh app-runner
```

**That's it!** Your application will be deployed to AWS App Runner with:
- ✅ Auto-scaling
- ✅ Load balancing  
- ✅ SSL/TLS certificates
- ✅ Health monitoring
- ✅ CloudWatch logging

---

## 🎯 Option 2: Manual CloudFormation Deployment

### Step 1: Deploy Infrastructure
```bash
aws cloudformation deploy \
  --template-file cloudformation-template.yml \
  --stack-name duix-ai-avatar-latency \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    DuixAppId="1377185422953811968" \
    DuixAppKey="4f3725b2-7d48-4ea7-8640-d1a11eb00f8c" \
    SourceCodeUrl="https://github.com/your-org/duix-ai-avatar-latency-demo"
```

### Step 2: Get Application URL
```bash
aws cloudformation describe-stacks \
  --stack-name duix-ai-avatar-latency \
  --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' \
  --output text
```

---

## 🎯 Option 3: Docker Container Deployment

### Step 1: Build Docker Image
```bash
docker build -t duix-ai-avatar .
```

### Step 2: Run Locally (Testing)
```bash
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  -e DUIX_APP_ID="1377185422953811968" \
  -e DUIX_APP_KEY="4f3725b2-7d48-4ea7-8640-d1a11eb00f8c" \
  duix-ai-avatar
```

### Step 3: Deploy to AWS ECS
```bash
# Use the deployment script
.\deploy.ps1 ecs  # Windows
./deploy.sh ecs   # Linux/Mac
```

---

## 🎯 Option 4: GitHub Actions (CI/CD)

### Step 1: Fork Repository
Fork this repository to your GitHub account

### Step 2: Set GitHub Secrets
In your repository settings, add these secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DUIX_APP_ID`
- `DUIX_APP_KEY`

### Step 3: Push to Main Branch
Any push to the main branch will automatically deploy to AWS App Runner

---

## 🔧 Environment Variables

Set these environment variables for production:

```bash
# Required
export DUIX_APP_ID="your-duix-app-id"
export DUIX_APP_KEY="your-duix-app-key"
export NODE_ENV="production"

# Optional
export AWS_REGION="us-east-1"
export PORT="3000"
export TOKEN_EXPIRY="1800"
```

---

## 📊 Monitoring Your Deployment

### Health Check URLs
- **Health**: `https://your-app-url/health`
- **Status**: `https://your-app-url/api/status`
- **Ping**: `https://your-app-url/ping`

### AWS Console Links
- **App Runner**: [Console](https://console.aws.amazon.com/apprunner/)
- **CloudWatch Logs**: [Console](https://console.aws.amazon.com/cloudwatch/home#logsV2:log-groups)
- **CloudFormation**: [Console](https://console.aws.amazon.com/cloudformation/)

---

## 🚨 Troubleshooting

### Common Issues

**AWS CLI Not Configured**
```bash
aws configure
# Follow the prompts to enter your credentials
```

**Permission Denied**
```bash
# Check your AWS permissions
aws sts get-caller-identity
```

**Docker Not Found**
```bash
# Install Docker Desktop
# Windows: https://docs.docker.com/desktop/windows/
# Mac: https://docs.docker.com/desktop/mac/
# Linux: https://docs.docker.com/engine/install/
```

**Node.js Version Issues**
```bash
# Check Node.js version (should be 18+)
node --version

# Update if needed
# Windows: Download from nodejs.org
# Mac: brew install node
# Linux: Use your package manager
```

### Getting Help

1. **Check CloudWatch Logs** for application errors
2. **Review AWS Console** for service status
3. **Test Health Endpoints** to verify deployment
4. **Check GitHub Issues** for known problems

---

## 🎉 Success!

Once deployed, your DUIX AI Avatar application will be available at the provided URL with:

- 🤖 **Real-time AI Avatar** with speech-to-speech interaction
- ⏱️ **Comprehensive Latency Measurement** with live metrics
- 🔒 **Production Security** with SSL/TLS encryption
- 📊 **Monitoring & Analytics** with CloudWatch integration
- 🚀 **Auto-scaling** based on demand

**Your application is now ready for production use!** 