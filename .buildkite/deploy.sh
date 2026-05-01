set -euo pipefail

IMAGE="$CI_REGISTRY_PATH/$IMAGE_NAME:$GIT_COMMIT_SHORT_SHA"

component='argocd-repo-server'
section_start "Deploy $component"
set_k8s_image Deployment $NAMESPACE $component initContainer copyutil $IMAGE
set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
kubectl rollout restart Deployment -n $NAMESPACE $component

component='argocd-applicationset-controller'
section_start "Deploy $component"
set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
kubectl rollout restart Deployment -n $NAMESPACE $component

component='argocd-application-controller'
section_start "Deploy $component"
set_k8s_image StatefulSet $NAMESPACE $component container ${component#argocd-} $IMAGE
kubectl rollout restart StatefulSet -n $NAMESPACE $component

component='argocd-notifications-controller'
section_start "Deploy $component"
set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
kubectl rollout restart Deployment -n $NAMESPACE $component

component='argocd-commit-server'
section_start "Deploy $component"
set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
kubectl rollout restart Deployment -n $NAMESPACE $component

component='argocd-server'
section_start "Deploy $component"
set_k8s_image Deployment $NAMESPACE $component container ${component#argocd-} $IMAGE
kubectl rollout restart Deployment -n $NAMESPACE $component
