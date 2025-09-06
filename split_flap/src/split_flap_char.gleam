import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import utils

pub const default_chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?/\\|@#_()<>"

const flip_duration_ms = 30

const idle_duration_ms = 20

type Model {
  Model(chars: String, dest: String, state: State)
}

type State {
  Idle
  Flipping
}

type Msg {
  LetterAttrChanged(String)
  CharsAttrChanged(String)
  DestinationChanged
  FlipStarted
  FlipEnded
  Clicked
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("letter", fn(val) {
        use char <- result.try(string.first(val))
        Ok(LetterAttrChanged(char))
      }),

      component.on_attribute_change("chars", fn(val) {
        { val }
        |> string.to_graphemes
        |> list.filter(fn(char) { char != " " })
        |> list.unique
        |> string.join("")
        |> string.append(to: " ")
        |> CharsAttrChanged
        |> Ok
      }),
    ])

  lustre.register(component, "split-flap-char")
}

pub fn element(
  char char: String,
  char_stack chars: Option(String),
  on_click on_click: Option(msg),
) -> Element(msg) {
  element.element(
    "split-flap-char",
    [
      attribute.attribute("letter", char),

      attribute.attribute("chars", case chars {
        Some(stack) -> stack
        None -> default_chars
      }),

      case on_click {
        Some(on_click) -> event.on_click(on_click)
        None -> attribute.none()
      },

      case on_click {
        Some(_) -> attribute.style("cursor", "pointer")
        None -> attribute.none()
      },
    ],
    [],
  )
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model(default_chars, " ", Idle), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    CharsAttrChanged(chars) -> {
      #(Model(..model, chars:), {
        use dispatch <- effect.from
        dispatch(DestinationChanged)
      })
    }

    LetterAttrChanged(dest) -> {
      case { string.contains(model.chars, dest) } {
        True -> {
          #(Model(..model, dest:), {
            use dispatch <- effect.from
            dispatch(DestinationChanged)
          })
        }
        False -> #(model, effect.none())
      }
    }

    DestinationChanged | FlipEnded -> {
      case model.state, string.first(model.chars) {
        Idle, Ok(x) if x != model.dest -> {
          #(Model(..model, state: Flipping), {
            use dispatch <- effect.from
            use <- utils.set_timeout(flip_duration_ms + 10)
            dispatch(FlipStarted)
          })
        }

        _, _ -> #(model, effect.none())
      }
    }

    FlipStarted -> {
      let assert Ok(#(first, rest)) = string.pop_grapheme(model.chars)
      let next = rest <> first
      #(Model(..model, chars: next, state: Idle), {
        use dispatch <- effect.from
        use <- utils.set_timeout(idle_duration_ms)
        dispatch(FlipEnded)
      })
    }

    Clicked -> {
      #(model, effect.none())
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
    html.style([], css(flip_duration_ms)),

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
      // case model.state {
      //   Idle -> element.none()
      //   Flipping ->
      //     html.div([attribute.class("flap flipping-top")], [
      //       html.span([attribute.class("flap-content")], [html.text(curr)]),
      //     ])
      // },
      // FLIPPING BOTTOM
      case model.state {
        Idle -> element.none()
        Flipping ->
          html.div([attribute.class("flap flipping-bottom")], [
            html.span([attribute.class("flap-content")], [html.text(next)]),
          ])
      },
    ]),
  ])
}

fn curr_and_next_chars(from model: Model) -> Result(#(String, String), Nil) {
  case string.to_graphemes(model.chars) |> list.take(2) {
    [a, b] -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

fn css(flip_duration ms: Int) -> String {
  "
  :host {
    display: inline-block;
    width: 100%;
    height: 100%;
    container-type: inline-size;
  }

  .split-flap {
    /* TODO -webkit-font-smoothing */
    position: relative;
    width: 100%;
    height: 100%;
    aspect-ratio: 1/1.618; /* golden ratio ;) */
    font-family: \"Fragment Mono\", monospace;
    font-weight: bold;
    font-size: 120cqw;
    border-radius: 5cqw;
    perspective: 600cqw;
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
    background: rgb(40, 40, 40);
    box-shadow: inset 0cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
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
    border-radius: 5cqw;
    user-select: text;
    height: 100%;
  }

  .flap.bottom {
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 5cqw 5cqw;
  }

  @keyframes flip-top {
    0% {
      transform: rotateX(0deg);
      box-shadow: inset 0cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
    }
    50%, 100% {
      transform: rotateX(-90deg);
      box-shadow: none;
    }
    
  }

  @keyframes flip-bottom {
    0% {
      transform: rotateX(90deg);
      box-shadow: none;
    }
    100% {
      transform: rotateX(0deg);
      box-shadow: inset 0cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
    }
  }

  .flap.flipping-top {
    pointer-events: none;
    top: 0;
    transform-origin: bottom;
    border-radius: 5cqw 5cqw 0 0;
    z-index: 10;
    background: rgb(40, 40, 40);
    animation: <flip_duration>ms ease-in flip-top;
    animation-iteration-count: 1;
    animation-fill-mode: forwards;
    box-shadow: inset 0cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
  }

  .flap.flipping-bottom {
    pointer-events: none;
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 5cqw 5cqw;
    z-index: 10;
    background: rgb(40, 40, 40);
    animation: <flip_duration>ms ease-in flip-bottom;
    animation-iteration-count: 1;
    animation-fill-mode: forwards;
    box-shadow: inset 0cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
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
  |> string.replace("<flip_duration>", int.to_string(ms))
}
