#
#  CRIMSy Containers
#  Copyright 2021 Leibniz-Institut f. Pflanzenbiochemie
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
# To build the image run "docker build -t crimsydb:postbis_pg12 ." in this directory
#
#
# STAGE 0
#
FROM postgres:12

# these statements must be on separate lines
ENV POSTBIS_REPO="https://github.com/no0p/postbis"
#
# install postgresql source repository
#
RUN set -x  \
 && echo "deb-src http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg-src.list \
 && apt-get update 

#
# install tools (git, make, ...) 
# install development tools
# clone postbis source code
# build and install 
# save artifacts in /opt/postbis for use in next stage

#
RUN set -x \
  && mkdir -p /opt/postbis \
  && cd /opt/postbis \
  && apt-get install -y --no-install-recommends ca-certificates git make \
  && apt-get install -y --force-yes --no-upgrade postgresql-server-dev-$PG_MAJOR "libpq5=$PG_MAJOR*" "libpq-dev=$PG_MAJOR*" \
  && apt-get build-dep -y --no-upgrade libpq-dev \
  && rm -rf /var/lib/apt/lists/* \
  && (ln -s  /usr/include/postgresql/$PG_MAJOR/server/libpq/md5.h  /usr/include/postgresql/$PG_MAJOR/server/common/md5.h \
    || echo "INFO: failed to create compatibility link - continuing") \
  && echo "INFO: Cloning PostBIS extension" \
  && git clone $POSTBIS_REPO \
  && cd /opt/postbis/postbis \
  && make 
#
#===================================================================
#
# STAGE 1
#
FROM postgres:12
LABEL maintainer="Frank Broda <fbroda@ipb-halle.de>"

COPY --from=0 /opt/postbis/postbis/postbis.so /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=0 /opt/postbis/postbis/postbis.control /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=0 /opt/postbis/postbis/sql/postbis--1.0.sql /usr/share/postgresql/$PG_MAJOR/extension/

#
# Steps to finalize the installation:
#
# su postgres psql %DATABASE% -f /opt/postbis/postbis--1.0.sql
#
#
