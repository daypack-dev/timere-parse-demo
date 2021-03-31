open Js_of_ocaml

let () =
  let input_box_id = "inputBox" in
  let output_box_id = "outputBox" in
  let input_box = Js.Unsafe.global##.document##getElementById input_box_id in
  let output_box = Js.Unsafe.global##.document##getElementById output_box_id in
  output_box##.innerHTML := Js.string "output";
  let write_msg s = output_box##.innerHTML := Js.string s in
  let write_error s = write_msg ("Error: " ^ s) in
  input_box##.onkeydown :=
    Dom_html.handler (fun e ->
        ( if e##.keyCode = 13 then
            match
              Timere_parse.timere
              (Js.to_string input_box##.value)
            with
            | Error msg -> write_error msg
            | Ok expr -> (
                match
                  Timere.resolve
                   expr
                with
                | Error msg -> write_error msg
                | Ok s -> (
                    let l =
                      s
                      |> OSeq.take 100
                      |> Seq.map (fun (x, y) ->
                          let x =
                            x
                            |> Timere.Date_time.of_timestamp
                            |> Option.get
                            |> Timere.Date_time.to_rfc3339
                          in
                          let y =
                            y
                            |> Timere.Date_time.of_timestamp
                            |> Option.get
                            |> Timere.Date_time.to_rfc3339
                          in
                          Printf.sprintf "[%s, %s)" x y)
                      |> List.of_seq
                    in
                    match l with
                    | [] -> write_msg "No time slots found"
                    | _ ->
                      let str = String.concat "<br>" l in
                      write_msg str ) ) );
        Js._true);
  ()
