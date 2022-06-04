#!/bin/env bash

SCRIPT_DIR="$(readlink --canonicalize $(dirname -- "${BASH_SOURCE[0]:-$0}"))";

cd $SCRIPT_DIR/conan-recipes/gtk/all &&
conan export . gtk/3.24.34@ &&
cd $SCRIPT_DIR/conan-recipes/gtkmm/all &&
conan export . gtkmm/3.24.6@
