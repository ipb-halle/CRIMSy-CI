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

cd "$DIR/crimsyplugins" 
docker build --pull -t ipbhalle/crimsyplugins .
docker push ipbhalle/crimsyplugins

cd "$DIR/crimsydb/bingo_pg12" 
docker build --pull -t ipbhalle/crimsydb:bingo_pg12 .
docker push ipbhalle/crimsydb:bingo_pg12
