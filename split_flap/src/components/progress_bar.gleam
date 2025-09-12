import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed
import lustre/event

import components/char as sf_char
import components/display_fns

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("cols", fn(val) {
        use parsed <- result.try(int.parse(val))
        Ok(ColsAttrChanged(int.max(parsed, 2)))
      }),

      component.on_attribute_change("pages", fn(val) {
        use parsed <- result.try(int.parse(val))
        Ok(PagesAttrChanged(parsed))
      }),

      component.on_attribute_change("page", fn(val) {
        use parsed <- result.try(int.parse(val))
        Ok(PageAttrChanged(parsed))
      }),
      component.on_attribute_change("auto_play", fn(val) {
        case val {
          "true" | "1" -> Ok(AutoPlayAttrChanged(True))
          _ -> Ok(AutoPlayAttrChanged(False))
        }
      }),
    ])
  lustre.register(component, "progress-bar")
}

pub fn element(
  pages pages: Int,
  page page: Int,
  cols cols: Int,
  auto_play auto_play: Bool,
  on_page page_handler: fn(Int) -> msg,
  on_auto_play auto_play_msg: msg,
) -> Element(msg) {
  element.element(
    "progress-bar",
    [
      component.part("progress-bar"),
      attribute.attribute("pages", int.to_string(pages)),
      attribute.attribute("page", int.to_string(page)),
      attribute.attribute("cols", int.to_string(cols)),
      attribute.attribute("auto_play", case auto_play {
        True -> "true"
        False -> "false"
      }),
      on_auto_play(auto_play_msg),
      on_page(page_handler),
    ],
    [],
  )
}

pub fn on_page(handler: fn(Int) -> msg) -> Attribute(msg) {
  event.on("page_clicked", {
    decode.at(["detail"], decode.int) |> decode.map(handler)
  })
}

pub fn on_auto_play(msg: msg) -> Attribute(msg) {
  event.on("auto_play", decode.success(msg))
}

type Model {
  Model(pages: Int, page: Int, cols: Int, auto_play: Bool)
}

type Msg {
  PagesAttrChanged(Int)
  PageAttrChanged(Int)
  ColsAttrChanged(Int)
  AutoPlayAttrChanged(Bool)
  PageClicked(Int)
  AutoPlayClicked
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model(0, 0, 28, True), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    ColsAttrChanged(cols) -> #(Model(..model, cols:), effect.none())
    PagesAttrChanged(pages) -> #(Model(..model, pages:), effect.none())
    PageAttrChanged(page) -> #(Model(..model, page:), effect.none())
    AutoPlayAttrChanged(auto_play) -> #(
      Model(..model, auto_play:),
      effect.none(),
    )

    PageClicked(page) -> #(model, event.emit("page_clicked", json.int(page)))
    AutoPlayClicked -> #(model, event.emit("auto_play", json.null()))
  }
}

fn view(model: Model) -> Element(Msg) {
  let pages = model.pages
  let page = model.page
  let auto_play = model.auto_play
  let empty_dot = "○"
  let filled_dot = "●"
  let stop = "⏹"
  let start = "▸"

  let dots =
    list.range(1, pages)
    |> list.map(fn(idx) {
      case idx == page {
        True -> filled_dot
        False -> empty_dot
      }
    })
    |> string.join(" ")

  let dots_len = {
    pages * 2
  }

  let control =
    case auto_play {
      True -> stop
      False -> start
    }
    |> display_fns.right(against: string.repeat(" ", dots_len + 2))

  let empty = string.repeat(" ", model.cols)
  let chars =
    control
    |> display_fns.center(against: empty)
    |> display_fns.center(dots, against: _)
    |> string.to_graphemes

  let first_dot_idx =
    list.fold_until(chars, 0, fn(acc, char) {
      case char {
        "○" | "●" -> Stop(acc)
        _ -> Continue(acc + 1)
      }
    })

  element.fragment([
    html.style([], css(model.cols)),
    keyed.div(
      [attribute.class("progress-bar")],
      list.index_map(chars, fn(char, idx) {
        let page = 1 + { { idx - first_dot_idx } / 2 }
        echo ["HEY", int.to_string(idx), char] |> string.join(" ")

        #(
          "pb-" <> int.to_string(idx),
          sf_char.element(
            char:,
            char_stack: case char {
              "○" | "●" -> Some(empty_dot <> filled_dot)
              "▸" | "⏹" -> Some(start <> stop)
              _ -> None
            },
            on_click: case char {
              "○" | "●" -> Some(PageClicked(page))
              "▸" | "⏹" -> Some(AutoPlayClicked)
              _ -> None
            },
          ),
        )
      }),
    ),
  ])
}

fn css(cols: Int) -> String {
  "
  :host {
    display: inline-block;
    width: 100%;
  }

  .progress-bar {
    display: flex;
    flex-direction: row;
    gap: 0;
  }
  split-flap-char {
    padding: 0.9cqw 0.3cqw;
  }
  "
  |> string.replace("<cols>", int.to_string(cols - 2))
}
