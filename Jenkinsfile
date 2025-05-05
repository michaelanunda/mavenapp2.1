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
    stages {
        stage('increment version') {
            steps {
                script {
                    incrementVersion()
                }
            }
        }
        stage("build app") {
            steps {
                script {
                    buildJar()
                }
            }
        }
        stage("build and push image") {
            steps {
                script {
                    buildImage(env.IMAGE_NAME_TAG)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME_TAG)
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    def shellCmd = "bash ./server-cmds.sh ${env.IMAGE_NAME_TAG}"
                    def ec2Instance = "ec2-user@18.118.208.195" //this needs to be changed every time the t4g nano instance is stopped, restarted (maybe???), or terminated then recreated again
                    def ec2Path = "/home/ec2-user"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sshagent(['ec2-server-key']) {
                        ec2Deploy(ec2Instance, shellCmd, ec2Path)
                    }
                }
            }
        }
    } 
    stage('commit and push changes') {
            steps {
                script {
                    commitAndPush(env.pomVersion)
                }
            }
        }  
  }
}