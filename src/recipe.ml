(*
  Recipe and equipment are supposed to be retrivied from the server when
  setting up the recipe, thus they should already have an uuid or
  have it set when created.
*)
type ingredient = {
  _id : string;
  food : string;
  quantity : string;
  quantity_unit : string;
}
[@@deriving yojson]

type equipment = { _id : string; tool : string; quantity : int }
[@@deriving yojson]

type recipe = {
  name : string;
  description : string;
  ingredients : ingredient list;
  equipments : equipment list;
}
[@@deriving yojson]

let make_empty_recipe () =
  { name = ""; description = ""; ingredients = []; equipments = [] }

type recipe_list = recipe list [@@deriving yojson]

type recipe_db = { _id : string; name : string; description : string }

type ingredient_db = { _id : string; food : string }

type equipment_db = { _id : string; tool : string }
