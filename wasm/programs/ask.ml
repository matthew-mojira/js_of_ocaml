open Effect
open Effect.Deep

type _ Effect.t += Ask : int Effect.t

let () =
  match_with (fun () ->
    let n = perform Ask in
    Printf.printf "got: %d\n" n)
    ()
    { retc = (fun () -> ());
      exnc = raise;
      effc = fun (type a) (eff : a Effect.t) ->
        match eff with
        | Ask -> Some (fun (k : (a, _) continuation) -> continue k 42)
        | _   -> None }
