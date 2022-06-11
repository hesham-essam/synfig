#!/bin/env bash

export CONAN_DEFAULT_PACKAGE_ID_MODE="full_package_mode"
SCRIPT_DIR="$(readlink --canonicalize $(dirname -- "${BASH_SOURCE[0]:-$0}"))";

cd $SCRIPT_DIR
mkdir conan_build
cd conan_build
conan install .. -if ./modules/ -s compiler.libcxx=libstdc++11 --build=missing &&
export PKG_CONFIG_PATH="$SCRIPT_DIR/conan_build/modules" &&
cmake -DCMAKE_MODULE_PATH="$SCRIPT_DIR/conan_build/modules" -DCMAKE_BUILD_TYPE=Release -GNinja .. &&
ninja
