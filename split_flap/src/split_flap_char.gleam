import gleam/list
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html

import utils

pub const chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?/\\|@#_()<>"

type Model {
  Model(char_stack: String, dest: String, state: State)
}

type State {
  Idle
  Flipping
}

type Msg {
  LetterAttrChanged(String)
  DestinationChanged
  FlipStarted
  FlipEnded
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("letter", fn(val) {
        use char <- result.try(string.first(val))
        case string.contains(chars, char) {
          True -> Ok(LetterAttrChanged(val))
          False -> Error(Nil)
        }
      }),
    ])

  lustre.register(component, "split-flap-char")
}

pub fn element(char: String) -> Element(msg) {
  element.element("split-flap-char", [attribute.attribute("letter", char)], [])
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model(chars, " ", Idle), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    LetterAttrChanged(dest) -> {
      #(Model(..model, dest:), {
        use dispatch <- effect.from
        dispatch(DestinationChanged)
      })
    }

    DestinationChanged | FlipEnded -> {
      case model.state, string.first(model.char_stack) {
        Idle, Ok(x) if x != model.dest -> {
          #(Model(..model, state: Flipping), {
            use dispatch <- effect.from
            use <- utils.set_timeout(50)
            dispatch(FlipStarted)
          })
        }

        _, _ -> #(Model(..model, state: Idle), effect.none())
      }
    }

    FlipStarted -> {
      let assert Ok(#(first, rest)) = string.pop_grapheme(model.char_stack)
      let next = rest <> first
      #(Model(..model, char_stack: next, state: Idle), {
        use dispatch <- effect.from
        use <- utils.set_timeout(15)
        dispatch(FlipEnded)
      })
    }
  }
}

/// The Flap is a horizontal stack of two halves. 
/// Flipping elements are conditionally rendered, 
/// otherwise the GPU goes bananas.
/// 
fn view(model: Model) -> Element(Msg) {
  let assert Ok(#(curr, next)) = curr_and_next_chars(model)

  element.fragment([
    html.style([], css),

    html.div([attribute.class("split-flap")], [
      // TOP FLAP (always visible)
      html.div([attribute.class("flap top")], [
        html.span([attribute.class("flap-content")], [
          html.text(case model.state {
            Idle -> curr
            _ -> next
          }),
        ]),
      ]),

      // BOTTOM FLAP
      case model.state {
        Idle -> element.none()
        _ ->
          html.div([attribute.class("flap bottom")], [
            html.span([attribute.class("flap-content")], [html.text(curr)]),
          ])
      },

      // FLIPPING TOP
      case model.state {
        Idle -> element.none()
        Flipping ->
          html.div(
            [
              attribute.class("flap flipping-top"),
              attribute.data("state", "flipping"),
            ],
            [html.span([attribute.class("flap-content")], [html.text(curr)])],
          )
      },

      // FLIPPING BOTTOM
      case model.state {
        Idle -> element.none()
        Flipping ->
          html.div(
            [
              attribute.class("flap flipping-bottom"),
              attribute.data("state", "flipping"),
            ],
            [html.span([attribute.class("flap-content")], [html.text(next)])],
          )
      },
    ]),
  ])
}

fn curr_and_next_chars(from model: Model) -> Result(#(String, String), Nil) {
  case string.to_graphemes(model.char_stack) |> list.take(2) {
    [a, b] -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

const css = "
  :host {
    display: inline-block;
    perspective: 10rem;
    width: 100%;
    height: 100%;
    container-type: inline-size;
  }

  .split-flap {
    /* TODO -webkit-font-smoothing */
    position: relative;
    width: 100%;
    height: 100%;
    aspect-ratio: 5/8;
    font-family: \"Fragment Mono\", monospace;
    font-weight: bold;
    font-size: 120cqw;
    background: rgb(40, 40, 40);
    border-radius: 5cqw;
    box-shadow: inset 0cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
  }

  .split-flap::selection {
    background: white;
    color: black;
  }

  .split-flap::after {
    content: \"\";
    position: absolute;
    left: 0;
    right: 0;
    top: 50%;
    height: 3.5cqw;
    background: rgb(20, 20, 20);
    z-index: 20;
  }

  .flap {
    position: absolute;
    width: 100%;
    height: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #d2d1d1;
    overflow: hidden;
    user-select: none;
    z-index: 1;
  }

  .flap-content {
    position: absolute;
    width: 100%;
    height: 200%;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    z-index: 0;
  }

  .flap.top {
    top: 0;
    transform-origin: bottom;
    border-radius: 0.5cqw 0.5cqw 0 0;
    user-select: text;
    height: 100%
  }

  .flap.bottom {
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 0.5cqw 0.5cqw;
  }

  .flap.flipping-top {
    opacity: 0;
    pointer-events: none;
    top: 0;
    transform-origin: bottom;
    border-radius: 0.5cqw 0.5cqw 0 0;
    z-index: 10;
    transform: rotateX(0deg);
    background: rgb(40, 40, 40);
  }

  .flap.flipping-bottom {
    /* Animated flap that rotates down during character change */
    opacity: 0;
    pointer-events: none;
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 0.5cqw 0.5cqw;
    z-index: 10;
    transform: rotateX(90deg);
    background: rgb(40, 40, 40);
  }

  .flap.flipping-top[data-state=\"flipping\"] {
    opacity: 1;
    z-index: 10;
    box-shadow: 0 0.5cqw 1cqw rgba(0, 0, 0, 0.3);
    transform: rotateX(-90deg);
    transition: transform 0.05s ease-in;
  }
  
  .flap.flipping-bottom[data-state=\"flipping\"] {
    opacity: 1;
    box-shadow: 0 0.5cqw 1cqw rgba(0, 0, 0, 0.3);
    z-index: 10;
    transform: rotateX(0deg);
    transition: transform 0.015s linear;
    transition-delay: 0.05s;
  }
  
  .flap.top .flap-content {
    top: 0;
    height: 100%
  }

  .flap.bottom .flap-content {
    bottom: 0;
  }

  .flap.flipping-top .flap-content {
    top: 0;
  }

  .flap.flipping-bottom .flap-content {
    /* Positions text in bottom half of flap */
    bottom: 0;
  }
"
