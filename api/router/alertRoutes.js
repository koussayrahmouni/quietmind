const express = require('express')
const alertController = require('../controller/alertController')

const router = express.Router()

// Route pour récupérer toutes les alertes
router.get('/', alertController.getAllAlerts)

// Route pour ajouter une nouvelle alerte
router.post('/', alertController.createAlert)

// Route pour supprimer une alerte par son ID
router.delete('/:id', alertController.deleteAlert)

module.exports = router
