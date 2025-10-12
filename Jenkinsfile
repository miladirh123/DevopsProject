pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Appliquer automatiquement après le plan Terraform ?')
    }

    environment {
        SONAR_PROJECT_KEY = 'node_app'
        SONAR_SCANNER_PATH = 'C:\\sonar-scanner\\bin\\sonar-scanner.bat'
        NODE_ENV = 'production'
        DOCKER_IMAGE = 'rahmam123/devapp'
    }

    stages {

        // 1️⃣ Checkout du code
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        // 2️⃣ Terraform Init & Plan
        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    file(credentialsId: 'ec2-key-file', variable: 'KEY_FILE')
                ]) {
                    bat '''
                        echo Initialisation de Terraform...
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

                        cd terraform
                        copy "%KEY_FILE%" ec2-key.pem

                        terraform init -upgrade || exit /b 1
                        terraform plan ^
                            -var="aws_access_key=%AWS_ACCESS_KEY_ID%" ^
                            -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" ^
                            -out=tfplan || exit /b 1

                        terraform show -no-color tfplan > tfplan.txt
                    '''
                }
            }
        }

        // 3️⃣ Validation manuelle (optionnelle)
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

        // 4️⃣ Terraform Apply
        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    file(credentialsId: 'ec2-key-file', variable: 'KEY_FILE')
                ]) {
                    bat '''
                        echo Application du plan Terraform...
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

                        cd terraform
                        copy "%KEY_FILE%" ec2-key.pem

                        terraform apply ^
                            -var="aws_access_key=%AWS_ACCESS_KEY_ID%" ^
                            -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" ^
                            -auto-approve || exit /b 1

                        terraform output -raw ec2_public_ip > ec2_ip.txt
                    '''
                }
            }
        }

        // 5️⃣ Analyse SonarQube
        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
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

        // 6️⃣ Déploiement sur EC2
        stage('Deploy to EC2') {
            steps {
                withCredentials([file(credentialsId: 'ec2-key-file', variable: 'KEY_FILE')]) {
                    script {
                        def ec2_ip = readFile('terraform/ec2_ip.txt').trim()
                        bat """
                            echo Deploiement sur EC2: ${ec2_ip}
                            pscp -i "%KEY_FILE%" -batch -scp app.js ec2-user@${ec2_ip}:/home/ec2-user/app.js
                            ssh -i "%KEY_FILE%" ec2-user@${ec2_ip} "docker pull %DOCKER_IMAGE% && docker stop devapp || true && docker rm devapp || true && docker run -d --name devapp -p 80:3000 %DOCKER_IMAGE%"
                        """
                    }
                }
            }
        }

        // 7️⃣ Notification
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
