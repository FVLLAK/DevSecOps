pipeline {
  agent any

  environment {
    IMAGE_NAME     = "lab2-app"
    CONTAINER_NAME = "lab2-app"
  }

  stages {

    /* 1) Checkout */
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git rev-parse --short HEAD || true'
      }
    }

    /* 2) (Optionnel) Net debug */
    stage('Net debug') {
      agent {
        docker {
          image 'busybox'
          args  '--network host'
          reuseNode true
        }
      }
      steps {
        sh '''
          echo "DNS (host):"
          cat /etc/resolv.conf || true
          echo "Resolve pypi.org:"
          nslookup pypi.org || true
          echo "HTTP check:"
          wget -qO- https://pypi.org/simple/pip/ | head -n 5 || true
        '''
      }
    }

    /* 3) Setup Python + deps */
    stage('Setup Python Environment') {
      agent {
        docker {
          image 'python:3.11-slim'
          args  '--network host'
          reuseNode true
        }
      }
      steps {
        sh '''
          echo "🐍 Setting up Python virtual environment..."
          python -m venv venv
          . venv/bin/activate
          pip install -r requirements.txt --retries 5 --timeout 120
        '''
      }
    }

    /* 4) Tests (facultatif) */
    stage('Run Unit Tests') {
      agent {
        docker {
          image 'python:3.11-slim'
          args  '--network host'
          reuseNode true
        }
      }
      steps {
        sh '''
          . venv/bin/activate || true
          if command -v pytest >/dev/null 2>&1; then
            echo "🧪 Running tests..."
            pytest -q || true
          else
            echo "pytest non installé, étape ignorée."
          fi
        '''
      }
    }

    /* 5) Build image */
    stage('Build Docker Image') {
      steps {
        sh '''
          echo "🐳 Building image..."
	  docker build --network=host -t ${IMAGE_NAME}:latest .
          docker images | grep ${IMAGE_NAME} || true
        '''
      }
    }

    /* 6) Trivy scan (si installé sur l’agent) */
    stage('Trivy Scan') {
      when { expression { return sh(script: 'command -v trivy >/dev/null 2>&1', returnStatus: true) == 0 } }
      steps {
        sh '''
          echo "🔍 Trivy scan..."
          trivy image --severity HIGH,CRITICAL --exit-code 0 ${IMAGE_NAME}:latest || true
        '''
      }
    }

    /* 7) Deploy (docker compose) */
    stage('Deploy') {
      steps {
        sh '''
          echo "🚀 Deploying with docker compose..."
          docker compose down || true
          docker compose up -d --build
          docker ps
        '''
      }
    }

  } /* fin stages */

  /* Post */
  post {
    success {
      echo "✅ Pipeline completed successfully!"
    }
    failure {
      echo "❌ Pipeline failed! Check console logs and reports."
    }
    always {
      echo "🧹 Cleaning workspace..."
      cleanWs()
    }
  }
}
