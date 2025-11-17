#!/bin/sh

# This script isn't for building zesaurx on a development machine. :)

# This script runs on the CM4. It fetches the modified zesaurx package from
# github (as a single tar.gz archive) then builds and installs it for local
# use.
#
# Copy this script from the repo environment over the to CM4, then
# change to where you want the emulator built. Then run the script
# from there. So typical usage is:
#
# scp build_zesarux.sh z88r@cm4.localdomain:tmp
# ssh z88r@cm4.localdomain
# cd dev/third_party
# ~/tmp/build_zesarux.sh
#
# This script doesn't remove an existing build directory. Do that manually.

# Flow is to find the zesarux-z88r archive locally, or to go and fetch it
# from github if it's not already there. Then unpack it, cd into it, and
# configure and make the emulator. Then run make install. The built code
# typically goes into a bin directory off $HOME.

MACHINE_NAME=`uname -m`
TMP_DIR=~/tmp
BIN_DIR=~/bin/zesarux-z88r
AUTOSNAP_DIR=~/.z88r-autosnap
SRC_ARCHIVE=$TMP_DIR/zesarux-z88r.tar.gz
LOCAL_SRC_ARCHIVE=$TMP_DIR/zesarux-z88r-20240624.tar.gz
REMOTE_SRC_ARCHIVE=https://github.com/derekfountain/zesarux-z88r/archive/refs/tags/zesarux-z88r-20240624.tar.gz

# If you pull the src archive from Githib, the root directory in it will
# be some weird name. This script needs fixing. :o}
ARCHIVE_ROOT_DIR=zesarux-z88r
BUILD_DIR=./$ARCHIVE_ROOT_DIR

# Not sure the config file collection can work, it's a private repo
# which needs authentication and such
#
LOCAL_CONFIG_FILE=~/.z88r-config
REMOTE_CONFIG_FILE=https://raw.githubusercontent.com/blackjetrock/z88-recreate/main/emulator/zesarux/.z88r-config

if [ ! "$MACHINE_NAME" = "aarch64" ]; then
  echo "This script should be run on the CM4"
  exit 255
fi

# Check if the xorg-dev package is installed. If it's not then the rest
# probably won't be. If it is, and the rest aren't, well, that's not going
# to end well.
#
dpkg-query -W -f='${Status}' xorg-dev | grep -q -P '^install ok installed$'
if [ $? -eq 1 ]; then
  echo "\nInstall build packages with this:"
  echo "apt-get -y install git gcc make libncurses-dev libssl-dev xorg-dev libpulse-dev libsndfile1-dev libasound2-dev"
  echo "then run this script again"
  exit 255
fi

if [ ! -d $TMP_DIR ]; then
  mkdir -p $TMP_DIR
fi

if [ ! -d $BIN_DIR ]; then
  mkdir -p $BIN_DIR
fi

if [ -d $BUILD_DIR ]; then
  echo "Directory $BUILD_DIR exists, remove it and run this script again"
  exit 255
fi

# Fetch the source archive to somewhere local if it's not already there.
# A dated archive is downloaded from Github, and locally renamed to
# something date-neutral. If a build other than the Github dated one
# is required, copy the archive to SRC_ARCHIVE
#
if [ ! -f $SRC_ARCHIVE ]; then

  echo "Fetching the source archive into $TMP_DIR"

  cd $TMP_DIR
  wget $REMOTE_SRC_ARCHIVE
  mv $LOCAL_SRC_ARCHIVE $SRC_ARCHIVE
  cd -

  echo "Done, assuming it worked :)"
fi

echo "Unpacking zesarux archive"
tar xf $SRC_ARCHIVE
cd $BUILD_DIR
cd src

echo "Configuring zesarux"
export CFLAGS="-O3"
export LDFLAGS="-O3"

./configure --enable-memptr --enable-visualmem --enable-cpustats --enable-ssl --disable-caca --disable-aa --disable-cursesw --prefix $BIN_DIR
echo "Configuration complete"

echo "Currently in `pwd`, running 'make' to build zesarux"
make clean && make -j3

echo "Installing to $BIN_DIR"
make install

# Create the runtime environment for the emulator. Not sure these
# should be here, they should be in a system installation script?
# But for now...

if [ ! -d $AUTOSNAP_DIR ]; then
  mkdir -p $AUTOSNAP_DIR
fi

# Fetch the default zesarux config file if it's not already there.
# Workaround message...
#
if [ ! -f $LOCAL_CONFIG_FILE ]; then

  echo "Fetch this file from the repo:"
  echo "   https://raw.githubusercontent.com/blackjetrock/z88-recreate/main/emulator/zesarux/.z88r-config"
  echo "and copy the file to $LOCAL_CONFIG_FILE" 

fi
