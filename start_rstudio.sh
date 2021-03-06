#!/bin/bash
PWD=$(pwd)
repo=${PWD##*/}
dockerspace=larsvilhuber


case $USER in
  *vilhuber)
  #WORKSPACE=$HOME/Workspace/git
  WORKSPACE=$PWD
  # We need the Census API key for this one
  [[ -f .Renviron ]] && source .Renviron
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac
  
# build the docker if necessary

docker pull $dockerspace/$repo 
BUILD=no
arg1=$1

if [[ $? == 1 ]]
then
  ## maybe it's local only
  docker image inspect $dockerspace/$repo > /dev/null
  [[ $? == 0 ]] && BUILD=no
fi
# override
[[ "$arg1" == "force" ]] && BUILD=yes

if [[ "$BUILD" == "yes" ]]; then
DOCKER_BUILDKIT=1 docker build . -t $dockerspace/$repo
nohup docker push $dockerspace/$repo &
fi

set -ev
docker run -e PASSWORD=testing -v $WORKSPACE:/home/rstudio --rm -p 8787:8787 $dockerspace/$repo
