const express = require("express");
const { predictCrise } = require("../service/crises.service");
const router = express.Router();

// POST /api/crises/predict
router.post("/predict", predictCrise);

module.exports = router;