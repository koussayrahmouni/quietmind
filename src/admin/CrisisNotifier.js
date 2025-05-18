// components/CrisisNotifier.js
import { useEffect, useState } from 'react';
import { toast } from 'react-toastify';
import axios from 'axios';

const POLLING_INTERVAL = 5000; // 5 seconds
let lastNotificationTime = null;

function CrisisNotifier() {
    const [lastPrediction, setLastPrediction] = useState(null);

    useEffect(() => {
        const checkStatus = async () => {
            try {
                const response = await axios.get('/api/predictions/current-status');
                const { hasCrisis, data } = response.data;
                
                if (data && (!lastPrediction || data.timestamp !== lastPrediction.timestamp)) {
                    setLastPrediction(data);
                    
                    if (hasCrisis && (!lastNotificationTime || data.timestamp !== lastNotificationTime)) {
                        showCrisisNotification(data);
                        lastNotificationTime = data.timestamp;
                    }
                }
            } catch (error) {
                console.error('Error checking status:', error);
            }
        };

        const intervalId = setInterval(checkStatus, POLLING_INTERVAL);
        return () => clearInterval(intervalId);
    }, [lastPrediction]);

    const showCrisisNotification = (data) => {
        toast.error(
            <div>
                <strong>{data.message}</strong>
                <div>BPM: {data.bpm}</div>
                <div>Temperature: {data.temperature}°C</div>
                <div>Probability: {(data.probability * 100).toFixed(1)}%</div>
            </div>,
            {
                position: "top-right",
                autoClose: 10000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
            }
        );
    };

    return null;
}

export default CrisisNotifier;