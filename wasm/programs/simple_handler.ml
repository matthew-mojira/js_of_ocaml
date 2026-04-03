open Effect
open Effect.Deep

let () =
  match_with (fun () -> 42) ()
    { retc = (fun v -> Printf.printf "returned: %d\n" v);
      exnc = raise;
      effc = fun _ -> None }
