#!/bin/bash

TOR_VERSION=$(wget -q https://gitweb.torproject.org/tor.git/plain/ReleaseNotes -O - | grep -E -m1 '^Changes in version\s[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\s' | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*[\s]*\).*$/\1/')
VERSION=${TOR_VERSION}-$(date +%Y%m%d-%H%M%S)

docker build --pull -t bluet/tor-relay-proxy .
docker scan bluet/tor-relay-proxy:latest

docker tag bluet/tor-relay-proxy:latest bluet/tor-relay-proxy:${VERSION}

# ask for confirmation to push. looping unless y or n is entered
while true ; do
        read -p "Add new git tag ${VERSION} and push? (Have you git add and git commit already?) [y/N]" yn
        case $yn in
                [Yy]* ) git tag "${VERSION}" -a -m "${VERSION}" && git push && git push --tags; break;;
                * ) break;;
        esac
done

# Fixes busybox trigger error https://github.com/tonistiigi/xx/issues/36#issuecomment-926876468
while true ; do
        read -p "Build for multi-platform and push? (Have I Updated VERSION Info? Is the latest VERSION=${VERSION} ?) [y/N]" yn
        case $yn in
                [Yy]* ) docker run --privileged -it --rm tonistiigi/binfmt --install all \
                        && docker buildx create --use \
                        && time docker buildx build -t bluet/tor-relay-proxy:latest -t bluet/tor-relay-proxy:${VERSION} --platform linux/amd64,linux/arm64/v8,linux/386,linux/arm/v6,linux/arm/v7,linux/ppc64le,linux/s390x --pull --push .; break;;
                * ) break;;
        esac
done
