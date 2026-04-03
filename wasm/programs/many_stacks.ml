(* many_stacks.ml
   Creates n_tasks stacks via Fork/Yield with a random scheduler.
   Each item in the run queue is a live suspended stack.
   At peak, n_tasks + 1 stacks exist simultaneously.

   Programmatically generated: change n_tasks to get any number of stacks. *)

open Effect
open Effect.Deep

let n_tasks = 20000
let n_steps = 80

let () = Random.init 42

type _ Effect.t +=
  | Yield : unit Effect.t
  | Fork  : (unit -> unit) -> unit Effect.t

let run_q : (unit, unit) continuation Queue.t = Queue.create ()

let live = ref 0

let dequeue_random () =
  let len = Queue.length run_q in
  if len = 0 then ()
  else
    let arr = Array.of_seq (Queue.to_seq run_q) in
    Queue.clear run_q;
    let i = Random.int len in
    Array.iteri (fun j k -> if j <> i then Queue.push k run_q) arr;
    continue arr.(i) ()

let rec spawn f =
  match_with f ()
    { retc = (fun () ->
          decr live;
          Printf.printf "task done  (%d stacks still live)\n%!" !live;
          dequeue_random ())
    ; exnc = raise
    ; effc = fun (type a) (e : a Effect.t) ->
        match e with
        | Yield -> Some (fun (k : (a, _) continuation) ->
              Queue.push k run_q;
              dequeue_random ())
        | Fork f -> Some (fun (k : (a, _) continuation) ->
              incr live;
              Queue.push k run_q;
              spawn f)
        | _ -> None }

let () =
  incr live;
  spawn (fun () ->
    Printf.printf "spawning %d tasks\n%!" n_tasks;
    for i = 1 to n_tasks do
      perform (Fork (fun () ->
        for step = 1 to n_steps do
          Printf.printf "task %3d  step %d/%d   %d stacks live\n%!"
            i step n_steps !live;
          perform Yield
        done))
    done;
    Printf.printf "main: all %d tasks forked  (%d stacks live)\n%!" n_tasks !live;
    perform Yield;
    Printf.printf "main done\n%!")
