#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource', 
    remote: 'https://github.com/michaelanunda/jenkins-shared-library', 
    credentialsId: ''
    ]
)

pipeline {
    agent any
    tools {
            maven 'maven-3.9'
          }
    environment {
            IMAGE_NAME = 'uba31/demo-app'
            IMAGE_TAG = 'java-maven-1.0'
            IMAGE_NAME_TAG = 'uba31/demo-app:java-maven-1.0'
          }
    stages {
        stage("build app") {
            steps {
                script {
                    echo "building application jar..."
                    buildJar()
                }
            }
        }
        stage("build image") {
            steps {
                script {
                    echo "building the docker image"
                    buildImage(env.IMAGE_NAME, env.IMAGE_TAG)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME, env.IMAGE_TAG)
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    echo 'deploying server-cmds.sh file to EC2...'
                    def shellCmd = "bash ./server-cmds.sh"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sshagent(['ec2-server-key']) {
                        sh """
                            scp -o StrictHostKeyChecking=no server-cmds.sh ec2-user@18.224.34.248:/home/ec2-user
                            scp -o StrictHostKeyChecking=no docker-compose.yaml ec2-user@18.224.34.248:/home/ec2-user
                            ssh -o StrictHostKeyChecking=no ec2-user@18.224.34.248 "${shellCmd}"
                        """
                    }
                }
            }
        }
    }   
  }
}