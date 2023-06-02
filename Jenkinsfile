pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/olaoruku007/terraform-pro1.git'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
