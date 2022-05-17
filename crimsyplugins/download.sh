#!/bin/sh
#
MOLPAINTJS_RELEASE=v0.3.5-alpha
OPENCHEMLIBJS_RELEASE=7.4.2
SPECKTACKLE_RELEASE=v0.0.5-ipb
OPENVECTOREDITOR_RELEASE=17.5.1
MINIPAINT_RELEASE=4.9.1

MOLPAINTJS_URL=https://github.com/ipb-halle/MolPaintJS/releases/download/$MOLPAINTJS_RELEASE
OPENCHEMLIBJS_URL=https://unpkg.com/openchemlib@$OPENCHEMLIBJS_RELEASE
SPECKTACKLE_URL=https://github.com/ipb-halle/specktackle/releases/download/$SPECKTACKLE_RELEASE
SPECKTACKLE_LICENSE_URL=https://raw.githubusercontent.com/ipb-halle/specktackle/$SPECKTACKLE_RELEASE
OPENVECTOREDITOR_URL=https://unpkg.com/open-vector-editor@$OPENVECTOREDITOR_RELEASE
MINIPAINT_URL=https://github.com/viliusle/miniPaint/archive/refs/tags/v$MINIPAINT_RELEASE

mkdir -p /tmp/plugins
cd /tmp/plugins

mkdir molpaintjs
curl -L --output molpaintjs/molpaint.js $MOLPAINTJS_URL/molpaint.js

mkdir openchemlibjs
curl -L --output openchemlibjs/openchemlib-full.js $OPENCHEMLIBJS_URL/dist/openchemlib-full.js
curl -L --output openchemlibjs/LICENSE $OPENCHEMLIBJS_URL/LICENSE

mkdir specktackle
curl -L --output specktackle/st.min.js $SPECKTACKLE_URL/st.min.js
curl -L --output specktackle/license.txt $SPECKTACKLE_LICENSE_URL/license.txt

mkdir openvectoreditor
curl -L --output openvectoreditor/open-vector-editor.min.js $OPENVECTOREDITOR_URL/umd/open-vector-editor.min.js
curl -L --output openvectoreditor/main.css $OPENVECTOREDITOR_URL/umd/main.css
curl -L --output openvectoreditor/LICENSE $OPENVECTOREDITOR_URL/LICENSE

curl -L --output miniPaint.tar.gz $MINIPAINT_URL.tar.gz

sha256sum -c - <<EOF || exit 1
580893aa3ad25abc2a78d3bee8ff14d2a9a4486e6d8df9291149f471e2c16791  molpaintjs/molpaint.js
fc3490f9a0612a3135a4f5c274dc0b079532b0dccd227159bbc6da4445adf6ae  openchemlibjs/openchemlib-full.js
38dc3aed3def8cc4dd15ac879daa4af9b0d71af86fef82611ca1752497c6f464  openchemlibjs/LICENSE
002f4c1871cb0c39a53f38a0350139aab385cade4e6e54bad339cc1ea429c70d  specktackle/st.min.js
da7eabb7bafdf7d3ae5e9f223aa5bdc1eece45ac569dc21b3b037520b4464768  specktackle/license.txt
a2b3a1a93b4dd545cc53c6060c95067b400772c67874617824c719df20ae70e3  openvectoreditor/open-vector-editor.min.js
4f036a3ec073af3a5dda67b5f2560e8d4686e87d4d6f264c96e3ec4f8a8247da  openvectoreditor/main.css
63274c0963ad116c21ca088c98387d132c232b7008c934449bf2c2977643bf0b  openvectoreditor/LICENSE
96213c861832946dedc2845c04965e186e69f0d0383f9c8d18fac88a9abc6dfe  miniPaint.tar.gz
EOF

# extract archive, rename directory
tar -xzf miniPaint.tar.gz
rm miniPaint.tar.gz
mv miniPaint-$MINIPAINT_RELEASE miniPaint

