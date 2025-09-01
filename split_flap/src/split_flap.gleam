import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html

pub const chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?@#$%^&*()"

// fn index_of(char: String) -> Int {
//   case string.length(char) {
//     1 -> do_index_of(char, chars, 0)
//     _ -> 0
//   }
// }

// fn do_index_of(needle: String, haystack: String, idx: Int) -> Int {
//   case string.pop_grapheme(haystack) {
//     Ok(#(char, rest)) ->
//       case char == needle {
//         True -> idx
//         False -> do_index_of(needle, rest, idx + 1)
//       }

//     Error(_) -> 0
//   }
// }

pub fn main() {
  let assert Ok(_) = register()
  Nil
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("letter", fn(val) {
        echo "on_attribute_change ZOMG"
        use char <- result.try(string.first(val))
        echo "char ZOMG " <> char
        case string.contains(chars, char) {
          True -> Ok(SetDestination(val))
          False -> Error(Nil)
        }
      }),
    ])

  echo "registered ZOMG"

  lustre.register(component, "split-flap-char")
}

/// Util for convenience to create the element.
pub fn element() -> Element(msg) {
  element.element("split-flap-char", [], [])
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(char_stack: String, dest: String, state: State)
}

type State {
  Idle
  FlippingTop
  FlippingBottom
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model(chars, " ", Idle), effect.none())
}

// fn set_destination(dest: String) -> effect.Effect(Msg) {
//   use dispatch <- effect.from
//   use <- set_timeout(1000)

//   dispatch(SetDestination(dest))
// }

// UPDATE ----------------------------------------------------------------------

type Msg {
  SetDestination(String)
  StartFlip
  EndFlip
}

fn to_string(msg: Msg) -> String {
  case msg {
    SetDestination(dest) -> "SetDestination(" <> dest <> ")"
    StartFlip -> "StartFlip"
    EndFlip -> "EndFlip"
  }
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  echo "update ZOMG " <> to_string(msg)
  case msg {
    SetDestination(dest) -> {
      #(Model(..model, dest:), {
        use dispatch <- effect.from
        dispatch(StartFlip)
      })
    }

    StartFlip -> {
      case string.first(model.char_stack) {
        Ok(x) if x != model.dest -> {
          #(Model(..model, state: FlippingTop), {
            use dispatch <- effect.from
            use <- set_timeout(1000)
            dispatch(EndFlip)
          })
        }
        _ -> #(Model(..model, state: Idle), effect.none())
      }
    }

    EndFlip -> {
      let assert Ok(#(first, rest)) = string.pop_grapheme(model.char_stack)
      let next = rest <> first
      echo "EndFlip ZOMG " <> next
      #(Model(..model, char_stack: next, state: Idle), {
        use dispatch <- effect.from
        use <- set_timeout(1000)

        dispatch(StartFlip)
      })
    }
  }
}

@external(javascript, "./split_flap.ffi.mjs", "set_timeout")
pub fn set_timeout(_delay: Int, _cb: fn() -> a) -> Nil {
  // It's good practice to provide a fallback for side effects that rely on FFI
  // where possible. This means your app can run - without the side effect - in
  // environments other than the browser.
  Nil
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let assert Ok(char) = string.first(model.char_stack)
  echo "view ZOMG " <> char
  element.fragment([
    html.style([], css),

    html.div([attribute.class("split-flap")], [
      html.div([attribute.class("flap top")], [
        html.span([attribute.class("flap-content")], [html.text(char)]),
      ]),
      html.div([attribute.class("flap bottom")], [
        html.span([attribute.class("flap-content")], [html.text(char)]),
      ]),

      html.div(
        [
          attribute.class("flap flipping-top"),
          case model.state {
            FlippingTop -> attribute.data("state", "flipping")
            _ -> attribute.none()
          },
        ],
        [
          html.span([attribute.class("flap-content")], [html.text(char)]),
        ],
      ),

      html.div(
        [
          attribute.class("flap flipping-bottom"),
          case model.state {
            FlippingBottom -> attribute.data("state", "flipping")
            _ -> attribute.none()
          },
        ],
        [
          html.span([attribute.class("flap-content")], [html.text(char)]),
        ],
      ),
    ]),
  ])
}

/// I just want intellisense for inline css is that so much to ask
const css = "
  :host {
    display: inline-block;
    perspective: 400px;
  }

  .split-flap {
    position: relative;
    width: 50px;
    height: 80px;
    font-family: \"Fragment Mono\", monospace;
    font-size: 60px;
    font-weight: bold;
    background: rgb(40, 40, 40);
    border-radius: 4px;
    box-shadow: inset 0px 1px 5px 5px rgba(0, 0, 0, 0.8);
    cursor: pointer;
  }

  .split-flap::after {
    content: \"\";
    position: absolute;
    left: 0;
    right: 0;
    top: 50%;
    height: 2px;
    background: #000;
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
  }

  .flap.top {
    top: 0;
    transform-origin: bottom;
    border-radius: 4px 4px 0 0;
    z-index: 2;
    user-select: text;
  }

  .flap.bottom {
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 4px 4px;
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
  }

  .flap.top .flap-content {
    top: 0;
  }

  .flap.bottom .flap-content {
    bottom: 0;
  }

  .flap.flipping-top {
    opacity: 0;
    pointer-events: none;
    top: 0;
    transform-origin: bottom;
    border-radius: 4px 4px 0 0;
    z-index: 10;
    box-shadow: 0 2px 4px rgb(0, 0, 0);
  }

  .flap.flipping-bottom {
    /* Animated flap that rotates down during character change */
    opacity: 0;
    pointer-events: none;
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 4px 4px;
    z-index: 10;
    box-shadow: 0 2px 4px rgb(0, 0, 0); /* Shadow for depth */
  }

  .flap.flipping-top .flap-content {
    top: 0;
  }

  .flap.flipping-bottom .flap-content {
    /* Positions text in bottom half of flap */
    bottom: 0;
  }
"
