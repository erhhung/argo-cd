set -euo pipefail

buildah_login
buildah_build $IMAGE_NAME --build-arg GIT_TAG=$GIT_COMMIT_SHORT_SHA --no-cache -f ./Dockerfile .
buildah_push  $IMAGE_NAME $GIT_COMMIT_SHORT_SHA
