(*
  Recipe and equipment are supposed to be retrivied from the server when
  setting up the recipe, thus they should already have an uuid or
  have it set when created.
*)
type ingredient = { food : string; quantity : string; quantity_unit : string }
[@@deriving yojson]

type equipment = { tool : string; quantity : int } [@@deriving yojson]

type recipe = {
  name : string;
  description : string;
  ingredients : ingredient list;
  equipments : equipment list;
}
[@@deriving yojson]

type ingredient_db = {
  _id : string;
  food : string;
  quantity : string;
  quantity_unit : string;
}

type equipment_db = { _id : string; tool : string; quantity : int }

type recipe_db = { _id : string; name : string; description : string }

type recipe_list = recipe list [@@deriving yojson]

type recipes_with_uuid = { recipes : recipe list; last_seen_id : string }
[@@deriving yojson]
