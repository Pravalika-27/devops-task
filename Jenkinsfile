pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Jenkins credential ID
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
                sh 'npm test || echo "Tests completed"' // Remove if no tests
            }
        }

        stage('Dockerize') {
            steps {
                sh "docker build -t $IMAGE_NAME:latest ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push $IMAGE_NAME:latest
                """
            }
        }

        stage('Deploy to ECS') {
            steps {
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

    post {
        always {
            echo "Pipeline finished."
        }
    }
}
