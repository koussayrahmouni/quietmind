const { spawn } = require('child_process');

// Store the latest face recognition results
let latestResults = [];

// Function to start the face recognition process
const startFaceRecognition = () => {
  const pythonScriptPath = 'C:\\Users\\koussay\\Desktop\\TP0\\chappiPidev\\python\\face_service.py'; // Update to your script's path

  // Spawn the Python process to run face_service.py
  const faceProcess = spawn('python', [pythonScriptPath]);

  // Capture the output of the Python script
  faceProcess.stdout.on('data', (data) => {
    const result = data.toString();
    try {
      const jsonResult = JSON.parse(result); // Try to parse each line of output as JSON
      latestResults.push(jsonResult);
      // You can also limit the results stored by trimming the array if you want to keep only the latest N results.
    } catch (error) {
      console.error("Error parsing Python output:", result);
    }
  });

  faceProcess.stderr.on('data', (data) => {
    console.error(`Python script error: ${data.toString()}`);
  });

  faceProcess.on('close', (code) => {
    console.log(`Python script finished with exit code ${code}`);
  });
};

// Function to get the latest face recognition results
const getLatestResults = () => {
  return latestResults;
};

// Export functions for use in other files (e.g., server.js)
module.exports = {
  startFaceRecognition,
  getLatestResults
};
