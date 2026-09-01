#!/bin/bash

set -e
cd "$(dirname "$0")"

eval $(opam env)
export PATH="$HOME/Tools/binaryen/build/bin:$PATH"

REPO="$(cd .. && pwd)"
WASMOO="$REPO/_build/default/compiler/bin-wasm_of_ocaml/wasm_of_ocaml.exe"

# Sources in ocamlc order: dependencies first, the main program last.
# Artifacts are named after the last source, e.g.
#   ./build.sh lib-effects/sched.ml lib-effects/concurrent.ml
# builds concurrent.{native,cps}.wasm.
SRCS=("${@%.ml}")          # strip .ml if provided
SRCS=("${SRCS[@]/%/.ml}")
SRC="${SRCS[-1]%.ml}"

# Let ocamlc find the .cmi of a dependency compiled into another directory.
INCLUDES=()
for dir in $(printf '%s\n' "${SRCS[@]%/*}" | sort -u); do
    INCLUDES+=(-I "$dir")
done

ocamlc "${INCLUDES[@]}" -o "$SRC.byte" "${SRCS[@]}"

# One Wasm program per effects backend, so the two can be compared.
for effects in native cps; do
    $WASMOO compile --effects="$effects" --enable wasi \
        "$SRC.byte" -o "$SRC.$effects.js"

    mv "$SRC.$effects.assets"/*.wasm "$SRC.$effects.wasm"
    wasm-dis "$SRC.$effects.wasm" -o "$SRC.$effects.wat"
done
