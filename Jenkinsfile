pipeline {
    agent any

    environment {
        SONAR_PROJECT_KEY = 'node-app'
    }

    stages {

        stage('Checkout Github') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        stage('Install node dependencies') {
            steps {
                bat 'npm install'
            }
        }

        /*stage('Run Tests') {
            steps {
                bat 'npm test'
            }
        }*/

        stage('SonarQube Analysis (Docker)') {
            steps {
                withCredentials([string(credentialsId: 'node-token', variable: 'SONAR_TOKEN')]) {
                    // Exécuter SonarScanner via Docker
                    bat """
                    docker run --rm ^
                        -e SONAR_HOST_URL=http://host.docker.internal:9000 ^
                        -e SONAR_LOGIN=%SONAR_TOKEN% ^
                        -v "%CD%:/usr/src" ^
                        sonarsource/sonar-scanner-cli
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed. Check logs.'
        }
    }
}
