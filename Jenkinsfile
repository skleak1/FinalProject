pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub_cred'
        SONAR_HOME = tool 'Sonar-Scan'
    }
    
    stages {
        stage('Clone Repo From GitHub') {
            steps {
                echo 'Cloning from Repo...'
                git url: 'https://github.com/skleak1/FinalProject.git', branch: 'main'
                echo 'Cloning Done'
            }
        }

        stage("Trivy Code Scan") {
            steps {
                sh '''
                docker run --rm \
                    -v $(pwd):/var/lib/jenkins/workspace/FinalProject/Node_API \
                    -v trivy-cache:/root/.cache/ \
                    aquasec/trivy:canary \
                    fs --exit-code 1 --severity HIGH,CRITICAL\
                        /var/lib/jenkins/workspace/FinalProject/Node_API
                '''
                echo 'Trivy Code Scan Complete'
            }
        }
        
        stage("Build Docker Image") {
            steps {
                echo 'Building Docker Image...'
                sh '''
                cd Node_API/
                docker build -t nodeapi .
                '''
                echo 'Build Complete'
            }
        }

        stage("Trivy Docker Image Scan") {
            steps {
                sh '''
                cd Node_API/
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock:ro \
                    -v trivy-cache:/root/.cache/ \
                    aquasec/trivy:canary \
                    image --exit-code 1 --severity HIGH,CRITICAL nodeapi:latest
                '''
                echo 'Trivy Docker Image Scan Complete'
            }
        }
        
        stage("Push Docker Image") {
            steps {
                echo 'Signing Into Docker Hub'
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS,
                                                    usernameVariable: 'DOCKER_USER',
                                                    passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    echo 'Signed into Docker Hub. Now Pushing Docker Image...'
                    sh '''
                    docker tag nodeapi $DOCKER_USER/nodeapi:v1.0
                    docker push $DOCKER_USER/nodeapi:v1.0
                    '''
                }
            }
        }
        
        stage("Create EC2 Instance from Terraform") {
            steps {
                echo 'Running Terraform'
                sh '''
                cd Terraform/
                terraform init
                terraform plan
                terraform apply -auto-approve
                '''
                echo 'Apply Complete'
            }
        }
        
        stage("Deploy Docker Image on EC2") {
            steps {
                script {
                    env.EC2_IP = sh(
                        script:'''
                        cd Terraform/ &&
                        terraform output -raw ec2_public_ip
                        ''',
                        returnStdout: true
                    ).trim()
                }
                
                sshagent(['my-ec2-key']) {
                    sh """
                    echo 'Waiting for EC2...'
                    sleep 60

                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} << EOF
                        if lsof -i:5000 -t >/dev/null; then
                            sudo fuser -k 5000/tcp
                        fi

                        sudo usermod -aG docker ubuntu
                        sudo chmod 777 /var/run/docker.sock
                        docker pull khingleak/nodeapi:v1.0
                        docker stop app || true
                        docker rm app || true
                        docker run -d -p 5000:5000 --name app khingleak/nodeapi:v1.0
                    EOF

                    echo 'Deployment Complete'
                    """
                }
            }
        }

        stage("Setup Prometheus and Grafana") {
            steps {
                sshagent(['my-ec2-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} << EOF
                        sudo chmod +x /usr/local/bin/docker-compose
                        cd EC2-Monitor-Grafana-Prometheus
                        sudo docker-compose -f build-process/docker-compose.yml up -d --build
                    EOF

                    echo 'Prometheus and Grafana Setup Complete'
                    """
                }
            }
        }
    }
}
