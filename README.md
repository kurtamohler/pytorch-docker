# pytorch-docker

This project creates a [Docker](https://www.docker.com/) image that can build
[PyTorch](https://github.com/pytorch/pytorch) from source.

The Docker image can also build [MultiPy](https://github.com/pytorch/multipy),
enabling you to make local changes to PyTorch or MultiPy and test them
together.

## Prerequisites

[Docker](https://www.docker.com/) is required.

## Build

### Clone this repo

```bash
git clone git@github.com:kurtamohler/pytorch-docker.git
cd pytorch-docker
```

### Clone your fork of PyTorch

This script clones your fork of PyTorch into the `pytorch-docker` source tree
and checks out the branch you want.

```bash
./clone-pytorch.sh <pytorch fork url> <pytorch branch>
```

### (Optional) Clone MultiPy

This clones MultiPy into the `pytorch-docker` source tree and checks out the
commit that corresponds with your PyTorch branch.

```bash
./clone-multipy.sh
```

### Build the Docker image

```bash
make -f docker.Makefile
```

### Run the Docker image


Find the ID of the new docker image with:

```bash
docker images
```

Then run the docker image.

```bash
./run-docker.sh <image ID>
```

NOTE: If the above fails with a message like "could not select device driver
... [[gpu]]", then you may need to install your distribution's
"nvidia-container-toolkit" package. For apt: `apt install nvidia-container-toolkit`

Within the docker image, activate conda. (TODO: Avoid needing to do this explicitly)

```bash
conda init
bash
```

### Build PyTorch

NOTE: You can change the `MAX_JOBS` argument to change the number of CPU cores
that the build process will use.

```bash
cd /opt/pytorch
TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX 8.0" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" MAX_JOBS=8 python setup.py install
```

### (Optional) Build MultiPy

```bash
cd /opt/multipy
python multipy/runtime/example/generate_examples.py
pip install -e . --install-option="--cudatests"
```

You can now run the MultiPy tests against your PyTorch build. For it to run
properly, you have to be in the `/opt/multipy` directory.

```bash
./multipy/runtime/build/test_deploy
```

NOTE: If you ever rebase your PyTorch checkout or switch to another commit, you may
have to resynchronize MultiPy with it by checking out the expected commit. Otherwise,
building MultiPy may fail.

```bash
git pull
git checkout $(cat ../pytorch/.github/ci_commit_pins/multipy.txt)
```

NOTE: If you make any changes to MultiPy or PyTorch, you need to delete the
runtime build directory in multipy before rebuilding MultiPy, like so:

```bash
rm -rf /opt/multipy/multipy/runtime/build
```
