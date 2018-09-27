#!/usr/bin/env groovy
pipeline {
    agent { label 'slave-D'}
    stages {
        stage('Checkout') {
            // Checkout files.
            steps {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: 'develop']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [], submoduleCfg: [],
                        userRemoteConfigs: [[
                            credentialsId: '598f3034-72d1-4716-a73b-a447667a5fde',
                            url: 'https://github.com/Vonage/stitch_iOS.git'
                        ]]
                    ])
            }
        }
        stage('Build') {
             steps {
                 //increase the version number
                sh 'cd ${WORKSPACE}/utils'
                sh 'LIB_VERSION=$(./increase_build_number.sh ${BUILD_NUMBER} | grep -v "ERROR")'
                sh 'echo LIB_VERSION="${LIB_VERSION}" >> ${WORKSPACE}/env.properties'

                //release a new version of the library
                sh 'cd ${WORKSPACE}/utils'
                sh './increase_build_number.sh ${BUILD_NUMBER}'
                sh './release_version.sh'
                sh 'git clean -xdf'
                sh 'rm -f env.properties'
                sh 'rm -f Podfile.lock'
                sh 'echo AUTHOR=`git --no-pager show -s --format="%an" $GIT_COMMIT` >> env.properties'
                sh 'echo COMPILED_BRANCH="${GIT_BRANCH##origin/}" >> env.properties'
                
                sh 'mkdir -p ${WORKSPACE}/DerivedData/${BUILD_NUMBER}'

                sh 'pod update'
                sh 'pod install'
                sh 'xcodebuild clean test -workspace Stitch_iOS.xcworkspace -scheme "StitchObjCTests" -enableCodeCoverage YES -derivedDataPath ${WORKSPACE}/DerivedData/${BUILD_NUMBER} -destination "OS=11.0,name=iPhone 8" 2>&1 | tee xcodebuild.log | ocunit2junit'
            }  
        }
        //stage('Invoke pipeline'){
        //    steps {
        //        script{
        //             build(job: "Android_VBS_Pipeline", wait: false)
        //        }
        //    }
        //}
    }
}  
