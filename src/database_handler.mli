val dispatch_query :
  (Caqti_lwt.connection -> ('a, Caqti_error.t) result Lwt.t) -> 'a Lwt.t
