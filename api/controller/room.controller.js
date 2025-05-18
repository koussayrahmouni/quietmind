const RoomService = require('../service/room.service');

module.exports = {
  // GET /api/room
  getAllRooms: (req, res) => {
    RoomService.getAllRooms((err, rooms) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(rooms);
    });
  },

  // GET /api/room/:id
  getRoomById: (req, res) => {
    const { id } = req.params;
    RoomService.getRoomById(id, (err, room) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!room) return res.status(404).json({ message: 'Room not found' });
      res.json(room);
    });
  },

  // POST /api/room
  createRoom: (req, res) => {
    const { light = 0, ventilateur = 0, store = 0 } = req.body;
    RoomService.createRoom({ light, ventilateur, store }, (err, newRoom) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(201).json(newRoom);
    });
  },

  // PUT /api/room/:id
  updateRoom: (req, res) => {
    const { id } = req.params;
    const { light, ventilateur, store } = req.body;
    RoomService.updateRoom(id, { light, ventilateur, store }, (err, updatedRoom) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(updatedRoom);
    });
  },

  // DELETE /api/room/:id
  deleteRoom: (req, res) => {
    const { id } = req.params;
    RoomService.deleteRoom(id, (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(204).send();
    });
  },

  
  // PATCH /api/room/:id/light
  updateLight: (req, res) => {
    const { id } = req.params;
    const { light } = req.body;
    RoomService.updateLight(id, light, (err, room) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(room);
    });
  },

  // PATCH /api/room/:id/store
  updateStore: (req, res) => {
    const { id } = req.params;
    const { store } = req.body;
    RoomService.updateStore(id, store, (err, room) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(room);
    });
  },

  // PATCH /api/room/:id/ventilateur
  updateVentilateur: (req, res) => {
    const { id } = req.params;
    const { ventilateur } = req.body;
    RoomService.updateVentilateur(id, ventilateur, (err, room) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(room);
    });
  },

  
};
