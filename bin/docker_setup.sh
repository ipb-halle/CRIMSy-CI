#!/bin/bash
#
# start a ccdbc docker container, create an empty database 
# and load the database cartridges.
#
# - mount an external volume for the database
# - expose port 5432 for the database
#
# Test setup:
# - Intel(R) Core(TM) i5-3570K CPU @ 3.40GHz 
# - 16 GiByte (phys), 4 GiByte (virt)
# - openSUSE 15.2 (phys), VMware 15.5.6 / Debian 10 [buster] (virt) 
# - 1.7 TByte ZFS [mirror, arc_max = 4 GiByte,  2x WDC WD20EZRX-00D] (phys)
# - database on 60 GByte ext4 (virt)
#
# Performance:
# - approx. 2 GByte per 100k compounds
# - approx. 140 insertions per second 
#
#
# Notes:
# - RDKit release 2020_09_4 cannot handle molecules like BrF3
#

docker run --detach \
        --env "POSTGRES_PASSWORD=test" \
	--env "PGDATA=/data" \
        --name test \
        -p 5432:5432 \
        --volume /data/ccdbc:/data \
        ccdbc:pg11

cat <<EOF | docker exec -i test su postgres
sleep 5
echo "setting up database"
cat <<SQL_END | psql 
CREATE USER test WITH NOCREATEDB NOCREATEROLE PASSWORD 'test' ;
CREATE DATABASE test WITH ENCODING 'UTF8' OWNER test;
\\connect test
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgchem_tigress";
CREATE EXTENSION IF NOT EXISTS "rdkit";
\\q
SQL_END
exit
EOF
