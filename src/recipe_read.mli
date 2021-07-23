val get_recipes_in_page :
  string -> int -> (Types.recipes_with_uuid, string) result Lwt.t

val get_recipes_from_ingredient :
  string -> (Types.recipe_list, string) result Lwt.t
