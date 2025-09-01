# Image de base légère avec Java
FROM openjdk:17-jdk-slim

# Dossier de travail
WORKDIR /app

# Copier l’APK compilé dans Docker
COPY app/build/outputs/apk/release/app-release.apk .

# Exposer un port (optionnel, juste pour test)
EXPOSE 8080

# Commande par défaut : garder le container actif
CMD ["tail", "-f", "/dev/null"]
