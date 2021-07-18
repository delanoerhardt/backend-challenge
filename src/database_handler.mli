val dispatch_query :
  (Caqti_lwt.connection -> ('a, Caqti_error.t) result Lwt.t) -> 'a Lwt.t

val get_uuid : unit -> string

val get_uuid_from_string : string -> string
