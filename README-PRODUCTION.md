# 🚀 DUIX AI Avatar - Production Deployment Guide

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Security Configuration](#security-configuration)
- [Deployment Options](#deployment-options)
- [Environment Configuration](#environment-configuration)
- [SSL/TLS Setup](#ssltls-setup)
- [Monitoring & Logging](#monitoring--logging)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

## 🎯 Overview

This production deployment supports:
- ✅ **Enterprise-grade security** with SSL validation and security headers
- ✅ **High availability** with clustering and auto-restart
- ✅ **Performance monitoring** with health checks and metrics
- ✅ **Scalable architecture** supporting horizontal scaling
- ✅ **Real-time AI avatars** with DUIX integration
- ✅ **Containerized deployment** with Docker and Docker Compose

## 🔧 Prerequisites

### System Requirements
- **Node.js**: ≥18.0.0
- **Memory**: Minimum 1GB RAM, Recommended 2GB+
- **CPU**: Minimum 1 core, Recommended 2+ cores
- **Storage**: 10GB+ available space
- **Network**: HTTPS connectivity to api.duix.com

### Dependencies
```bash
# Install production dependencies
npm install --production

# Optional: Install PM2 for process management
npm install -g pm2

# Optional: Install Docker for containerization
# Follow Docker installation guide for your OS
```

## 🛡️ Security Configuration

### 1. Environment Variables
Create `production.env` with your credentials:

```env
# Required: DUIX API Credentials
DUIX_APP_ID=your_actual_app_id
DUIX_APP_KEY=your_actual_app_key

# Security Settings
NODE_ENV=production
ENABLE_SSL_VALIDATION=true
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Performance Settings
TOKEN_EXPIRY=1800
UV_THREADPOOL_SIZE=128
```

### 2. Security Headers
The application automatically enables security headers in production:
- Content Security Policy (CSP)
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy
- Feature-Policy

### 3. Rate Limiting
Production rate limits are automatically applied:
- **API endpoints**: 100 requests per 15 minutes
- **DUIX endpoints**: 10 requests per minute
- **Test endpoints**: 20 requests per 5 minutes

## 🚀 Deployment Options

### Option 1: Direct Node.js Deployment

```bash
# Production start
npm run prod

# With environment file
npm run prod:env

# Check health
npm run health
```

### Option 2: PM2 Process Management

```bash
# Start with PM2
npm run pm2:start

# Monitor processes
npm run pm2:status

# View logs
npm run pm2:logs

# Restart application
npm run pm2:restart
```

### Option 3: Docker Deployment

```bash
# Build Docker image
npm run docker:build

# Run container
npm run docker:run

# Or use Docker Compose
docker-compose up -d
```

### Option 4: Full Production Stack

```bash
# Deploy with nginx reverse proxy and monitoring
docker-compose --profile nginx --profile monitoring up -d
```

## 🌍 Environment Configuration

### Required Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `NODE_ENV` | Environment mode | `development` | ✅ |
| `DUIX_APP_ID` | DUIX application ID | - | ✅ |
| `DUIX_APP_KEY` | DUIX application key | - | ✅ |
| `PORT` | Server port | `3000` | ❌ |
| `HOST` | Server host | `0.0.0.0` | ❌ |
| `ENABLE_SSL_VALIDATION` | Enable SSL certificate validation | `true` in production | ❌ |
| `ALLOWED_ORIGINS` | CORS allowed origins | none | ❌ |
| `TOKEN_EXPIRY` | JWT token expiry in seconds | `1800` | ❌ |

### Optional Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | Logging level | `warn` |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window | `900000` |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` |

## 🔐 SSL/TLS Setup

### Production SSL Configuration
The application automatically enables production-grade SSL:

- **TLS Versions**: 1.2 and 1.3 only
- **Cipher Suites**: Modern, secure ciphers only
- **Certificate Validation**: Enabled for all external connections
- **SNI Support**: Enabled for proper hostname verification

### Custom SSL Certificates
For custom SSL termination (nginx, load balancer):

```nginx
# Example nginx configuration
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📊 Monitoring & Logging

### Health Checks
- **Endpoint**: `GET /health`
- **Status Endpoint**: `GET /api/status`
- **Monitoring**: Automatic health checks in Docker and PM2

### Logging Configuration
- **Log Files**: `./logs/` directory
- **Log Levels**: error, warn, info, debug
- **Log Rotation**: Automatic with size limits
- **Format**: JSON structured logging in production

### Metrics and Monitoring
Enable monitoring stack:

```bash
# Start with Prometheus and Grafana
docker-compose --profile monitoring up -d

# Access Grafana: http://localhost:3001 (admin/admin123)
# Access Prometheus: http://localhost:9090
```

## ⚡ Performance Optimization

### Clustering
- **PM2**: Automatically uses all CPU cores
- **Docker**: Scale with `docker-compose up -d --scale duix-avatar=3`

### Memory Management
- **Heap Size**: 4GB maximum configured
- **Memory Monitoring**: Automatic restart at 1GB usage
- **Garbage Collection**: Optimized for production

### Caching
- **Static Files**: 1-day cache in production
- **API Responses**: ETags enabled
- **Connection Pooling**: Optimized HTTPS agents

## 🐛 Troubleshooting

### Common Issues

#### 1. SSL Certificate Errors
```bash
# Check SSL validation setting
echo $ENABLE_SSL_VALIDATION

# Test DUIX API connectivity
curl -I https://api.duix.com
```

#### 2. Memory Issues
```bash
# Check memory usage
pm2 monit

# Restart if needed
pm2 restart duix-avatar
```

#### 3. Rate Limiting
```bash
# Check rate limit errors in logs
pm2 logs duix-avatar | grep "Rate limit"

# Adjust rate limits in production.env
```

### Debug Mode
Never enable debug endpoints in production. They are automatically disabled when `NODE_ENV=production`.

### Logs Analysis
```bash
# View application logs
pm2 logs duix-avatar

# Filter error logs
pm2 logs duix-avatar --err

# Follow logs in real-time
pm2 logs duix-avatar -f
```

## 🔄 Maintenance

### Regular Updates
```bash
# Update dependencies
npm audit fix

# Security audit
npm audit --audit-level high

# Update application
git pull origin main
npm install --production
pm2 restart duix-avatar
```

### Backup Procedures
- **Configuration**: Backup `production.env` securely
- **Logs**: Regular log rotation and archival
- **Monitoring Data**: Backup Grafana dashboards and Prometheus data

### Performance Monitoring
- **CPU Usage**: Monitor with PM2 or Docker stats
- **Memory Usage**: Set alerts at 80% threshold
- **Response Times**: Monitor API latency
- **Error Rates**: Alert on error rate > 1%

### Security Maintenance
- **Dependencies**: Weekly security updates
- **SSL Certificates**: Monitor expiration dates
- **Access Logs**: Regular review for suspicious activity
- **Rate Limits**: Adjust based on legitimate traffic patterns

## 📞 Support

### Production Support Checklist
- [ ] Environment variables configured
- [ ] SSL certificates valid
- [ ] Health checks passing
- [ ] Monitoring alerts configured
- [ ] Backup procedures in place
- [ ] Security hardening applied
- [ ] Performance baselines established

### Emergency Procedures
1. **Service Down**: Check health endpoint, restart with PM2/Docker
2. **High Memory**: Scale down, investigate memory leaks
3. **SSL Issues**: Verify certificates, check DUIX API status
4. **Rate Limiting**: Review traffic patterns, adjust limits if needed

---

## 🎉 Production Deployment Success!

Your DUIX AI Avatar application is now production-ready with:

✅ **Enterprise Security**: SSL validation, security headers, rate limiting  
✅ **High Availability**: Clustering, auto-restart, health monitoring  
✅ **Performance**: Optimized for production workloads  
✅ **Monitoring**: Comprehensive logging and metrics  
✅ **Scalability**: Ready for horizontal scaling  

**Next Steps:**
1. Configure your domain and SSL certificates
2. Set up monitoring alerts
3. Configure backup procedures
4. Load test your deployment
5. Set up CI/CD pipeline for updates

For additional support, refer to the [DUIX Documentation](https://docs.duix.com/) and monitoring dashboards. 