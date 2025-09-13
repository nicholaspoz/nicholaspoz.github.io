import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
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
import prng/random
import prng/seed

// NOTE: you need to have a music font installed to see this unicode
pub const default_chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789▶()𝄢𝅘𝅥𝄽#!"

const flip_duration_ms = 30

type Model {
  // Model(chars: String, dest: String, state: State)
  Model(
    adjacency_list: dict.Dict(String, String),
    current_char: String,
    dest_char: String,
    state: State,
    flip_duration_ms: Int,
    jitter: Int,
    char_id: String,
  )
}

type State {
  Idle
  NeedsAnimation(String)
  // Target character to animate to
  Animating(String)
  // Currently animating to this character
}

type Msg {
  LetterAttrChanged(String)
  CharsAttrChanged(String)
  AnimationStarted
  BottomAnimationEnded
  FlipEnded
}

fn to_adjacency_list(chars: String) -> dict.Dict(String, String) {
  string.first(chars)
  |> result.map(fn(char) { chars <> char })
  |> result.unwrap("")
  |> string.to_graphemes
  |> list.window_by_2
  |> dict.from_list
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.open_shadow_root(True),
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
  flip_duration _flip_duration_ms: Option(Int),
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
        None -> attribute.style("cursor", "inherit")
      },
    ],
    [],
  )
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  let char_id =
    "char-"
    <> {
      let #(str, _) = random.step(random.string(), seed.random())
      str
    }
  echo "char_id: " <> char_id

  #(
    Model(
      adjacency_list: to_adjacency_list(default_chars),
      dest_char: " ",
      current_char: " ",
      state: Idle,
      flip_duration_ms: flip_duration_ms,
      jitter: int.random(25),
      char_id: char_id,
    ),
    effect.none(),
  )
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    CharsAttrChanged(chars) -> {
      #(Model(..model, state: Idle, adjacency_list: to_adjacency_list(chars)), {
        use dispatch <- effect.from
        dispatch(LetterAttrChanged(model.dest_char))
      })
    }

    LetterAttrChanged(dest) -> {
      case model.current_char == dest {
        True -> #(model, effect.none())
        False -> {
          #(
            Model(..model, dest_char: dest, state: NeedsAnimation(dest)),
            event.emit("animation-needed", json.string(model.char_id)),
          )
        }
      }
    }

    AnimationStarted -> {
      // AnimationManager told us to start animating
      let next =
        dict.get(model.adjacency_list, model.current_char) |> result.unwrap(" ")
      #(
        Model(..model, current_char: next, state: Animating(model.dest_char)),
        effect.none(),
      )
    }

    BottomAnimationEnded -> {
      // CSS animation finished
      case model.state {
        Animating(target) -> {
          case model.current_char == target {
            True -> {
              // Reached destination
              #(Model(..model, state: Idle), {
                event.emit("animation-complete", json.string(model.char_id))
              })
            }
            False -> {
              // Need to continue animating
              #(Model(..model, state: NeedsAnimation(target)), {
                event.emit("animation-needed", json.string(model.char_id))
              })
            }
          }
        }
        _ -> #(model, effect.none())
      }
    }

    FlipEnded -> {
      // Legacy - might not be needed anymore
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
    html.style([], css(model.flip_duration_ms + model.jitter)),

    html.div(
      [
        attribute.class("split-flap"),
        attribute.attribute("data-char-id", model.char_id),
        attribute.attribute("data-animation-state", case model.state {
          Idle -> "idle"
          NeedsAnimation(_) -> "needs-animation"
          Animating(_) -> "animating"
        }),
        // Listen for events from AnimationManager
        event.on("animation-start", decode.success(AnimationStarted)),
      ],
      [
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
          Animating(_) ->
            html.div(
              [
                attribute.class("flap bottom"),
              ],
              [
                html.span([attribute.class("flap-content")], [html.text(curr)]),
              ],
            )
          NeedsAnimation(_) -> element.none()
        },

        // FLIPPING BOTTOM (only during animation)
        case model.state {
          Animating(_) ->
            html.div(
              [
                attribute.class("flap flipping-bottom animate-now"),
                // Listen for animation end events
                event.on("animationend", decode.success(BottomAnimationEnded)),
              ],
              [html.span([attribute.class("flap-content")], [html.text(next)])],
            )
          _ -> element.none()
        },
      ],
    ),
  ])
}

fn curr_and_next_chars(from model: Model) -> Result(#(String, String), Nil) {
  let curr = model.current_char
  let next = result.unwrap(dict.get(model.adjacency_list, curr), " ")
  Ok(#(curr, next))
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
    font-size: 120cqw;
    font-weight: 500;
    border-radius: 5cqw;
    perspective: 400cqw;
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
    opacity: 0;
  }
  
  .flap.bottom.flipping {
    opacity: 1;
  }

  @keyframes flip-bottom {
    0% {
      transform: rotateX(80deg);      
    }
    100% {
      transform: rotateX(0deg);
    }
  }

  .flap.flipping-bottom {
    opacity: 0;
    pointer-events: none;
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 5cqw 5cqw;
    z-index: 10;
    background: rgb(40, 40, 40);
    box-shadow: none;
    border-radius: 0;
    will-change: transform;
    transform: translateZ(0);
  }
  
  .flap.flipping-bottom.animate-now {
    opacity: 1;
    animation: <flip_duration>ms ease-in flip-bottom;
    animation-fill-mode: forwards;
  }
  
  .flap.top .flap-content {
    top: 0;
    height: 100%
  }

  .flap.bottom .flap-content {
    bottom: 0;
  }

  .flap.flipping-bottom .flap-content {
    /* Positions text in bottom half of flap */
    bottom: 0;
  }
"
  |> string.replace("<flip_duration>", int.to_string(ms))
}
