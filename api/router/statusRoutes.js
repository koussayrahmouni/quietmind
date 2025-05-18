  // router/statusController.js

const express = require('express');
const router = express.Router();
const statusController = require('../controller/statusController');

router.post('/create', statusController.createStatus);
router.get('/heartbeats', statusController.getAllHeartbeats);
router.get('/temperature', statusController.getAllTemperature);
 router.get('/sound', statusController.getAllSound);

 router.get('/last-coordinates', statusController.getLatestCoordinates);


// status.route.js
router.get('/last-data/:child_id', statusController.getLastDataForChild);

router.get('/soundchappi', statusController.getAllSoundchappi);

module.exports = router;
