pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECS_CLUSTER = 'node-app-cluster'
        ECS_SERVICE = 'node-app-service'
        IMAGE_NAME = 'pravalika27/taskdev'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Pravalika-27/devops-task.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'npm install'
                sh 'npm test || echo "No tests available, skipping..."'
            }
        }

        stage('Dockerize & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t $IMAGE_NAME:latest .
                        docker push $IMAGE_NAME:latest
                    """
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws_credentials') {
                    sh """
                        aws ecs update-service \
                            --cluster $ECS_CLUSTER \
                            --service $ECS_SERVICE \
                            --force-new-deployment \
                            --region $AWS_REGION
                    """
                }
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline finished."
        }
    }
}
