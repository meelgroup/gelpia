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
export CPPFLAGS="-I$REQ_DIR/include -I$BREW_PREFIX/opt/bison/include -I$BREW_PREFIX/opt/flex/include ${CPPFLAGS:-}"
export LDFLAGS="-L$REQ_DIR/lib -L$BREW_PREFIX/opt/bison/lib -L$BREW_PREFIX/opt/flex/lib ${LDFLAGS:-}"
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
if [ "$(uname -m)" = "x86_64" ]; then
  curl -L https://downloads.sourceforge.net/project/gaol/gaol/4.2.0/gaol-4.2.0.tar.gz -o gaol.tar.gz
  tar -xf gaol.tar.gz
  patch -p0 < "$ROOT_DIR/documents/gaol-4.2.0.patch"
  mv gaol-4.2.0 gaol
  cd gaol

  ./configure \
    --with-mathlib=crlibm \
    --disable-debug \
    --disable-preserve-rounding \
    --enable-optimize \
    --disable-verbose-mode \
    --enable-simd \
    --prefix="$REQ_DIR"
  make
  make install
else
  git clone https://github.com/goualard-f/GAOL.git gaol
  cd gaol
  git checkout cd0ee1a75febab97a7f6c18a03e31780a2717f2c
  patch -p1 < "$ROOT_DIR/documents/gaol-4.2.0.patch"

  # The repo ships pre-compiled flex/bison output (.cpp files). Regenerate them
  # so the abs support added by the patch is actually compiled into the library.
  flex -o gaol/gaol_interval_lexer.cpp gaol/gaol_interval_lexer.lpp
  bison --defines=gaol/gaol_interval_parser.h \
        -o gaol/gaol_interval_parser.cpp \
        gaol/gaol_interval_parser.ypp

  meson setup build --prefix="$REQ_DIR" -Dwith-mathlib=crlibm
  meson compile -C build
  meson install -C build
fi
