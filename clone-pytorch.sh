#!/bin/bash

if [ "$#" -ne "2" ]; then
    echo "usage: $0 <pytorch fork url> <branch name>"
    exit 1
fi

set -e

PYTORCH_FORK_URL="$1"
BRANCH="$2"

git clone $PYTORCH_FORK_URL pytorch

pushd pytorch

git remote add upstream git@github.com:pytorch/pytorch.git
git fetch upstream


git checkout $BRANCH
git submodule sync --recursive
git submodule update --init --recursive

popd
