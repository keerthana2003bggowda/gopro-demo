pipeline{
    agent {label 'go'}

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
            sh 'nohup ./gopro &'
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