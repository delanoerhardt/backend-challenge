let ( let* ) = Lwt.bind

module type DB = Rapper_helper.CONNECTION

open Database_queries
open Recipe

let connection_pool =
  match
    Caqti_lwt.connect_pool ~max_size:5
      (Uri.of_string "postgresql://postgres:password@localhost:5432")
  with
  | Ok pool -> pool
  | Error error -> failwith (Caqti_error.show error)

let get_uuid () = Uuidm.to_string @@ Uuidm.v `V4

let dispatch_query f =
  let* result = Caqti_lwt.Pool.use f connection_pool in
  match result with
  | Ok data -> Lwt.return data
  | Error error ->
      let error_message = "Query failed with:\n" ^ Caqti_error.show error in
      let _ = print_endline error_message in
      Lwt.fail_with error_message

let add_recipe_ingredients ingredients lwt_list =
  List.iter
    (fun ingredient ->
      let ingredient_query =
        dispatch_query (insert_ingredient_query ingredient)
      in
      lwt_list := ingredient_query :: !lwt_list;
      ())
    ingredients

let add_recipe_equipments equipments lwt_list =
  List.iter
    (fun equipment ->
      let equipment_query = dispatch_query (insert_equipment_query equipment) in
      lwt_list := equipment_query :: !lwt_list;
      ())
    equipments

let add_recipe_connections recipe_uuid equipments ingredients =
  List.iter
    (fun (equipment : Recipe.equipment) ->
      let _ =
        dispatch_query
          (insert_equipment_of_recipe_query ~recipe_id:recipe_uuid ~equipment)
      in
      ())
    equipments;
  List.iter
    (fun (ingredient : Recipe.ingredient) ->
      let _ =
        dispatch_query
          (insert_ingredient_of_recipe_query ~recipe_id:recipe_uuid ~ingredient)
      in
      ())
    ingredients

let add_recipe (recipe_or_error : (Recipe.recipe, string) result) =
  match recipe_or_error with
  | Error error -> Error error
  | Ok { name; description; ingredients; equipments } ->
      let recipe_uuid = get_uuid () in
      print_endline recipe_uuid;
      let recipe_lwt =
        dispatch_query
          (insert_recipe_query { _id = recipe_uuid; name; description })
      in
      let lwt_list = ref [ recipe_lwt ] in
      add_recipe_ingredients
        (List.map
           (fun ({ _id; food; _ } : ingredient) -> { _id; food })
           ingredients)
        lwt_list;
      add_recipe_equipments
        (List.map
           (fun ({ _id; tool; _ } : equipment) -> { _id; tool })
           equipments)
        lwt_list;
      let result = Lwt.join !lwt_list in
      let _ =
        Lwt.bind result (fun _ ->
            add_recipe_connections recipe_uuid equipments ingredients;
            Lwt.return_unit)
      in
      Ok "Recipe added sucessfully"
(* Can't really know if it's really Ok here, but will be left as is for now *)

let fill_recipes (recipe_db_list : recipe_db list) =
  let recipe_id_list =
    List.map (fun ({ _id; _ } : Recipe.recipe_db) -> _id) recipe_db_list
  in

  let* ingredients_of_recipes_tuple =
    dispatch_query (get_recipe_ingredients_query recipe_id_list)
  in
  let ingredients_of_recipes =
    List.map
      (fun (recipe_id, _id, food, quantity, quantity_unit) ->
        (recipe_id, { _id; food; quantity; quantity_unit }))
      ingredients_of_recipes_tuple
  in

  let* equipments_of_recipes_tuple =
    dispatch_query (get_recipe_equipments_query recipe_id_list)
  in
  let equipments_of_recipes =
    List.map
      (fun (recipe_id, _id, tool, quantity) ->
        (recipe_id, { _id; tool; quantity }))
      equipments_of_recipes_tuple
  in

  let ingredients_ref = ref ingredients_of_recipes in
  let equipments_ref = ref equipments_of_recipes in

  let rec inner compare_value list_ref acc () =
    match !list_ref with
    | [] -> ()
    | head :: tail ->
        if fst head = compare_value then (
          acc := snd head :: !acc;
          inner compare_value (ref tail) acc ())
  in

  List.map
    (fun (recipe : recipe_db) ->
      let current_ingredients = ref [] in
      let current_equipments = ref [] in
      inner recipe._id ingredients_ref current_ingredients ();
      inner recipe._id equipments_ref current_equipments ();
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
    dispatch_query
      (get_recipe_page_query ~recipes_skipped:(page * recipes_per_page)
         ~recipes_per_page)
  in

  fill_recipes recipe_db_list

let get_recipes_from_ingredient ingredient_id =
  let* recipe_db_list =
    dispatch_query (get_recipes_by_ingredient ~ingredient_id)
  in

  fill_recipes recipe_db_list
