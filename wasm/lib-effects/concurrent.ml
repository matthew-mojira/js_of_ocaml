(*
Copyright (c) 2015, KC Sivaramakrishnan <sk826@cl.cam.ac.uk>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)

(* Demonstrate the concurrent scheduler
   ------------------------------------
    Spawn binary tree of tasks in depth-first order

        ************
         Fiber tree
        ************
              0
            /  \
           1    2
          / \  / \
         3   4 5  6
*)

let log = Printf.printf

let rec f id depth =
  log "Starting number %i\n%!" id;
  if depth > 0
  then (
    log "Forking number %i\n%!" ((id * 2) + 1);
    Sched.fork (fun () -> f ((id * 2) + 1) (depth - 1));
    log "Forking number %i\n%!" ((id * 2) + 2);
    Sched.fork (fun () -> f ((id * 2) + 2) (depth - 1)))
  else (
    log "Yielding in number %i\n%!" id;
    Sched.yield ();
    log "Resumed number %i\n%!" id);
  log "Finishing number %i\n%!" id

let () =
  Sched.run (fun () -> f 0 2);
  ()
