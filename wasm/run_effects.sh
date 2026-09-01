#!/bin/bash

WASM_DIR="$(dirname "$0")"
eval $(opam env)

pass=0
fail=0

# run <program.ml> [args...]
#
# Produces the reference output that compare_outputs.sh diffs the Wasm runs
# against.  This goes through ocamlc rather than the `ocaml` interpreter so the
# reference comes from the same bytecode the Wasm artifacts are compiled from;
# script mode differs in, for instance, how it qualifies exception names.
run() {
    local prog="${1%.ml}"
    printf "%-55s " "$1"
    if compile_and_run "$prog" "$prog.ml" --; then
        echo "OK"
        ((pass++))
    else
        echo "FAIL"
        ((fail++))
    fi
}

# compile_and_run <program> <source.ml>... -- [args...]
#
# Compiles the sources to bytecode, runs it with the given arguments and saves
# the combined output to <program>.ml.out.  Returns the exit status of the run.
compile_and_run() {
    local prog="$1"
    shift
    local dir="$WASM_DIR/$(dirname "$prog")"
    local byte="$WASM_DIR/$prog.byte"
    local srcs=()
    while [ "$1" != "--" ]; do srcs+=("$WASM_DIR/$1"); shift; done
    shift

    local status
    if ocamlc -I "$dir" -o "$byte" "${srcs[@]}" > /dev/null 2>&1; then
        "$byte" "$@" > "$WASM_DIR/$prog.ml.out" 2>&1
        status=$?
    else
        echo "compilation failed" > "$WASM_DIR/$prog.ml.out"
        status=1
    fi
    rm -f "$byte" "$dir"/*.cmi "$dir"/*.cmo
    return $status
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
# Jsoo_runtime API and are not runnable with plain ocaml.
# multi-file: concurrent.ml uses the scheduler defined in sched.ml
printf "%-55s " "lib-effects/concurrent.ml"
if compile_and_run lib-effects/concurrent \
       lib-effects/sched.ml lib-effects/concurrent.ml --; then
    echo "OK"; ((pass++))
else
    echo "FAIL"; ((fail++))
fi
# requires CLI arguments: depth ops
printf "%-55s " "lib-effects/deep_state.ml"
if compile_and_run lib-effects/deep_state lib-effects/deep_state.ml -- 3 100; then
    echo "OK"; ((pass++))
else
    echo "FAIL"; ((fail++))
fi
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
echo "$pass passed, $fail failed"
