pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Appliquer automatiquement après le plan Terraform ?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Choisir l’action à exécuter')
    }

    environment {
        AWS_DEFAULT_REGION = 'eu-west-2'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/miladirh123/DevopsProject.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        terraform plan \
                        -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                        -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
                        -out=tfplan
                    '''
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Terraform Apply / Destroy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        if (params.action == 'apply') {
                            if (!params.autoApprove) {
                                def plan = readFile 'tfplan.txt'
                                input message: "Souhaitez-vous appliquer ce plan Terraform ?",
                                parameters: [text(name: 'Plan', description: 'Veuillez examiner le plan Terraform', defaultValue: plan)]
                            }

                            sh 'terraform apply -input=false tfplan'
                        } else if (params.action == 'destroy') {
                            sh '''
                                terraform destroy \
                                -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
                                --auto-approve
                            '''
                        } else {
                            error "Action invalide. Choisissez 'apply' ou 'destroy'."
                        }
                    }
                }
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
