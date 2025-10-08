pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Appliquer automatiquement après le plan Terraform ?')
    }

    environment {
        SONAR_PROJECT_KEY = 'node_app'
        SONAR_SCANNER_PATH = 'C:\\sonar-scanner\\bin\\sonar-scanner.bat'
        NODE_ENV = 'production'
        DOCKER_IMAGE = 'miladirh123/appnode'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo '📥 Étape 1 : Récupération du code source...'
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo '🌍 Étape 2 : Génération du plan Terraform...'
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat '''
                        @echo off
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                        cd terraform
                        echo Initialisation Terraform...
                        terraform init -upgrade || exit /b 1
                        echo Génération du plan...
                        terraform plan -var="aws_access_key=%AWS_ACCESS_KEY_ID%" -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" -out=tfplan || exit /b 1
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
                echo '✅ Étape 3 : Validation manuelle du plan Terraform...'
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Souhaitez-vous appliquer ce plan Terraform ?",
                          parameters: [text(name: 'Plan', description: 'Veuillez examiner le plan Terraform', defaultValue: plan)]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                echo '🚀 Étape 4 : Application du plan Terraform...'
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat '''
                        @echo off
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                        cd terraform
                        echo Application du plan...
                        terraform apply -var="aws_access_key=%AWS_ACCESS_KEY_ID%" -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" -input=false tfplan || exit /b 1
                        terraform output -raw ec2_public_ip > ec2_ip.txt
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                echo '🐳 Étape 5 : Construction et push de l’image Docker...'
                withCredentials([
                    usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
                ]) {
                    bat '''
                        @echo off
                        echo Construction de l’image...
                        docker build -t %DOCKER_IMAGE% .
                        echo Connexion à Docker Hub...
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        echo Push de l’image...
                        docker push %DOCKER_IMAGE%
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '📊 Étape 6 : Analyse SonarQube...'
                withCredentials([
                    string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')
                ]) {
                    bat """
                        @echo off
                        set SONAR_TOKEN=%SONAR_TOKEN%
                        echo Lancement de l’analyse SonarQube...
                        "%SONAR_SCANNER_PATH%" ^
                            -D"sonar.projectKey=%SONAR_PROJECT_KEY%" ^
                            -D"sonar.sources=." ^
                            -D"sonar.host.url=http://localhost:9000" ^
                            -D"sonar.login=%SONAR_TOKEN%"
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo '🚀 Étape 7 : Déploiement sur EC2 via Docker Hub...'
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY', usernameVariable: 'USER')
                ]) {
                    script {
                        def ec2_ip = readFile('terraform/ec2_ip.txt').trim()
                        bat """
                            @echo off
                            echo Connexion à EC2 et déploiement...
                            ssh -i %KEY% %USER%@${ec2_ip} ^
                                "docker pull %DOCKER_IMAGE% && docker stop appnode || true && docker rm appnode || true && docker run -d --name appnode -p 80:3000 %DOCKER_IMAGE%"
                        """
                    }
                }
            }
        }

        stage('Notify') {
            steps {
                echo '📣 Étape 8 : Notification de fin de pipeline.'
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
