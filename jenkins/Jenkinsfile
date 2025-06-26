pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = 'kimai'
    }

    stages {
        stage('Start Kimai with Docker Compose') {
            steps {
                script {
                    sh '''
                        echo "[INFO] Cleaning previous containers..."
                        docker compose -f docker-compose.yml down || true

                        echo "[INFO] Starting Kimai..."
                        docker compose -f docker-compose.yml up -d
                    '''
                }
            }
        }

        stage('Check Docker Containers') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Show App URL') {
            steps {
                script {
                    def ip = sh(script: "curl -s http://checkip.amazonaws.com", returnStdout: true).trim()
                    echo "✅ Kimai running at: http://${ip}:8001"
                }
            }
        }
    }
}
