#!/bin/bash
# Script attempts to format properly the skinsdb meta to simple_skins
# Script removes all `;` which interfere with formspec generation

mkdir -p meta_fix
pushd meta
for f in ./*.txt; do
    sed -e '1s/^/name = "/;2s/^/author = "/;3s/^/license = "/;s/$/",/;s/\;//g' $f > ./../meta_new/$f
    
done
popd
