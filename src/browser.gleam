import gleam/dict
import gleam/dynamic/decode
import gleam/json

/// Convert an adjacency list to JSON for passing to the display element's data attribute.
/// The JS animation code reads this to determine character transitions.
pub fn adjacency_list_to_json(
  adjacency_list: dict.Dict(String, String),
) -> json.Json {
  json.dict(adjacency_list, fn(string) { string }, json.string)
}

// MARK: Timers

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

// MARK: Animation

/// Trigger animation for all split-flap displays on the page.
/// This reads each display's `data-adjacency-list` attribute and animates
/// each character to its `data-dest` destination.
@external(javascript, "./browser.ffi.mjs", "animate")
pub fn animate() -> Nil
