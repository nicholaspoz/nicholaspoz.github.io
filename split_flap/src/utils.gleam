import gleam/dynamic/decode

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

@external(javascript, "./split_flap.ffi.mjs", "wtf")
pub fn wtf(thing: decode.Dynamic) -> Nil {
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
