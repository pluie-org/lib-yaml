#!/bin/bash
# --------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
lib="pluie-yaml-0.3"
 c1="\033[1;38;5;215m"
 c2="\033[1;38;5;97m"
cok="\033[1;38;5;37m"
cko="\033[1;38;5;204m"
off="\033[m"
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
    echo -e "\n   $s $c1[$c2$1$c1] $state$off"
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
    echo
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
    build.title "$f SAMPLE BUILD" $?
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
