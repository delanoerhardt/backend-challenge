open Queries_insert
open Recipe

let lwt_bind_unit a = Lwt.bind a (fun _ -> Lwt.return_unit)

let make_ingredient_into_tuples recipe_id ingredient_list ingred_of_recipe_list
    (ingredient : ingredient) =
  let ingredient_id = Uuid_handler.get_uuid_from_string ingredient.food in

  ingredient_list := (ingredient_id, ingredient.food) :: !ingredient_list;

  ingred_of_recipe_list :=
    (recipe_id, ingredient_id, ingredient.quantity, ingredient.quantity_unit)
    :: !ingred_of_recipe_list

let make_equipment_into_tuples recipe_id equipment_list equip_of_recipe_list
    (equipment : equipment) =
  let equipment_id = Uuid_handler.get_uuid_from_string equipment.tool in

  equipment_list := (equipment_id, equipment.tool) :: !equipment_list;

  equip_of_recipe_list :=
    (recipe_id, equipment_id, equipment.quantity) :: !equip_of_recipe_list

let add_recipe { name; description; ingredients; equipments } =
  let recipe_id = Uuid_handler.get_uuid () in

  let recipe_lwt =
    lwt_bind_unit
    @@ Database_handler.dispatch_query
         (insert_recipe_query { _id = recipe_id; name; description })
  in

  let ingredient_list = ref [] in
  let equipment_list = ref [] in
  let ingred_of_recipe_list = ref [] in
  let equip_of_recipe_list = ref [] in

  List.iter
    (make_ingredient_into_tuples recipe_id ingredient_list ingred_of_recipe_list)
    ingredients;

  List.iter
    (make_equipment_into_tuples recipe_id equipment_list equip_of_recipe_list)
    equipments;

  let lwt_list =
    [
      recipe_lwt;
      Lwt.map (fun _ -> ())
      @@ Database_handler.dispatch_query
           (insert_ingredients_query !ingredient_list);
      Lwt.map (fun _ -> ())
      @@ Database_handler.dispatch_query
           (insert_equipments_query !equipment_list);
    ]
  in

  let entities_inserts = Lwt.join lwt_list in

  let _connections_insert =
    Lwt.map
      (fun _ ->
        ignore
        @@ Database_handler.dispatch_query
             (insert_ingredient_of_recipe_query !ingred_of_recipe_list);
        ignore
        @@ Database_handler.dispatch_query
             (insert_equipment_of_recipe_query !equip_of_recipe_list))
      entities_inserts
  in

  Lwt.return @@ Ok "Recipe added sucessfully"
(* Can't really know if it's really Ok here, but will be left as is for now *)
