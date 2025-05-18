const { spawn } = require('child_process');
const path = require('path');

let pythonProcess = null;
let isRunning = false;

exports.startRecognition = (req, res) => {
    if (isRunning) {
        return res.status(400).json({ error: "Service already running" });
    }

    pythonProcess = spawn('python', [path.join(__dirname, '../python/face_service.py')]);
    
    pythonProcess.stdout.on('data', (data) => {
        try {
            const results = JSON.parse(data.toString());
            // Broadcast to clients (implement your real-time system here)
        } catch (e) {
            console.error('Parse error:', e);
        }
    });

    pythonProcess.stderr.on('data', (data) => {
        console.error(`Python Error: ${data}`);
    });

    pythonProcess.on('close', (code) => {
        isRunning = false;
        console.log(`Python process exited with code ${code}`);
    });

    isRunning = true;
    res.json({ status: "recognition_started" });
};

exports.stopRecognition = (req, res) => {
    if (!isRunning) {
        return res.status(400).json({ error: "Service not running" });
    }

    pythonProcess.kill();
    isRunning = false;
    res.json({ status: "recognition_stopped" });
};