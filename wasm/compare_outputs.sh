#!/bin/bash

WASM_DIR="$(dirname "$0")"

# Each program is built for both effects backends; both are compared against
# the same reference output, produced by the OCaml interpreter.
BACKENDS="native cps"

pass=0
fail=0
missing=0

# compare <program.ml>
compare() {
    local prog="${1%.ml}"
    local ml_out="$WASM_DIR/$prog.ml.out"
    local backend wasm_out

    for backend in $BACKENDS; do
        wasm_out="$WASM_DIR/$prog.$backend.wasm.out"
        printf "%-46s %-7s " "$prog.ml" "$backend"

        if [ ! -f "$ml_out" ]; then
            echo "MISSING ml.out"
            ((missing++))
        elif [ ! -f "$wasm_out" ]; then
            echo "MISSING $backend.wasm.out"
            ((missing++))
        elif diff -q "$ml_out" "$wasm_out" > /dev/null 2>&1; then
            echo "OK"
            ((pass++))
        else
            echo "DIFF"
            diff "$ml_out" "$wasm_out"
            ((fail++))
        fi
    done
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
# assume_no_perform{,_unhandled,_nested_handler}.ml need the jsoo-only
# Jsoo_runtime API and have neither a native nor a Wasm run.
compare lib-effects/concurrent.ml
compare lib-effects/deep_state.ml
compare lib-effects/dyn_wind.ml
compare lib-effects/effects.ml
compare lib-effects/eratosthenes.ml
compare lib-effects/reify_reflect.ml
compare lib-effects/sched.ml
compare lib-effects/state.ml
compare lib-effects/test_domain.ml
compare lib-effects/transaction.ml

# examples/
compare examples/ask.ml
compare examples/gen.ml
compare examples/gen2.ml
compare examples/hello.ml
compare examples/many_stacks.ml
compare examples/random_jump.ml
compare examples/simple_handler.ml

# tests-wasm_of_ocaml/
compare tests-wasm_of_ocaml/gh2093.ml

echo ""
echo "$pass matched, $fail differed, $missing missing output files"
