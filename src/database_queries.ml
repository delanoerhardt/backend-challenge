open Recipe

module type DB = Rapper_helper.CONNECTION
(* INSERT QUERIES *)

let insert_recipe_query =
  [%rapper
    execute
      {sql|
        INSERT INTO recipe_table
        VALUES(%string{_id}, %string{name}, %string{description});
      |sql}
      record_in]

let insert_ingredient_query =
  [%rapper
    execute
      {sql|
        INSERT INTO ingredient_table
        VALUES
          ( %string{_id}
          , %string{food}
          );
      |sql}
      record_in]

let insert_equipment_query =
  [%rapper
    execute
      {sql|
        INSERT INTO equipment_table
        VALUES( %string{_id}, %string{tool});
      |sql}
      record_in]

let insert_ingredient_of_recipe_query ~(recipe_id : string)
    ~(ingredient : ingredient) =
  [%rapper
    execute
      {sql|
        INSERT INTO ingredient_of_recipe
        VALUES
          ( %string{recipe_id}
          , %string{ingredient_id}
          , %string{quantity_unit}
          , %string{quantity});
      |sql}]
    ~recipe_id ~ingredient_id:ingredient._id
    ~quantity_unit:ingredient.quantity_unit ~quantity:ingredient.quantity

let insert_equipment_of_recipe_query ~(recipe_id : string)
    ~(equipment : equipment) =
  [%rapper
    execute
      {sql|
        INSERT INTO equipment_of_recipe
        VALUES( %string{recipe_id}, %string{equipment_id}, %int{quantity});
      |sql}]
    ~recipe_id ~equipment_id:equipment._id ~quantity:equipment.quantity

(* GET PAGED QUERIES *)

let get_recipe_page_query =
  [%rapper
    get_many
      {sql|
        SELECT @string{name}, @string{_id}, @string{description}
        FROM recipe_table ORDER BY _id OFFSET %int{recipes_skipped}
        LIMIT %int{recipes_per_page};
      |sql}
      function_out] (fun ~description ~_id ~name -> { _id; name; description })

let get_recipe_ingredients_query recipe_id_list =
  [%rapper
    get_many
      {sql|
        SELECT @string{i_of_r.recipe_id},
        @string{i._id}, @string{i.food},
        @string{i_of_r.quantity}, @string{i_of_r.quantity_unit} 
        FROM ingredient_of_recipe AS i_of_r
        JOIN ingredient_table AS i ON ingredient_id = _id 
        WHERE recipe_id IN (%list{%string{recipe_ids}})
        ORDER BY recipe_id;
      |sql}]
    ~recipe_ids:recipe_id_list

let get_recipe_equipments_query recipe_id_list =
  [%rapper
    get_many
      {sql|
        SELECT @string{e_of_r.recipe_id}, @string{e._id},
        @string{e.tool}, @int{e_of_r.quantity} 
        FROM equipment_of_recipe AS e_of_r
        JOIN equipment_table AS e ON equipment_id = _id 
        WHERE recipe_id IN (%list{%string{recipe_ids}})
        ORDER BY recipe_id;
      |sql}]
    ~recipe_ids:recipe_id_list

let get_recipes_by_ingredient =
  [%rapper
    get_many
      {sql|
        SELECT @string{name}, @string{_id}, @string{description}
        FROM ingredient_of_recipe JOIN recipe_table ON _id = recipe_id
        WHERE ingredient_id = %string{ingredient_id}
        ORDER BY _id;
      |sql}
      function_out] (fun ~description ~_id ~name -> { _id; name; description })
