FROM scratch
COPY myprog.spt /myprog.nabla
COPY rootfs/etc /etc
ENTRYPOINT [ "myprog.nabla" ]
