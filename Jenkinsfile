pipeline{
    agent {label 'go'}

    environment {
    PATH = "/usr/local/go/bin:${env.PATH}"
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
        stage('Deploy') {
            steps {
            // sh 'kill -9 $(pgrep -f gopro) 2>/dev/null || true'
            sh 'nohup ./gopro > app.log 2>&1 &'
            // sh 'sleep 3'
            // sh 'cat app.log'
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