#!/bin/bash

set -e

MULTIPY_COMMIT=$(cat pytorch/.github/ci_commit_pins/multipy.txt)

git clone --recurse-submodules https://github.com/pytorch/multipy.git

pushd multipy
git checkout $MULTIPY_COMMIT
popd
