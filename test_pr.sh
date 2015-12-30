#!/bin/bash

if [ "x$VERBOSE" != "x" ]; then
    set -v
    set -x
fi

CC=arm-linux-gnueabi-gcc

# Set this to something built by:
#   cmake -DLLVM_PATH=../../.. -DLIBUNWIND_ENABLE_SHARED=0 \
#       -DCMAKE_C_COMPILER=arm-linux-gnueabi-gcc \
#       -DCMAKE_CXX_COMPILER=arm-linux-gnueabi-g++ ..
#   make
#
# Or use the bundled libunwind.a copy.
LIBUNWIND_A=`pwd`/libunwind.a
ARM_SYSROOT=/usr/arm-linux-gnueabi

(cd lib/builtins;
arm-linux-gnueabi-gcc -ggdb3 -c -o gcc_personality_v0.{o,c};
arm-linux-gnueabi-gcc -ggdb3 -c -o int_util.{o,c};
ar rcs pr.a gcc_personality_v0.o int_util.o
)

(cd test/builtins/Unit;
arm-linux-gnueabi-gcc -ggdb3 -nodefaultlibs -fexceptions -I../../lib \
    -o gcc_personality_test \
    gcc_personality_test.c \
    gcc_personality_test_helper.cxx \
    ../../../lib/builtins/pr.a $LIBUNWIND_A \
    -lstdc++ -lc -ldl;
if qemu-arm -L $ARM_SYSROOT ./gcc_personality_test; then echo "pass";
else echo "fail"; fi
)