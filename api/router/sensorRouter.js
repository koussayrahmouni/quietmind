const express = require('express');
const router = express.Router();
const db = require("../../config/database");
const sendAlertEmail = require("./mailer");

// Route pour les données en temps réel
router.get('/sensors/realtime/:idchild', (req, res) => {
  const idchild = req.params.idchild;

  // Configurer les en-têtes pour SSE
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  // Fonction pour envoyer les données au client
  const sendData = async () => {
    try {
      const results = await new Promise((resolve, reject) => {
        db.query(
          "SELECT * FROM status WHERE child_id = ? ORDER BY id DESC LIMIT 1", 
          [idchild], 
          (err, results) => {
            if (err) reject(err);
            else resolve(results);
          }
        );
      });

      // Envoyer uniquement la dernière ligne ajoutée
      if (results.length > 0) {
        res.write(`data: ${JSON.stringify(results[0])}\n\n`);
      }
    } catch (error) {
      console.error("Erreur lors de la récupération des données :", error);
    }
  };

  // Envoyer les données toutes les secondes
  const interval = setInterval(sendData, 5000);

  // Nettoyer l'intervalle lorsque la connexion est fermée
  req.on('close', () => {
    clearInterval(interval);
    res.end();
  });
});
// Route pour envoyer un e-mail d'alerte
router.post("/send-alert-email", (req, res) => {
  const { to, subject, text } = req.body;

  if (!to || !subject || !text) {
    return res.status(400).json({ message: "Tous les champs sont requis." });
  }

  sendAlertEmail(to, subject, text);
  res.status(200).json({ message: "E-mail d'alerte envoyé." });
});
  

router.post("/alerts", (req, res) => {
  const { message, type, id_mesure } = req.body;

  if (!message || !type || !id_mesure) {
    return res.status(400).json({ message: "Tous les champs sont requis." });
  }

  const query = "INSERT INTO alert (alert_message, 	alert_type, status_id) VALUES (?, ?, ?)";
  db.query(query, [message, type, id_mesure], (err, results) => {
    if (err) {
      console.error("Erreur lors de l'insertion de l'alerte :", err);
      return res.status(500).json({ message: "Erreur serveur" });
    }

    const newAlert = { 
      id: results.insertId, 
      message, 
      type, 
      id_mesure, 
      created_at: new Date() 
    };

    // Envoyer seulement la réponse JSON, ne pas utiliser res.write ici
    res.status(201).json({ message: "Alerte enregistrée avec succès.", newAlert });
  });
});


// Route pour supprimer une notification par son id
router.delete("/alerts/:id", (req, res) => {
  const alertId = req.params.id;

  if (!alertId) {
    return res.status(400).json({ message: "L'id de la notification est requis." });
  }

  const query = "DELETE FROM alert WHERE id = ?";
  db.query(query, [alertId], (err, results) => {
    if (err) {
      console.error("Erreur lors de la suppression de la notification :", err);
      return res.status(500).json({ message: "Erreur serveur" });
    }

    if (results.affectedRows === 0) {
      return res.status(404).json({ message: "Notification non trouvée." });
    }

    res.status(200).json({ message: "Notification supprimée avec succès." });
  });
});

router.get("/alerts/:id_mesure", (req, res) => {
  const id_mesure = req.params.id_mesure;

  if (!id_mesure) {
    return res.status(400).json({ message: "L'id_child est requis." });
  }

  // Utiliser DATE(SYSDATE()) pour filtrer les notifications de la date du jour
  const query = "SELECT * FROM alert WHERE  DATE(created_at) = DATE(SYSDATE()) ORDER BY created_at DESC";
  db.query(query, [id_mesure], (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération des notifications :", err);
      return res.status(500).json({ message: "Erreur serveur" });
    }

    res.status(200).json(results);
  });
});
// Route pour les alertes en temps réel
 /* router.get('/alerts/realtime/:idchild', (req, res) => {
  const idchild = req.params.idchild;

  // Configurer les en-têtes pour SSE
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  // Fonction pour envoyer les alertes au client
  const sendAlerts = async () => {
    try {
      const results = await new Promise((resolve, reject) => {
        db.query(
          "SELECT * FROM alert WHERE status_id = ? AND DATE(created_at) = DATE(SYSDATE())", 
          [idchild], 
          (err, results) => {
            if (err) reject(err);
            else resolve(results);
          }
        );
      });

      // Envoyer la dernière alerte au client
      if (results.length > 0) {
        res.write(`data: ${JSON.stringify(results[0])}\n\n`);
      }
    } catch (error) {
      console.error("Erreur lors de la récupération des alertes :", error);
    }
  };

  // Envoyer les alertes immédiatement
  sendAlerts();

  // Envoyer les alertes toutes les 5 secondes (exemple)
  const interval = setInterval(sendAlerts, 5000);

  // Nettoyer l'intervalle lorsque la connexion est fermée
  req.on('close', () => {
    clearInterval(interval);
    res.end();
  });
});*/
// Route pour récupérer toutes les mesures d'un enfant
router.get('/history/:idchild', async (req, res) => {
  const idchild = req.params.idchild;

  try {
    // Exécuter la requête SQL pour récupérer toutes les mesures de l'enfant
    const results = await new Promise((resolve, reject) => {
      db.query(
        "SELECT * FROM status WHERE child_id  = ? ORDER BY id DESC", 
        [idchild], 
        (err, results) => {
          if (err) reject(err);
          else resolve(results);
        }
      );
    });

    // Retourner les résultats sous forme de JSON
    res.json(results);
  } catch (error) {
    console.error("Erreur lors de la récupération des données :", error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});
router.get("/alerts/check/:type/:id_mesure", (req, res) => {
  const { type, id_mesure } = req.params;

  if (!type || !id_mesure) {
    return res.status(400).json({ message: "Le type et l'ID de mesure sont requis." });
  }

  const query = `
    SELECT id 
    FROM alert
    WHERE alert_type = ? AND status_id = ? AND DATE(created_at) = CURDATE()
  `;

  db.query(query, [type, id_mesure], (err, results) => {
    if (err) {
      console.error("Erreur lors de la vérification de l'alerte :", err);
      return res.status(500).json({ error: "Erreur serveur." });
    }

    res.status(200).json({ exists: results.length > 0 });
  });
});
module.exports = router;