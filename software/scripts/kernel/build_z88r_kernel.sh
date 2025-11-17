#!/bin/sh

# The kernel this script currently produces doesn't drive the MIPI
# screen correctly. It looks like it should, and there are no errors
# anywhere, but the screen doesn't come on. Needs investigation.
# I moved on.

exit 255



# Patch and cross compile the Raspberry Pi kernel for the Z88R project.
#
# See this page:
# https://www.raspberrypi.com/documentation/computers/linux_kernel.html
# for the gist of what's going on.
#
# Instructions:
#
# Essentially, clone the Pi kernel project:
#
#  git clone --depth=1 https://github.com/raspberrypi/linux
#
# Change into the root of that subdirectory:
#
#  cd linux
#
# Then run this script from that location:
#
#  /path/to/this/script/build_z88r_kernel.sh

echo "Script to patching and build Raspberry Pi kernel for Z88R project"
echo "Running from \"`pwd`\""

# Path to this script, resources are relative to this
#
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ ! -d arch ]; then
    echo "This doesn't appear to be a Linux source tree. (Missing \"arch/\" directory.) Exit."
    exit 255
fi

# Find the patch file
#
PATCH_FILE="$SCRIPT_DIR/rpi_kernel.patch"

if [ ! -f $PATCH_FILE ]; then
    echo "Patch file \"$PATCH_FILE\" is missing. Exit."
    exit 255
fi

echo "Applying patch"

git apply $PATCH_FILE

echo "Copying new source files into place"

# Pick up the new source files
#
cp $SCRIPT_DIR/devterm-panel-overlay.dts arch/arm/boot/dts/overlays/devterm-panel-overlay.dts
cp $SCRIPT_DIR/devterm-panel-uc-overlay.dts arch/arm/boot/dts/overlays/devterm-panel-uc-overlay.dts
cp $SCRIPT_DIR/panel-cwd686.c drivers/gpu/drm/panel/panel-cwd686.c
cp $SCRIPT_DIR/panel-cwu50.c drivers/gpu/drm/panel/panel-cwu50.c

#
# Now build it...
#

export KERNEL=kernel8
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

echo "Picking up Raspberry Pi default config"

make bcm2711_defconfig

# Modify config to set the panel as kernel module
#
echo "Modifying default config"

perl -p -i -e 's/\# CONFIG_DRM_PANEL_CWD686 is not set/CONFIG_DRM_PANEL_CWD686=m/' .config
perl -p -i -e 's/# CONFIG_DRM_PANEL_CWU50 is not set/CONFIG_DRM_PANEL_CWU50=m/' .config

# Build kernel
#
echo "Building kernel and modules (takes ages)"

make -j8

# Build modules
#
rm -rf ./modules
mkdir ./modules

INSTALL_MOD_PATH=./modules make -j8 modules_install

rm -f ./modules/lib/modules/*/build
rm -f ./modules/lib/modules/*/source

echo "Copying output to ../out"

# Copy everything to export directory
#
rm -rf ../out
mkdir -p ../out/modules

cp -rav ./modules/* ../out/modules

mkdir -p ../out/overlays

cp arch/arm64/boot/Image ../out/$KERNEL.img
cp arch/arm64/boot/dts/broadcom/*.dtb ../out
cp arch/arm64/boot/dts/overlays/*.dtb* ../out/overlays/
cp arch/arm64/boot/dts/overlays/README ../out/overlays/

echo "Complete! Don't forget to update your config.txt"
