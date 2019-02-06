pipeline {
    agent {label "slave-F"}

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {  
            steps {
                checkout scm
            }
        }

        stage ('Build & Unit Test') {
            steps {
                sh '''
                xcodebuild test -scheme NexmoClientTests -enableCodeCoverage YES -derivedDataPath ${WORKSPACE}/DerivedData/${BUILD_NUMBER} -destination "OS=12.1,name=iPhone X"
                '''
            }
        }

        stage ('Build Test app') {
            steps {
                sh 'xcodebuild -version -scheme NexmoTestApp'                
            }
        }       
    }
}
