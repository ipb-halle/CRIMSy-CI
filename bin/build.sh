#!/bin/bash
#
# - refresh base images by pulling from docker hub
# - build and tag images locally
# - push built images  to docker hub
#
p=`dirname $0`
DIR=`realpath "$p/.."`

cleanup() {
    echo "build process has failed"
}

trap "cleanup; exit 1" ERR

cd "$DIR" 
# grep --include Dockerfile -rhE "^FROM " . | \
#   cut -d' ' -f2- | tr -d ' ' | sort | uniq | \
#   xargs -l1 docker pull 

cd "$DIR/crimsyplugins" 
docker build -t ipbhalle/crimsyplugins .
docker push ipbhalle/crimsyplugins

cd "$DIR/crimsydb/bingo_pg12" 
docker build -t ipbhalle/crimsydb:bingo_pg12 .
docker push ipbhalle/crimsydb:bingo_pg12
