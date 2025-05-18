require("dotenv").config();
const express = require("express");
const http = require("http"); // NÉCESSAIRE pour socket.io
const pool = require("./config/database");
const cors = require("cors"); // ✅ Add this

const socket = require("./config/socket");

const app = express();
const server = http.createServer(app); // Serveur HTTP pour socket.io
const io = socket.init(server);        // Initialisation socket.io

const userRouter = require("./api/router/user.router");
const childRouter = require("./api/router/child.router");
const statusRouter = require('./api/router/statusRoutes');
const alertRouter = require('./api/router/alertRoutes');
const crisesRouter = require('./api/router/crises.router');
const roomRouter = require('./api/router/room.router');

app.use(cors()); // <-- Add this line


// Middlewares
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Logger simple
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
    console.log("🛠 Request Body:", req.body);
    next();
});

// Routes API
app.use('/api/status', statusRouter);
app.use('/api/alert', alertRouter);
app.use("/api/users", userRouter);
app.use("/api/children", childRouter);
app.use('/api/crises', crisesRouter);
app.use('/api/room', roomRouter);

// Route de test
app.get("/api", (req, res) => {
    res.json({
        success: 1,
        message: "API opérationnelle",
    });
});

// Dashboard combiné
app.get('/dashboard', (req, res) => {
    const sql = `
    SELECT c.*, s.id, s.bpm, s.Temperature, s.Latitude, s.Longitude, s.sound
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

// Erreur globale
app.use((err, req, res, next) => {
    console.error("Server Error:", err);
    res.status(500).json({ success: 0, message: "Internal Server Error" });
});

// Start the server (⚠️ on utilise bien `server.listen` ici)
const PORT = process.env.APP_PORT || 3000;
server.listen(PORT, () => {
    console.log(`🚀 Serveur avec WebSocket actif sur http://localhost:${PORT}`);
});
