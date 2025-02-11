pipeline {
    agent any

    stages {
        stage('Provision EC2 with Terraform') {
            steps {
                withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                    script {
                        sh '''
                        terraform init
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Retrieve EC2 Public IP') {
            steps {
                script {
                    def publicIp = sh(script: 'terraform output -raw public_ip', returnStdout: true).trim()
                    env.PUBLIC_IP = publicIp
                    echo "EC2 Public IP: ${env.PUBLIC_IP}"
                }
            }
        }

        stage('Install Nginx with Ansible') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ssh-private-key', keyFileVariable: 'SSH_KEY_FILE')]) {
                        sh '''
                        echo "SSH_KEY_FILE: ${SSH_KEY_FILE}"
                        ls -l ${SSH_KEY_FILE}
                        chmod 600 ${SSH_KEY_FILE}
                        ansible-playbook -i "${PUBLIC_IP}," -u ec2-user --private-key ${SSH_KEY_FILE} nginx.yml
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                sh 'terraform destroy -auto-approve'  // Clean up resources
            }
        }
    }
}