import gleam/dynamic/decode

@external(javascript, "./browser.ffi.mjs", "set_timeout")
pub fn set_timeout(_delay: Int, _cb: fn() -> a) -> Int {
  0
}

@external(javascript, "./browser.ffi.mjs", "clear_timeout")
pub fn clear_timeout(_id: Int) -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "measure_orientation")
pub fn measure_orientation(in _root: decode.Dynamic) -> String {
  ""
}

@external(javascript, "./browser.ffi.mjs", "on_resize")
pub fn on_resize(_root: decode.Dynamic, _cb: fn() -> Nil) -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "animate")
pub fn animate() -> Nil {
  Nil
}
