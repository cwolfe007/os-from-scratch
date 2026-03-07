#!/bin/bash

set -x
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
export MAKEFLAGS="-j$(nproc)"

if [[ ! -d ./src ]]; then
  mkdir ./src
fi

pushd ./src

if [[ ! -d binutils-gdb ]]; then
  git clone git://sourceware.org/git/binutils-gdb.git
fi

if [[ ! -d gcc ]]; then
  git clone https://gcc.gnu.org/git/gcc.git
fi

if [[ ! -d build-binutils ]]; then
  mkdir build-binutils
fi

if [[ ! -f $PREFIX/$TARGET-ld ]]; then
  pushd build-binutils
  # compile linker and utilities
  ../binutils-gdb/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
  make
  make install
  popd
fi

if [[ ! -f $PREFIX/$TARGET-gdb ]]; then
  pushd binutils-gdb
  # compile gdb
  ./gdb/configure --target=$TARGET --prefix="$PREFIX" --disable-werror
  make all-gdb
  make install-gdb
  popd
fi

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

if [[ ! -f $PREFIX/$TARGET-gcc ]]; then
  # compile gdb
  rm -rf build-gcc
  mkdir build-gcc
  pushd build-gcc
  ../gcc/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
  make all-gcc
  make all-target-libgcc
  make all-target-libstdc++-v3
  make install-gcc
  make install-target-libgcc
  make install-target-libstdc++-v3
  popd
fi
# get out of src/
popd
