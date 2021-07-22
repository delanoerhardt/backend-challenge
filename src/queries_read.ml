open Recipe

module type Db = Rapper_helper.CONNECTION

let get_recipe_page_query =
  [%rapper
    get_many
      {sql|
        SELECT @string{_id}, @string{name}, @string{description}
        FROM recipe_table WHERE _id > %string{last_seen_id} ORDER BY _id
        LIMIT %int{recipes_per_page};
      |sql}
      function_out] (fun ~description ~name ~_id -> { _id; name; description })

let get_recipe_ingredients_query recipe_id_list =
  [%rapper
    get_many
      {sql|
        SELECT @string{i_of_r.recipe_id}, @string{i.food},
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
        SELECT @string{e_of_r.recipe_id},
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
