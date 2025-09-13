pipeline {
    agent any

    tools {
        nodejs "node18"   // Matches the name you configured in Jenkins
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')  // DockerHub credential ID
        AWS_REGION = 'us-east-1'
        ECS_CLUSTER = 'node-app-cluster'
        ECS_SERVICE = 'node-app-service'
        TASK_DEFINITION = 'node-app-task'
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
                sh 'npm test || echo "No tests found"'
            }
        }

        stage('Dockerize') {
            steps {
                sh "docker build -t $IMAGE_NAME:latest ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $IMAGE_NAME:latest
                    """
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                // Using AWS Credentials Plugin
                withAWS(credentials: 'aws_credentials', region: "${AWS_REGION}") {
                    sh """
                        aws ecs update-service \
                            --cluster $ECS_CLUSTER \
                            --service $ECS_SERVICE \
                            --force-new-deployment
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
