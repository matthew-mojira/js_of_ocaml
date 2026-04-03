open Effect
open Effect.Deep

type _ Effect.t += Yield : int -> unit Effect.t

let count_up n =
  for i = 1 to n do
    perform (Yield i)
  done

let () =
  match_with count_up 50000
    { retc = (fun () -> ());
      exnc = raise;
      effc = fun (type a) (eff : a Effect.t) ->
        match eff with
        | Yield n -> Some (fun (k : (a, _) continuation) ->
            Printf.printf "%d\n" n;
            continue k ())
        | _ -> None }
