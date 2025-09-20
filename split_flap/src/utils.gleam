import gleam/dict
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

@external(javascript, "./split_flap.ffi.mjs", "set_timeout")
pub fn set_timeout(_delay: Int, _cb: fn() -> a) -> Int {
  0
}

@external(javascript, "./split_flap.ffi.mjs", "clear_timeout")
pub fn clear_timeout(_id: Int) -> Nil {
  Nil
}

@external(javascript, "./split_flap.ffi.mjs", "measure_orientation")
pub fn measure_orientation(
  in _root: decode.Dynamic,
  // of _selector: String,
) -> String {
  ""
}

@external(javascript, "./split_flap.ffi.mjs", "on_resize")
pub fn on_resize(_root: decode.Dynamic, _cb: fn() -> Nil) -> Nil {
  Nil
}

@external(javascript, "./split_flap.ffi.mjs", "animate")
pub fn animate() -> Nil {
  Nil
}

/// Find the item in the list directly after the `current` item.
/// Will return `Error(Nil)` if the `current` item is the last item, 
/// or if it is not found in the list.
/// 
pub fn find_next(l: List(a), current: a) -> Result(a, Nil) {
  case l {
    [h1, h2, ..rest] -> {
      case h1 == current {
        True -> Ok(h2)
        False -> find_next([h2, ..rest], current)
      }
    }
    _ -> Error(Nil)
  }
}

/// probs a better way to do this
pub fn zip_longest(
  list1: List(a),
  list2: List(b),
) -> List(#(Option(a), Option(b))) {
  let #(head1, rest1) = case list1 {
    [] -> #(None, [])
    [h, ..rest] -> #(Some(h), rest)
  }

  let #(head2, rest2) = case list2 {
    [] -> #(None, [])
    [h, ..rest] -> #(Some(h), rest)
  }

  let el = case head1, head2 {
    None, None -> None
    Some(h1), None -> Some(#(Some(h1), None))
    None, Some(h2) -> Some(#(None, Some(h2)))
    Some(h1), Some(h2) -> Some(#(Some(h1), Some(h2)))
  }

  case el {
    None -> []
    Some(el) -> [el, ..zip_longest(rest1, rest2)]
  }
}

pub fn first_is_some(pair: #(Option(a), b)) -> Result(b, Nil) {
  case pair {
    #(Some(_), b) -> Ok(b)
    _ -> Error(Nil)
  }
}

pub fn to_adjacency_list(chars: String) -> dict.Dict(String, String) {
  string.first(chars)
  |> result.map(fn(char) { chars <> char })
  |> result.unwrap("")
  |> string.to_graphemes
  |> list.window_by_2
  |> dict.from_list
}
