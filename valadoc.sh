#!/bin/bash
valadoc --package-name=pluie-yaml-0.4 --verbose --force --deps -o ./doc --pkg gee-0.8 --pkg gio-2.0 --pkg gobject-2.0 --pkg glib-2.0 --pkg pluie-echo-0.2 ./src/vala/Pluie/*.vala ./build/install.vala
rm doc/*.png
cp resources/doc-scripts.js ./doc/scripts.js
cp resources/doc-style.css ./doc/style.css

