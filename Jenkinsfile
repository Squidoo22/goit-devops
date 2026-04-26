pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
    - name: git
      image: alpine/git
      command: ["cat"]       # keep it idle so Jenkins can exec into it
      tty: true
"""
    }
  }

  environment {
    ECR_REGISTRY = "253108853577.dkr.ecr.us-east-1.amazonaws.com"
    IMAGE_NAME   = "l9-ecr"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"

    COMMIT_EMAIL = "jenkins@localhost"
    COMMIT_NAME  = "jenkins"
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \\
              --context `pwd`/docker-django-app/django/ \\
              --dockerfile `pwd`/docker-django-app/django/Dockerfile \\
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \\
              --cache=true \\
              --insecure \\
              --skip-tls-verify
          '''
        }
      }
    }

    stage('Update Chart Tag in Git') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh '''
              git clone https://icodebits:$PASSWORD@github.com/icodebits/goit-devops.git
              cd goit-devops
              git checkout lesson-8-9
              cd charts/django-app

              sed -i "s/tag: .*/tag: $IMAGE_TAG/" values.yaml

              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"

              git add values.yaml
              git commit -m "Update image tag to $IMAGE_TAG"
              git push origin lesson-8-9
            '''
          }
        }
      }
    }
  }
}