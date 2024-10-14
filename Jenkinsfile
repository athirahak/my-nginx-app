pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "gcr.io/nginx-web-app/my-nginx-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/athirahak/my-nginx-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        stage('Push to Google Container Registry') {
            steps {
                script {
                    sh 'gcloud auth configure-docker'
                    docker.image("${DOCKER_IMAGE}").push()
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    gcloud container clusters get-credentials my-nginx-cluster --zone us-central1-c
                    kubectl apply -f deployment.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
