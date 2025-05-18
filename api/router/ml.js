// routes/ml.js
const express = require('express');
const router = express.Router();
const mlController = require('../controller/ml.Controller');

// POST /api/ml/predict
router.post('/predict', mlController.predictCrisis);

// Add future ML-related routes here
// router.post('/retrain', mlController.retrainModel);
// router.get('/status', mlController.modelStatus);

module.exports = router;