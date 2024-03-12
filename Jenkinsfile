#!/usr/bin/env groovy
@Library('acdc') _

String imageName = 'labeler-service'
String dockerStagePath = 'server/target/docker/stage'

pipeline {

  agent {
    kubernetes {
      defaultContainer 'goldenalgo'
      yamlFile 'build.yaml'
    }
  }

  options {
    ansiColor('xterm')
    disableConcurrentBuilds(abortPrevious: true)
  }

  environment {
    FFPROBE_PATH = "/usr/bin/ffprobe"
    FFMPEG_PATH = "/usr/bin/ffmpeg"
  }

  stages {

    stage('Notify Stash build starting') {
      steps {
        echo "build is starting..."
        script {
          notifyBitbucket()
        }
      }
    }

    stage('Build & QA') {
      steps {
        sh 'npm install'
        sh 'sbt qa doc'
        step([$class: 'CoberturaPublisher', autoUpdateHealth: false,
              autoUpdateStability: false, coberturaReportFile: '**/cobertura.xml',
              failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0,
              onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
      }
    }

    stage('Build docker image') {
      when {
        branch "master"
      }
      steps {
        sh 'sbt clean docker:stage'
        container(name: 'kaniko') {
          sh """
          executor -c=$WORKSPACE/$dockerStagePath -f=$WORKSPACE/$dockerStagePath/Dockerfile --cleanup --no-push --destination image --tarPath image.tar
          """
        }
      }
    }

    stage("Vulnerability scan") {
      when {
        branch "master"
      }
      steps {
        sshagent(credentials: ['sofa-user-automation']) {
          container('trivy') {
            sh """
            set -e
            trivy --cache-dir .trivycache/ image --exit-code 0 --no-progress --input image.tar
            trivy --cache-dir .trivycache/ image --exit-code 1 --ignore-unfixed --severity CRITICAL --no-progress --input image.tar
            """
          }
        }
      }
    }

    stage('Publish docker image') {
      when {
        branch "master"
      }
      steps {
        sshagent(credentials: ['sofa-user-automation']) {
          container('trivy') {
            sh """
            set -e
            crane push image.tar registry-acdc.tools.msi.audi.com/$imageName:master
            """
          }
        }
      }
    }
  }

  post {
    always {
      script {
        currentBuild.result = currentBuild.result ?: 'SUCCESS'
        notifyBitbucket()
      }
    }
  }
}
