import React, { useState, useEffect, useRef } from "react";
import { usePrediction } from "../hooks/usePrediction";
import CameraFeed from "./CameraFeed";
import "./PredictionForm.css";

export default function PredictionForm() {
  const { prediction, loading, error, makePrediction } = usePrediction();
  const [formData, setFormData] = useState({
    bpm: "",
    activity: "Repos",
    temperature: ""
  });

  // Face recognition state
  const [isRunning, setIsRunning] = useState(false);
  const [results, setResults] = useState([]);
  const pollInterval = useRef(null);

  // Poll for results when recognition is active
  useEffect(() => {
    const fetchResults = async () => {
      try {
        const response = await fetch('http://localhost:3000/api/face/results');
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        const data = await response.json();
        if (data.length > 0) {
          setResults(data);
        }
      } catch (err) {
        console.error("Failed to fetch results:", err);
      }
    };

    const startRecognition = async () => {
      try {
        const response = await fetch("/api/face/start");
        if (!response.ok) {
          throw new Error('Failed to start service');
        }
      } catch (err) {
        console.error("Start error:", err);
        setIsRunning(false);
      }
    };

    const stopRecognition = async () => {
      try {
        await fetch("/api/face/stop");
      } catch (err) {
        console.error("Stop error:", err);
      }
    };

    if (isRunning) {
      // Start polling every second
      pollInterval.current = setInterval(fetchResults, 1000);
      // Start recognition service
      startRecognition();
    } else {
      // Cleanup
      clearInterval(pollInterval.current);
      stopRecognition();
      setResults([]);  // Clear results when stopped
    }

    return () => {
      clearInterval(pollInterval.current);
    };
  }, [isRunning]);

  const toggleRecognition = () => {
    setIsRunning(prev => !prev);
  };

  const translateEmotion = (emotion) => {
    const emotions = {
      happy: "Heureux",
      sad: "Triste",
      angry: "En colère",
      neutral: "Neutre",
      surprised: "Surpris",
      disgusted: "Dégoûté",
      fearful: "Effrayé"
    };
    return emotions[emotion] || emotion;
  };

  return (
    <div className="prediction-container">
      {/* Health Form (keep your existing form) */}

      <div className="face-recognition">
        <h2>Reconnaissance Faciale</h2>
        <CameraFeed isActive={isRunning} results={results} />
        
        <button
          onClick={toggleRecognition}
          className={`control-btn ${isRunning ? 'active' : ''}`}
        >
          {isRunning ? '⏹ Arrêter' : '▶ Démarrer'}
        </button>

        <div className="results-container">
          <h3>Détections récentes:</h3>
          {isRunning ? (
            results.length > 0 ? (
              <div className="detections-grid">
                {results.map((result, index) => (
                  <div key={index} className="detection-card">
                    <div className="detection-header">
                      <span className="person-name">
                        {result.name === "Unknown" ? "Inconnu" : result.name}
                      </span>
                      <span className={`emotion-pill ${result.emotion}`}>
                        {translateEmotion(result.emotion)}
                      </span>
                    </div>
                    <div className="detection-time">
                      {new Date(result.timestamp).toLocaleTimeString()}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p>🔍 Aucun visage détecté...</p>
            )
          ) : (
            <p>Cliquez sur "Démarrer" pour commencer</p>
          )}
        </div>
      </div>
    </div>
  );
}
