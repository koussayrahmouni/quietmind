const pool = require('../../config/database');

const RoomService = {
  getAllRooms: (callback) => {
    const sql = 'SELECT * FROM room';
    pool.query(sql, (err, results) => {
      callback(err, results);
    });
  },

  getRoomById: (id, callback) => {
    const sql = 'SELECT * FROM room WHERE id = ?';
    pool.query(sql, [id], (err, results) => {
      callback(err, results[0]);
    });
  },

  createRoom: (data, callback) => {
    const sql = 'INSERT INTO room (light, ventilateur, store) VALUES (?, ?, ?)';
    const params = [data.light, data.ventilateur, data.store];
    pool.query(sql, params, (err, result) => {
      callback(err, { id: result.insertId, ...data });
    });
  },

  updateRoom: (id, data, callback) => {
    const sql = `
      UPDATE room
      SET light = ?, ventilateur = ?, store = ?
      WHERE id = ?
    `;
    const params = [data.light, data.ventilateur, data.store, id];
    pool.query(sql, params, (err) => {
      callback(err, { id: Number(id), ...data });
    });
  },

  deleteRoom: (id, callback) => {
    const sql = 'DELETE FROM room WHERE id = ?';
    pool.query(sql, [id], (err) => {
      callback(err);
    });
  },

  updateLight: (id, light, callback) => {
    const sql = 'UPDATE room SET light = ? WHERE id = ?';
    pool.query(sql, [light, id], (err) => {
      callback(err, { id: Number(id), light });
    });
  },

  updateStore: (id, store, callback) => {
    const sql = 'UPDATE room SET store = ? WHERE id = ?';
    pool.query(sql, [store, id], (err) => {
      callback(err, { id: Number(id), store });
    });
  },

  updateVentilateur: (id, ventilateur, callback) => {
    const sql = 'UPDATE room SET ventilateur = ? WHERE id = ?';
    pool.query(sql, [ventilateur, id], (err) => {
      callback(err, { id: Number(id), ventilateur });
    });
  },
};

module.exports = RoomService;
