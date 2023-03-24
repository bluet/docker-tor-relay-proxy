#!/bin/bash

VERSION=0.1.`date +%s`

docker build --pull -t bluet/tor-relay-proxy .
docker scan bluet/tor-relay-proxy:latest

docker tag bluet/tor-relay-proxy:latest bluet/tor-relay-proxy:v${VERSION}

while true; do
        read -p "Add new git tag v${VERSION} and push? (Have you git add and git commit already?) [y/N]" yn
        case $yn in
                [Yy]* ) git tag "v${VERSION}" -a -m "v${VERSION}" && git push && git push --tags; break;;
                [Nn]* ) exit;;
                * ) echo "";;
        esac
done

# git tag "v${VERSION}" -a -m "v${VERSION}"
# git push
# git push --tags

# Fixes busybox trigger error https://github.com/tonistiigi/xx/issues/36#issuecomment-926876468
docker run --privileged -it --rm tonistiigi/binfmt --install all

docker buildx create --use

while true; do
        read -p "Have I Updated VERSION Info? (Is current VERSION=${VERSION} ?) [y/N]" yn
        case $yn in
                [Yy]* ) docker buildx build -t bluet/tor-relay-proxy:latest -t bluet/tor-relay-proxy:${VERSION} --platform linux/amd64,linux/arm64/v8 --pull --push .; break;;
                [Nn]* ) exit;;
                * ) echo "";;
        esac
done
