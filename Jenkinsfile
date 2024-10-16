pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "gcr.io/nginx-app-project-dev/my-nginx-app"
        PROJECT_ID = "nginx-app-project-dev"
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
                    withEnv(["PATH+GCLOUD=/google-cloud-sdk/bin"]) {
                        sh 'gcloud auth configure-docker'
                        sh "docker push ${DOCKER_IMAGE}"
                    }
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

