open Effect
open Effect.Deep

type _ Effect.t += Yield : int -> unit Effect.t

let count_up n =
  for i = 1 to n do
    perform (Yield i)
  done

(* Tracks the generator's lifecycle *)
type gen_state =
  | Ready
  | Suspended of (unit, int option) continuation
  | Done

let make_generator f arg =
  let state = ref Ready in
  let handler = {
    retc = (fun () -> state := Done; None);
    exnc = raise;
    effc = fun (type a) (eff : a Effect.t) ->
      match eff with
      | Yield n -> Some (fun (k : (a, int option) continuation) ->
          state := Suspended k;
          Some n)
      | _ -> None
  } in
  let next () =
    match !state with
    | Done        -> None
    | Ready       -> match_with f arg handler
    | Suspended k -> continue k ()
  in
  next

let () =
  let next = make_generator count_up 5000 in
  let rec loop () =
    match next () with
    | None   -> ()
    | Some n ->
        Printf.printf "Got %d — doing something with it!\n" n;
        loop ()
  in
  loop ()
