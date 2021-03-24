#!/bin/sh
#
# Download data from pubchem
#
#
#
p=`realpath $0`
DIR=`dirname "$p"`

mkdir -p $DIR/../data
cd $DIR/../data

wget -r -c \
  --limit-rate=300k \
  -e robots=off \
  --wait 1 \
  https://ftp.ncbi.nlm.nih.gov/pubchem/Compound/CURRENT-Full/SDF/

#
# OTHER interesting URLS 
#
#  https://ftp.ncbi.nlm.nih.gov/pubchem/Compound/CURRENT-Full/SDF/
#  https://ftp.ncbi.nlm.nih.gov/pubchem/Compound/Extras/
#  https://ftp.ncbi.nlm.nih.gov/pubchem/RDF/bioassay/
#  https://ftp.ncbi.nlm.nih.gov/pubchem/RDF/concept/
#  https://ftp.ncbi.nlm.nih.gov/pubchem/RDF/synonym/
#  https://ftp.ncbi.nlm.nih.gov/pubchem/Substance/CURRENT-Full/SDF/
#  https://ftp.ncbi.nlm.nih.gov/pubchem/specifications/
#
