#!/bin/sh

# Copyright(c) 2013 Intel Corporation. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Krzysztof.M.Sywula@intel.com

set -e

do_local_conf () {
  cat > $yocto_conf_dir/local.conf <<EOF

BB_NUMBER_THREADS = "12"

PARALLEL_MAKE = "-j 14"

MACHINE = "clanton"
DISTRO ?= "clanton-full"
EXTRA_IMAGE_FEATURES = "debug-tweaks"
USER_CLASSES ?= "buildstats image-mklibs image-prelink"
PATCHRESOLVE = "noop"
CONF_VERSION = "1"
EOF
}

do_bblayers_conf () {
  cat > $yocto_conf_dir/bblayers.conf <<EOF	
# LAYER_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
LCONF_VERSION = "6"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""
BBLAYERS ?= " \\
  $poky_dir/meta \\
  $poky_dir/meta-yocto \\
  $poky_dir/meta-yocto-bsp \\
  $metaintel_dir \\
  $metaoe_dir \\
  $my_dir/meta-clanton-distro \\
  $my_dir/meta-clanton-bsp \\
  $my_dir/meta-oe/meta-networking \\
EOF

  for item in $EXTRA_LAYERS; do
  cat >> $yocto_conf_dir/bblayers.conf <<EOF
  $my_dir/$item \\
EOF
done

  cat >> $yocto_conf_dir/bblayers.conf <<EOF
  "
EOF
}

do_git() {
  setup/gitsetup.py -c setup/$1.cfg -w $1
}

usage()
{
    cat <<EOFHELP
Usage: $0 [-e layer|-h] 
  For this help use $0 -h
  In order to create default BSP image:
  $0
  For customized image with additional layers, e.g.:
  $0 -e meta-clanton-dev
  
  Possible additional layers are:
EOFHELP
ls | grep "meta-.*" | egrep -h -v "meta-clanton-bsp|meta-clanton-distro|meta-intel" | sed 's/^/    /'
}

parse_opts() {
  OPTIND=1 # Reset in case getopts has been used previously in the shell.
  while getopts "he:" opt; do
    case "$opt" in
      \?) # invalid option
          usage
          exit 1
          ;;
      h)
         usage
         exit 0
         ;;
      e)
         EXTRA_LAYERS="$OPTARG"
        ;;
    esac
  done

  # shift $((OPTIND-1))
}

do_patchheartbleed() {
  # Apply heartbleed patches for openssl available in
  # v1.4.4 on top of v1.4.2 poky distro used in Quark
  cd poky
  git remote add yp-poky git://git.yoctoproject.org/poky
  git fetch yp-poky
  git cherry-pick -x 15063788eb302e87ba5baae5ccf0d9b8a9d97357^..e55ac718a5d5f9e1546ef5ae7dd1a2c77485daa8
  cd ../
}

do_patchexcludegoogle() {
  #google code can't be acquired in some area ,so exclude it (cxmicrowave)
  patch meta-oe/meta-oe/recipes-multimedia/libav/libav.inc < setup/PatchExcludeLibvpx.patch
}

main() {
  my_dir=$(dirname $(readlink -f $0))
  metaintel_dir=$my_dir/meta-intel
  poky_dir=$my_dir/poky
  metaoe_dir=$my_dir/meta-oe/meta-oe
  yocto_conf_dir=$my_dir/yocto_build/conf

  parse_opts "$@"

  do_git poky
  do_git meta-intel
  do_git meta-oe

  mkdir -p $yocto_conf_dir
  do_bblayers_conf
  do_local_conf
  do_patchheartbleed

  do_patchexcludegoogle
}

main "$@"
