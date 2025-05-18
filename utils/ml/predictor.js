// utils/ml/predictor.js
const { PythonShell } = require('python-shell');
const path = require('path');

const predict = async (data) => {
    const options = {
        pythonPath: 'python',
        scriptPath: path.join(__dirname, '../../scripts'),
        pythonOptions: ['-u'],
        mode: 'json'
    };

    return new Promise((resolve, reject) => {
        const pyshell = new PythonShell('pred.py', options);
        
        pyshell.send(JSON.stringify(data));
        
        pyshell.on('message', (message) => {
            try {
                resolve(JSON.parse(message));
            } catch (e) {
                reject(e);
            }
        });
        
        pyshell.end((err) => {
            if (err) reject(err);
        });
    });
};

module.exports = { predict };