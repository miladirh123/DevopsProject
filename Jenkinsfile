pipeline {
    agent any
    tools {
        nodejs 'NodeJS'  // Assure-toi d'avoir configuré NodeJS dans Jenkins
    }
    environment {
        SONAR_PROJECT_KEY = 'node-app'
        SONAR_SCANNER_HOME = tool 'SonarQubeScanner' // SonarQube Scanner installé dans Jenkins
    }

    stages {
        stage('Checkout Github'){
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }
        
        stage('Install node dependencies'){
            steps {
                bat 'npm install'
            }
        }

        stage('Tests'){
            steps {
                bat 'npm test'
            }
        }

        stage('SonarQube Analysis'){
            steps {
                withCredentials([string(credentialsId: 'node-token', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') {
                        bat """
                        %SONAR_SCANNER_HOME%\\bin\\sonar-scanner.bat ^
                        -Dsonar.projectKey=%SONAR_PROJECT_KEY% ^
                        -Dsonar.sources=. ^
                        -Dsonar.host.url= http://localhost:9000/^
                        -Dsonar.login=%SONAR_TOKEN%
                        """
                    }
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
