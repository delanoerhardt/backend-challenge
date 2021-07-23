module type Db = Rapper_helper.CONNECTION

module Dynparam = struct
  type t = Pack : ('a Caqti_type.t * 'a) -> t

  let empty = Pack (Caqti_type.unit, ())

  let add t x (Pack (t', x')) = Pack (Caqti_type.tup2 t' t, (x', x))
end

let gen_placeholder column_amount list =
  let row_placeholder =
    List.init column_amount (fun _ -> "?")
    |> String.concat ", " |> Printf.sprintf "(%s)"
  in

  List.map (fun _ -> row_placeholder) list |> String.concat ", "

let get_types_and_values row_type list =
  List.fold_left
    (fun prev_pack a -> Dynparam.add row_type a prev_pack)
    Dynparam.empty list

let gen_insert_rows_query column_amount row_type list sql
    (module Db : Rapper_helper.CONNECTION) =
  let sql_command = sql (gen_placeholder column_amount list) in

  let (Dynparam.Pack (types, values)) = get_types_and_values row_type list in

  let query = Caqti_request.exec ~oneshot:true types sql_command in

  Db.exec query values
