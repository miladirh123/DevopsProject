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

        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY_FILE', usernameVariable: 'USER')
                ]) {
                    bat '''
                        setlocal EnableDelayedExpansion
                        set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                        set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

                        set PRIVATE_KEY_CONTENTS=
                        for /f "usebackq delims=" %%i in ("%KEY_FILE%") do (
                            set line=%%i
                            set PRIVATE_KEY_CONTENTS=!PRIVATE_KEY_CONTENTS!!line!\\n!
                        )
                        endlocal & set PRIVATE_KEY_CONTENTS=%PRIVATE_KEY_CONTENTS%

                        cd terraform
                        terraform init -upgrade || exit /b 1
                        terraform plan -var="aws_access_key=%AWS_ACCESS_KEY_ID%" -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" -var="private_key=%PRIVATE_KEY_CONTENTS%" -out=tfplan || exit /b 1
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
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY_FILE', usernameVariable: 'USER')
                ]) {
                    bat '''
                        setlocal EnableDelayedExpansion
                        set PRIVATE_KEY_CONTENTS=
                        for /f "usebackq delims=" %%i in ("%KEY_FILE%") do (
                            set line=%%i
                            set PRIVATE_KEY_CONTENTS=!PRIVATE_KEY_CONTENTS!!line!\\n!
                        )
                        endlocal & set PRIVATE_KEY_CONTENTS=%PRIVATE_KEY_CONTENTS%

                        cd terraform
                        terraform apply -var="aws_access_key=%AWS_ACCESS_KEY_ID%" -var="aws_secret_key=%AWS_SECRET_ACCESS_KEY%" -var="private_key=%PRIVATE_KEY_CONTENTS%" -input=false tfplan || exit /b 1
                        terraform output -raw ec2_public_ip > ec2_ip.txt
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY', usernameVariable: 'USER')
                ]) {
                    script {
                        def ec2_ip = readFile('terraform/ec2_ip.txt').trim()
                        bat """
                            ssh -o StrictHostKeyChecking=no -i %KEY% %USER%@${ec2_ip} ^
                                "docker pull %DOCKER_IMAGE% && docker stop devapp || true && docker rm devapp || true && docker run -d --name devapp -p 80:3000 %DOCKER_IMAGE%"
                        """
                    }
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
        success {
            echo '✅ Pipeline exécuté avec succès !'
        }
        failure {
            echo '❌ Échec du pipeline. Vérifiez les logs.'
        }
    }
}
