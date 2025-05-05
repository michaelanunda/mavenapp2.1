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
    // environment {
    //         IMAGE_NAME = 'uba31/demo-app'
    //       }
    stages {
        // stage("set image tag") {
        //     steps {
        //         script {
        //             IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        //             env.IMAGE_TAG = IMAGE_TAG
        //             env.IMAGE_NAME_TAG = "${env.IMAGE_NAME}:${IMAGE_TAG}"
        //         }
        //     }
        // }
        stage('increment version') { // Nana's approach
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.pomVersion = "${version}"
                    env.IMAGE_NAME = "uba31/demo-app"
                    env.IMAGE_TAG = "${version}-${env.BUILD_NUMBER}"
                    env.IMAGE_NAME_TAG = "${env.IMAGE_NAME}:${env.IMAGE_TAG}"
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
                    buildImage(env.IMAGE_NAME_TAG)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME_TAG)
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    echo 'deploying server-cmds.sh file to EC2...'
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
                    echo 'Committing and pushing the changes made to pom.xml in git'
                    
                    // Configure Git with Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                        sh """
                            git config --global user.name 'Jenkins'
                            git config --global user.email 'jenkins@example.com'
                            git status
                            git branch
                            git config --list
                            git add .
                            git commit -m "Incremented version of pom.xml to ${env.pomVersion}"
                            git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/michaelanunda/mavenapp2.1.git HEAD:starting-code
                        """
                    }
                }
            }
        }  
  }
}