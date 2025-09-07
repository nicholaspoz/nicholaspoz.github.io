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
    ])
  lustre.register(component, "progress-bar")
}

pub fn element(
  progress progress: Int,
  cols cols: Int,
  on_back back_msg: Option(msg),
  on_forward forward_msg: Option(msg),
) -> Element(msg) {
  element.element(
    "progress-bar",
    [
      attribute.attribute("progress", int.to_string(progress)),
      attribute.attribute("cols", int.to_string(cols)),
      case back_msg {
        Some(m) -> on_back(m)
        None -> attribute.none()
      },
      case forward_msg {
        Some(m) -> on_forward(m)
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

type Model {
  Model(progress: Int, cols: Int)
}

type Msg {
  ProgressAttrChanged(Int)
  ColsAttrChanged(Int)
  BackClicked
  ForwardClicked
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model(0, 2), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    ColsAttrChanged(cols) -> #(Model(..model, cols:), effect.none())
    ProgressAttrChanged(progress) -> #(Model(..model, progress:), effect.none())
    BackClicked -> #(model, event.emit("go_back", json.null()))
    ForwardClicked -> #(model, event.emit("go_forward", json.null()))
  }
}

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.style([], css(model.cols)),
    html.div([attribute.class("progress-bar")], [
      sf_char.element("<", Some("<"), on_click: Some(BackClicked)),

      sf_display.element(
        [
          sf_display.Text(text: progress_string(model.progress, model.cols)),
        ],
        cols: model.cols - 2,
        rows: 1,
        chars: Some("ABCDEFGHIJK%"),
      ),

      sf_char.element(">", Some(">"), on_click: Some(ForwardClicked)),
    ]),
  ])
}

fn progress_string(progress: Int, cols: Int) -> String {
  string.repeat("%", progress * cols / 100)
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
  "
  |> string.replace("<cols>", int.to_string(cols - 2))
}
