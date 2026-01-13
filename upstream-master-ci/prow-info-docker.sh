#!/bin/bash
set -u

# Path to the scripts
PATH_CI="${PWD}/upstream-master-ci"
export PATH_CI
DATE=`date +%d%m%y-%H%M`

REPO_OWNER="ppc64le-cloud"
REPO_NAME="docker-ce-build"
PATH_SCRIPTS="/home/prow/go/src/github.com/${REPO_OWNER}/${REPO_NAME}"
echo DATE=\"${DATE}\" 2>&1 | tee ${PATH_SCRIPTS}/env/date.list

echo "Prow Job to check the kernel's configuration as a part of CI checks"

${PWD}/dockerctl.sh start

# Get the env files
echo "** Set up (env files) **"
chmod ug+x ${PATH_CI}/get-env-ci.sh && ${PATH_CI}/get-env-ci.sh

echo "*** Check Kernel Config ***"
chmod ug+x ${PATH_CI}/info.sh
${PATH_CI}/info.sh
REPO_OWNER=ppc64le-cloud
REPO_NAME=docker-ce-build
TRACKING_REPO=${REPO_OWNER}/${REPO_NAME}
TRACKING_BRANCH=prow-job-tracking
FILE_TO_PUSH=job/${JOB_NAME}

if [[ $? == 0 ]]; then 
    chmod ug+x ./trigger-prow-job-from-git.sh
    ./trigger-prow-job-from-git.sh -r ${TRACKING_REPO} \
    -b ${TRACKING_BRANCH} -s ${PWD}/env/date.list -d ${FILE_TO_PUSH}
    if [[ $? != 0 ]]; then
        echo "Failed to add the git commit to trigger the next job"
        exit 3
    fi
else
    if [[ $? == 1 ]]; then
        echo "Error checking the kernel configuration"
    else
        echo "Could not create a logging directory for storing the job logs"
    fi
    exit 1
fi
