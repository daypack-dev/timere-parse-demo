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
        (if e##.keyCode = 13 then
           match Timere_parse.timere (Js.to_string input_box##.value) with
           | Error msg -> write_error msg
           | Ok t -> (
               let tz = Timedesc.Time_zone.utc in
               match
                 Timere.(
                   resolve ~search_using_tz:tz
                     (t
                      & since (Timedesc.now ())
                      & before
                        (Timedesc.make_exn ~tz ~year:2030 ~month:1 ~day:1 ~hour:0
                           ~minute:0 ~second:0 ())))
               with
               | Error msg -> write_error msg
               | Ok s -> (
                   let l =
                     s
                     |> OSeq.take 100
                     |> Seq.map (fun (x, y) ->
                         let x =
                           x
                           |> Timedesc.of_timestamp ~tz_of_date_time:tz
                           |> Option.get
                           |> Timedesc.to_string
                           |> Option.get
                         in
                         let y =
                           y
                           |> Timedesc.of_timestamp ~tz_of_date_time:tz
                           |> Option.get
                           |> Timedesc.to_string
                           |> Option.get
                         in
                         Printf.sprintf "[%s, %s)" x y)
                     |> List.of_seq
                   in
                   match l with
                   | [] -> write_msg "No time slots found"
                   | _ ->
                     let str = String.concat "<br>" l in
                     write_msg str)));
        Js._true);
  ()
