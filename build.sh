#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
meson --prefix=/usr ./ build
sudo ninja -v install -C build
if [ $? -eq 0 ]; then
    echo "== LIB BUILD SUCCESS =="
    valac -v --pkg gee-0.8 --pkg pluie-echo-0.2 --pkg pluie-yaml-0.3 main.vala
    if [ $? -eq 0 ]; then
        echo "== BUILD SUCCESS =="
    else 
        echo "== BUILD FAILED =="
    fi
else
    echo "== LIB BUILD FAILED =="
fi
