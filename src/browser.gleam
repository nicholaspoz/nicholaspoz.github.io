import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result

// External Types
pub type GsapTimeline

pub type HtmlElement

pub fn adjacency_list_to_json(
  adjacency_list: dict.Dict(String, String),
) -> json.Json {
  json.dict(adjacency_list, fn(string) { string }, json.string)
}

@external(javascript, "./browser.ffi.mjs", "set_timeout")
pub fn set_timeout(delay: Int, cb: fn() -> a) -> Int

@external(javascript, "./browser.ffi.mjs", "clear_timeout")
pub fn clear_timeout(id: Int) -> Nil

@external(javascript, "./browser.ffi.mjs", "measure_orientation")
pub fn measure_orientation(in root: decode.Dynamic) -> String

@external(javascript, "./browser.ffi.mjs", "on_resize")
pub fn on_resize(root: decode.Dynamic, cb: fn() -> Nil) -> Nil

@external(javascript, "./browser.ffi.mjs", "animate")
pub fn animate() -> Nil

@external(javascript, "./browser.ffi.mjs", "doc_query_selector")
pub fn doc_query_selector(selector: String) -> Result(HtmlElement, Nil)

@external(javascript, "./browser.ffi.mjs", "el_query_selector")
pub fn el_query_selector(
  el: HtmlElement,
  selector: String,
) -> Result(HtmlElement, Nil)

@external(javascript, "./browser.ffi.mjs", "el_query_selector_all")
pub fn el_query_selector_all(
  el: HtmlElement,
  selector: String,
) -> List(HtmlElement)

/// Whoever calls this function should create a new dict of timelines
/// TODO: need to add the timeline dict to the application model
pub fn animate_2(
  selector: String,
  timelines: dict.Dict(String, GsapTimeline),
  adjacency_list: dict.Dict(String, String),
) -> GsapTimeline {
  let assert Ok(display_root) = doc_query_selector(selector)
  let adjacency_list = adjacency_list_to_json(adjacency_list)

  let timeline = case dict.get(timelines, selector) {
    Error(_) -> new_timeline()
    Ok(tl) -> stop_children(tl)
  }

  list.fold(
    over: el_query_selector_all(display_root, ".split-flap"),
    from: timeline,
    with: fn(tl, element) {
      element
      |> apply_flip(adjacency_list)
      |> add_child_to_parent(tl)
    },
  )
  |> play
}

type SplitFlap {
  SplitFlap(
    top: HtmlElement,
    bottom: HtmlElement,
    flipping_bottom: HtmlElement,
    top_content: HtmlElement,
    bottom_content: HtmlElement,
    flipping_bottom_content: HtmlElement,
  )
}

fn get_split_flap(root: HtmlElement) -> Result(SplitFlap, Nil) {
  use top <- result.try(el_query_selector(root, ".top"))
  use bottom <- result.try(el_query_selector(root, ".bottom"))
  use flipping_bottom <- result.try(el_query_selector(root, ".flipping-bottom"))
  use top_content <- result.try(el_query_selector(top, ".flap-content"))
  use bottom_content <- result.try(el_query_selector(bottom, ".flap-content"))
  use flipping_bottom_content <- result.try(el_query_selector(
    flipping_bottom,
    ".flap-content",
  ))

  Ok(SplitFlap(
    top,
    bottom,
    flipping_bottom,
    top_content,
    bottom_content,
    flipping_bottom_content,
  ))
}

pub fn do_flip(
  el: HtmlElement,
  adjacency_list: dict.Dict(String, String),
) -> Result(GsapTimeline, Nil) {
  let assert Ok(flap) = get_split_flap(el)

  let curr = get_text_content(flap.top_content)
  let destination = get_destination(el)
  use <- bool.guard(curr != destination, Error(Nil))

  // If the adjacency list has changed, the current character may not be in it.
  // In this case, we force the next character to " ", and walk the adjacency
  // list from there.
  // let next = case dict.get(adjacency_list, curr) {
  //   Ok(next) -> next
  //   Error(_) -> " "
  // }

  let timeline =
    new_timeline()
    |> tl_set(flap.bottom, dict.from_list([#("opacity", Num(1))]), Num(0))
    |> build_timeline(adjacency_list, flap, curr, destination)

  todo
}

fn build_timeline(
  tl: GsapTimeline,
  adjacency_list: dict.Dict(String, String),
  flap: SplitFlap,
  curr: String,
  destination: String,
) -> GsapTimeline {
  use <- bool.guard(curr != destination, tl)

  // If the adjacency list has changed, the current character may not be in it.
  // In this case, we force the next character to " ", and walk the adjacency
  // list from there.
  let next = case dict.get(adjacency_list, curr) {
    Ok(next) -> next
    Error(_) -> " "
  }
  let tl =
    tl
    |> tl_call(
      fn() {
        set_text_content(flap.top_content, next)
        set_text_content(flap.bottom_content, curr)
        set_text_content(flap.flipping_bottom_content, next)
      },
      0,
    )
    |> tl_to(
      flap.flipping_bottom,
      dict.from_list([
        #("rotationX", Num(0)),
        #("duration", Float(0.04)),
        #("ease", Str("power1.inOut")),
      ]),
    )
    |> tl_set(
      flap.flipping_bottom,
      dict.from_list([#("rotationX", Num(90))]),
      Str(">"),
    )

  // let tl = 
  todo
}

// MARK: HtmlElement FFI

@external(javascript, "./browser.ffi.mjs", "get_text_content")
pub fn get_text_content(el: HtmlElement) -> String

@external(javascript, "./browser.ffi.mjs", "set_text_content")
pub fn set_text_content(el: HtmlElement, text: String) -> Nil

@external(javascript, "./browser.ffi.mjs", "get_destination")
pub fn get_destination(el: HtmlElement) -> String

// MARK: GsapTimeline FFI
pub type StrOrNum {
  Str(String)
  Num(Int)
  Float(Float)
}

@external(javascript, "./browser.ffi.mjs", "new_timeline")
pub fn new_timeline() -> GsapTimeline

pub fn tl_set(
  tl: GsapTimeline,
  el: HtmlElement,
  params: dict.Dict(String, StrOrNum),
  position: StrOrNum,
) -> GsapTimeline {
  tl_set_ext(
    tl,
    el,
    json.dict(params, fn(string) { string }, fn(str_or_num) {
      case str_or_num {
        Str(str) -> json.string(str)
        Num(num) -> json.int(num)
        Float(float) -> json.float(float)
      }
    }),
    case position {
      Str(str) -> json.string(str)
      Num(num) -> json.int(num)
      Float(float) -> json.float(float)
    },
  )
}

@external(javascript, "./browser.ffi.mjs", "tl_set")
pub fn tl_set_ext(
  tl: GsapTimeline,
  el: HtmlElement,
  params: json.Json,
  position: json.Json,
) -> GsapTimeline

@external(javascript, "./browser.ffi.mjs", "tl_call")
pub fn tl_call(tl: GsapTimeline, cb: fn() -> Nil, position: Int) -> GsapTimeline

pub fn tl_to(
  tl: GsapTimeline,
  el: HtmlElement,
  params: dict.Dict(String, StrOrNum),
) -> GsapTimeline {
  tl_to_ext(
    tl,
    el,
    json.dict(params, fn(string) { string }, fn(str_or_num) {
      case str_or_num {
        Str(str) -> json.string(str)
        Num(num) -> json.int(num)
        Float(float) -> json.float(float)
      }
    }),
  )
}

@external(javascript, "./browser.ffi.mjs", "tl_to")
pub fn tl_to_ext(
  tl: GsapTimeline,
  el: HtmlElement,
  params: json.Json,
) -> GsapTimeline

@external(javascript, "./browser.ffi.mjs", "stop_children")
pub fn stop_children(tl: GsapTimeline) -> GsapTimeline

@external(javascript, "./browser.ffi.mjs", "add_child")
pub fn add_child_to_parent(
  child: GsapTimeline,
  parent: GsapTimeline,
) -> GsapTimeline

@external(javascript, "./browser.ffi.mjs", "apply_flip")
pub fn apply_flip(el: HtmlElement, adjacency_list: json.Json) -> GsapTimeline

@external(javascript, "./browser.ffi.mjs", "play")
pub fn play(gsap_timeline: GsapTimeline) -> GsapTimeline
