let get_uuid () = Uuidm.to_string @@ Uuidm.v `V4

let namespace =
  match Uuidm.of_string "fef42a17-60fd-42d1-96b7-2617551b1119" with
  | None ->
      raise (Invalid_argument "Internal error when generating a uuid namespace")
  | Some result -> result

let get_uuid_from_string name =
  Uuidm.to_string @@ Uuidm.v (`V5 (namespace, name))
