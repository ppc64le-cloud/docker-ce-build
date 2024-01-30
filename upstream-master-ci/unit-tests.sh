apt-get -y update && apt-get -y upgrade && apt-get -y install sudo iptables wget

# Install Go
wget https://golang.org/dl/go1.21.5.linux-ppc64le.tar.gz
tar -C /usr/local -xzf go1.21.5.linux-ppc64le.tar.gz
export PATH=/usr/local/go/bin:$PATH

mkdir makebundles && cd makebundles
git clone https://github.com/moby/moby.git
pushd moby
export GIT_COMMIT=$(git rev-list -n 1 HEAD)
export GIT_URL="https://github.com/moby/moby.git"
make binary dynbinary build run shell
docker run --rm -t --privileged \
                                  -v "$WORKSPACE/bundles:/go/src/github.com/docker/docker/bundles" \
                                  --name dockerbuildimage \
                                  -e DOCKER_EXPERIMENTAL \
                                  -e DOCKER_GITCOMMIT=${GIT_COMMIT} \
                                  -e DOCKER_GRAPHDRIVER \
                                  -e VALIDATE_REPO=${GIT_URL} \
                                  dockerbuildimage \
                                  hack/test/unit
exit 0