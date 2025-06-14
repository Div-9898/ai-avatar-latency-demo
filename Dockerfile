# ✅ AWS-Optimized Multi-Stage Dockerfile for DUIX AI Avatar
# Stage 1: Build dependencies
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with production optimizations
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force

# Stage 2: Production runtime
FROM node:18-alpine AS production

# Install security updates and required packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    dumb-init \
    curl \
    ca-certificates && \
    rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S duixapp -u 1001

# Set working directory
WORKDIR /app

# Copy dependencies from builder stage
COPY --from=builder --chown=duixapp:nodejs /app/node_modules ./node_modules

# Copy application files
COPY --chown=duixapp:nodejs . .

# Create logs directory
RUN mkdir -p /app/logs && chown duixapp:nodejs /app/logs

# Switch to non-root user
USER duixapp

# Expose port
EXPOSE 3000

# Health check for AWS ELB/ALB
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Use dumb-init for proper signal handling in containers
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "server.js"]

# ============================================================================
# Production Build Instructions:
# 
# Build: docker build -t duix-avatar:latest .
# Run:   docker run -p 3000:3000 --env-file production.env duix-avatar:latest
# 
# For production deployment:
# - Use docker-compose or Kubernetes
# - Mount persistent volumes for logs
# - Set resource limits (memory, CPU)
# - Configure proper networking and load balancing
# ============================================================================ 