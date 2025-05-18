const { PythonShell } = require('python-shell');
const path = require('path');

exports.predictCrisis = async (req, res) => {
    try {
        const { bpm, activite, temperature } = req.body;
        
        // Hardcoded test response - COMMENT OUT AFTER TESTING
        if (process.env.DEBUG_MODE === 'true') {
            return res.json({
                success: true,
                prediction: 0,
                probability: 0.23,
                message: "✅ Normal (DEBUG MODE)"
            });
        }

        const options = {
            pythonPath: process.env.PYTHON_PATH || 'python',
            scriptPath: path.join(__dirname, '../scripts'),
            pythonOptions: ['-u'],
            mode: 'text' // Switch to 'text' if JSON fails
        };

        const result = await new Promise((resolve, reject) => {
            let stdout = '';
            let stderr = '';
            
            const pyshell = new PythonShell('pred.py', options);
            
            pyshell.on('message', (message) => {
                stdout += message;
            });

            pyshell.on('stderr', (error) => {
                stderr += error;
            });

            pyshell.on('close', (code) => {
                if (code !== 0) {
                    return reject(new Error(`Python exited with code ${code}: ${stderr}`));
                }
                try {
                    resolve(JSON.parse(stdout));
                } catch (e) {
                    reject(new Error(`Failed to parse Python output: ${stdout}`));
                }
            });

            pyshell.send(JSON.stringify(req.body));
        });

        res.json({ success: true, ...result });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
            ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
        });
    }
};