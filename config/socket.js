// config/socket.js
let io;

module.exports = {
  init: (httpServer) => {
    const { Server } = require("socket.io");
    io = new Server(httpServer, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
      },
    });

    io.on("connection", (socket) => {
      console.log("🔌 Client connecté:", socket.id);

      socket.on("disconnect", () => {
        console.log("❌ Client déconnecté:", socket.id);
      });
    });

    return io;
  },

  getIO: () => {
    if (!io) throw new Error("Socket.io n'est pas initialisé !");
    return io;
  },
};
