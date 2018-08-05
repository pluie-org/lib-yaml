#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
#  @version   : 0.3
#  @date      : 2018
#  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
#  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
#  @copyright : pluie.org   <http://www.pluie.org/>
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  This file is part of lib-yaml.
#  
#  lib-yaml is free software (free as in speech) : you can redistribute it
#  and/or modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation, either version 3 of the License,
#  or (at your option) any later version.
#  
#  lib-yaml is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with lib-yaml.  If not, see <http://www.gnu.org/licenses/>.
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#

# --------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
lib="pluie-yaml-0.4"
 c1="\033[1;38;5;215m"
 c2="\033[1;38;5;97m"
cok="\033[1;38;5;37m"
cko="\033[1;38;5;204m"
off="\033[m"
resume=
# --------------------------------------------------------
function build.title()
{
    local     s="$cko>"
    local    c3=""
    local state=""
    if [ ! -z "$2" ]; then
        state="${cko}FAILED"
        if [ $2 -eq 0 ]; then
            state="${cok}SUCCESS"
        fi
        s="$cko<"
    fi
    if [ ! -z $3 ]; then
        echo -e " |- $state $c1$1 $off"
    else
        echo -e "\n   $s $c1[$c2$1$c1] $state$off"
    fi
}
# --------------------------------------------------------
function build.lib()
{
    cd "$DIR"
    build.title "$lib LIB BUILD"
    echo
    meson --prefix=/usr ./ build
    sudo ninja -v install -C build
    local    rs=$?
    build.title "$lib LIB BUILD" $rs
    return $rs
}
# --------------------------------------------------------
function build.samples()
{
    for file in ./samples/*.vala
    do
        if [[ -f $file ]]; then
            build.sample "$file"
        fi
    done
    echo -e "\n RESUME : "
    for t in $resume; do
        build.title "${t:1}" ${t:0:1} 1
    done
    echo -e " binary files are located in ./bin ($DIR)"
}
# --------------------------------------------------------
function build.sample()
{
    local     f="$(basename $1)"
    local    fx="${f:0:-5}"
    local state="FAILED"
    local   cmd="valac -v --pkg gee-0.8 --pkg pluie-echo-0.2 --pkg $lib $1 -o ./bin/$fx"
    build.title "$f SAMPLE BUILD"
    echo -e "\n$cmd"
    $cmd
    local done=$?
    resume="$resume$done$f "
    build.title "$f SAMPLE BUILD" $done
}
# --------------------------------------------------------
function build.main()
{
    build.lib
    if [ $? -eq 0 ]; then
        build.samples
    fi
}

build.main
