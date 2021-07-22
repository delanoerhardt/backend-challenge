let ( let* ) = Lwt.bind

let connection_pool =
  match
    Caqti_lwt.connect_pool ~max_size:5
      (Uri.of_string "postgresql://postgres:password@localhost:5432")
  with
  | Ok pool -> pool
  | Error error -> failwith (Caqti_error.show error)

let dispatch_query f =
  let* result = Caqti_lwt.Pool.use f connection_pool in
  match result with
  | Ok data -> Lwt.return @@ Ok data
  | Error error ->
      print_endline (Caqti_error.show error);
      Lwt.return @@ Error error
