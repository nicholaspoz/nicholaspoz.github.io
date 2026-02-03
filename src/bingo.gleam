/////////////////////////////
/////////////////////////////

import gleam/bool
import gleam/function
import gleam/int
import gleam/json
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result.{try}
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed
import lustre/event

import browser
import model.{
  type BingoState, type Content, type Frame, type Scene, BingoState, C,
  EmptyLine, Frame, L, Link, R, Text,
}
import scenes.{scenes}
import utils

pub fn main() -> Result(Nil, lustre.Error) {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Ok(Nil)
}

const default_chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-'.:▶()𝄞𝄢𝅘𝅥𝄽!"

const pagination_chars = " ○●()𝄆𝄇"

// MARK: MODEL

type Model {
  Model(
    scenes: List(Scene),
    rows: Int,
    columns: Int,
    current: Result(BingoState, Nil),
    auto_play: Bool,
    timeout: Option(Int),
    path: String,
  )
}

type Msg {
  Resized
  ColumnsChanged(Int)
  PageClicked(Int)
  AutoPlayClicked
  TimeoutStarted(Int)
  TimeoutEnded
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  let cols = 0
  let scenes = scenes
  let state = utils.initial_state(scenes)
  let path = browser.get_path()

  #(
    Model(
      scenes: scenes,
      rows: 7,
      columns: cols,
      current: state,
      auto_play: True,
      timeout: None,
      path: path,
    ),
    effect.batch([
      set_adjacency_list_effect("pagination", Some(pagination_chars)),

      case state {
        Ok(state) -> set_adjacency_list_effect("display", state.scene.chars)
        Error(_) -> effect.none()
      },

      {
        use dispatch, root_element <- effect.after_paint
        browser.on_resize(root_element, fn() { dispatch(Resized) })
      },
    ]),
  )
}

// MARK: Effects

fn set_adjacency_list_effect(name: String, chars: Option(String)) {
  let adjacency_list =
    utils.to_adjacency_list(case chars {
      Some(chars) -> chars
      None -> default_chars
    })
    |> json.dict(function.identity, json.string)

  use _, _ <- effect.before_paint
  browser.set_adjacency_list(name, adjacency_list)
}

fn on_resize_effect(model: Model) -> Effect(Msg) {
  effect.batch([
    {
      use _, _ <- effect.after_paint
      browser.update_flap_height()
    },
    {
      use dispatch, root_element <- effect.before_paint
      let cols = case model.path, browser.measure_orientation(root_element) {
        "/", "landscape" -> 21
        _, _ -> 15
      }
      dispatch(ColumnsChanged(cols))
    },
  ])
}

fn start_timeout(frame: Frame, current_timeout id: Option(Int)) -> Effect(Msg) {
  use dispatch, _ <- effect.after_paint
  case id {
    Some(id) -> browser.clear_timeout(id)
    None -> Nil
  }
  let id = browser.set_timeout(frame.ms, fn() { dispatch(TimeoutEnded) })
  dispatch(TimeoutStarted(id))
}

// MARK: UPDATE

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case reduce(model, msg) {
    Ok(next) -> next
    Error(_) -> {
      // SOMEBODY should DO SOMETHING about this!
      echo "ERROR"
      #(model, effect.none())
    }
  }
}

fn reduce(model: Model, msg: Msg) -> Result(#(Model, Effect(Msg)), Nil) {
  case msg {
    Resized -> Ok(#(model, on_resize_effect(model)))

    ColumnsChanged(columns) -> {
      use <- bool.guard(columns == model.columns, Ok(#(model, effect.none())))
      use initial_state <- try(model.current)
      Ok(#(
        Model(..model, scenes: scenes, columns: columns),
        start_timeout(initial_state.frame, current_timeout: model.timeout),
      ))
    }

    TimeoutStarted(id) ->
      Ok(
        #(Model(..model, timeout: Some(id)), {
          browser.animate()
          effect.none()
        }),
      )

    TimeoutEnded -> {
      use current <- try(model.current)
      use next <- try(utils.find_next_state(model.scenes, current))
      // even when paused, continue the current scene to its last frame
      let continue = { current.scene == next.scene } || model.auto_play

      case continue {
        False -> Ok(#(Model(..model, timeout: None), effect.none()))
        True ->
          Ok(#(
            Model(..model, current: Ok(next), timeout: None),
            effect.batch([
              set_adjacency_list_effect("display", next.scene.chars),
              start_timeout(next.frame, current_timeout: None),
            ]),
          ))
      }
    }

    PageClicked(page) -> {
      use scene <- try(utils.find_scene(model.scenes, page))
      use frame <- try(list.first(scene.frames))
      let next =
        result.map(model.current, fn(current) {
          case current.scene != scene {
            True -> BingoState(scene, frame)
            False -> current
          }
        })

      Ok(#(
        Model(..model, auto_play: False, current: next),
        effect.batch([
          case next {
            Ok(state) -> set_adjacency_list_effect("display", state.scene.chars)
            Error(_) -> effect.none()
          },

          start_timeout(frame, model.timeout),
        ]),
      ))
    }

    AutoPlayClicked -> {
      Ok(
        #(Model(..model, timeout: None, auto_play: !model.auto_play), {
          use dispatch, _ <- effect.after_paint
          case model.timeout {
            Some(id) -> browser.clear_timeout(id)
            None -> Nil
          }
          browser.animate()
          dispatch(TimeoutEnded)
        }),
      )
    }
  }
}

// MARK: VIEW

fn view(model: Model) -> Element(Msg) {
  let lines = case model.current {
    Ok(BingoState(_, Frame(_, lines:))) -> lines
    Error(_) -> []
  }

  html.div([attribute.class("matrix")], [
    display(lines, cols: model.columns, rows: model.rows),

    pagination(
      pages: list.length(model.scenes),
      page: list.fold_until(model.scenes, 1, fn(acc, s) {
        case model.current {
          Ok(state) if s == state.scene -> {
            Stop(acc)
          }
          Ok(_) -> Continue(acc + 1)
          Error(_) -> Stop(0)
        }
      }),
      cols: model.columns,
      auto_play: model.auto_play,
    ),
  ])
}

fn display(lines: List(Content), cols cols: Int, rows rows: Int) -> Element(msg) {
  let sanitized_lines = utils.pad_empty_rows(lines, rows)

  keyed.fragment(
    list.index_map(sanitized_lines, fn(line, row_num) {
      #(int.to_string(row_num), row("display", line, row_num:, cols:))
    }),
  )
}

fn row(
  name: String,
  line: Content,
  row_num row_num: Int,
  cols num_cols: Int,
) -> Element(msg) {
  let bg = string.repeat(" ", num_cols)
  let #(text, url) = case line {
    Text(text:) -> #(text, None)
    Link(text:, url:) -> #(text, Some(url))
    EmptyLine -> #(C(bg), None)
  }
  let text = case text {
    L(str) -> utils.left(str, bg)
    C(str) -> utils.center(str, bg)
    R(str) -> utils.right(str, bg)
  }

  let children =
    text
    |> string.to_graphemes
    |> list.index_map(fn(char, idx) {
      let id = int.to_string(row_num) <> "-" <> int.to_string(idx)
      #(id, character(id, dest: char, on_click: None))
    })

  let link_attrs = case url {
    Some(url) -> [attribute.href(url), attribute.target("_blank")]
    _ -> [attribute.role("div")]
  }

  keyed.element(
    "a",
    [attribute.class("row"), attribute.data("name", name), ..link_attrs],
    children,
  )
}

fn character(
  id id: String,
  dest dest: String,
  on_click on_click: Option(msg),
) -> Element(msg) {
  html.div(
    [
      attribute.id(id),
      attribute.class("split-flap"),
      attribute.data("dest", dest),
      case on_click {
        Some(m) -> event.on_click(m)
        None -> attribute.none()
      },
      case on_click {
        Some(_) -> attribute.style("cursor", "pointer")
        None -> attribute.style("cursor", "inherit")
      },
    ],
    [
      html.div([attribute.class("flap top")], [
        html.span([attribute.class("flap-content")], []),
      ]),

      html.div([attribute.class("flap bottom")], [
        html.span([attribute.class("flap-content")], []),
      ]),

      html.div([attribute.class("flap flipping-bottom")], [
        html.span([attribute.class("flap-content")], []),
      ]),
    ],
  )
}

fn pagination(
  pages pages: Int,
  page page: Int,
  cols cols: Int,
  auto_play auto_play: Bool,
) -> Element(Msg) {
  let empty = string.repeat(" ", cols)

  let dots =
    list.range(1, pages)
    |> list.map(fn(idx) {
      case idx == page {
        True -> "●"
        False -> "○"
      }
    })
    |> string.join(" ")

  let dots = case auto_play {
    True -> "( " <> dots <> " )"
    False -> "𝄆 " <> dots <> " 𝄇"
  }

  let chars =
    dots
    |> utils.center(against: empty)
    |> string.to_graphemes

  let first_dot_idx =
    list.fold_until(chars, 0, fn(acc, char) {
      case char {
        "○" | "●" -> Stop(acc)
        _ -> Continue(acc + 1)
      }
    })

  keyed.div(
    [
      attribute.data("name", "pagination"),
      attribute.class("pagination"),
      attribute.class("row"),
    ],
    list.index_map(chars, fn(char, idx) {
      let page = 1 + { { idx - first_dot_idx } / 2 }
      let id = "pb-" <> int.to_string(idx)
      #(
        id,
        character(id:, dest: char, on_click: case char {
          "○" | "●" -> Some(PageClicked(page))
          "𝄆" | "𝄇" | "(" | ")" -> Some(AutoPlayClicked)
          _ -> None
        }),
      )
    }),
  )
}
