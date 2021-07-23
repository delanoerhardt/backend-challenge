open Opium
open Routes

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
