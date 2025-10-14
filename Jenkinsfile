pipeline {
    agent { label 'windows' }

    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Appliquer automatiquement après le plan Terraform ?'
        )
    }

    environment {
        SONAR_PROJECT_KEY = 'node_app'
        SONAR_SCANNER_PATH = 'C:\\sonar-scanner\\bin\\sonar-scanner.bat'
        NODE_ENV = 'production'
        DOCKER_IMAGE = 'rahmam123/devapp'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-cred',
                    url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        stage('SonarQube Analysis') {
            options { timeout(time: 3, unit: 'MINUTES') }
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    bat """
                        "%SONAR_SCANNER_PATH%" ^
                        -Dsonar.projectKey=%SONAR_PROJECT_KEY% ^
                        -Dsonar.sources=. ^
                        -Dsonar.host.url=http://localhost:9000 ^
                        -Dsonar.login=%SONAR_TOKEN%
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('Terraform') {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        bat '''
                            terraform init -upgrade
                            terraform plan -out=tfplan ^
                                -var="aws_access_key=%AWS_ACCESS_KEY_ID%" ^
                                -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%"
                            terraform show -no-color tfplan > tfplan.txt
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('Terraform') {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        bat '''
                            terraform apply -auto-approve ^
                                -var="aws_access_key=%AWS_ACCESS_KEY_ID%" ^
                                -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%"
                            terraform output -raw ec2_public_ip > ec2_ip.txt
                        '''
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    def ec2_ip = readFile('Terraform/ec2_ip.txt').trim()
                    bat """
                        echo 📦 Déploiement sur ${ec2_ip}...
                        ssh -o StrictHostKeyChecking=no -i "C:/jenkins/keys/ec2-key.pem" ec2-user@${ec2_ip} ^
                            "docker pull %DOCKER_IMAGE% &&
                             docker stop devapp || true &&
                             docker rm devapp || true &&
                             docker run -d --name devapp -p 80:3000 %DOCKER_IMAGE%"
                    """
                }
            }
        }

        stage('Notify') {
            steps {
                echo '📢 Pipeline terminé. Application déployée sur EC2.'
            }
        }
    }

    post {
        success { echo '✅ Pipeline exécuté avec succès !' }
        failure { echo '❌ Échec du pipeline. Vérifiez les logs Terraform ou SSH.' }
    }
}
