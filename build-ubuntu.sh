#!/bin/sh

CIRCT_BUILD=./build
CIRCT_INSTALL=../local

mkdir -p $CIRCT_BUILD
cd $CIRCT_BUILD
cmake -G Ninja .. \
	-DCMAKE_C_COMPILER=clang-16 \
	-DCMAKE_CXX_COMPILER=clang++-16 \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DLLVM_DIR=/usr/lib/llvm-16/cmake/ \
	-DMLIR_DIR=/usr/lib/llvm-16/lib/cmake/mlir \
	-DLLVM_EXTERNAL_LIT=/usr/local/bin/lit \
	-DLLVM_LIT_ARGS="-v --show-unsupported" \
	-DVERILATOR_DISABLE=ON \
	-DCMAKE_INSTALL_PREFIX=$CIRCT_INSTALL
ninja
ninja check-circt
