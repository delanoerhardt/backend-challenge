open Database_queries
open Recipe

let add_recipe_ingredients ingredients lwt_list =
  List.iter
    (fun ingredient ->
      let ingredient_query =
        Database_handler.dispatch_query (insert_ingredient_query ingredient)
      in
      lwt_list := ingredient_query :: !lwt_list;
      ())
    ingredients

let add_recipe_equipments equipments lwt_list =
  List.iter
    (fun equipment ->
      let equipment_query =
        Database_handler.dispatch_query (insert_equipment_query equipment)
      in
      lwt_list := equipment_query :: !lwt_list;
      ())
    equipments

let add_recipe_connections recipe_uuid equipments ingredients =
  List.iter
    (fun (equipment : Recipe.equipment_db) ->
      let _ =
        Database_handler.dispatch_query
          (insert_equipment_of_recipe_query ~recipe_id:recipe_uuid ~equipment)
      in
      ())
    equipments;
  List.iter
    (fun (ingredient : Recipe.ingredient_db) ->
      let _ =
        Database_handler.dispatch_query
          (insert_ingredient_of_recipe_query ~recipe_id:recipe_uuid ~ingredient)
      in
      ())
    ingredients

let add_recipe (recipe_or_error : (Recipe.recipe, string) result) =
  match recipe_or_error with
  | Error error -> Error error
  | Ok { name; description; ingredients; equipments } ->
      let recipe_uuid = Database_handler.get_uuid () in

      let recipe_lwt =
        Database_handler.dispatch_query
          (insert_recipe_query { _id = recipe_uuid; name; description })
      in

      let ingredients_db_list =
        List.map
          (fun ({ food; quantity; quantity_unit } : ingredient) ->
            {
              _id = Database_handler.get_uuid_from_string food;
              food;
              quantity;
              quantity_unit;
            })
          ingredients
      in

      let equipments_db_list =
        List.map
          (fun ({ tool; quantity } : equipment) ->
            { _id = Database_handler.get_uuid_from_string tool; tool; quantity })
          equipments
      in

      let lwt_list = ref [ recipe_lwt ] in

      add_recipe_ingredients ingredients_db_list lwt_list;
      add_recipe_equipments equipments_db_list lwt_list;

      let entities_inserts = Lwt.join !lwt_list in

      let _connections_insert =
        Lwt.bind entities_inserts (fun _ ->
            add_recipe_connections recipe_uuid equipments_db_list
              ingredients_db_list;
            Lwt.return_unit)
      in

      Ok "Recipe added sucessfully"
(* Can't really know if it's really Ok here, but will be left as is for now *)
