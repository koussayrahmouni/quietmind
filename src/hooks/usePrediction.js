import { useState } from 'react';
import { predictHealthStatus } from '../services/predictionService';

export const usePrediction = () => {
  const [prediction, setPrediction] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const makePrediction = async (data) => {
    setLoading(true);
    setError(null);
    
    try {
      const result = await predictHealthStatus(data);
      
      if (result.success) {
        setPrediction(result);
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Failed to connect to prediction service');
    } finally {
      setLoading(false);
    }
  };

  return { prediction, loading, error, makePrediction };
};