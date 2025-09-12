const express = require('express')
const app = express()
const port = process.env.PORT || 3000

// TODO: Add proper error handling middleware
// Middleware
app.use(express.json())

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
