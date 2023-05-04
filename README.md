## Installation

First, clone this repo:

```bash
git clone <url>
cd pytorch-docker
```

Next, run this script to clone your fork of PyTorch and checkout the branch you
want.

```bash
./clone-pytorch.sh git@github.com:kurtamohler/pytorch.git storage-pyobject-preservation-3
```

(Optional) Clone multipy

```bash
./clone-multipy.sh
```

Find the ID of the new docker image with:

```bash
docker images
```

Run the docker image:

```bash
./run-docker.sh <image ID>
```

Within the docker image, activate conda and then build PyTorch (TODO: Put this in a script, and use a flag for CUDA vs CPU-only):

```bash
conda init
bash
cd /opt/pytorch
```

Build with CUDA:

```bash
TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX 8.0" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" MAX_JOBS=8 python setup.py install
```

Build with CPU only (TODO: This doesn't work yet. After it's built, `import torch`
causes a segfault):

```bash
USE_CUDA=0 CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" MAX_JOBS=8 python setup.py install
```
