open Js_of_ocaml

let () =
  let input_box_id = "inputBox" in
  let output_box_id = "outputBox" in
  let input_box = Js.Unsafe.global##.document##getElementById input_box_id in
  let output_box = Js.Unsafe.global##.document##getElementById output_box_id in
  let search_param =
    Daypack_lib.Search_param.Years_ahead_start_unix_second
      {
        search_using_tz_offset_s = None;
        start = Daypack_lib.Time.Current.cur_unix_second ();
        search_years_ahead = 2;
      }
  in
  output_box##.innerHTML := Js.string "output";
  let write_msg s = output_box##.innerHTML := Js.string s in
  let write_error s = write_msg ("Error: " ^ s) in
  input_box##.onkeydown :=
    Dom_html.handler (fun e ->
        ( if e##.keyCode = 13 then
            match
              Daypack_lib.Time_expr.Of_string.of_string
                (Js.to_string input_box##.value)
            with
            | Error msg -> write_error msg
            | Ok expr -> (
                match
                  Daypack_lib.Time_expr.matching_time_slots search_param expr
                with
                | Error msg -> write_error msg
                | Ok s -> (
                    let l =
                      s
                      |> OSeq.take 100
                      |> Seq.map (fun (x, y) ->
                          let x =
                            Daypack_lib.Time.To_string
                            .yyyymondd_hhmmss_string_of_unix_second
                              ~display_using_tz_offset_s:None x
                            |> Result.get_ok
                          in
                          let y =
                            Daypack_lib.Time.To_string
                            .yyyymondd_hhmmss_string_of_unix_second
                              ~display_using_tz_offset_s:None y
                            |> Result.get_ok
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
