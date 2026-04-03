#!/bin/bash

WASM_DIR="$(dirname "$0")"

pass=0
fail=0
missing=0

compare() {
    local ml_out="$WASM_DIR/${1%.ml}.ml.out"
    local wasm_out="$WASM_DIR/${1%.ml}.wasm.out"
    printf "%-55s " "$1"

    if [ ! -f "$ml_out" ]; then
        echo "MISSING ml.out"
        ((missing++))
    elif [ ! -f "$wasm_out" ]; then
        echo "MISSING wasm.out"
        ((missing++))
    elif diff -q "$ml_out" "$wasm_out" > /dev/null 2>&1; then
        echo "OK"
        ((pass++))
    else
        echo "DIFF"
        diff "$ml_out" "$wasm_out"
        ((fail++))
    fi
}

# effects/
compare effects/cmphash.ml
compare effects/evenodd.ml
compare effects/marshal.ml
compare effects/overflow.ml
compare effects/partial.ml
compare effects/reperform.ml
compare effects/sched.ml
compare effects/shallow_state.ml
compare effects/shallow_state_io.ml
compare effects/test1.ml
compare effects/test2.ml
compare effects/test3.ml
compare effects/test4.ml
compare effects/test5.ml
compare effects/test6.ml
compare effects/test10.ml
compare effects/test11.ml
compare effects/test_lazy.ml
compare effects/unhandled_unlinked.ml
compare effects/used_cont.ml

# effect-syntax/
compare effect-syntax/coroutines.ml
compare effect-syntax/iterators.ml
compare effect-syntax/resume_exn.ml
compare effect-syntax/shallow2deep.ml
compare effect-syntax/test1.ml
compare effect-syntax/test2.ml
compare effect-syntax/test3.ml
compare effect-syntax/test4.ml
compare effect-syntax/test5.ml
compare effect-syntax/test6.ml
compare effect-syntax/test10.ml
compare effect-syntax/test11.ml
compare effect-syntax/tutorial.ml

# lib-effects/
compare lib-effects/deep_state.ml
compare lib-effects/effects.ml
compare lib-effects/sched.ml

# examples/
compare examples/ask.ml
compare examples/gen.ml
compare examples/gen2.ml
compare examples/hello.ml
compare examples/many_stacks.ml
compare examples/random_jump.ml
compare examples/simple_handler.ml

echo ""
echo "$pass matched, $fail differed, $missing missing output files"
