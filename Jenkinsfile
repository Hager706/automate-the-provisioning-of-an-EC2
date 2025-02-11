// pipeline {
//     agent any
    
//     environment {
//         AWS_ACCESS_KEY_ID     = credentials('aws-access-key')  
//         AWS_SECRET_ACCESS_KEY = credentials('aws-access-key')
//         AWS_REGION            = "us-east-1"
//         SSH_KEY_PATH          = "~/.ssh/my-key.pem"
//     }

//     stages {
//         stage('Checkout Code') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/Hager706/Terraform-Ansible-AWS.git'
//             }
//         }

//         stage('Provision EC2 with Terraform') {
//             steps {
//                 script {
//                     sh '''
//                     cd terraform
//                     terraform init
//                     terraform apply -auto-approve
//                     '''
//                 }
//             }
//         }

//         stage('Fetch EC2 IP') {
//             steps {
//                 script {
//                     def instanceIP = sh(script: "cd terraform && terraform output -raw instance_ip", returnStdout: true).trim()
//                     writeFile file: "inventory.ini", text: """
//                     [nginx]
//                     ${instanceIP} ansible_user=ec2-user ansible_ssh_private_key_file=${SSH_KEY_PATH}
//                     """
//                 }
//             }
//         }

//         stage('Install Nginx using Ansible') {
//             steps {
//                 script {
//                     sh '''
//                     cd ansible
//                     ansible-playbook -i inventory.ini install_nginx.yml
//                     '''
//                 }
//             }
//         }
//     }

//     post {
//         success {
//             echo "EC2 provisioned and Nginx installed successfully!💃"
//         }
//         failure {
//             echo "Pipeline failed!🙂💔"
//         }
//     }
// }

pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-access-key')
        SSH_PRIVATE_KEY       = credentials('ssh-private-key')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Provision EC2 with Terraform') {
            steps {
                script {
                    sh '''
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Retrieve EC2 Public IP') {
            steps {
                script {
                    def instanceIP = sh(script: 'terraform output -raw instanceIP', returnStdout: true).trim()
                    env.PUBLIC_IP = instanceIP
                    echo "EC2 Public IP: ${env.PUBLIC_IP}"
                }
            }
        }

        stage('Install Nginx with Ansible') {
            steps {
                script {
                    sh '''
                    echo "${SSH_PRIVATE_KEY}" > /tmp/ssh_key.pem
                    chmod 600 /tmp/ssh_key.pem
                    ansible-playbook -i "${env.PUBLIC_IP}," -u ec2-user --private-key /tmp/ssh_key.pem nginx.yml
                    '''
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
            sh 'terraform destroy -auto-approve'  // Clean up resources
        }
    }
}