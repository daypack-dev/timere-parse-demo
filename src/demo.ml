open Js_of_ocaml

let () =
  let input_box_id = "inputBox" in
  let search_time_zone_box_id = "searchTimeZoneBox" in
  let display_time_zone_box_id = "displayTimeZoneBox" in
  let output_box_id = "outputBox" in
  let input_box = Js.Unsafe.global##.document##getElementById input_box_id in
  let display_time_zone_box =
    Js.Unsafe.global##.document##getElementById display_time_zone_box_id
  in
  let search_time_zone_box =
    Js.Unsafe.global##.document##getElementById search_time_zone_box_id
  in
  let output_box = Js.Unsafe.global##.document##getElementById output_box_id in
  output_box##.innerHTML := Js.string "output";
  let write_msg s = output_box##.innerHTML := Js.string s in
  let write_error s = write_msg ("Error: " ^ s) in
  let search_tz = ref None in
  let display_tz = ref None in
  search_time_zone_box##.onkeydown := Dom_html.handler (fun e -> 
        (if e##.keyCode = 13 then
          match Timedesc.Time_zone.make (Js.to_string search_time_zone_box##.value) with
          | None -> write_error "Invalid time zone"
          | Some tz' -> (
            write_msg ("Default search time zone set to " ^ Timedesc.Time_zone.name tz');
            search_tz := Some tz'
          )
        );
        Js._true
  );
  display_time_zone_box##.onkeydown := Dom_html.handler (fun e -> 
        (if e##.keyCode = 13 then
          match Timedesc.Time_zone.make (Js.to_string display_time_zone_box##.value) with
          | None -> write_error "Invalid time zone"
          | Some tz' -> (
            write_msg ("Display time zone set to " ^ Timedesc.Time_zone.name tz');
            display_tz := Some tz'
          )
        );
        Js._true
  );
  input_box##.onkeydown :=
    Dom_html.handler (fun e ->
        (if e##.keyCode = 13 then
           match Timere_parse.timere (Js.to_string input_box##.value) with
           | Error msg -> write_error msg
           | Ok t -> (
               let search_tz = Option.value ~default:Timedesc.Time_zone.utc !search_tz in
               let display_tz = Option.value ~default:Timedesc.Time_zone.utc !display_tz in
               match
                 Timere.(
                   resolve ~search_using_tz:search_tz
                     (t
                      &&& since (Timedesc.now ~tz_of_date_time:search_tz ())
                      &&& before
                        (Timedesc.make_exn ~tz:search_tz ~year:2030 ~month:1 ~day:1
                           ~hour:0 ~minute:0 ~second:0 ())))
               with
               | Error msg -> write_error msg
               | Ok s -> (
                   let s = s |> OSeq.take 20 in
                   match s () with
                   | Seq.Nil -> write_msg "No time slots found"
                   | _ ->
                     let str =
                       String.concat "<br>"
                         (s
                          |> Seq.map (fun (x, y) ->
                              (Timedesc.of_timestamp_exn ~tz_of_date_time:display_tz x,
                              Timedesc.of_timestamp_exn ~tz_of_date_time:display_tz y
                              )
                              )
                          |> Seq.map (fun (x, y) ->
                              Fmt.str "[%a, %a)"
                                (Timedesc.pp_rfc3339 ())
                                x
                                (Timedesc.pp_rfc3339 ())
                                y)
                          |> List.of_seq)
                     in
                     write_msg str)));
        Js._true);
  ()
