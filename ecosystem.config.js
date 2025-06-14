// ✅ PM2 Production Configuration for DUIX AI Avatar
module.exports = {
  apps: [{
    name: 'duix-avatar',
    script: 'server.js',
    
    // Production Environment
    env_production: {
      NODE_ENV: 'production',
      ENABLE_SSL_VALIDATION: 'true',
      PORT: 3000,
      HOST: '0.0.0.0'
    },
    
    // Development Environment
    env_development: {
      NODE_ENV: 'development',
      ENABLE_SSL_VALIDATION: 'false',
      PORT: 3000,
      HOST: '0.0.0.0'
    },
    
    // Production Performance Settings
    instances: 'max', // Use all CPU cores
    exec_mode: 'cluster',
    
    // Memory Management
    max_memory_restart: '1G',
    
    // Auto-restart Configuration
    autorestart: true,
    watch: false, // Disable in production for performance
    max_restarts: 10,
    min_uptime: '10s',
    
    // Logging Configuration
    log_file: './logs/combined.log',
    out_file: './logs/out.log',
    error_file: './logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    
    // Process Management
    kill_timeout: 5000,
    listen_timeout: 10000,
    
    // Health Monitoring
    health_check_interval: 30000,
    health_check_grace_period: 10000,
    
    // Environment Variables for Production
    env: {
      NODE_ENV: 'production',
      ENABLE_SSL_VALIDATION: 'true',
      UV_THREADPOOL_SIZE: '128',
      PORT: 3000,
      HOST: '0.0.0.0'
    }
  }],

  // Deployment Configuration
  deploy: {
    production: {
      user: 'node',
      host: ['your-production-server.com'],
      ref: 'origin/main',
      repo: 'git@github.com:your-org/duix-ai-avatar.git',
      path: '/var/www/duix-avatar',
      'post-deploy': 'npm install && npm run prod',
      'pre-setup': 'apt update && apt install git -y'
    }
  }
}; 