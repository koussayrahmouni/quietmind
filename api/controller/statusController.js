// api/controller/statusController.js
const pool = require('../../config/database');
const io = require('../../config/socket').getIO();
const { spawn } = require('child_process');
const path = require('path');

// Create a new status record and optionally trigger an alert on crisis prediction
exports.createStatus = (req, res) => {
  const { bpm, Temperature, Latitude, Longitude, child_id, sound, activite } = req.body;

  // Validate required fields
  if ([bpm, Temperature, Latitude, Longitude, child_id, sound, activite].some(v => v === undefined)) {
    return res.status(400).json({ error: 'Tous les champs sont requis.' });
  }

  // Insert into status table
  const sqlInsert = `
    INSERT INTO status
      (bpm, Temperature, Latitude, Longitude, child_id, sound)
    VALUES (?, ?, ?, ?, ?, ?)
  `;

  pool.query(
    sqlInsert,
    [bpm, Temperature, Latitude, Longitude, child_id, sound],
    (err, result) => {
      if (err) {
        console.error('Error inserting status:', err);
        return res.status(500).json({ error: err.message });
      }

      const statusId = result.insertId;

      // 🔊 Enregistrer dans Soundchappi si le son dépasse 70
      if (sound > 70) {
        const sqlSound = `
          INSERT INTO Soundchappi (sound, child_id)
          VALUES (?, ?)
        `;
        pool.query(sqlSound, [sound, child_id], (errSound) => {
          if (errSound) {
            console.error('Erreur lors de l’insertion dans Soundchappi:', errSound);
          } else {
            console.log('🔔 Son > 70 enregistré dans Soundchappi');
          }
        });
      }

      // 🔄 Événement socket
      io.emit('status:new', {
        id: statusId,
        bpm,
        Temperature,
        Latitude,
        Longitude,
        child_id,
        sound,
        activite,
        message: '🆕 Nouveau status ajouté',
      });

      // 🤖 Prédiction de crise avec script Python
      const payload = { bpm, activite, temperature: Temperature };
      const scriptDir = path.join(__dirname, '../../python');
      const pyProc = spawn('python', ['-u', 'pred.py', JSON.stringify(payload)], { cwd: scriptDir });

      let output = '';
      pyProc.stdout.on('data', data => (output += data.toString()));
      pyProc.stderr.on('data', data => console.error('Python error:', data.toString()));

      pyProc.on('close', code => {
        try {
          const resultPy = JSON.parse(output);

          // 🚨 Crise détectée → enregistrer une alerte
          if (resultPy.prediction === 1) {
            const { message, probability } = resultPy;
            const alertSql = `
              INSERT INTO Alert
                (alert_message, alert_type, status_id, bpm, temperature, activite, probability, date)
              VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
            `;
            pool.query(
              alertSql,
              [message, 'Crise', statusId, bpm, Temperature, activite, probability],
              (errAlert) => {
                if (errAlert) {
                  console.error('Error inserting alert:', errAlert);
                } else {
                  io.emit('alert', {
                    alert_type: 'Crise',
                    alert_message: message,
                    status_id: statusId,
                    bpm,
                    temperature: Temperature,
                    activite,
                    probability,
                  });
                }
              }
            );
          }

          // ✅ Réponse finale
          return res.json({
            id: statusId,
            prediction: resultPy.prediction,
            probability: resultPy.probability,
            message: resultPy.message,
          });
        } catch (error) {
          console.error('Prediction parsing error:', error);
          return res.json({ id: statusId, error: 'Prediction failed' });
        }
      });
    }
  );
};


// Existing getters unchanged
exports.getAllHeartbeats = (req, res) => {
  const sql = `
    SELECT bpm, date
    FROM status
    ORDER BY date DESC
  `;
  pool.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
};

exports.getAllTemperature = (req, res) => {
  const sql = `
    SELECT Temperature, date
    FROM status
    ORDER BY date DESC
  `;
  pool.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
};

exports.getAllSound = (req, res) => {
  const sql = `
    SELECT sound, date
    FROM status
    ORDER BY date DESC
  `;
  pool.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
};

exports.getLatestCoordinates = (req, res) => {
  const sql = `
    SELECT Latitude, Longitude, date
    FROM status
    ORDER BY date DESC
    LIMIT 1
  `;
  pool.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching latest coordinates:', err);
      return res.status(500).json({ error: 'Erreur lors de la récupération des coordonnées.' });
    }
    if (results.length === 0) {
      return res.status(404).json({ message: 'Aucune donnée disponible.' });
    }
    res.json(results[0]);
  });
};

exports.getLastDataForChild = (req, res) => {
  const { child_id } = req.params;
  if (!child_id) {
    return res.status(400).json({ error: 'child_id is required' });
  }
  const sql = `
    SELECT bpm, Temperature, Latitude, Longitude, sound, date
    FROM status
    WHERE child_id = ?
    ORDER BY date DESC
    LIMIT 1
  `;
  pool.query(sql, [child_id], (err, results) => {
    if (err) {
      console.error('Error fetching last data for child:', err);
      return res.status(500).json({ error: 'Erreur lors de la récupération des données.' });
    }
    if (results.length === 0) {
      return res.status(404).json({ message: 'Aucune donnée trouvée pour cet enfant.' });
    }
    res.json(results[0]);
  });
};
exports.getAllSoundchappi = (req, res) => {
  const sql = `
    SELECT id, sound, child_id, date
    FROM Soundchappi
    ORDER BY date DESC
  `;
  pool.query(sql, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des sons:', err);
      return res.status(500).json({ error: 'Erreur lors de la récupération des données Soundchappi.' });
    }
    res.json(results);
  });
};
