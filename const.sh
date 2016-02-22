#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

export W2L_DIR=$(pwd)
export W2L_CONFIG_FILE="./w2l.conf"
export W2L_REPO_DIR="./WikiToLearn"
export W2L_CONFIGS_DIR=$(pwd)'/configs/'

