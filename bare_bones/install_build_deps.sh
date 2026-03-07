#!/bin/bash

dnf install \
  gcc \
  gcc-c++ \
  make \
  bison \
  flex \
  gmp-devel \
  libmpc-devel \
  mpfr-devel \
  texinfo \
  isl-devel -y

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
