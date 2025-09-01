FROM nginx:alpine
# Créer un dossier pour stocker l'APK
RUN mkdir -p /usr/share/nginx/html/apk
# Copier l'APK buildé
COPY app-release.apk /usr/share/nginx/html/apk/
# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
