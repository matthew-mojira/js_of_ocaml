#!/bin/bash

set -e
cd "$(dirname "$0")"

eval $(opam env)
export PATH="$HOME/Tools/binaryen/build/bin:$PATH"

REPO="$(cd .. && pwd)"
WASMOO="$REPO/_build/default/compiler/bin-wasm_of_ocaml/wasm_of_ocaml.exe"

SRC="${1%.ml}"  # strip .ml if provided

ocamlc -o "$SRC.byte" "$SRC.ml"

# One Wasm program per effects backend, so the two can be compared.
for effects in native cps; do
    $WASMOO compile --effects="$effects" --enable wasi \
        "$SRC.byte" -o "$SRC.$effects.js"

    mv "$SRC.$effects.assets"/*.wasm "$SRC.$effects.wasm"
    wasm-dis "$SRC.$effects.wasm" -o "$SRC.$effects.wat"
done
