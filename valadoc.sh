#!/bin/bash
#^# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
#  @software    :    pluie-yaml       <https://git.pluie.org/pluie/lib-yaml>
#  @version     :    0.55
#  @type        :    library
#  @date        :    2018
#  @license     :    GPLv3.0          <http://www.gnu.org/licenses/>
#  @author      :    a-Sansara        <[dev]at[pluie]dot[org]>
#  @copyright   :    pluie.org        <http://www.pluie.org>
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  This file is part of pluie-yaml.
#
#  pluie-yaml is free software (free as in speech) : you can redistribute it
#  and/or modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation, either version 3 of the License,
#  or (at your option) any later version.
#
#  pluie-yaml is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with pluie-yaml.  If not, see  <http://www.gnu.org/licenses/>.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #^#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
lib="pluie-yaml-0.5"
cd $DIR
valadoc --package-name=$lib --verbose --force --deps -o ./doc --pkg gee-0.8 --pkg gio-2.0 --pkg gobject-2.0 --pkg gmodule-2.0 --pkg glib-2.0 --pkg pluie-echo-0.2 ./src/vala/Pluie/*.vala ./build/install.vala
if [ $? -eq 0 ]; then
    rm doc/*.png
    cp resources/doc-scripts.js ./doc/scripts.js
    cp resources/doc-style.css ./doc/style.css
    rm $lib.tar.gz
    tar -czvf $lib.tar.gz doc/
fi
