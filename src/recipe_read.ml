open Queries_read
open Recipe

let ( let* ) = Lwt.bind

let rec inner compare_value list_ref acc =
  match !list_ref with
  | [] -> ()
  | head :: tail ->
      if fst head = compare_value then (
        acc := snd head :: !acc;
        list_ref := tail;
        inner compare_value list_ref acc)

let map_result f list_result =
  match list_result with Ok list -> List.map f list | Error _ -> []

let fill_recipes ?(last_seen_id = "00000000-0000-0000-0000-000000000000")
    recipe_db_list =
  let recipe_id_list =
    List.map (fun ({ _id; _ } : Recipe.recipe_db) -> _id) recipe_db_list
  in

  let ingredients_of_recipes_tuple =
    Database_handler.dispatch_query
      (get_recipe_ingredients_query recipe_id_list)
  in
  let equipments_of_recipes_tuple =
    Database_handler.dispatch_query (get_recipe_equipments_query recipe_id_list)
  in

  let ingredients_of_recipes =
    Lwt.map
      (map_result (fun (recipe_id, food, quantity, quantity_unit) ->
           (recipe_id, { food; quantity; quantity_unit })))
      ingredients_of_recipes_tuple
  in

  let equipments_of_recipes =
    Lwt.map
      (map_result (fun (recipe_id, tool, quantity) ->
           (recipe_id, { tool; quantity })))
      equipments_of_recipes_tuple
  in

  let* ingredients_equipments =
    Lwt.both ingredients_of_recipes equipments_of_recipes
  in

  let ingredients_ref = ref @@ fst ingredients_equipments in
  let equipments_ref = ref @@ snd ingredients_equipments in

  let last_id = ref last_seen_id in

  let recipes =
    List.map
      (fun (recipe : recipe_db) ->
        let current_ingredients = ref [] in
        let current_equipments = ref [] in

        inner recipe._id ingredients_ref current_ingredients;
        inner recipe._id equipments_ref current_equipments;

        last_id := recipe._id;

        {
          name = recipe.name;
          description = recipe.description;
          ingredients = !current_ingredients;
          equipments = !current_equipments;
        })
      recipe_db_list
  in

  Ok { last_seen_id = !last_id; recipes } |> Lwt.return

let get_recipes_in_page (last_seen_id : string) recipes_per_page =
  let* recipe_db_list_result =
    Database_handler.dispatch_query
      (get_recipe_page_query ~last_seen_id ~recipes_per_page)
  in

  match recipe_db_list_result with
  | Ok recipe_db_list -> fill_recipes ~last_seen_id recipe_db_list
  | Error _ -> Lwt.return @@ Error "Couldn't find recipes"

let get_recipes_from_ingredient ingredient_id =
  let* recipe_db_list_result =
    Database_handler.dispatch_query (get_recipes_by_ingredient ~ingredient_id)
  in

  match recipe_db_list_result with
  | Ok recipe_db_list ->
      fill_recipes recipe_db_list
      |> Lwt.map (Result.map (fun { recipes; _ } -> recipes))
  | Error _ -> Lwt.return @@ Error "Couldn't find recipes"
