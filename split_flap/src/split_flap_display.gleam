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
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed

import split_flap_char

fn error_string(error: json.DecodeError) -> String {
  case error {
    json.UnexpectedEndOfInput -> "UnexpectedEndOfInput"
    json.UnexpectedByte(byte) -> "UnexpectedByte(" <> byte <> ")"
    json.UnexpectedSequence(sequence) ->
      "UnexpectedSequence(" <> sequence <> ")"
    json.UnableToDecode(errors) -> "UnableToDecode(" <> "todo" <> ")"
  }
}

pub fn register() -> Result(Nil, lustre.Error) {
  let assert Ok(_) = split_flap_char.register()

  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("lines", fn(val) {
        echo "on_attribute_change" <> val
        let lines = json.parse(val, using: decode.list(of: decode.string))
        case lines {
          Ok(lines) -> Ok(SetLines(lines))
          Error(error) -> {
            echo "error " <> error_string(error)
            Ok(Noop)
          }
        }
      }),
    ])

  lustre.register(component, "split-flap-display")
}

pub fn element() -> Element(msg) {
  element.element("split-flap-display", [], [])
}

type Msg {
  SetLines(List(String))
  Noop
}

type Model {
  Model(rows: Int, cols: Int, lines: List(String))
}

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model(6, 22, []), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    SetLines(lines) -> #(Model(model.rows, model.cols, lines), effect.none())
    Noop -> #(model, effect.none())
  }
}

fn zip_longest(list1: List(a), list2: List(b)) -> List(#(Option(a), Option(b))) {
  let #(head1, rest1) = case list1 {
    [] -> #(None, [])
    [h, ..rest] -> #(Some(h), rest)
  }

  let #(head2, rest2) = case list2 {
    [] -> #(None, [])
    [h, ..rest] -> #(Some(h), rest)
  }

  // let 

  let el = case head1, head2 {
    None, None -> None
    Some(h1), None -> Some(#(Some(h1), None))
    None, Some(h2) -> Some(#(None, Some(h2)))
    Some(h1), Some(h2) -> Some(#(Some(h1), Some(h2)))
  }

  case el {
    None -> []
    Some(el) -> list.prepend(zip_longest(rest1, rest2), el)
  }
}

fn view(model: Model) -> Element(msg) {
  let rows_and_lines =
    zip_longest(list.range(0, model.rows - 1), model.lines)
    |> list.filter_map(fn(el) {
      case el {
        #(Some(row_num), line) -> Ok(#(row_num, line))
        _ -> Error(Nil)
      }
    })

  element.fragment([
    html.style([], css),

    keyed.div(
      [attribute.class("display")],
      list.map(rows_and_lines, fn(row_and_line) {
        let #(row_num, line) = row_and_line
        #(int.to_string(row_num), row(row_num, model.cols, line))
      }),
    ),
  ])
}

fn row(index: Int, num_cols: Int, line: Option(String)) -> Element(msg) {
  let chars =
    string.to_graphemes(case line {
      None -> string.repeat(" ", num_cols)
      Some(line) -> string.pad_end(line, num_cols, " ")
    })
    |> zip_longest(list.range(0, num_cols - 1), _)
    |> list.filter_map(fn(el) {
      case el {
        #(Some(col_num), char) -> Ok(#(col_num, char))
        _ -> Error(Nil)
      }
    })

  keyed.div(
    [attribute.class("row")],
    list.map(chars, fn(cols_and_chars) {
      let #(col_num, char) = cols_and_chars
      let key = int.to_string(index) <> "-" <> int.to_string(col_num)
      #(key, split_flap_char.element(option.unwrap(char, " ")))
    }),
  )
}

const css = "
  :host {
    display: inline-block;
    width: 100%;
    height: 100%;
    container-type: inline-size;
  }

  split-flap-char {
    padding: 1cqw 0.3cqw;
  }

  .display {
    display: flex;
    flex-direction: column;
    gap: 0;
    border: 1cqw solid rgb(20, 20, 20);
    border-radius: 0.5cqw;
    /* background: rgb(40, 40, 40); */
    background: linear-gradient(250deg, rgb(40, 40, 40) 0%,rgb(60, 60, 60) 25%,rgba(40,40,40,1) 80%);
    padding: 2cqw 4cqw;
    box-shadow: inset 0cqw -0.3cqw 1cqw 0.3cqw rgba(0, 0, 0, 0.4)
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 0rem;
  }
"
