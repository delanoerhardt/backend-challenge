val add_recipe : (Recipe.recipe, string) result -> (string, string) result

val get_recipes_in_page : int -> int -> Recipe.recipe_list Lwt.t

val get_recipes_from_ingredient : string -> Recipe.recipe_list Lwt.t
