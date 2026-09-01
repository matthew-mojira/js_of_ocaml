#!/bin/bash

WASM_DIR="$(dirname "$0")"
WIZENG="wizeng.x86-64-linux --ext:legacy-eh --ext:stack-switching"

# Every program is built for both effects backends, so run both.
BACKENDS="native cps"

pass=0
fail=0
missing=0

# run <program.ml> [args...]
#
# Programs built from several sources (concurrent.ml, which needs sched.ml)
# are linked into a single Wasm module by build.sh, so they are run here
# exactly like any single-source program.
run() {
    local prog="${1%.ml}"
    shift
    local backend file out
    for backend in $BACKENDS; do
        file="$WASM_DIR/$prog.$backend.wasm"
        out="$WASM_DIR/$prog.$backend.wasm.out"
        printf "%-46s %-7s " "$prog.ml" "$backend"
        if [ ! -f "$file" ]; then
            echo "MISSING"
            ((missing++))
        elif $WIZENG "$file" "$@" > "$out" 2>&1; then
            echo "OK"
            ((pass++))
        else
            echo "FAIL"
            ((fail++))
        fi
    done
}

# effects/
run effects/cmphash.ml
run effects/evenodd.ml
run effects/marshal.ml
run effects/overflow.ml
run effects/partial.ml
run effects/reperform.ml
run effects/sched.ml
run effects/shallow_state.ml
run effects/shallow_state_io.ml
run effects/test1.ml
run effects/test2.ml
run effects/test3.ml
run effects/test4.ml
run effects/test5.ml
run effects/test6.ml
run effects/test10.ml
run effects/test11.ml
run effects/test_lazy.ml
run effects/unhandled_unlinked.ml
run effects/used_cont.ml

# effect-syntax/
run effect-syntax/coroutines.ml
run effect-syntax/iterators.ml
run effect-syntax/resume_exn.ml
run effect-syntax/shallow2deep.ml
run effect-syntax/test1.ml
run effect-syntax/test2.ml
run effect-syntax/test3.ml
run effect-syntax/test4.ml
run effect-syntax/test5.ml
run effect-syntax/test6.ml
run effect-syntax/test10.ml
run effect-syntax/test11.ml
run effect-syntax/tutorial.ml

# lib-effects/
# assume_no_perform{,_unhandled,_nested_handler}.ml need the jsoo-only
# Jsoo_runtime API and have no Wasm build.
run lib-effects/concurrent.ml
run lib-effects/deep_state.ml 3 100
run lib-effects/dyn_wind.ml
run lib-effects/effects.ml
run lib-effects/eratosthenes.ml
run lib-effects/reify_reflect.ml
run lib-effects/sched.ml
run lib-effects/state.ml
run lib-effects/test_domain.ml
run lib-effects/transaction.ml

# examples/
run examples/ask.ml
run examples/gen.ml
run examples/gen2.ml
run examples/hello.ml
run examples/many_stacks.ml
run examples/random_jump.ml
run examples/simple_handler.ml

# tests-wasm_of_ocaml/
run tests-wasm_of_ocaml/gh2093.ml

echo ""
echo "$pass passed, $fail failed, $missing missing"
