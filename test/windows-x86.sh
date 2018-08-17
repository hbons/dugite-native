#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$DIR/.."
SOURCE="$ROOT/git"
DESTINATION="$ROOT/build/git"

GIT_LFS_VERSION=2.5.0 \
TARGET_PLATFORM=windows \
WIN_ARCH=32 \
GIT_FOR_WINDOWS_URL=https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/MinGit-2.18.0-32-bit.zip \
GIT_FOR_WINDOWS_CHECKSUM=c2f59c121d0f5aac31c959e5ba2878542b6cbca6604778566061d45585e70895 \
GIT_LFS_CHECKSUM=408f95d919037b068318cb2affb450c17a46915fe6b3d9b10dfc15dc0df15bca \
. "$ROOT/script/build-windows.sh" $SOURCE $DESTINATION

if [ "os" != "windows" ]; then
  echo "Archive contents:"
  cd $DESTINATION
  du -ah $DESTINATION
  cd - > /dev/null
fi

GZIP_FILE="dugite-native-$VERSION-windows-test.tar.gz"
LZMA_FILE="dugite-native-$VERSION-windows-test.lzma"

echo ""
echo "Creating archives..."
if [ "$(uname -s)" == "Darwin" ]; then
  tar -czf $GZIP_FILE -C $DESTINATION .
  tar --lzma -cf $LZMA_FILE -C $DESTINATION .
else
  tar -caf $GZIP_FILE -C $DESTINATION .
  tar -caf $LZMA_FILE -C $DESTINATION .
fi

if [ "$APPVEYOR" == "True" ]; then
  GZIP_CHECKSUM=$(sha256sum $GZIP_FILE | awk '{print $1;}')
  LZMA_CHECKSUM=$(sha256sum $LZMA_FILE | awk '{print $1;}')
else
  GZIP_CHECKSUM=$(shasum -a 256 $GZIP_FILE | awk '{print $1;}')
  LZMA_CHECKSUM=$(shasum -a 256 $LZMA_FILE | awk '{print $1;}')
fi

GZIP_SIZE=$(du -h $GZIP_FILE | cut -f1)
LZMA_SIZE=$(du -h $LZMA_FILE | cut -f1)

echo "Packages created:"
echo "${GZIP_FILE} - ${GZIP_SIZE} - checksum: ${GZIP_CHECKSUM}"
echo "${LZMA_FILE} - ${LZMA_SIZE} - checksum: ${LZMA_CHECKSUM}"