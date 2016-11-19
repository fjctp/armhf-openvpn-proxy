#!/bin/bash

echo "Start updating"
git pull
echo ""

if [ "$#" -ne 1 ]; then
  echo 'Please enter the image tag'
  exit
fi

IMAGE_TAG="$1"
echo "Start building image $IMAGE_TAG"
echo ""

docker build . -t $IMAGE_TAG
if [ -n "$(docker images -q --filter 'dangling=true')" ]; then 
  docker rmi $(docker images -q --filter 'dangling=true')
fi