import components/display_fns
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import components/char as sf_char
import components/display as sf_display

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("progress", fn(val) {
        use parsed <- result.try(int.parse(val))
        Ok(ProgressAttrChanged(parsed))
      }),

      component.on_attribute_change("cols", fn(val) {
        use parsed <- result.try(int.parse(val))
        Ok(ColsAttrChanged(int.max(parsed, 2)))
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
  progress progress: Int,
  cols cols: Int,
  on_back back_msg: Option(msg),
  on_forward forward_msg: Option(msg),
  auto_play auto_play: Bool,
  on_auto_play auto_play_msg: Option(msg),
) -> Element(msg) {
  element.element(
    "progress-bar",
    [
      component.part("progress-bar"),
      attribute.attribute("progress", int.to_string(progress)),
      attribute.attribute("cols", int.to_string(cols)),
      attribute.attribute("auto_play", case auto_play {
        True -> "true"
        False -> "false"
      }),
      case back_msg {
        Some(m) -> on_back(m)
        None -> attribute.none()
      },
      case forward_msg {
        Some(m) -> on_forward(m)
        None -> attribute.none()
      },
      case auto_play_msg {
        Some(m) -> on_auto_play(m)
        None -> attribute.none()
      },
    ],
    [],
  )
}

pub fn on_back(msg: msg) -> Attribute(msg) {
  event.on("go_back", decode.success(msg))
}

pub fn on_forward(msg: msg) -> Attribute(msg) {
  event.on("go_forward", decode.success(msg))
}

pub fn on_auto_play(msg: msg) -> Attribute(msg) {
  event.on("auto_play", decode.success(msg))
}

type Model {
  Model(progress: Int, cols: Int, auto_play: Bool)
}

type Msg {
  ProgressAttrChanged(Int)
  ColsAttrChanged(Int)
  AutoPlayAttrChanged(Bool)
  BackClicked
  ForwardClicked
  AutoPlayClicked
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model(0, 2, True), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    ColsAttrChanged(cols) -> #(Model(..model, cols:), effect.none())
    ProgressAttrChanged(progress) -> #(Model(..model, progress:), effect.none())
    AutoPlayAttrChanged(auto_play) -> #(
      Model(..model, auto_play:),
      effect.none(),
    )

    BackClicked -> #(model, event.emit("go_back", json.null()))
    ForwardClicked -> #(model, event.emit("go_forward", json.null()))
    AutoPlayClicked -> #(model, event.emit("auto_play", json.null()))
  }
}

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.style([], css(model.cols)),
    html.div([attribute.class("progress-bar")], [
      sf_char.element("◂", Some("◂"), on_click: Some(BackClicked)),

      progress_button(model),

      sf_char.element("▸", Some("▸"), on_click: Some(ForwardClicked)),
    ]),
  ])
}

fn progress_button(model: Model) -> Element(Msg) {
  let len = model.cols - 2
  let progress = model.progress
  let auto_play = model.auto_play
  let empty_char = "▫"
  let filled_char = "▪"
  let empty = empty_char |> string.repeat(len)
  let filled = filled_char |> string.repeat(progress * len / 100)
  let pct = display_fns.left(filled, against: empty)

  html.button(
    [
      attribute.class("progress-bar-button"),
      event.on_click(AutoPlayClicked),
    ],
    [
      sf_display.element(
        [
          sf_display.Text(text: {
            case auto_play {
              True -> pct
              False -> display_fns.center("(PAUSED)", against: pct)
            }
          }),
        ],
        cols: model.cols - 2,
        rows: 1,
        chars: Some("ABCDEFGHIJKLMNOPQRSTUVWXYZ()" <> empty_char <> filled_char),
      ),
    ],
  )
}

fn css(cols: Int) -> String {
  "
  :host {
    display: inline-block;
    width: 100%;
  }

  split-flap-char {
    padding: 0.9cqw 0.3cqw;
  }

  .progress-bar {
    width: 100%;
    display: grid;
    grid-template-columns: 1fr <cols>fr 1fr;
    gap: 0;
  }

  .progress-bar-button {
    width: 100%;
    height: 100%;
    background: none;
    padding: 0;
    margin: 0;
    border: none;
  }
  
  split-flap-display::part(row) {
    cursor: pointer;
  }
  "
  |> string.replace("<cols>", int.to_string(cols - 2))
}
