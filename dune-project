(lang dune 2.8)

(name backend-challenge)

(generate_opam_files true)

(package
 (name backend-challenge)
 (depends
  ocaml
  opium
  ppx_deriving_yojson
  yojson
  caqti
  caqti-lwt
  caqti-driver-postgresql))
