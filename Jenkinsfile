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
                        // Wrap the shell commands in a multiline string, escaping EOF correctly
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@18.118.151.39 <<EOF
                            ${dockerCmdLogin} 
                            ${dockerCmdRun}
                            EOF
                        """
                        // Note: Using <<'EOF' instead of <<EOF prevents variable interpolation within the block
                        // If you want to allow interpolation, simply remove the single quotes around EOF
                        // Will need to edit the public ip of ec2-user every time the EC2 Instance has no elastic ip and is stopped or terminated and a new one is created
                    }
                }
            }
        }
    }   
 }
}