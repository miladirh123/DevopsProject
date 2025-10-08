pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Appliquer automatiquement après le plan Terraform ?')
    }

    environment {
        SONAR_PROJECT_KEY = 'node_app'
        SONAR_SCANNER_PATH = 'C:\\sonar-scanner\\bin\\sonar-scanner.bat'
        NODE_ENV = 'production'
        DOCKER_IMAGE = 'tonutilisateur/appnode' // Remplace par ton nom Docker Hub
    }

    stages {

        // 📥 1. Checkout du code
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        // 🌍 2. Terraform Plan
        stage('Terraform Plan') {
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
                        terraform init -upgrade || exit /b 1
                        terraform plan -var="aws_access_key=%AWS_ACCESS_KEY_ID%" -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" -out=tfplan || exit /b 1
                        terraform show -no-color tfplan > tfplan.txt
                    '''
                }
            }
        }

        // ✅ 3. Validation manuelle du plan
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

        // 🚀 4. Terraform Apply + capture IP EC2
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
                        terraform apply -var="aws_access_key=%AWS_ACCESS_KEY_ID%" -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" -input=false tfplan
                        terraform output -raw ec2_public_ip > ec2_ip.txt
                    '''
                }
            }
        }

        // 🐳 5. Build & Push Docker Image
        stage('Build & Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
                ]) {
                    bat '''
                        echo Construction de l'image Docker...
                        docker build -t %DOCKER_IMAGE% .

                        echo Connexion à Docker Hub...
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin

                        echo Push de l'image...
                        docker push %DOCKER_IMAGE%
                    '''
                }
            }
        }

        // 📊 6. Analyse SonarQube
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

        // 🚀 7. Déploiement sur EC2 via Docker
        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY', usernameVariable: 'USER')
                ]) {
                    script {
                        def ec2_ip = readFile('terraform/ec2_ip.txt').trim()
                        bat """
                            echo Déploiement sur EC2...
                            ssh -i %KEY% %USER%@${ec2_ip} ^
                                "docker pull %DOCKER_IMAGE% && docker stop appnode || true && docker rm appnode || true && docker run -d --name appnode -p 80:3000 %DOCKER_IMAGE%"
                        """
                    }
                }
            }
        }

        // 📣 8. Notification
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
