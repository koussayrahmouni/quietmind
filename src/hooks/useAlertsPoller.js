import { useEffect, useRef } from 'react';
import { notify } from 'services/notificationBus';

export function useAlertsPoller(intervalMs = 30000) {
  const lastSeen = useRef(new Date().toISOString());

  useEffect(() => {
    const fetchAndNotify = async () => {
      try {
        const res = await fetch(
          `/api/status/alerts?since=${encodeURIComponent(lastSeen.current)}`
        );
        if (!res.ok) throw new Error(res.statusText);

        const alerts = await res.json();
        alerts.forEach(a => {
          notify({
            type:  'error',
            title: '⚠️ Crisis Alert!',
            message: `${a.childName} — ${(a.probability * 100).toFixed(1)}% (BPM ${a.bpm}, ${a.temperature}°C)`,
          });

          if (new Date(a.timestamp) > new Date(lastSeen.current)) {
            lastSeen.current = a.timestamp;
          }
        });
      } catch (e) {
        console.error('Polling error:', e);
      }
    };

    fetchAndNotify();
    const timerId = setInterval(fetchAndNotify, intervalMs);
    return () => clearInterval(timerId);
  }, [intervalMs]);
}
