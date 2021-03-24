#
# CRIMSy plugins HTTP Server
# (c) 2021 Frank Broda
#
# docker build -f Dockerfile -t crimsyplugins .
#
#
FROM curlimages/curl

COPY download.sh /
RUN /download.sh

FROM httpd 

#
RUN rm -rf /usr/local/apache2/htdocs/*
RUN mkdir -p /usr/local/apache/htdocs/plugins
COPY --from=0 /tmp/plugins /usr/local/apache2/htdocs/plugins
