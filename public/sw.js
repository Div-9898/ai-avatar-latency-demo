// ✅ AWS-Ready Service Worker for DUIX Avatar
const CACHE_NAME = 'duix-avatar-v1.0.0';
const STATIC_CACHE = 'duix-static-v1.0.0';
const DYNAMIC_CACHE = 'duix-dynamic-v1.0.0';

// ✅ Files to cache for offline support
const STATIC_FILES = [
    '/',
    '/index.html',
    '/styles.css',
    '/manifest.json',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css',
    'https://cdn.guiji.ai/duix/sdk/0.2.1/duix.js'
];

// ✅ API endpoints to cache
const API_ENDPOINTS = [
    '/api/health',
    '/api/status',
    '/api/avatars',
    '/api/voices'
];

// ✅ Install Service Worker
self.addEventListener('install', (event) => {
    console.log('🔧 Service Worker installing...');
    
    event.waitUntil(
        Promise.all([
            // Cache static files
            caches.open(STATIC_CACHE).then((cache) => {
                console.log('📦 Caching static files...');
                return cache.addAll(STATIC_FILES);
            }),
            // Skip waiting to activate immediately
            self.skipWaiting()
        ])
    );
});

// ✅ Activate Service Worker
self.addEventListener('activate', (event) => {
    console.log('✅ Service Worker activating...');
    
    event.waitUntil(
        Promise.all([
            // Clean up old caches
            caches.keys().then((cacheNames) => {
                return Promise.all(
                    cacheNames.map((cacheName) => {
                        if (cacheName !== STATIC_CACHE && 
                            cacheName !== DYNAMIC_CACHE && 
                            cacheName !== CACHE_NAME) {
                            console.log('🗑️ Deleting old cache:', cacheName);
                            return caches.delete(cacheName);
                        }
                    })
                );
            }),
            // Take control of all clients
            self.clients.claim()
        ])
    );
});

// ✅ Fetch Event Handler with AWS optimization
self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);
    
    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }
    
    // Skip chrome-extension and other non-http requests
    if (!url.protocol.startsWith('http')) {
        return;
    }
    
    // Handle different types of requests
    if (isStaticFile(url)) {
        event.respondWith(handleStaticFile(request));
    } else if (isAPIRequest(url)) {
        event.respondWith(handleAPIRequest(request));
    } else if (isDUIXSDK(url)) {
        event.respondWith(handleDUIXSDK(request));
    } else {
        event.respondWith(handleDynamicRequest(request));
    }
});

// ✅ Static File Handler (Cache First)
async function handleStaticFile(request) {
    try {
        const cache = await caches.open(STATIC_CACHE);
        const cachedResponse = await cache.match(request);
        
        if (cachedResponse) {
            console.log('📦 Serving from cache:', request.url);
            return cachedResponse;
        }
        
        console.log('🌐 Fetching static file:', request.url);
        const networkResponse = await fetch(request);
        
        if (networkResponse.ok) {
            cache.put(request, networkResponse.clone());
        }
        
        return networkResponse;
    } catch (error) {
        console.error('❌ Static file error:', error);
        return new Response('Offline - File not available', { status: 503 });
    }
}

// ✅ API Request Handler (Network First with Cache Fallback)
async function handleAPIRequest(request) {
    try {
        console.log('🔗 API request:', request.url);
        
        // Try network first for fresh data
        const networkResponse = await fetch(request, {
            headers: {
                'Cache-Control': 'no-cache'
            }
        });
        
        if (networkResponse.ok) {
            // Cache successful API responses
            const cache = await caches.open(DYNAMIC_CACHE);
            cache.put(request, networkResponse.clone());
            return networkResponse;
        }
        
        throw new Error(`API responded with ${networkResponse.status}`);
        
    } catch (error) {
        console.warn('⚠️ API network failed, trying cache:', error.message);
        
        // Fallback to cache
        const cache = await caches.open(DYNAMIC_CACHE);
        const cachedResponse = await cache.match(request);
        
        if (cachedResponse) {
            console.log('📦 Serving API from cache:', request.url);
            return cachedResponse;
        }
        
        // Return offline response for critical endpoints
        if (request.url.includes('/api/health')) {
            return new Response(JSON.stringify({
                status: 'offline',
                timestamp: new Date().toISOString(),
                cached: true
            }), {
                headers: { 'Content-Type': 'application/json' },
                status: 200
            });
        }
        
        return new Response('API temporarily unavailable', { status: 503 });
    }
}

// ✅ DUIX SDK Handler (Cache First with Network Update)
async function handleDUIXSDK(request) {
    try {
        const cache = await caches.open(STATIC_CACHE);
        const cachedResponse = await cache.match(request);
        
        if (cachedResponse) {
            console.log('📦 Serving DUIX SDK from cache');
            
            // Update cache in background
            fetch(request).then((networkResponse) => {
                if (networkResponse.ok) {
                    cache.put(request, networkResponse.clone());
                }
            }).catch(() => {
                // Ignore network errors for background updates
            });
            
            return cachedResponse;
        }
        
        console.log('🌐 Fetching DUIX SDK from network');
        const networkResponse = await fetch(request);
        
        if (networkResponse.ok) {
            cache.put(request, networkResponse.clone());
        }
        
        return networkResponse;
        
    } catch (error) {
        console.error('❌ DUIX SDK error:', error);
        return new Response('DUIX SDK unavailable', { status: 503 });
    }
}

// ✅ Dynamic Request Handler (Network First)
async function handleDynamicRequest(request) {
    try {
        console.log('🌐 Dynamic request:', request.url);
        return await fetch(request);
    } catch (error) {
        console.warn('⚠️ Dynamic request failed:', error.message);
        
        // Try cache as fallback
        const cache = await caches.open(DYNAMIC_CACHE);
        const cachedResponse = await cache.match(request);
        
        if (cachedResponse) {
            return cachedResponse;
        }
        
        return new Response('Content unavailable offline', { status: 503 });
    }
}

// ✅ Helper Functions
function isStaticFile(url) {
    const staticExtensions = ['.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2'];
    const pathname = url.pathname.toLowerCase();
    
    return staticExtensions.some(ext => pathname.endsWith(ext)) ||
           pathname === '/' ||
           pathname === '/index.html' ||
           pathname === '/manifest.json';
}

function isAPIRequest(url) {
    return url.pathname.startsWith('/api/');
}

function isDUIXSDK(url) {
    return url.hostname === 'cdn.guiji.ai' || 
           url.hostname === 'api.duix.com' ||
           url.pathname.includes('duix');
}

// ✅ Background Sync for offline actions
self.addEventListener('sync', (event) => {
    console.log('🔄 Background sync:', event.tag);
    
    if (event.tag === 'duix-avatar-sync') {
        event.waitUntil(syncDUIXData());
    }
});

async function syncDUIXData() {
    try {
        console.log('🔄 Syncing DUIX data...');
        
        // Sync avatar configurations
        await fetch('/api/avatars');
        await fetch('/api/voices');
        
        console.log('✅ DUIX data synced');
    } catch (error) {
        console.error('❌ Sync failed:', error);
    }
}

// ✅ Push Notification Handler
self.addEventListener('push', (event) => {
    console.log('📱 Push notification received');
    
    const options = {
        body: 'DUIX Avatar is ready for conversation',
        icon: '/icon-192.png',
        badge: '/badge-72.png',
        tag: 'duix-avatar',
        requireInteraction: false,
        actions: [
            {
                action: 'open',
                title: 'Open Avatar',
                icon: '/icon-open.png'
            }
        ]
    };
    
    event.waitUntil(
        self.registration.showNotification('DUIX Avatar', options)
    );
});

// ✅ Notification Click Handler
self.addEventListener('notificationclick', (event) => {
    console.log('🔔 Notification clicked:', event.action);
    
    event.notification.close();
    
    if (event.action === 'open' || !event.action) {
        event.waitUntil(
            clients.openWindow('/')
        );
    }
});

// ✅ Message Handler for communication with main thread
self.addEventListener('message', (event) => {
    console.log('💬 Message received:', event.data);
    
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
    
    if (event.data && event.data.type === 'CACHE_DUIX_TOKEN') {
        // Cache DUIX authentication token for offline use
        const cache = caches.open(DYNAMIC_CACHE);
        // Implementation depends on token structure
    }
});

// ✅ Error Handler
self.addEventListener('error', (event) => {
    console.error('❌ Service Worker error:', event.error);
});

self.addEventListener('unhandledrejection', (event) => {
    console.error('❌ Service Worker unhandled rejection:', event.reason);
});

console.log('🚀 DUIX Avatar Service Worker loaded - AWS Ready!'); 