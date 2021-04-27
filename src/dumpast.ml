open Ppxlib
open Jsonoo.Encode

let parse_ast =
  object (self)
    inherit [Jsonoo.t] Ast_traverse.lift as super

    method unit () = null

    method tuple args = list id args

    method string value = string value

    method float value = float value

    method bool value = bool value

    method record args = object_ args

    method other _ = string "serializing other values is not supported yet"

    method nativeint _ = string "serializing nativeint is not supported yet"

    method int64 _ = string "serializing int64 is not supported yet"

    method int32 _ = string "serializing int32 is not supported yet"

    method int value = int value

    method constr label args = object_ [ (label, list id args) ]

    method char value = char value

    method array f arg = list id (Array.to_list arg |> List.map f)

    method! structure_item { pstr_desc; pstr_loc } =
      object_
        [ ("type", string "structure_item")
        ; ("pstr_desc", super#structure_item_desc pstr_desc)
        ; ("pstr_loc", super#location pstr_loc)
        ]

    method! structure s = object_ [ ("structure", list self#structure_item s) ]

    method! list f = list f
  end

let transform source =
  try
    let v = Parse.implementation (Lexing.from_string source) in
    parse_ast#structure v
  with _ -> Jsonoo.Encode.string "Syntax error"

let from_structure (structure : Parsetree.structure) =
  try parse_ast#structure structure
  with _ -> Jsonoo.Encode.string "Syntax error"