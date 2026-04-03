#!/bin/bash

WASM_DIR="$(dirname "$0")"
WIZENG="wizeng.x86-64-linux --ext:legacy-eh --ext:stack-switching"

pass=0
fail=0

run() {
    local file="$WASM_DIR/${1%.ml}.wasm"
    local out="$WASM_DIR/${1%.ml}.wasm.out"
    printf "%-55s " "$1"
    if $WIZENG "$file" "${@:2}" > "$out" 2>&1; then
        echo "OK"
        ((pass++))
    else
        echo "FAIL"
        ((fail++))
    fi
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

# lib-effects/ (only files that were successfully compiled to wasm)
#run lib-effects/assume_no_perform.ml       # jsoo-only API
#run lib-effects/assume_no_perform_nested_handler.ml
#run lib-effects/assume_no_perform_unhandled.ml
#run lib-effects/concurrent.ml             # needed multi-file compilation
run lib-effects/deep_state.ml 3 100
#run lib-effects/dyn_wind.ml               # ppx_expect
run lib-effects/effects.ml
#run lib-effects/eratosthenes.ml           # ppx_expect
#run lib-effects/reify_reflect.ml          # ppx_expect
run lib-effects/sched.ml
#run lib-effects/state.ml                  # ppx_expect
#run lib-effects/test_domain.ml            # ppx_expect
#run lib-effects/transaction.ml            # ppx_expect

# examples/
run examples/ask.ml
run examples/gen.ml
run examples/gen2.ml
run examples/hello.ml
run examples/many_stacks.ml
run examples/random_jump.ml
run examples/simple_handler.ml

echo ""
echo "$pass passed, $fail failed"
