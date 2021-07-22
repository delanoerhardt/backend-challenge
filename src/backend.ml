open Opium

let ( let* ) = Lwt.bind

let post_recipe request =
  let* json_option = Request.to_json request in

  let* add_recipe_result =
    match json_option with
    | None -> Lwt.return @@ Error "Invalid JSON"
    | Some json -> (
        match Recipe.recipe_of_yojson json with
        | Error error -> Lwt.return @@ Error ("Malformed recipe in: " ^ error)
        | Ok recipe -> Recipe_insert.add_recipe recipe)
  in

  match add_recipe_result with
  | Error error ->
      Lwt.return
        (Response.make ~status:`Bad_request ~body:(Body.of_string error) ())
  | Ok message ->
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string message) ())

let get_recipes_in_page request =
  let recipes_per_page = 8 in
  let last_seen_id =
    try Router.param request "last_seen_id"
    with Not_found -> "00000000-0000-0000-0000-000000000000"
  in

  let* result = Recipe_read.get_recipes_in_page last_seen_id recipes_per_page in

  match result with
  | Error error ->
      Response.of_plain_text ~status:`Bad_request error |> Lwt.return
  | Ok result ->
      Recipe.recipes_with_uuid_to_yojson result
      |> Response.of_json |> Lwt.return

let get_recipes_by_ingredient ingredient_id =
  let* result = Recipe_read.get_recipes_from_ingredient ingredient_id in

  match result with
  | Error error ->
      Response.of_plain_text ~status:`Bad_request error |> Lwt.return
  | Ok result ->
      Recipe.recipe_list_to_yojson result |> Response.of_json |> Lwt.return

let get_recipes_by_ingredient_name request =
  Router.param request "ingredient_name"
  |> Uuid_handler.get_uuid_from_string |> get_recipes_by_ingredient

let get_recipes_by_ingredient_id request =
  Router.param request "ingredient_id" |> get_recipes_by_ingredient

let () =
  print_endline "Ready";

  App.empty
  |> App.post "/add-recipe" post_recipe
  |> App.get "/get-recipes/" get_recipes_in_page
  |> App.get "/get-recipes/:last_seen_id" get_recipes_in_page
  |> App.get "/get-recipes/by-name/:ingredient_name"
       get_recipes_by_ingredient_name
  |> App.get "/get-recipes/by-id/:ingredient_id" get_recipes_by_ingredient_id
  |> App.run_multicore
