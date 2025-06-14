# 🤖 DUIX AI Avatar - Real-Time Latency Measurement

A production-ready AI Avatar application with comprehensive real-time latency measurement, built for AWS deployment. Features speech-to-speech interaction with detailed performance analytics.

## ✨ Features

### 🎯 **Real-Time Latency Measurement**
- **Speech-to-Speech Latency**: Complete user speech → avatar response timing
- **Component Breakdown**: ASR, AI Processing, TTS, and Network latencies
- **Live Metrics**: Current, Average, Best latency with count tracking
- **Performance Indicators**: Color-coded performance ratings
- **Network Monitoring**: Server round-trip time measurement

### 🗣️ **AI Avatar Capabilities**
- **Real-Time Conversation**: Natural speech-to-speech interaction
- **Voice Recognition**: Advanced ASR with real-time feedback
- **Text-to-Speech**: High-quality TTS with emotional expression
- **Visual Avatar**: Professional AI avatar with lip-sync
- **Multi-Language Support**: Configurable language settings

### 🛡️ **Production Features**
- **SSL/TLS Security**: Full encryption with certificate validation
- **AWS Optimized**: Ready for App Runner, ECS, and CloudFormation
- **Health Monitoring**: Comprehensive health checks and metrics
- **Auto-Scaling**: Configurable scaling based on demand
- **Error Handling**: Graceful fallbacks and circuit breaker patterns

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- AWS CLI configured
- Docker (optional)
- Git

### Local Development
```bash
# Clone the repository
git clone https://github.com/your-org/duix-ai-avatar-latency-demo.git
cd duix-ai-avatar-latency-demo

# Install dependencies
npm install

# Start development server
npm run dev

# Open browser
open http://localhost:3000
```

### Environment Variables
```bash
# Required for production
export DUIX_APP_ID="your-duix-app-id"
export DUIX_APP_KEY="your-duix-app-key"
export NODE_ENV="production"

# Optional
export AWS_REGION="us-east-1"
export PORT="3000"
export TOKEN_EXPIRY="1800"
```

## 🌐 AWS Deployment

### Option 1: AWS App Runner (Recommended)
```bash
# Make deployment script executable
chmod +x deploy.sh

# Deploy to AWS App Runner
./deploy.sh app-runner
```

### Option 2: CloudFormation Template
```bash
# Deploy using CloudFormation
aws cloudformation deploy \
  --template-file cloudformation-template.yml \
  --stack-name duix-ai-avatar-latency \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    DuixAppId="your-app-id" \
    DuixAppKey="your-app-key" \
    SourceCodeUrl="https://github.com/your-org/duix-ai-avatar-latency-demo"
```

### Option 3: Docker Container
```bash
# Build Docker image
docker build -t duix-ai-avatar .

# Run container
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  -e DUIX_APP_ID="your-app-id" \
  -e DUIX_APP_KEY="your-app-key" \
  duix-ai-avatar
```

### Option 4: Docker Compose
```bash
# Start with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📊 Latency Measurement System

### Real-Time Metrics
The application tracks multiple latency components:

1. **ASR Latency**: Speech recognition processing time
2. **AI Processing**: Response generation time  
3. **TTS Latency**: Text-to-speech synthesis time
4. **Network Latency**: Client-server round-trip time
5. **Total Speech-to-Speech**: Complete interaction latency

### Performance Indicators
- 🟢 **Excellent**: < 300ms (Green)
- 🟡 **Good**: 300-500ms (Light Green) 
- 🟠 **Fair**: 500-1000ms (Yellow)
- 🔴 **Poor**: 1000-2000ms (Orange)
- ⚫ **Bad**: > 2000ms (Red)

### Keyboard Shortcuts
- `Ctrl + L`: Toggle latency display
- `Space`: Toggle microphone mute
- `Escape`: Toggle fullscreen

## 🏗️ Architecture

### Frontend Components
- **DUIX SDK Integration**: Official DUIX JavaScript SDK
- **Real-Time UI**: Live latency display with breakdown
- **Voice Controls**: Microphone and audio management
- **Responsive Design**: Mobile and desktop optimized

### Backend Services
- **Express.js Server**: Production-ready Node.js backend
- **JWT Authentication**: Secure token-based auth
- **Rate Limiting**: Protection against abuse
- **Health Checks**: AWS-compatible health endpoints
- **SSL/TLS**: Full encryption support

### AWS Infrastructure
- **App Runner**: Fully managed container service
- **CloudWatch**: Logging and monitoring
- **Secrets Manager**: Secure credential storage
- **Auto Scaling**: Automatic capacity management
- **Load Balancing**: High availability setup

## 🔧 Configuration

### Application Settings
```javascript
// Conversation ID for DUIX service
conversationId: "1933581339817095170"

// Avatar and voice selection
avatarId: "108" // Zhang San (Professional)
voiceId: "guina" // Professional Chinese voice

// Feature toggles
enableASR: true // Voice recognition
enableSubtitles: true // Show subtitles
```

### Production Environment
```bash
# Production optimizations
NODE_ENV=production
ENABLE_SSL_VALIDATION=true
UV_THREADPOOL_SIZE=128
NODE_OPTIONS="--max-old-space-size=4096"

# AWS configuration
AWS_REGION=us-east-1
PORT=3000
HOST=0.0.0.0
```

## 📈 Monitoring & Analytics

### Health Endpoints
- `GET /health` - Basic health check
- `GET /healthz` - Detailed health status
- `GET /ping` - Simple ping response
- `GET /api/status` - Application status

### CloudWatch Metrics
- Request latency and throughput
- CPU and memory utilization
- Error rates and status codes
- Custom application metrics

### Logging
- Structured JSON logging
- Request/response tracking
- Error monitoring
- Performance analytics

## 🛠️ Development

### Project Structure
```
├── public/           # Frontend assets
│   ├── index.html   # Main application
│   └── styles.css   # Styling
├── server.js        # Backend server
├── package.json     # Dependencies
├── Dockerfile       # Container config
├── docker-compose.yml # Local development
├── cloudformation-template.yml # AWS infrastructure
├── deploy.sh        # Deployment script
└── README.md        # Documentation
```

### API Endpoints
```
GET  /                          # Main application
GET  /health                    # Health check
GET  /api/status               # Application status
POST /api/measure-latency      # Latency measurement
GET  /api/avatars              # Available avatars
GET  /api/voices               # Available voices
POST /api/duix/create-conversation # Create conversation
```

### Testing
```bash
# Run health check
npm run health

# Test latency endpoint
curl -X POST http://localhost:3000/api/measure-latency \
  -H "Content-Type: application/json" \
  -d '{"clientSendTime": '$(date +%s%3N)'}'

# Local Docker test
./deploy.sh test
```

## 🔒 Security

### Production Security Features
- **Helmet.js**: Security headers
- **Rate Limiting**: Request throttling
- **CORS**: Cross-origin protection
- **SSL/TLS**: Full encryption
- **Input Validation**: Request sanitization
- **Secrets Management**: AWS Secrets Manager

### Environment Security
- No hardcoded credentials
- Environment variable configuration
- AWS IAM role-based access
- Container security scanning
- Regular dependency updates

## 🚨 Troubleshooting

### Common Issues

**SSL Certificate Errors**
```bash
# Check SSL validation setting
echo $ENABLE_SSL_VALIDATION

# Verify DUIX API connectivity
curl -k https://api.duix.com/duix-openapi-v2/sdk/v2/getconcurrentNumber
```

**High Latency**
- Check network connectivity
- Verify AWS region selection
- Monitor CloudWatch metrics
- Review application logs

**Avatar Connection Issues**
- Verify DUIX credentials
- Check conversation ID
- Review browser console
- Test WebRTC connectivity

### Debug Mode
```bash
# Enable debug logging
NODE_ENV=development npm start

# View detailed logs
docker-compose logs -f duix-avatar
```

## 📞 Support

### Resources
- [DUIX Official Documentation](https://docs.duix.com)
- [AWS App Runner Guide](https://docs.aws.amazon.com/apprunner/)
- [WebRTC Troubleshooting](https://webrtc.org/getting-started/testing)

### Monitoring
- CloudWatch Dashboard: Auto-created with deployment
- Application logs: `/aws/apprunner/duix-ai-avatar-latency`
- Health checks: Automated with AWS ALB

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

---

**Built with ❤️ for real-time AI avatar interactions**

🚀 **Ready for production deployment on AWS!** 