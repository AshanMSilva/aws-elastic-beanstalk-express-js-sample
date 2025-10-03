pipeline {
    agent any

    environment {
        SNYK_TOKEN = credentials('snyk-token')
        DOCKER_CREDS = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out repository..."
                checkout scm
                sh 'ls -l'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t node-app:latest .'
            }
        }

        stage('Unit Tests') {
            steps {
                echo "Running unit tests"
                sh 'docker run --rm node-app:latest npm test'
            }
            post {
                failure {
                echo "Unit tests failed."
                }
            }
        }

        stage('Security scan - Snyk') {
            steps {
                echo "Security scan using Snyk"
                sh '''
                  docker run --rm \
                    -e SNYK_TOKEN=$SNYK_TOKEN \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    snyk/snyk:docker snyk container test node-app:latest --severity-threshold=high || true
                '''
            }
        }

        stage('Push image to registry') {
            steps {
                echo "Push image to Docker Hub"
                sh '''
                  echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin
                  docker tag node-app:latest $DOCKERHUB_CREDS_USR/node-app:latest
                  docker push $DOCKERHUB_CREDS_USR/node-app:latest
                '''
            }
        }
    }
    post {
        success {
            echo "Build and push successful!"
        }
        failure {
            echo "Build failed. Check logs for details."
        }
        always {
            archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
        }
    }
}