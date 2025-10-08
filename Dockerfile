# Utilise une image Node officielle
FROM node:18

# Crée un dossier de travail
WORKDIR /app

# Copie les fichiers du projet
COPY . .

# Installe les dépendances
RUN npm install

# Expose le port utilisé par ton app (ex: 3000)
EXPOSE 3000

# Commande de démarrage
CMD ["npm", "start"]
