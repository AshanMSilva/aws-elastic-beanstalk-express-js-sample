pipeline {
  agent { docker { image 'node:16' } }

  environment {
    IMAGE = "ashanmsilva/aws-node-sample"
    DOCKERHUB_CREDS = credentials('dockerhub-creds')
    SNYK_TOKEN = credentials('snyk-token') // secret text
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Unit tests') {
      steps {
        sh 'npm test'
      }
      post {
        failure {
          echo "Unit tests failed."
        }
      }
    }

    stage('Security scan - Snyk') {
      steps {
        // install Snyk cli and authenticate with token stored in Jenkins as secret text
        sh '''
          npm install -g snyk@latest
          snyk auth ${SNYK_TOKEN}
          snyk test --severity-threshold=high
        '''
      }
    }

    stage('Build Docker image') {
      steps {
        sh "docker build -t ${IMAGE}:${env.BUILD_NUMBER} ."
      }
    }

    stage('Push image to registry') {
      steps {
        sh '''
          # docker login using credentials stored as username/password in Jenkins
          echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin
          docker push ${IMAGE}:${env.BUILD_NUMBER}
        '''
      }
    }

    stage('Archive artifacts') {
      steps {
        archiveArtifacts artifacts: 'logs/**,coverage/**,dist/**', allowEmptyArchive: true
      }
    }
  }

  post {
    always {
      echo "Build finished: ${currentBuild.currentResult}"
    }
    failure {
      mail to: 'ashansilva.17@cse.mrt.ac.lk', subject: "Pipeline failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}", body: "Check Jenkins."
    }
  }
}
