let alert (msg : string) : unit =
  Js_of_ocaml.Js.Unsafe.global##alert (Js_of_ocaml.Js.string msg)

let console_log (msg : string) : unit =
  Js_of_ocaml.Js.Unsafe.global##.console##log (Js_of_ocaml.Js.string msg)
