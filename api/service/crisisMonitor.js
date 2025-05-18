// services/crisisMonitor.js
const cron = require('node-cron');
const mysql = require('mysql2/promise');
const { PythonShell } = require('python-shell');

// Create connection pool
const monitoringPool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'final',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Simple in-memory storage for alerts
const activeAlerts = new Map();
let lastCheck = new Date();

function startMonitoring() {
  cron.schedule('*/30 * * * * *', async () => {
    try {
      const [rows] = await monitoringPool.query(`
        SELECT 
          s.id, 
          s.bpm AS bpm, 
          s.temperature AS temperature, 
          s.child_id,
          CONCAT(c.FirstName, ' ', c.LastName) AS full_name
        FROM status s
        JOIN child c ON s.child_id = c.id
        
      `, [lastCheck]);

      lastCheck = new Date();

      for (const record of rows) {
        const inputData = {
          bpm: record.bpm,
          temperature: record.temperature,
          activite: record.activite || 'Repos'
        };

        const prediction = await PythonShell.run('C:/Users/koussay/Desktop/TP0/chappiPidev/python/pred.py', {
          args: [JSON.stringify(inputData)],
          pythonPath: process.env.PYTHON_PATH || 'python'
        });

        const result = JSON.parse(prediction[0]);

        if (result.prediction === 1 && result.probability > 0.5) {
          const alertData = {
            childId: record.child_id,
            childName: record.full_name,
            probability: result.probability,
            bpm: record.bpm,
            temperature: record.temperature,
            message: result.message,
            timestamp: new Date().toISOString(),
            severity: 'high'
          };
          
          activeAlerts.set(record.child_id, alertData);
        }
      }
    } catch (error) {
      console.error('Monitoring error:', error);
    }
  });
}

// Export functions
module.exports = {
  startMonitoring,
  getActiveAlerts: () => Array.from(activeAlerts.values()),
  clearAlert: (childId) => activeAlerts.delete(childId)
};