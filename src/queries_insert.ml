open Recipe
open Query_gen

let insert_recipe_query =
  [%rapper
    execute
      {sql|
          INSERT INTO recipe_table
          VALUES(%string{_id}, %string{name}, %string{description});
        |sql}
      record_in]

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
