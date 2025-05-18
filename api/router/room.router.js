const express = require('express');
const RoomController = require('../controller/room.controller');

const router = express.Router();

router
  .route('/')
  .get(RoomController.getAllRooms)
  .post(RoomController.createRoom);

router
  .route('/:id')
  .get(RoomController.getRoomById)
  .put(RoomController.updateRoom)
  .delete(RoomController.deleteRoom);
router.patch('/:id/light',       RoomController.updateLight);
router.patch('/:id/store',       RoomController.updateStore);
router.patch('/:id/ventilateur', RoomController.updateVentilateur);

module.exports = router;
