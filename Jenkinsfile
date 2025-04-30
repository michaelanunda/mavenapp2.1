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
                    env.IMAGE_TAG = IMAGE_TAG
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
                    def ec2Instance = "ec2-user@3.145.174.36" //this needs to be changed every time the t4g nano instance is stopped, restarted (maybe???), or terminated then recreated again
                    def ec2Path = "/home/ec2-user"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sshagent(['ec2-server-key']) {
                        ec2Deploy(ec2Instance, shellCmd, ec2Path)
                    }
                }
            }
        }
    }   
  }
}