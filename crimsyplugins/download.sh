#!/bin/sh
#
MOLPAINTJS_RELEASE=v0.3.5-alpha
OPENCHEMLIBJS_RELEASE=v7.2.3
SPECKTACKLE_RELEASE=v0.0.5-ipb

MOLPAINTJS_URL=https://github.com/ipb-halle/MolPaintJS/releases/download/$MOLPAINTJS_RELEASE
OPENCHEMLIBJS_URL=https://github.com/cheminfo/openchemlib-js/releases/download/$OPENCHEMLIBJS_RELEASE
SPECKTACKLE_URL=https://github.com/ipb-halle/specktackle/releases/download/$SPECKTACKLE_RELEASE

mkdir -p /tmp/plugins
cd /tmp/plugins

mkdir molpaintjs
curl -L --output molpaintjs/molpaint.js $MOLPAINTJS_URL/molpaint.js

mkdir openchemlibjs
curl -L --output openchemlibjs/openchemlib-full.js $OPENCHEMLIBJS_URL/openchemlib-full.js

mkdir specktackle
curl -L --output specktackle/st.min.js $SPECKTACKLE_URL/st.min.js

sha256sum -c - <<EOF
580893aa3ad25abc2a78d3bee8ff14d2a9a4486e6d8df9291149f471e2c16791  molpaintjs/molpaint.js
4c615e20509e3eb6c9a6c6c9591e6f36ad31d7c4f7e7a4c50fe4ceb7dc7cc411  openchemlibjs/openchemlib-full.js
002f4c1871cb0c39a53f38a0350139aab385cade4e6e54bad339cc1ea429c70d  specktackle/st.min.js
EOF

