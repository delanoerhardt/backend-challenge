module type DB = Rapper_helper.CONNECTION

let ( let* ) = Lwt.bind

let connection_pool =
  match
    Caqti_lwt.connect_pool ~max_size:5
      (Uri.of_string "postgresql://postgres:password@localhost:5432")
  with
  | Ok pool -> pool
  | Error error -> failwith (Caqti_error.show error)

let get_uuid () = Uuidm.to_string @@ Uuidm.v `V4

let random_namespace =
  match Uuidm.of_string "fef42a17-60fd-42d1-96b7-2617551b1119" with
  | None ->
      raise (Invalid_argument "Internal error when generating a uuid namespace")
  | Some result -> result

let get_uuid_from_string name =
  Uuidm.to_string @@ Uuidm.v (`V5 (random_namespace, name))

let dispatch_query f =
  let* result = Caqti_lwt.Pool.use f connection_pool in
  match result with
  | Ok data -> Lwt.return data
  | Error error ->
      let error_message = "Query failed with:\n" ^ Caqti_error.show error in
      let _ = print_endline error_message in
      Lwt.fail_with error_message
