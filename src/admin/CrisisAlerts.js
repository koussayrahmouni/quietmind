// src/components/CrisisAlerts.js
import { useState, useEffect } from 'react';
import { List, Badge } from 'antd';
import socket from '../services/socket';
import "./crisis.css";
const CrisisAlerts = () => {
  const [alerts, setAlerts] = useState([]);

  useEffect(() => {
    socket.on('crisis-alert', (newAlert) => {
      setAlerts(prev => [newAlert, ...prev.slice(0, 9)]);
    });

    return () => {
      socket.off('crisis-alert');
    };
  }, []);

  return (
    <div className="crisis-alerts">
      <h2>Recent Crisis Alerts</h2>
      <List
        itemLayout="horizontal"
        dataSource={alerts}
        renderItem={alert => (
          <List.Item>
            <List.Item.Meta
              avatar={<Badge status="error" />}
              title={<span style={{ color: 'red' }}>{alert.childName}</span>}
              description={
                <>
                  <div>Heartbeat: {alert.heartbeat} BPM</div>
                  <div>Temperature: {alert.temperature}°C</div>
                  <div>Probability: {(alert.probability * 100).toFixed(1)}%</div>
                  <div>{new Date(alert.timestamp).toLocaleString()}</div>
                </>
              }
            />
          </List.Item>
        )}
      />
    </div>
  );
};