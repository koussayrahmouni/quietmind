require("dotenv").config();
const express = require("express");
const pool = require("./config/database");

const app = express();
const userRouter = require("./api/router/user.router");
const childRouter = require("./api/router/child.router");
const statusRouter = require('./api/router/statusRoutes');
const alertRouter = require('./api/router/alertRoutes');
const crisesRouter = require('./api/router/crises.router');

// Logging Middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
    console.log("🛠 DEBUG - Request Body:", req.body);
    next();
});

// Middleware pour parser JSON et URL-encoded
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const PORT = process.env.APP_PORT || 3000;

// Routes
app.use('/api/status', statusRouter);
app.use('/api/alert', alertRouter);
app.use('/api/users', userRouter);
app.use('/api/children', childRouter);
app.use('/api/crises', crisesRouter);

// Route de base
app.get("/api", (req, res) => {
    res.json({ success: 1, message: "This is a working REST API" });
});

// Dashboard (jointure child + status)
app.get('/dashboard', (req, res) => {
    const sql = `
      SELECT c.*, s.id, s.Heartbeat, s.Temperature, s.Latitude, s.Longitude, s.sound
      FROM child c
      LEFT JOIN status s ON c.id = s.child_id
    `;
    pool.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 404
app.use((req, res) => {
    res.status(404).json({ success: 0, message: "Route not found" });
});

// Gestion globale des erreurs
app.use((err, req, res, next) => {
    console.error("Server Error:", err);
    res.status(500).json({ success: 0, message: "Internal Server Error" });
});

// Afficher toutes les routes
app._router.stack.forEach(r => {
    if (r.route && r.route.path) console.log(r.route.path);
});

// Démarrage
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));