pipeline {
    agent { label 'windows' }

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: true, description: 'Appliquer automatiquement le plan Terraform')
    }

    environment {
        DOCKER_IMAGE = 'rahmam123/devapp'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        stage('Terraform Init & Apply') {
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
                        terraform init
                        terraform apply -auto-approve -var="aws_access_key=$env:AWS_ACCESS_KEY_ID" `
                                                        -var="aws_secret_key=$env:AWS_SECRET_ACCESS_KEY"
                    '''
                }
            }
        }

        stage('Notify') {
            steps {
                echo '✅ Instance EC2 créée avec succès via Terraform.'
            }
        }
    }

    post {
        failure {
            echo '❌ Échec du pipeline. Vérifiez les logs Terraform.'
        }
    }
}
