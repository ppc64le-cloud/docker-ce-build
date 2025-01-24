#!/bin/bash
# Script to get containerd repository if RUNC_VERSION is unspecified

set -o allexport
FILE_ENV="env.list"
source /workspace/${FILE_ENV}
if [[ -z ${CONTAINERD_RUNC_TAG} ]]; then    
    git clone --depth 1 --branch ${CONTAINERD_TAG} https://github.com/containerd/containerd.git
fi