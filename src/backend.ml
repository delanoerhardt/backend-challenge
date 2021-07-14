open Opium

type ingredient = { food : string; quantity : string; quantity_unit : string }
[@@deriving yojson]

type equipment = { tool : string; quantity : string } [@@deriving yojson]

type recipe = {
  name : string;
  description : string;
  ingredients : ingredient list;
  equipments : equipment list;
}
[@@deriving yojson]

type t = recipe list [@@deriving yojson]

let recipe_list = ref []

let ( let* ) = Lwt.bind

let post_recipe request =
  print_endline (Int.to_string (List.length !recipe_list));
  let* json_option = Request.to_json request in
  let recipe =
    match json_option with
    | None -> Error "Invalid JSON"
    | Some json -> (
        match recipe_of_yojson json with
        | Error error -> Error ("Malformed recipe in: " ^ error)
        | Ok recipe -> Ok recipe)
  in
  match recipe with
  | Error error ->
      Lwt.return
        (Response.make ~status:`Bad_request ~body:(Body.of_string error) ())
  | Ok recipe ->
      recipe_list := recipe :: !recipe_list;
      Lwt.return (Response.make ~status:`OK ())

let rec drop amount list =
  if amount > 0 then
    match list with [] -> [] | _ :: tail -> drop (amount - 1) tail
  else list

let take amount list =
  let rec take_acc amount list acc =
    match list with
    | [] -> ()
    | head :: tail ->
        acc := head :: !acc;
        if amount > 1 then take_acc (amount - 1) tail acc
  and acc = ref [] in
  take_acc amount list acc;
  !acc

let slice list start amount = drop start list |> take amount

let get_recipes_ordered_in_page request =
  let _order_by = Router.param request "order"
  and page = Router.param request "page" |> int_of_string in
  let recipes_per_page = 10 in
  let result = slice !recipe_list (page * recipes_per_page) recipes_per_page in

  to_yojson result |> Response.of_json |> Lwt.return

let () =
  print_endline "Ready";
  App.empty
  |> App.post "/add-recipe" post_recipe
  |> App.get "/get-recipes/:order/:page" get_recipes_ordered_in_page
  |> App.run_multicore
