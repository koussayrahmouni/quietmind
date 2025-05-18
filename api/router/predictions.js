// routes/predictions.js
const express = require('express');
const router = express.Router();
//const { getLatestPrediction } = require('../service/predictionService');

router.get('/current-status', (req, res) => {
    const prediction = getLatestPrediction();
    res.json({
        hasCrisis: prediction ? prediction.probability > 0.5 : false,
        data: prediction
    });
});

module.exports = router;