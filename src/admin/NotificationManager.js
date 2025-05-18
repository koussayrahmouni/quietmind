import React, { useEffect, useState } from 'react';
import { notificationBus } from '../services/notificationBus';

const NotificationManager = () => {
  const [notifications, setNotifications] = useState([]);

  useEffect(() => {
    const handleNotification = (notification) => {
      setNotifications((prev) => [...prev, notification]);
    };

    notificationBus.on('notify', handleNotification);

    return () => {
      notificationBus.off('notify', handleNotification);
    };
  }, []);

  return (
    <div>
      {notifications.map((notif, index) => (
        <div key={index} className={`notification ${notif.type}`}>
          <h4>{notif.title}</h4>
          <p>{notif.message}</p>
        </div>
      ))}
    </div>
  );
};

export default NotificationManager;
