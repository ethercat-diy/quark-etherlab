SUMMARY = "rtai"
DESCRIPTION = "rtai"
HOMEPAGE = "http://www.rtai.org"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://CREDITS;md5=7845f4d8e94ed36651ecff554dd2b0be"

SRC_URI = "https://www.rtai.org/userfiles/downloads/RTAI/rtai-4.0.tar.bz2"

#SRCREV = "a0919cd23c633b2087433dde1ae15f26cb293df8"

#EXTRA_OECONF = "--disable-smp --enable-x86-tsc --prefix=/usr/xenomai"


S = "${WORKDIR}/git"

do_configure() {
  ./configure --disable-smp --enable-x86-tsc --build=i686-linux --host=i586-poky-linux-uclibc --target=i586-poky-linux-uclibc
}
#--host etc. copied from autotool log

do_compile() {
  oe_runmake
}

do_install() {
  oe_runmake DESTDIR=${D} install
  rm -rf ${D}/usr/xenomai/share/doc
  rm -rf ${D}/usr/xenomai/lib/.debug
  rm -rf ${D}/usr/xenomai/sbin/.debug
}

PACKAGES = "${PN}-dbg ${PN} ${PN}-doc ${PN}-dev ${PN}-staticdev"
FILES_${PN}-dbg="/usr/xenomai/bin/.debug /usr/xenomai/sbin/.debug /usr/xenomai/lib/.debug /usr/xenomai/bin/regression/native/.debug /usr/xenomai/bin/regression/posix/.debug /usr/xenomai/bin/regression/native+posix/.debug /usr/src/debug"
FILES_${PN} = "/dev/rtp* /dev/rtheap /usr/xenomai/bin/* /usr/xenomai/sbin/* /usr/xenomai/lib/lib*.so.* /usr/xenomai/lib/posix.wrappers"
FILES_${PN}-doc = "/usr/xenomai/share/doc /usr/xenomai/share/man"
FILES_${PN}-dev = "/usr/xenomai/include /usr/xenomai/lib/lib*.so /usr/xenomai/lib/pkgconfig"
FILES_${PN}-staticdev = "/usr/xenomai/lib/*.la /usr/xenomai/lib/*.a"
