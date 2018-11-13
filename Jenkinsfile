#!/usr/bin/env groovy
pipeline {
    agent { label 'slave-D'}
    stages {
        stage('Invoke pipeline'){
            steps {
                script{
                     build(job: "Stitch_iOS", wait: false)
                }
            }
        }
    }
}  
