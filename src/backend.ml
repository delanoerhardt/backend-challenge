open Opium

let ( let* ) = Lwt.bind

let post_recipe request =
  let* json_option = Request.to_json request in

  let recipe_or_error =
    match json_option with
    | None -> Error "Invalid JSON"
    | Some json -> (
        match Recipe.recipe_of_yojson json with
        | Error error -> Error ("Malformed recipe in: " ^ error)
        | Ok recipe -> Ok recipe)
  in

  match Recipe_insert.add_recipe recipe_or_error with
  | Error error ->
      Lwt.return
        (Response.make ~status:`Bad_request ~body:(Body.of_string error) ())
  | Ok message ->
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string message) ())

let get_recipes_in_page request =
  let page = Router.param request "page" |> int_of_string in
  let recipes_per_page = 10 in
  let* result =
    Lwt.map Recipe.recipe_list_to_yojson
      (Recipe_read.get_recipes_in_page page recipes_per_page)
  in

  result |> Response.of_json |> Lwt.return

let get_recipes_by_ingredient ingredient_id =
  let* result =
    Lwt.map Recipe.recipe_list_to_yojson
      (Recipe_read.get_recipes_from_ingredient ingredient_id)
  in

  result |> Response.of_json |> Lwt.return

let get_recipes_by_ingredient_name request =
  Router.param request "ingredient_name" |> get_recipes_by_ingredient

let get_recipes_by_ingredient_id request =
  Router.param request "ingredient_id"
  |> Database_handler.get_uuid_from_string |> get_recipes_by_ingredient

let () =
  print_endline "Ready";
  App.empty
  |> App.post "/add-recipe" post_recipe
  |> App.get "/get-recipes/:order/:page" get_recipes_in_page
  |> App.get "/get-recipes/by-name/:ingredient_name"
       get_recipes_by_ingredient_name
  |> App.get "/get-recipes/by-id/:ingredient_id" get_recipes_by_ingredient_id
  |> App.run_multicore
