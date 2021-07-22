open Recipe

module type Db = Rapper_helper.CONNECTION
(* INSERT QUERIES *)

let insert_recipe_query =
  [%rapper
    execute
      {sql|
        INSERT INTO recipe_table
        VALUES(%string{_id}, %string{name}, %string{description});
      |sql}
      record_in]

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

let insert_ingredients_query ingredients =
  let sql =
    Printf.sprintf
      {|
      INSERT INTO ingredient_table VALUES %s
      ON CONFLICT DO NOTHING;
    |}
  in

  gen_insert_rows_query 2 Caqti_type.(tup2 string string) ingredients sql

let insert_equipments_query equipments =
  let sql =
    Printf.sprintf
      {|
        INSERT INTO equipment_table VALUES %s
        ON CONFLICT DO NOTHING;
      |}
  in

  gen_insert_rows_query 2 Caqti_type.(tup2 string string) equipments sql

let insert_ingredient_of_recipe_query ingredient_of_recipe_inner =
  let sql =
    Printf.sprintf
      {|
        INSERT INTO ingredient_of_recipe
        VALUES %s;
      |}
  in

  gen_insert_rows_query 4
    Caqti_type.(tup4 string string string string)
    ingredient_of_recipe_inner sql

let insert_equipment_of_recipe_query equipment_of_recipe_inner =
  let sql =
    Printf.sprintf
      {|
        INSERT INTO equipment_of_recipe
        VALUES %s;
      |}
  in

  gen_insert_rows_query 3
    Caqti_type.(tup3 string string int)
    equipment_of_recipe_inner sql
