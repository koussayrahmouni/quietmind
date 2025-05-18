const mysql = require('mysql2');

// Créez une connexion MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',  // Remplacez par votre nom d'utilisateur MySQL
  database: 'final'  // Remplacez par le nom de votre base de données
});

// Vérifie si la connexion fonctionne
db.connect((err) => {
  if (err) {
    console.error('Erreur de connexion : ' + err.stack);
    return;
  }
  console.log('Connecté à la base de données avec l\'ID ' + db.threadId);
});
module.exports = db;

