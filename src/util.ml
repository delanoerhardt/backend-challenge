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
