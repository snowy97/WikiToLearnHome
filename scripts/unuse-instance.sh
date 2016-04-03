#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "unuse-instance.sh" ]] ; then
    echo "Wrong way to execute unuse-instance.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

echo "Bringing down..."

if docker inspect wikitolearn-haproxy &> /dev/null ; then
    docker stop wikitolearn-haproxy
    docker rm wikitolearn-haproxy
fi