(* random_jump.ml
   All n stacks are pre-allocated simultaneously using Effect.Shallow.fiber
   before any of them runs. One central shallow handler routes Goto effects
   between stacks, making it appear as if stacks jump directly to each other.

   At every moment: exactly n stacks are live.
     - 1 running
     - n-1 suspended in the stacks[] table

   Effect.Shallow is used because fiber and continue_with share the same
   continuation type. The handler reinstalls itself (as a fresh record, not
   a nested frame) after each Goto — so the call stack does not grow.

   Programmatically generated: change n and total_jumps freely. *)

open Effect
open Effect.Shallow

let n           = 20000
let total_jumps = 800000

let () = Random.init 42

type _ Effect.t += Goto : int -> unit Effect.t

(* stacks.(i) = Some k  =>  task i is suspended
   stacks.(i) = None     =>  task i is currently running *)
let stacks : (unit, unit) continuation option array = Array.make n None

let current_id = ref 0
let jump_count = ref 0

let task id () =
  let rec loop () =
    if !jump_count < total_jumps then begin
      let target = (id + 1 + Random.int (n - 1)) mod n in
      Printf.printf "stack %2d --> stack %2d   jump %3d/%d\n%!"
        id target (!jump_count + 1) total_jumps;
      perform (Goto target);
      loop ()
    end
  in
  loop ()

(* The handler is a value, not a stack frame — reinstalling it is free.
   continue_with is a tail call: current handler frame is replaced, not nested. *)
let rec mk_handler () : (unit, unit) handler =
  { retc = (fun () ->
        Printf.printf "\ndone after %d jumps across %d simultaneous stacks\n%!"
          !jump_count n)
  ; exnc = raise
  ; effc = fun (type a) (e : a Effect.t) ->
      match e with
      | Goto target ->
          Some (fun (k : (a, unit) continuation) ->
            incr jump_count;
            stacks.(!current_id) <- Some k;    (* freeze current stack *)
            current_id := target;
            let kt = Option.get stacks.(target) in
            stacks.(target) <- None;
            continue_with kt () (mk_handler ()))  (* switch to target stack *)
      | _ -> None }

let () =
  (* Pre-create all n stacks without running any of them.
     Each fiber is a stack with the function ready to start but not yet executed. *)
  for id = 0 to n - 1 do
    stacks.(id) <- Some (fiber (fun () -> task id ()))
  done;
  Printf.printf "%d stacks created simultaneously, none yet running\n\n%!" n;

  (* Pull stack 0 and start the whole thing. *)
  let k0 = Option.get stacks.(0) in
  stacks.(0) <- None;
  continue_with k0 () (mk_handler ())
