# Image de base avec Java (nécessaire pour Android APK ou Gradle)
FROM openjdk:17-jdk-slim

# Crée le dossier pour l'APK
WORKDIR /app

# Copie l'APK depuis le job GitLab CI
COPY app-release.apk /app/app.apk

# Commande par défaut
CMD ["echo", "APK deployed successfully at /app/app.apk"]
