pipline {
    agent any
    environment {
        TF_VAR_access_key = credentials('aws-access-key')
        TF_VAR_secret_key = credentials('aws-secret-key')
    }


    stages {
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('Terraform apply') {
            steps {
                input message: 'Apply the plan?'
                sh 'terraform apply tfplan'
            }
        }
    }
}