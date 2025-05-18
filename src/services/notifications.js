import express from 'express';
import { notify } from '../services/notificationBus'; // Import the notificationBus function

const router = express.Router();

// API endpoint to receive notifications from backend
router.post('/notify', (req, res) => {
  const { childId, childName, probability, bpm, temperature, message, timestamp, severity } = req.body;

  // Trigger the frontend notification
  notify({
    type: severity === 'high' ? 'error' : 'info',
    title: `Crisis Alert for ${childName}`,
    message: `${message} | BPM: ${bpm}, Temp: ${temperature}`,
    options: { timestamp, severity }
  });

  res.status(200).json({ success: true });
});

export default router;
