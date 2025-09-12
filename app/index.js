const express = require('express')
const app = express()
const port = process.env.PORT || 3000

// Security: Add security headers middleware
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff')
  res.setHeader('X-Frame-Options', 'DENY')
  res.setHeader('X-XSS-Protection', '1; mode=block')
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains')
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
  res.setHeader('Content-Security-Policy', "default-src 'self'")
  next()
})

// TODO: Add proper error handling middleware
// Middleware
app.use(express.json({ limit: '10mb' })) // Security: Limit JSON payload size

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  })
})

app.get('/ready', (req, res) => {
  res.status(200).json({ 
    status: 'ready', 
    timestamp: new Date().toISOString()
  })
})

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Hello World!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  })
})

// Metrics endpoint for monitoring
// FIXME: This is basic - should integrate with Prometheus later
app.get('/metrics', (req, res) => {
  const metrics = {
    requests: {
      total: req.headers['x-request-count'] || 0
    },
    memory: {
      used: process.memoryUsage().heapUsed,
      total: process.memoryUsage().heapTotal
    },
    uptime: process.uptime()
  }
  res.json(metrics)
})

app.listen(port, () => {
  console.log(`Hello World app listening on port ${port}`)
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`)
})
