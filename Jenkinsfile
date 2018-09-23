pipeline {
    agent { label 'slave-D'}
        
    stages {
        stage ('build') {
            steps{
                checkout scm
                sh "git config --list"
                sh "mkdir -p ${WORKSPACE}/DerivedData/${BUILD_NUMBER}"
                sh "pod update"
                sh "pod install"
                sh "xcodebuild -version"
                sh "xcodebuild clean test -workspace Stitch_iOS.xcworkspace -scheme StitchObjCTests -enableCodeCoverage YES -derivedDataPath ${WORKSPACE}/DerivedData/${BUILD_NUMBER} -destination 'OS=11.0,name=iPhone 8' 2>&1 | tee xcodebuild.log | ocunit2junit"

            }
        }

        stage ('test') {
            steps {
            }
            post {
                always {
                }
            }
        }

        stage ('code coverage') {
            steps {
        }
        stage ('Sonar Scanner') {
            steps {
                tool name: 'Sonar Scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                withSonarQubeEnv('CI-Sonar') {
                sh "/opt/sonar-runner/bin/sonar-scanner"
                }
            }
        }
    }
}