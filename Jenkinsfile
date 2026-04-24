pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub_cred'
    }
    
    stages {
        stage('Clone Repo From GitHub') {
            steps {
                echo 'Cloning from Repo...'
                git url: 'https://github.com/skleak1/Assignment7.git', branch: 'main'
                echo 'Cloning Done'
            }
        }
        
        stage("Build Docker Image") {
            steps {
                echo 'Building Docker Image...'
                sh '''
                cd Website/
                docker build -t website .
                '''
                echo 'Build Complete'
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
                    docker tag website $DOCKER_USER/website:v1.0
                    docker push $DOCKER_USER/website:v1.0
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
                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} "
                        docker pull khingleak/website:v1.0 &&
                        docker stop app || true &&
                        docker rm app || true &&
                        docker run -d -p 80:80 --name app khingleak/website:v1.0
                    "
                    """
                }
            }
        }
    }
}