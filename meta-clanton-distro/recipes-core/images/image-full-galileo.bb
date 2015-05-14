require image-full.bb

IMAGE_INSTALL += "galileo-target"
IMAGE_INSTALL += "mtd-utils-jffs2"
IMAGE_INSTALL += "quark-init"

#IMAGE_INSTALL += "xenomai"

IMAGE_INSTALL += "gcc"
IMAGE_INSTALL += "libgcc"
IMAGE_INSTALL += "pure-ftpd"
IMAGE_INSTALL += "eglibc-dev"
IMAGE_INSTALL += "autoconf"
IMAGE_INSTALL += "automake"
IMAGE_INSTALL += "binutils"
IMAGE_INSTALL += "gdb"

IMAGE_INSTALL += "libc-dev libstdc++-dev"
IMAGE_INSTALL += "libc6-dev"
IMAGE_INSTALL += "kernel-dev"

ROOTFS_POSTPROCESS_COMMAND += "install_sketch ; "

install_sketch() {
        install -d ${IMAGE_ROOTFS}/sketch
}
