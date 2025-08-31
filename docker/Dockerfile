FROM openjdk:17

WORKDIR /app
COPY app/build/outputs/apk/release/app-release.apk /app/app-release.apk

CMD ["ls", "-lh", "app-release.apk"]
