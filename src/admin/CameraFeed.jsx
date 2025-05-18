import React, { useRef, useEffect, useState } from "react";

const CameraFeed = ({ isActive, results }) => {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 });

  useEffect(() => {
    let stream;
    const enableCamera = async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({ video: true });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          // Set dimensions once video metadata is loaded
          videoRef.current.onloadedmetadata = () => {
            setDimensions({
              width: videoRef.current.videoWidth,
              height: videoRef.current.videoHeight
            });
          };
        }
      } catch (err) {
        console.error("Error accessing camera:", err);
      }
    };
    enableCamera();
    return () => {
      if (stream) {
        stream.getTracks().forEach((t) => t.stop());
      }
    };
  }, []);

  // Draw detection boxes when results change
  useEffect(() => {
    if (!canvasRef.current || !videoRef.current || !results.length) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    // Clear previous drawings
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    results.forEach(result => {
      const { top, right, bottom, left, name, emotion } = result;
      
      // Scale coordinates if needed (assuming backend returns relative coordinates)
      const scaleX = canvas.width / (dimensions.width || 1);
      const scaleY = canvas.height / (dimensions.height || 1);
      
      const scaledLeft = left * scaleX;
      const scaledTop = top * scaleY;
      const scaledRight = right * scaleX;
      const scaledBottom = bottom * scaleY;
      const width = scaledRight - scaledLeft;
      const height = scaledBottom - scaledTop;

      // Draw face rectangle
      ctx.strokeStyle = '#00FF00';
      ctx.lineWidth = 2;
      ctx.strokeRect(scaledLeft, scaledTop, width, height);

      // Draw label background
      ctx.fillStyle = '#00FF00';
      ctx.fillRect(scaledLeft, scaledBottom - 30, width, 30);

      // Draw name
      ctx.font = '16px Arial';
      ctx.fillStyle = '#FFFFFF';
      ctx.fillText(
        name === "Unknown" ? "Inconnu" : name, 
        scaledLeft + 6, 
        scaledBottom - 15
      );

      // Draw emotion if available
      if (emotion) {
        ctx.fillText(
          `Emotion: ${emotion}`, 
          scaledLeft + 6, 
          scaledBottom - 35
        );
      }
    });
  }, [results, dimensions]);

  return (
    <div style={{ position: 'relative', width: '100%', maxHeight: '500px' }}>
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        style={{ 
          width: '100%', 
          borderRadius: '8px', 
          display: 'block' 
        }}
      />
      <canvas
        ref={canvasRef}
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          pointerEvents: 'none'
        }}
        width={dimensions.width}
        height={dimensions.height}
      />
    </div>
  );
};

export default CameraFeed;