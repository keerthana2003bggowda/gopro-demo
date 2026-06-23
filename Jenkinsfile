pipeline{
    agent {label 'go'}

    environment {
    PATH = "/usr/local/go/bin:${env.PATH}"
        JFROG_CREDS = credentials('artifactory-creds')
        JFROG_URL = 'http://13.203.219.26:8082/artifactory/go-artifacts'
    }

     


    stages {

        stage('Checkout') {
            steps{
                git branch: 'main',
                credentialsId: 'github-pat',
                    url: 'https://github.com/keerthana2003bggowda/gopro-demo.git'

            }

        }
        stage('Build') {
            steps {
                sh 'go build -o gopro main.go'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh "${tool('sonar-scanner')}/bin/sonar-scanner"
                }
            }
        }
        stage('Deploy') {
            steps {
            sh 'nohup ./gopro &'
            
        }
        
        }   
        stage('Publish to JFrog') {
            steps {
                sh 'curl -u $JFROG_CREDS_USR:$JFROG_CREDS_PSW -T gopro "${JFROG_URL}/gopro-${BUILD_NUMBER}"'
            }
        }
    }
    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}