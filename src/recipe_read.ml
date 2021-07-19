open Database_queries
open Recipe

let ( let* ) = Lwt.bind

let fill_recipes (recipe_db_list : recipe_db list) =
  let recipe_id_list =
    List.map (fun ({ _id; _ } : Recipe.recipe_db) -> _id) recipe_db_list
  in

  let* ingredients_of_recipes_tuple =
    Database_handler.dispatch_query
      (get_recipe_ingredients_query recipe_id_list)
  in
  let ingredients_of_recipes =
    List.map
      (fun (recipe_id, food, quantity, quantity_unit) ->
        (recipe_id, { food; quantity; quantity_unit }))
      ingredients_of_recipes_tuple
  in

  let* equipments_of_recipes_tuple =
    Database_handler.dispatch_query (get_recipe_equipments_query recipe_id_list)
  in
  let equipments_of_recipes =
    List.map
      (fun (recipe_id, tool, quantity) -> (recipe_id, { tool; quantity }))
      equipments_of_recipes_tuple
  in

  let ingredients_ref = ref ingredients_of_recipes in
  let equipments_ref = ref equipments_of_recipes in

  let rec inner compare_value list_ref acc =
    match !list_ref with
    | [] -> ()
    | head :: tail ->
        if fst head = compare_value then (
          acc := snd head :: !acc;
          list_ref := tail;
          inner compare_value list_ref acc)
  in

  List.map
    (fun (recipe : recipe_db) ->
      let current_ingredients = ref [] in
      let current_equipments = ref [] in

      inner recipe._id ingredients_ref current_ingredients;
      inner recipe._id equipments_ref current_equipments;

      {
        name = recipe.name;
        description = recipe.description;
        ingredients = !current_ingredients;
        equipments = !current_equipments;
      })
    recipe_db_list
  |> Lwt.return

let get_recipes_in_page (page : int) (recipes_per_page : int) =
  let* recipe_db_list =
    Database_handler.dispatch_query
      (get_recipe_page_query ~recipes_skipped:(page * recipes_per_page)
         ~recipes_per_page)
  in

  fill_recipes recipe_db_list

let get_recipes_from_ingredient ingredient_id =
  let* recipe_db_list =
    Database_handler.dispatch_query (get_recipes_by_ingredient ~ingredient_id)
  in

  fill_recipes recipe_db_list
