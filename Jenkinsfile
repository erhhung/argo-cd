// groovylint-disable CompileStatic
// groovylint-disable NestedBlockDepth
// groovylint-disable DuplicateStringLiteral
// groovylint-disable GStringExpressionWithinString

// global shared library functions: defaultCheckout, withHarbor, bash
// https://github.com/erhhung/homelab-k8s/tree/main/files/jenkins/sharedlib

pipeline {
  agent { label 'builder' }

  options {
    skipDefaultCheckout()
  }
  environment {
    IMAGE_NAME = 'argocd'
    NAMESPACE  = 'argocd'
  }

  stages {
    stage('Setup') {
      steps {
        defaultCheckout()

        // inject Harbor credential
        // vars for `buildah_login`
        withHarbor {
          bash '''
          sys_info
          env_vars
          identities
          init_certs
          buildah_login
          '''
        }
      }
    }

    stage('Build') {
      steps {
        bash '''
        # `buildah_*` functions will emit section markers
        buildah_build $IMAGE_NAME --build-arg GIT_TAG=$GIT_COMMIT_SHORT_SHA --no-cache -f ./Dockerfile .
        buildah_push  $IMAGE_NAME $GIT_COMMIT_SHORT_SHA
        '''
      }
    }

    stage('Deploy') {
      steps {
        bash '''
        IMAGE="$CI_REGISTRY_PATH/$IMAGE_NAME:$GIT_COMMIT_SHORT_SHA"

        component='argocd-repo-server'
        section_start deploy "Deploy $component"
        set_k8s_image Deployment $NAMESPACE $component initContainer copyutil $IMAGE
        set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
        kubectl rollout restart Deployment -n $NAMESPACE $component
        section_end deploy

        component='argocd-applicationset-controller'
        section_start deploy "Deploy $component"
        set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
        kubectl rollout restart Deployment -n $NAMESPACE $component
        section_end deploy

        component='argocd-application-controller'
        section_start deploy "Deploy $component"
        set_k8s_image StatefulSet $NAMESPACE $component container ${component#argocd-} $IMAGE
        kubectl rollout restart StatefulSet -n $NAMESPACE $component
        section_end deploy

        component='argocd-notifications-controller'
        section_start deploy "Deploy $component"
        set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
        kubectl rollout restart Deployment -n $NAMESPACE $component
        section_end deploy

        component='argocd-commit-server'
        section_start deploy "Deploy $component"
        set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
        kubectl rollout restart Deployment -n $NAMESPACE $component
        section_end deploy

        component='argocd-server'
        section_start deploy "Deploy $component"
        set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
        kubectl rollout restart Deployment -n $NAMESPACE $component
        section_end deploy
        '''
      }
    }
  }
}
