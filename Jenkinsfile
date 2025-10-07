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

        // Optionnel : Active si tu veux exécuter les tests
        /*
        stage('Run Tests') {
            steps {
                bat 'npm test'
            }
        }
        */

        stage('SonarQube Analysis') {
            steps {
                withCredentials([
                    string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')
                ]) {
                    bat '''
                        set SONAR_TOKEN=%SONAR_TOKEN%
                        sonar-scanner.bat ^
                            -D"sonar.projectKey=%SONAR_PROJECT_KEY%" ^
                            -D"sonar.sources=." ^
                            -D"sonar.host.url=http://host.docker.internal:9000" ^
                            -D"sonar.login=%SONAR_TOKEN%"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build completed successfully!'
        }
        failure {
            echo '❌ Build failed. Check logs for details.'
        }
    }
}
