def gv

pipeline {
    agent any
    stages {
        stage("init") {
            steps {
                script {
                    gv = load "script.groovy"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    echo "building jar"
                    //gv.buildJar()
                }
            }
        }
        stage("build image") {
            steps {
                script {
                    echo "building image"
                    //gv.buildImage()
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                   withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        def dockerCmdLogin = "echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin"
                        def dockerCmdRun = 'docker run -p 3080:3080 -d uba31/demo-app:1.0'

                        sshagent(['ec2-server-key']) {
                        // Dynamic IP handling, e.g., using an environment variable or config.
                        def ec2Ip = '52.15.198.230' // Replace public IP of ec2 instance if not using an elastic ip

                        // Use multiline shell command with improved error handling
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${ec2Ip} <<EOF
                            sudo yum install -y docker
                            sudo service docker start
                            sudo usermod -aG docker $USER
                            docker --version
                            ${dockerCmdLogin}
                            ${dockerCmdRun}
                         EOF
                        """
                    }
                }
            }
        }
    }   
 }
}