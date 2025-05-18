import React, { useState, useEffect } from 'react';

import './AlertMonitor.css';

function AlertMonitor() {
  const [alerts, setAlerts] = useState([]);

  const checkAlerts = async () => {
    try {
      const response = await fetch(`http://localhost:3000/api/alerts`);
      const newAlerts = await response.json();
      setAlerts(newAlerts);
    } catch (error) {
      console.error('Error fetching alerts:', error);
    }
  };

  const dismissAlert = async (childId) => {
    try {
        await fetch(`http://localhost:3000/api/alerts/${childId}`, { method: 'DELETE' });

      setAlerts(alerts.filter(alert => alert.childId !== childId));
    } catch (error) {
      console.error('Error dismissing alert:', error);
    }
  };

  useEffect(() => {
    checkAlerts();
    const interval = setInterval(checkAlerts, 60000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="alert-container">
      {alerts.map(alert => (
        <div key={alert.childId} className={`alert ${alert.severity}`}>
          <h3>Crisis Alert for {alert.childName}</h3>
          <p>Message: {alert.message}</p>
          <p>Heart Rate: {alert.bpm} BPM</p>
          <p>Temperature: {alert.temperature}°C</p>
          <p>Probability: {(alert.probability * 100).toFixed(0)}%</p>
          <button onClick={() => dismissAlert(alert.childId)}>Dismiss</button>
        </div>
      ))}
    </div>
  );
}

export default AlertMonitor;