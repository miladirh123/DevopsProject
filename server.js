const express = require('express'); // On importe Express
const app = express();              // On crée une application Express
const PORT = 3000;                  // On définit le port du serveur

// Route principale
app.get('/', (req, res) => res.send('Hello World!')); 

// Lancer le serveur
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
