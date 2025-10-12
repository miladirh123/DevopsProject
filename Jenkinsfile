pipeline {
    agent { label 'windows' }

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

        stage('Terraform Init & Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    file(credentialsId: 'ec2-key-file', variable: 'EC2_KEY_PATH')
                ]) {
                    powershell '''
                        $privateKey = Get-Content "$env:EC2_KEY_PATH" -Raw
                        $env:PRIVATE_KEY_CONTENTS = $privateKey

                        cd terraform
                        terraform init -upgrade
                        terraform plan -var="aws_access_key=$env:AWS_ACCESS_KEY_ID" `
                                       -var="aws_secret_key=$env:AWS_SECRET_ACCESS_KEY" `
                                       -var="private_key=$env:PRIVATE_KEY_CONTENTS" `
                                       -out=tfplan
                        terraform show -no-color tfplan > tfplan.txt
                    '''
                }
            }
        }

        stage('Terraform Manual Approval') {
            when {
                not { equals expected: true, actual: params.autoApprove }
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
                    file(credentialsId: 'ec2-key-file', variable: 'EC2_KEY_PATH')
                ]) {
                    powershell '''
                        $privateKey = Get-Content "$env:EC2_KEY_PATH" -Raw
                        $env:PRIVATE_KEY_CONTENTS = $privateKey

                        cd terraform
                        terraform apply -var="aws_access_key=$env:AWS_ACCESS_KEY_ID" `
                                        -var="aws_secret_key=$env:AWS_SECRET_ACCESS_KEY" `
                                        -var="private_key=$env:PRIVATE_KEY_CONTENTS" `
                                        -input=false tfplan
                        terraform output -raw ec2_public_ip > ec2_ip.txt
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([file(credentialsId: 'ec2-key-file', variable: 'EC2_KEY_PATH')]) {
                    script {
                        def ec2_ip = readFile('terraform/ec2_ip.txt').trim()
                        bat """
                            echo Deploiement sur ${ec2_ip}...
                            pscp -i "%EC2_KEY_PATH%" docker-compose.yml ec2-user@${ec2_ip}:/home/ec2-user/
                            plink -i "%EC2_KEY_PATH%" ec2-user@${ec2_ip} ^
                                "docker-compose down || true && docker-compose up -d"
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
            echo '❌ Échec du pipeline. Vérifiez les logs Terraform ou SSH.'
        }
    }
}
