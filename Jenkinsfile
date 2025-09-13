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
        GIT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        IMAGE_TAG = "${GIT_COMMIT}"
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
                // Check if test script exists, skip if not
                script {
                    def hasTest = sh(script: "jq -e '.scripts.test' package.json", returnStatus: true) == 0
                    if (hasTest) {
                        sh 'npm test'
                    } else {
                        echo "No tests found, skipping test stage"
                    }
                }
            }
        }

        stage('Dockerize') {
            steps {
                sh "docker build -t $IMAGE_NAME:latest -t $IMAGE_NAME:$IMAGE_TAG ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $IMAGE_NAME:latest
                        docker push $IMAGE_NAME:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
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
        failure {
            echo "❌ Pipeline failed."
        }
    }
}
