pipeline {
    agent {
        docker {
          label 'docker'
          image 'thinkahead/aws-vsphere-ws-byol:ansible2.7'
          args '-u root --privileged'
        }
    }
    environment {
        vda = "VDAServerSetup_1906.exe"
        vdacontrollers = "ctxlicense-0.lab.local"
        client_id = credentials('client_id')
        client_secret = credentials('client_secret')
        subid = credentials('subid')
        tenantid = credentials('tenantid')
        rgname = "packer"
        storage_account = credentials('storage_account')
        mycitrix = credentials('mycitrix')

        //verbose logging
        PACKER_LOG = 1
    }
    stages {
        stage('Build Windows Image') {
            steps {
                timeout(time: 3, unit: 'HOURS')
                {
                    sh '''
                    packer build -color=false -machine-readable ./windows2016vda.json
                    '''
                }
            }
        }
        stage('Create Artifacts') {
            steps{
                archiveArtifacts artifacts: 'hotfix.json', fingerprint: true
                archiveArtifacts artifacts: 'package.json', fingerprint: true
            }
        }
    }
    post {
        success {
                echo "Sucess!"
                slackSend color: 'good', message: "${env.JOB_NAME} has COMPLETED for job ${env.BUILD_NUMBER}! (<${env.BUILD_URL}|Open>)"
        }
        failure {
                echo "Job failed"
                slackSend color: 'danger', message: "${env.JOB_NAME} has FAILED! (<${env.BUILD_URL}|Open>)"
        }
        always {
            //workaround for cleanup due to docker root
            sh "chmod -R 777 ."
            cleanWs()
        }
    }
}