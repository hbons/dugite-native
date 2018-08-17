#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$DIR/.."
SOURCE="$ROOT/git"
DESTINATION="$ROOT/build/git"

GIT_LFS_VERSION=2.5.0 \
TARGET_PLATFORM=windows \
WIN_ARCH=64 \
GIT_FOR_WINDOWS_URL=https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/MinGit-2.18.0-64-bit.zip \
GIT_FOR_WINDOWS_CHECKSUM=1dfd05de1320d57f448ed08a07c0b9de2de8976c83840f553440689b5db6a1cf \
GIT_LFS_CHECKSUM=452375d3968491520df29cde989164c41c1c4ff12ba30dfb343872f6d24016f1 \
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