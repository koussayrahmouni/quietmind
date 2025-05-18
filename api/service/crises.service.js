const { spawn } = require("child_process");
const path = require("path");
const pool = require("../../config/database");
const io = require("../../config/socket").getIO();

const predictCrise = (req, res) => {
  const { bpm, activite, temperature } = req.body;

  if (bpm == null || !activite || temperature == null) {
    return res.status(400).json({ success: 0, message: "Missing bpm, activite or temperature" });
  }

  const scriptPath = path.join(__dirname, "../../python");
  const pyProc = spawn('python', ['-u', 'pred.py', JSON.stringify({ bpm, activite, temperature })], { cwd: scriptPath });

  let output = '';
  pyProc.stdout.on('data', (data) => output += data.toString());
  pyProc.stderr.on('data', (data) => console.error('Python error:', data.toString()));

  pyProc.on('close', (code) => {
    try {
      const result = JSON.parse(output);
      if (result.error) return res.status(500).json({ success: 0, message: result.error });

      const prediction = result.prediction;
      const message = result.message;
      const probability = result.probability;

      // Simuler l'insertion d'un status_id pour exemple
      const fakeStatusId = Math.floor(Math.random() * 1000);

      if (prediction === 1) {
        // Crise détectée, insérer dans Alert et notifier via socket
        const alertQuery = `
        INSERT INTO Alert
          (alert_message, alert_type, status_id, bpm, temperature, activite, probability, date)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
      `;
      pool.query(
        alertQuery,
        [ message, 'Crise', fakeStatusId, bpm, temperature, activite, probability ],
        (err, resultInsert) => {
          if (!err) {
            io.emit("alert", {
              alert_type: "Crise",
              alert_message: message,
              status_id: fakeStatusId,
              bpm,
              temperature,
              activite,
              probability
            });
          }
        }
      );
      }

      res.json({ success: 1, data: result });

    } catch (err) {
      return res.status(500).json({ success: 0, message: "Invalid Python output" });
    }
  });
};

module.exports = { predictCrise };
