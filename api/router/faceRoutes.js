const express = require('express');
const router = express.Router();
const controller = require('../controller/faceController');

router.post('/start', controller.startRecognition);
router.post('/stop', controller.stopRecognition);

module.exports = router;