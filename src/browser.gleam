import gleam/dynamic/decode
import gleam/json

@external(javascript, "./browser.ffi.mjs", "set_timeout")
pub fn set_timeout(delay: Int, cb: fn() -> a) -> Int

@external(javascript, "./browser.ffi.mjs", "clear_timeout")
pub fn clear_timeout(id: Int) -> Nil

// MARK: Layout

@external(javascript, "./browser.ffi.mjs", "update_flap_height")
pub fn update_flap_height() -> Nil

@external(javascript, "./browser.ffi.mjs", "measure_orientation")
pub fn measure_orientation(in root: decode.Dynamic) -> String

@external(javascript, "./browser.ffi.mjs", "on_resize")
pub fn on_resize(root: decode.Dynamic, cb: fn() -> Nil) -> Nil

@external(javascript, "./browser.ffi.mjs", "get_path")
pub fn get_path() -> String

// MARK: Animation

@external(javascript, "./browser.ffi.mjs", "set_adjacency_list")
pub fn set_adjacency_list(name: String, adjacency_list: json.Json) -> Nil

/// Trigger animation for all split-flap displays on the page.
/// This reads each display's `data-adjacency-list` attribute and animates
/// each character to its `data-dest` destination.
@external(javascript, "./browser.ffi.mjs", "animate")
pub fn animate() -> Nil
