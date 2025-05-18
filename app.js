require("dotenv").config();
const express = require("express");
const bodyParser = require('body-parser');
const cors = require("cors");
const { spawn } = require('child_process');
const path = require('path');
const faceService = require('./api/service/faceService'); 
const WebSocket = require('ws');
const app = express();

// Import routes and services
const predictionRoutes = require('./api/router/predictions');
const userRouter = require("./api/router/user.router");
const childRouter = require("./api/router/child.router");
const sensorRouter = require("./api/router/sensorRouter");
const { startMonitoring, getActiveAlerts, clearAlert } = require('./api/service/crisisMonitor');

// Middleware
app.use(cors({ 
    origin: process.env.CLIENT_URL || "http://localhost:3001",
    credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/predictions', predictionRoutes);
app.use("/api/users", userRouter);
app.use("/api/children", childRouter);
app.use('/api/sensors', sensorRouter);
app.use(bodyParser.json());
// Face Recognition Endpoints
let faceProcess = null;
let latestResults = [];

app.get('/api/face/start', (req, res) => {
  try {
    faceService.startFaceRecognition();  // Start the face recognition process
    res.status(200).send('Face recognition started.');
  } catch (err) {
    res.status(500).send('Error starting face recognition');
  }
});

// Route to get the latest face recognition results
app.get('/api/face/results', (req, res) => {
  try {
    const results = faceService.getLatestResults();  // Get the latest results from the service
    res.json(results);  // Send the results as a JSON response
  } catch (err) {
    res.status(500).send('Error fetching results');
  }
});
// Alert Endpoints
app.get('/api/alerts', (req, res) => {
    res.json(getActiveAlerts());
});

app.delete('/api/alerts/:childId', (req, res) => {
    clearAlert(req.params.childId);
    res.sendStatus(200);
});

// ML Prediction Endpoint
app.post('/api/predict', async (req, res) => {
    try {
        const { bpm, activite, temperature } = req.body;

        if (!bpm || !activite || !temperature) {
            return res.status(400).json({ 
                error: "Missing required parameters",
                required: ["bpm", "activite", "temperature"]
            });
        }

             const options = {
            pythonPath: process.env.PYTHON_PATH || 'python',
            scriptPath: path.join(__dirname, 'python'),
            args: [JSON.stringify({ bpm, activite, temperature })],
            pythonOptions: ['-u'],
            timeout: 10000
        };


        const result = await new Promise((resolve, reject) => {
            const pyshell = new PythonShell('pred.py', options);
            let output = '';

            pyshell.on('message', message => output += message);
            pyshell.end(err => err ? reject(err) : resolve(output));
        });

        res.json(JSON.parse(result));
    } catch (error) {
        console.error("Prediction Error:", error);
        res.status(500).json({ 
            error: error.message,
            errorCode: "ML001",
            timestamp: new Date().toISOString()
        });
    }
});

// WebSocket Server
const server = app.listen(process.env.APP_PORT || 3000, () => {
    console.log(`
    🚀 Server running on port ${process.env.APP_PORT || 3000}
    📡 Face API: http://localhost:${process.env.APP_PORT || 3000}/api/face
    🌐 WebSocket: http://localhost:${process.env.APP_PORT || 3000}
    `);
});

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
    console.log('New WebSocket client connected');
    ws.on('close', () => console.log('Client disconnected'));
});

// Error Handlers
app.use((req, res) => res.status(404).json({ 
    success: 0, 
    message: "Route not found",
    documentation: process.env.API_DOCS_URL 
}));

app.use((err, req, res, next) => {
    console.error("💥 Unhandled Error:", err.stack);
    res.status(500).json({ 
        success: 0, 
        message: "Internal Server Error",
        referenceId: `ERR-${Date.now()}`
    });
});

// Initialize Services
startMonitoring();