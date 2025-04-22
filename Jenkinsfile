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
                    echo 'deploying docker-compose.yaml file to EC2...'
                    def dockerComposeCmd = "docker-compose -f docker-compose.yaml up --detach"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sshagent(['ec2-server-key']) {
                        sh """
                            scp docker-compose.yaml ec2-user@3.149.4.132:/home/ec2-user '
                            ssh -o StrictHostKeyChecking=no ec2-user@3.149.4.132 "${dockerComposeCmd}"
                            '
                        """
                    }
                }
            }
        }
    }   
  }
}