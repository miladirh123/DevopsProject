pipeline {
    agent any

    environment {
        SONAR_PROJECT_KEY = 'node_app'
        WORKSPACE_DIR = "${env.WORKSPACE}" // répertoire du projet Jenkins
        SONAR_TOKEN = credentials('SONAR_TOKEN') // token SonarQube stocké dans Jenkins Credentials
    }

    stages {

        stage('Checkout Github') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        /*stage('Install node dependencies') {
            steps {
                bat 'npm install'
            }
        }*/
        stage('Run Tests') {
            steps {
                bat 'npm test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                bat """
                docker run --rm ^
                -e SONAR_HOST_URL=http://host.docker.internal:9000 ^
                -e SONAR_LOGIN=%SONAR_TOKEN% ^
                -v "%WORKSPACE_DIR%:/usr/src" ^
                sonarsource/sonar-scanner-cli
                """
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
