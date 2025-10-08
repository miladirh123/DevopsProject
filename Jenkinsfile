pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Appliquer automatiquement après le plan Terraform ?')
    }

    environment {
        SONAR_PROJECT_KEY = 'node_app'
        SONAR_SCANNER_PATH = 'C:\\sonar-scanner\\bin\\sonar-scanner.bat'
        NODE_ENV = 'production'
    }

    stages {

        // 📥 1. Checkout du code
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        // 🌍 2. Provisionnement EC2 avec Terraform
        stage('Terraform Plan & Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat '''
                        echo Vérification des identifiants AWS...
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                        cd terraform
                        terraform init -upgrade
                        terraform plan -out=tfplan
                        terraform show -no-color tfplan > tfplan.txt
                    '''
                }
            }
        }

        stage('Terraform Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Souhaitez-vous appliquer ce plan Terraform ?",
                          parameters: [text(name: 'Plan', description: 'Veuillez examiner le plan Terraform', defaultValue: plan)]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat '''
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                        cd terraform
                        terraform apply -input=false tfplan
                    '''
                }
            }
        }

        // 📦 3. Installation des dépendances Node.js
        stage('Install Node Dependencies') {
            steps {
                bat 'npm install'
            }
        }

        // 🧪 4. Tests unitaires
        /*stage('Run Tests') {
            steps {
                bat 'npm test'
            }
        }*/

        // 📊 5. Analyse SonarQube
        stage('SonarQube Analysis') {
            steps {
                withCredentials([
                    string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')
                ]) {
                    bat """
                        set SONAR_TOKEN=%SONAR_TOKEN%
                        "%SONAR_SCANNER_PATH%" ^
                            -D"sonar.projectKey=%SONAR_PROJECT_KEY%" ^
                            -D"sonar.sources=." ^
                            -D"sonar.host.url=http://localhost:9000" ^
                            -D"sonar.login=%SONAR_TOKEN%"
                    """
                }
            }
        }

        // 🚀 6. Déploiement sur EC2
        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY', usernameVariable: 'USER')
                ]) {
                    bat '''
                        echo Déploiement sur EC2...
                        ssh -i %KEY% %USER%@<EC2_PUBLIC_IP> "cd /var/www/app && git pull && npm install && npm run start"
                    '''
                }
            }
        }

        // 📣 7. Notification
        stage('Notify') {
            steps {
                echo '📢 Pipeline terminé. Application déployée sur EC2.'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline exécuté avec succès !'
        }
        failure {
            echo '❌ Échec du pipeline. Vérifiez les logs.'
        }
    }
}
