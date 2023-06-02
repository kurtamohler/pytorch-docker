#!/bin/bash

if [ "$#" -ne "1" ]; then
  echo "usage: $0 <docker image ID>"
  exit 1
fi

IMAGE_ID="$1"

# TODO: Detect if multipy was cloned or not
docker run --gpus all --rm -ti --ipc=host -v $(pwd)/pytorch:/opt/pytorch -v $(pwd)/multipy:/opt/multipy -u $(stat -c "%u:%g" .) $IMAGE_ID
