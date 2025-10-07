pipeline {
    agent any

    environment {
        SONAR_PROJECT_KEY = 'node_app'
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

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    bat """
                    sonar-scanner.bat ^
                    -D"sonar.projectKey=%SONAR_PROJECT_KEY%" ^
                    -D"sonar.sources=." ^
                    -D"sonar.host.url=http://host.docker.internal:9000" ^
                    -D"sonar.login=%SONAR_TOKEN%"
                    """
                }
            }
        }

    } // <-- fin des stages

    post {
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed. Check logs.'
        }
    }

}
