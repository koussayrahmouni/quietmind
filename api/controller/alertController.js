// api/controller/alertController.js
const pool = require("../../config/database");

// Récupérer toutes les alertes
exports.getAllAlerts = (req, res) => {
  const sql = `
    SELECT
      id,
      alert_message  AS message,
      alert_type,
      status_id,
      bpm,
      temperature,
      probability,
      DATE_FORMAT(date, '%Y-%m-%dT%H:%i:%sZ') AS date
    FROM Alert
    ORDER BY date DESC
  `;
  pool.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
};


// Créer une nouvelle alerte
exports.createAlert = (req, res) => {
  const { alert_message, alert_type, status_id } = req.body;
  const sql = `INSERT INTO Alert (alert_message, alert_type, status_id) VALUES (?, ?, ?)`;
  pool.query(sql, [alert_message, alert_type, status_id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId });
  });
};

// Supprimer une alerte par ID
exports.deleteAlert = (req, res) => {
  const alertId = req.params.id;
  const sql = `DELETE FROM Alert WHERE id = ?`;
  pool.query(sql, [alertId], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.affectedRows > 0) res.send('Alerte supprimée avec succès');
    else res.status(404).send('Alerte non trouvée');
  });
};
