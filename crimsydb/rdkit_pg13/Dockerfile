#
#  CCDBC
#  Combined Chemistry DataBase Cartridge
#
#  Copyright 2019 Leibniz-Institut f. Pflanzenbiochemie
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#====================================================================
#
# Docker container with PostgreSQL 13 and rdkit. Please use the following 
# rdkit into your database:
#
#   CREATE EXTENSION IF NOT EXISTS "rdkit";
#
# To build the image run "docker build -t crimsydb:rdkit_pg13 ." in this directory
#
# Acknowledgment:
# rdkit installation inspired by Tim Dudgeon <tdudgeon@informaticsmatters.com>
#
# Author: Frank Broda (fbroda@ipb-halle.de)
#
#
FROM postgres:13
LABEL maintainer="Frank Broda <fbroda@ipb-halle.de>"

# patch freetype issue 

# these statements must be on separate lines
ENV RDKIT_RELEASE=Release_2020_09_4 
ENV RDBASE=/opt/rdkit-$RDKIT_RELEASE 
ENV PYTHONPATH=$PYTHONPATH:$RDBASE \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RDBASE/lib:/usr/lib/x86_64-linux-gnu
#
# install postgresql source repository
#
RUN set -x  \
 && echo "deb-src http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg-src.list \
 && apt-get update \
 && apt-get install -y libboost-dev libboost-system-dev libboost-thread-dev libboost-serialization-dev \
 && apt-get install -y libboost-python-dev libboost-regex-dev libboost-iostreams-dev libfreetype6

#
# save installation state
# install tools (wget, unzip, cmake, ...) 
# install development tools
# build and install rdkit 
# purge unneeded packages / clean up (may be incomplete for RDKit)
#  && apt-get install -y postgresql-plpython-$PG_MAJOR postgresql-plpython3-$PG_MAJOR \
#
RUN set -x \
  && mkdir -p /opt/pgchem \
  && cd /opt/pgchem \
  && apt-mark showmanual > apt-mark.manual \
  && apt-get install -y --no-install-recommends ca-certificates wget unzip cmake zlib1g-dev apt-utils \
  && apt-get install -y --force-yes --no-upgrade postgresql-server-dev-$PG_MAJOR "libpq5=$PG_MAJOR*" "libpq-dev=$PG_MAJOR*" \
  && apt-get install -y python-numpy python-dev sqlite3 libsqlite3-dev libfreetype6-dev \
  && apt-get build-dep -y --no-upgrade libpq-dev \
  && rm -rf /var/lib/apt/lists/* \
  && (ln -s  /usr/include/postgresql/$PG_MAJOR/server/libpq/md5.h  /usr/include/postgresql/$PG_MAJOR/server/common/md5.h \
    || echo "INFO: failed to create compatibility link - continuing") \
  && NUMCPU=`lscpu -e | grep yes | wc -l` \
  && echo "INFO: Installing RDKit" \
  && cd /opt \
  && wget -O /opt/rdkit.zip https://github.com/rdkit/rdkit/archive/$RDKIT_RELEASE.zip \
  && unzip rdkit.zip \
  && mkdir -p $RDBASE/build \
  && cd $RDBASE \
  && cd $RDBASE/build \
  && cmake -DRDK_BUILD_INCHI_SUPPORT=ON -DRDK_BUILD_PGSQL=ON -DPostgreSQL_ROOT=/usr/lib/postgresql/$PG_MAJOR \
     -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/$PG_MAJOR/server -DPYTHON_EXECUTABLE=python3 .. \
  && make -j $NUMCPU \
  && make install \
  && sh ./Code/PgSQL/rdkit/pgsql_install.sh \
  && echo "INFO: Cleaning up" \
  && make clean \
  && cd $RDBASE \
  && rm -r Docs Code CTest* Regress Web build build_support rdkit-config* \
  && cd /opt/pgchem \
  && apt-mark showmanual | xargs -l1 apt-mark auto \
  && cat apt-mark.manual | xargs -l1 apt-mark manual \
  && apt-get purge -y --auto-remove \
  && cd /opt \
  && rm -r rdkit.zip 

