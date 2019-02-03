nabla-base
==========

This is a common template or interface for you to start building your own nabla
container image.

Checkout [nabla containers](https://github.com/nabla-containers) and in
particular [runnc](https://github.com/nabla-containers/runnc).

### How to

In order to build a docker image for nabla containers, we have to build:

1. the nabla toolstack
2. the unikernel image
3. the docker image


#### Build the nabla toolstack

There's an informative blog post on how to build the nabla rumprun toolstack
[here](http://blog.cloudkernels.net/posts/building-nabla-aarch64/)


Alternatively you can use one of the (unofficial) docker images with the
toolstack embedded at /usr/local:

- [x86_64-rumprun-netbsd-](https://hub.docker.com/r/cloudkernels/debian-rumprun-build)
- [aarch64-rumprun-netbsd-](https://hub.docker.com/r/cloudkernels/debian-rumprun-build)

You can run these containers using the following command:

```
docker run --runtime=runc --rm -v ${PWD}:/build -it cloudkernels/debian-rumprun-build:${ARCH} /bin/bash
```

where ${ARCH} could be x86_64 or aarch64.


#### Build the unikernel Image

building the image is as easy as running the following:

```
${ARCH}-rumprun-netbsd-gcc myprog.c -o myprog-rumprun
```

```
rumprun-bake solo5-spt myprog.spt myprog-rumprun
```

So we have ourselves an .spt file (a unikernel). To try it out, assuming you
have a [solo5-spt](https://github.com/Solo5/solo5) binary lying around you can
do the following:

```
solo5-spt ./myprog.spt
```

Asumming the unikernel image is successful, its time to construct the docker image.

#### Build the docker image

Rumprun is a quirky unikernel framework, with a number of assumptions we can't
ignore. Thus, in order to get the unikernel running correctly when in a nabla
container environmnent, we need to be careful and include the correct stubs for
a dummy root filesystem. So, clone [this
repo](https://github.com/cloudkernels/nabla-base), which contains the basic
rootfs from rumprun's lib/librumprunfs_base/rootfs, and a template Dockerfile
shown below:

```
FROM scratch
COPY myprog.spt /myprog.nabla
COPY rootfs/etc /etc
ENTRYPOINT [ "myprog.nabla" ]
```

Copy the spt file in this directory and run:

```
docker build -f Dockerfile -t myprog-nabla:${ARCH} .
```

You should come up with a local docker image named myprog-nabla, tagged with
your current architecture variant (x86_64 or aarch64).

Assuming you have setup [runnc](https://github.com/nabla-containers/runnc)
correctly, spawning the container is as easy as:

```
docker run --rm --runtime=runnc myprog-nabla:${ARCH}
```
