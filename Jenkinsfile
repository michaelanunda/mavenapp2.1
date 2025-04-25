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
          }
    stages {
        stage("set image tag") {
            steps {
                script {
                    IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG = "java-maven-${env.IMAGE_TAG}"
                    env.IMAGE_NAME_TAG = "${env.IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
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
                    def shellCmd = "bash ./server-cmds.sh ${env.IMAGE_NAME_TAG}"
                    def ec2Instance = "ec2-user@3.141.25.161"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sshagent(['ec2-server-key']) {
                        sh """
                            scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user
                            scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user
                            ssh -o StrictHostKeyChecking=no ${ec2Instance} "${shellCmd}"
                        """
                    }
                }
            }
        }
    }   
  }
}