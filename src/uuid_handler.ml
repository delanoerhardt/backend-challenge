let free_random_states = ref []

let get_random_state () =
  match !free_random_states with
  | [] -> Random.State.make_self_init ()
  | random_state :: tail ->
      free_random_states := tail;
      random_state

let get_random_bits () =
  let random_state = get_random_state () in
  let u = Bytes.create 16 in
  let r0 = Random.State.bits random_state in
  let r1 = Random.State.bits random_state in
  let r2 = Random.State.bits random_state in
  let r3 = Random.State.bits random_state in
  Bytes.set u 0 @@ Char.unsafe_chr (r0 land 0xFF);
  Bytes.set u 1 @@ Char.unsafe_chr ((r0 lsr 8) land 0xFF);
  Bytes.set u 2 @@ Char.unsafe_chr ((r0 lsr 16) land 0xFF);
  Bytes.set u 3 @@ Char.unsafe_chr ((r0 lsr 24) land 0xFF);
  Bytes.set u 4 @@ Char.unsafe_chr (r1 land 0xFF);
  Bytes.set u 5 @@ Char.unsafe_chr ((r1 lsr 8) land 0xFF);
  Bytes.set u 6 @@ Char.unsafe_chr ((r1 lsr 16) land 0xFF);
  Bytes.set u 7 @@ Char.unsafe_chr ((r1 lsr 24) land 0xFF);
  Bytes.set u 8 @@ Char.unsafe_chr (r2 land 0xFF);
  Bytes.set u 9 @@ Char.unsafe_chr ((r2 lsr 8) land 0xFF);
  Bytes.set u 10 @@ Char.unsafe_chr ((r2 lsr 16) land 0xFF);
  Bytes.set u 11 @@ Char.unsafe_chr ((r2 lsr 24) land 0xFF);
  Bytes.set u 12 @@ Char.unsafe_chr (r3 land 0xFF);
  Bytes.set u 13 @@ Char.unsafe_chr ((r3 lsr 8) land 0xFF);
  Bytes.set u 14 @@ Char.unsafe_chr ((r3 lsr 16) land 0xFF);
  Bytes.set u 15 @@ Char.unsafe_chr ((r3 lsr 24) land 0xFF);

  free_random_states := random_state :: !free_random_states;
  u

let get_uuid () =
  let random_bits = get_random_bits () in
  Uuidm.to_string @@ Uuidm.v4 random_bits

let namespace =
  match Uuidm.of_string "fef42a17-60fd-42d1-96b7-2617551b1119" with
  | None ->
      raise (Invalid_argument "Internal error when generating a uuid namespace")
  | Some result -> result

let get_uuid_from_string name =
  Uuidm.to_string @@ Uuidm.v (`V5 (namespace, name))
