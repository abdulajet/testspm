pipeline {//node('iOS Node') {
    agent { label 'slave-D'}

    stage('Checkout') {
         // Checkout files.
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
        // Build
        sh 'xcodebuild clean test -workspace Stitch_iOS.xcworkspace -scheme "StitchObjCTests" -enableCodeCoverage YES -derivedDataPath ${WORKSPACE}/DerivedData/${BUILD_NUMBER} -destination "OS=11.0,name=iPhone 8" 2>&1 | tee xcodebuild.log | ocunit2junit'
    }    
}