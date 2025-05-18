import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';

export const predictHealthStatus = async (data) => {
  try {
    const response = await axios.post(`${API_URL}/predict`, {
      bpm: data.bpm,
      activite: data.activity,  // Note: Match the key naming convention
      temperature: data.temperature
    }, {
      timeout: 10000
    });
    
    return {
      success: true,
      ...response.data
    };
  } catch (error) {
    return {
      success: false,
      error: error.response?.data?.error || 'Prediction service unavailable',
      details: error.message
    };
  }
};