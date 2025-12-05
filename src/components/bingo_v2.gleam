import gleam/bool
import gleam/function
import gleam/int
import gleam/json
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result.{lazy_or, try}
import gleam/string
import lustre
import lustre/attribute
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed
import lustre/event

import components/bingo/model.{type Content, type Frame, type Scene, Link}
import components/bingo/scenes.{scenes}
import components/display_fns
import utils.{find_next}

const default_chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789▶()𝄢𝅘𝅥𝄽#!"

pub fn register() -> Result(Nil, lustre.Error) {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Ok(Nil)
}

type BingoState {
  BingoState(scene: Scene, frame: Frame)
}

type Model {
  Model(
    scenes: List(Scene),
    columns: Int,
    current: Result(BingoState, Nil),
    auto_play: Bool,
    timeout: Option(Int),
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
  // let scenes = scenes.scenes(columns)
  let state = initial_state([])

  #(
    Model(
      scenes: [],
      columns: cols,
      current: state,
      auto_play: True,
      timeout: None,
    ),
    {
      use dispatch, root_element <- effect.before_paint
      utils.on_resize(root_element, fn() {
        echo "Resized"
        dispatch(Resized)
      })
    },
  )
}

fn get_cols_effect() -> Effect(Msg) {
  use dispatch, root_element <- effect.before_paint
  let cols = case utils.measure_orientation(root_element) {
    "portrait" -> 15
    _ -> 27
  }
  dispatch(ColumnsChanged(cols))
}

fn initial_state(scenes: List(Scene)) -> Result(BingoState, Nil) {
  use first_scene <- try(list.first(scenes))
  use first_frame <- try(list.first(first_scene.frames))
  Ok(BingoState(first_scene, first_frame))
}

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
    Resized -> Ok(#(model, get_cols_effect()))

    ColumnsChanged(columns) -> {
      use <- bool.guard(columns == model.columns, Ok(#(model, effect.none())))
      case model.timeout {
        Some(id) -> utils.clear_timeout(id)
        None -> Nil
      }
      let scenes = scenes(columns)
      use initial_state <- try(initial_state(scenes))
      Ok(#(
        Model(
          ..model,
          scenes: scenes,
          columns: columns,
          current: Ok(initial_state),
          timeout: None,
        ),
        start_timeout(initial_state.frame, None),
      ))
    }

    TimeoutStarted(id) ->
      Ok(
        #(Model(..model, timeout: Some(id)), {
          utils.animate()
          effect.none()
        }),
      )

    TimeoutEnded -> {
      use current <- try(model.current)
      use next <- try(find_next_state(model.scenes, current))
      // even when paused, continue the current scene to its last frame
      let continue = { current.scene == next.scene } || model.auto_play

      case continue {
        False -> Ok(#(Model(..model, timeout: None), effect.none()))
        True ->
          Ok(#(
            Model(..model, current: Ok(next), timeout: None),
            start_timeout(next.frame, current_timeout: None),
          ))
      }
    }

    PageClicked(page) -> {
      use scene <- try(find_scene(model.scenes, page))
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
        start_timeout(frame, model.timeout),
      ))
    }

    AutoPlayClicked -> {
      Ok(
        #(Model(..model, timeout: None, auto_play: !model.auto_play), {
          use dispatch, _ <- effect.after_paint
          case model.timeout {
            Some(id) -> utils.clear_timeout(id)
            None -> Nil
          }
          utils.animate()
          dispatch(TimeoutEnded)
        }),
      )
    }
  }
}

fn find_scene(scenes: List(Scene), page: Int) -> Result(Scene, Nil) {
  case scenes, page {
    _, 1 -> list.first(scenes)
    [], _ -> Error(Nil)
    [_, ..rest], _ -> find_scene(rest, page - 1)
  }
}

fn start_timeout(frame: Frame, current_timeout id: Option(Int)) -> Effect(Msg) {
  use dispatch, _ <- effect.after_paint
  case id {
    Some(id) -> utils.clear_timeout(id)
    None -> Nil
  }
  let id = utils.set_timeout(frame.ms, fn() { dispatch(TimeoutEnded) })
  dispatch(TimeoutStarted(id))
}

fn find_next_state(
  scenes: List(Scene),
  current: BingoState,
) -> Result(BingoState, Nil) {
  case find_next(current.scene.frames, current.frame) {
    Ok(frame) -> Ok(BingoState(current.scene, frame))
    Error(_) ->
      lazy_or(
        {
          use scene <- try(find_next(scenes, current.scene))
          use frame <- try(list.first(scene.frames))
          Ok(BingoState(scene, frame))
        },
        // Start over
        fn() { initial_state(scenes) },
      )
  }
}

fn view(model: Model) -> Element(Msg) {
  let #(lines, chars) = case model.current {
    Ok(BingoState(scene, frame)) -> #(frame.lines, scene.chars)
    Error(_) -> #([], None)
  }

  html.div(
    [
      attribute.class("panel"),
      component.part("panel"),
    ],
    [
      html.div([attribute.class("matrix"), component.part("matrix")], [
        display(lines, chars, cols: model.columns, rows: 7),

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
      ]),
    ],
  )
}

fn display(
  lines: List(Content),
  chars: Option(String),
  cols cols: Int,
  rows rows: Int,
) -> Element(msg) {
  let sanitized_lines =
    lines
    |> utils.zip_longest(list.range(0, rows - 1), _)
    |> list.filter_map(utils.first_is_some)

  let adjacency_list =
    utils.to_adjacency_list(case chars {
      Some(chars) -> chars
      None -> default_chars
    })

  let list_data =
    adjacency_list
    |> json.dict(function.identity, json.string)
    |> json.to_string()

  keyed.div(
    [attribute.class("display"), attribute.data("adjacency-list", list_data)],
    list.index_map(sanitized_lines, fn(line, line_num) {
      #(int.to_string(line_num), row(line, row: line_num, cols: cols))
    }),
  )
}

fn row(
  line: Option(Content),
  row row_num: Int,
  cols num_cols: Int,
) -> Element(msg) {
  let chars = case line {
    Some(content) ->
      content.text
      |> string.pad_end(num_cols, " ")
      |> string.slice(0, num_cols)

    None -> string.repeat(" ", num_cols)
  }

  let children =
    chars
    |> string.to_graphemes
    |> list.index_map(fn(char, idx) {
      let id = int.to_string(row_num) <> "-" <> int.to_string(idx)
      #(id, character(id, dest: char, on_click: None))
    })

  let link_attrs = case line {
    Some(Link(_, url:)) -> [attribute.href(url), attribute.target("_blank")]
    _ -> []
  }

  keyed.element(
    "a",
    [attribute.class("row"), component.part("row"), ..link_attrs],
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
    |> display_fns.center(against: empty)
    |> string.to_graphemes

  let first_dot_idx =
    list.fold_until(chars, 0, fn(acc, char) {
      case char {
        "○" | "●" -> Stop(acc)
        _ -> Continue(acc + 1)
      }
    })

  let list_data =
    utils.to_adjacency_list(" ○●()𝄆𝄇")
    |> json.dict(function.identity, json.string)
    |> json.to_string()

  keyed.div(
    [
      attribute.id("pagination"),
      attribute.class("row"),
      attribute.data("adjacency-list", list_data),
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
// const css = "
//   :host {
//     display: block;
//     container-type: inline-size;
//     height: 100%;
//     width: 100%;
//     min-height: fit-content;
//   }

//   .panel {
//     position: relative;
//     width: 100%;
//     height: 100%;
//     min-height: fit-content;
//     overflow: hidden;

//     display: flex;
//     flex-direction: column;
//     justify-content: center;
//   }

//   .matrix {
//     display: flex;
//     flex-direction: column;
//     justify-content: space-between;
//     height: 100%;
//     min-height: fit-content;
//   }

//   .display {
//     container-type: inline-size;
//     display: flex;
//     flex-direction: column;
//     gap: 1cqh; 
//     width: 100%;
//     height: 100%;
//     background-color: rgb(40, 40, 40);
//   }

//   .row {
//     container-type: inline-size;
//     display: flex;
//     flex-direction: row;
//     gap: 1cqw;
//     cursor: default;
//   }

//   .row[href] {
//     cursor: pointer;
//   }

//   .split-flap {
//     position: relative;
//     width: 100%;
//     aspect-ratio: 1/1.618; /* golden ratio ;) */
//     display: inline-block;
//     container-type: inline-size;
//   }

//   .split-flap::selection {
//     background: white;
//     color: black;
//   }

//   .split-flap::after {
//     content: \"\";
//     position: absolute;
//     left: 0;
//     right: 0;
//     top: 50%;
//     height: 3.5cqw;
//     background: rgb(20, 20, 20);
//     z-index: 20;
//   }

//   .flap {
//     position: absolute;
//     width: 100%;
//     height: 50%;
//     font-size: 120cqw;
//     font-weight: 500;
//     color: #d2d1d1;
//     overflow: hidden;
//     user-select: none;
//     border-radius: 5cqw;
//     perspective: 400cqw;
//     background: rgb(40, 40, 40);
//     box-shadow: inset 1cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
//     z-index: 1;

//     display: flex;
//     align-items: center;
//     justify-content: center;
//   }

//   .flap-content {
//     position: absolute;
//     width: 100%;
//     height: 200%;
//     display: flex;
//     align-items: center;
//     justify-content: center;
//     text-align: center;
//     z-index: 0;
//   }

//   .flap.top {
//     top: 0;
//     transform-origin: bottom;
//     border-radius: 5cqw;
//     user-select: text;
//     height: 100%;
//   }

//   .flap.bottom {
//     bottom: 0;
//     transform-origin: top;
//     border-radius: 0 0 5cqw 5cqw;
//     opacity: 0;
//   }

//   .flap.flipping-bottom {
//     pointer-events: none;
//     bottom: 0;
//     transform-origin: top;
//     border-radius: 0 0 5cqw 5cqw;
//     z-index: 10;
//     transform: rotateX(90deg);
//     will-change: transform;
//   }

//   .flap.top .flap-content {
//     top: 0;
//     height: 100%
//   }

//   .flap.bottom .flap-content {
//     bottom: 0;
//   }

//   .flap.flipping-bottom .flap-content {
//     bottom: 0;
//   }
//   "
