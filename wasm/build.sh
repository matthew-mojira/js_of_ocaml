#!/bin/bash

set -e
cd "$(dirname "$0")"

eval $(opam env)
export PATH="$HOME/Tools/binaryen/build/bin:$PATH"

WASMOO=$HOME/Tools/js_of_ocaml-native_effects/_build/default/compiler/bin-wasm_of_ocaml/wasm_of_ocaml.exe

SRC="${1%.ml}"  # strip .ml if provided

ocamlc -o "$SRC.byte" "$SRC.ml"
$WASMOO compile --effects=jspi --enable wasi "$SRC.byte" -o "$SRC.js"

mv "$SRC.assets"/*.wasm "$SRC.wasm"
wasm-dis "$SRC.wasm" -o "$SRC.wat"
