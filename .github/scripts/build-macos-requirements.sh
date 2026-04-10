#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REQ_DIR="$ROOT_DIR/requirements"
BUILD_DIR="$REQ_DIR/Sources"
BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
trap 'rm -rf "$BUILD_DIR"' EXIT

export PATH="$BREW_PREFIX/opt/bison/bin:$BREW_PREFIX/opt/flex/bin:$PATH"
export LIBRARY_PATH="$REQ_DIR/lib:${LIBRARY_PATH:-}"
export C_INCLUDE_PATH="$REQ_DIR/include:${C_INCLUDE_PATH:-}"
export CPLUS_INCLUDE_PATH="$REQ_DIR/include:${CPLUS_INCLUDE_PATH:-}"
export CPPFLAGS="-I$BREW_PREFIX/opt/bison/include -I$BREW_PREFIX/opt/flex/include ${CPPFLAGS:-}"
export LDFLAGS="-L$BREW_PREFIX/opt/bison/lib -L$BREW_PREFIX/opt/flex/lib ${LDFLAGS:-}"
export CFLAGS="-fPIC ${CFLAGS:-}"
export CXXFLAGS="-std=c++11 -fPIC ${CXXFLAGS:-}"

cd "$BUILD_DIR"

cp "$REQ_DIR/crlibm/crlibm.tar.gz" .
mkdir -p crlibm
tar -xf crlibm.tar.gz -C crlibm --strip-components 1
cd crlibm
./configure --prefix="$REQ_DIR"
make
make install

cd "$BUILD_DIR"
curl -L https://downloads.sourceforge.net/project/gaol/gaol/4.2.0/gaol-4.2.0.tar.gz -o gaol.tar.gz
tar -xf gaol.tar.gz
patch -p0 < "$ROOT_DIR/documents/gaol-4.2.0.patch"
mv gaol-4.2.0 gaol
cd gaol

gaol_config_flags=(
  --with-mathlib=crlibm
  --disable-debug
  --disable-preserve-rounding
  --enable-optimize
  --disable-verbose-mode
  --prefix="$REQ_DIR"
)

if [ "$(uname -m)" = "x86_64" ]; then
  gaol_config_flags+=(--enable-simd)
fi

./configure "${gaol_config_flags[@]}"
make
make install
