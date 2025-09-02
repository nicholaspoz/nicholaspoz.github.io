import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Lt}
import gleam/string
import lustre
import lustre/attribute
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed

import split_flap_char

pub type Content {
  Text(text: String)
  Link(text: String, url: String)
}

fn content_decoder() -> decode.Decoder(Content) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "text" -> {
      use text <- decode.field("text", decode.string)
      decode.success(Text(text:))
    }
    "link" -> {
      use text <- decode.field("text", decode.string)
      use url <- decode.field("url", decode.string)
      decode.success(Link(text:, url:))
    }
    _ -> decode.failure(Text(""), "No variant found")
  }
}

type Line =
  List(Content)

fn decode_error_string(error: decode.DecodeError) -> String {
  case error {
    decode.DecodeError(expected:, found:, path:) ->
      expected <> " | " <> found <> " | " <> string.join(path, ", ")
  }
}

fn line_decoder() -> decode.Decoder(Line) {
  decode.list(content_decoder())
}

fn error_string(error: json.DecodeError) -> String {
  case error {
    json.UnexpectedEndOfInput -> "UnexpectedEndOfInput"
    json.UnexpectedByte(byte) -> "UnexpectedByte(" <> byte <> ")"
    json.UnexpectedSequence(sequence) ->
      "UnexpectedSequence(" <> sequence <> ")"
    json.UnableToDecode(error) ->
      "UnableToDecode("
      <> list.map(error, decode_error_string) |> string.join("\n")
      <> ")"
  }
}

pub fn register() -> Result(Nil, lustre.Error) {
  let assert Ok(_) = split_flap_char.register()

  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("lines", fn(val) {
        echo "on_attribute_change" <> val
        let lines = json.parse(val, using: decode.list(of: line_decoder()))
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
  SetLines(List(Line))
  Noop
}

type Model {
  Model(rows: Int, cols: Int, lines: List(Line))
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
        #(
          int.to_string(row_num),
          keyed.div(
            [attribute.class("row")],
            case keyed_line_elements(line, model.cols, row_num) {
              None -> []
              Some(line) -> line
            },
            // #(int.to_string(row_num), line)
          ),
        )
      }),
    ),
  ])
}

fn keyed_line_elements(
  line: Option(List(Content)),
  len: Int,
  row_num: Int,
) -> Option(List(#(String, Element(msg)))) {
  let content = case line {
    Some([h, ..rest]) -> Some(#(h, Some(rest)))

    None | Some([]) -> {
      case len {
        0 -> None
        _ -> {
          // add padding
          Some(#(Text(string.repeat(" ", len)), Some([])))
        }
      }
    }
  }

  use #(content, rest) <- option.map(content)

  let key = option.unwrap(rest, []) |> list.length |> int.to_string

  let parent = case content {
    Text(_) -> keyed.fragment
    Link(_, url) -> keyed.fragment
    // Link(_, url) -> keyed.element(
    //   "a",
    //   [
    //     attribute.href(url),
    //     attribute.target("_blank"),
    //     attribute.style("display", "contents"),
    //   ],
    //   _,
    // )
  }

  let children = char_elements(content.text, len, row_num)
  let curr = #(key, parent(children))

  let len = len - list.length(children)
  case int.compare(len, with: 0) {
    Eq | Lt -> [curr]

    _ -> {
      let next = keyed_line_elements(rest, len, row_num) |> option.unwrap([])
      list.prepend(next, curr)
    }
  }
}

fn char_elements(
  text: String,
  len: Int,
  row_num: Int,
) -> List(#(String, Element(msg))) {
  string.to_graphemes(text)
  |> list.take(len)
  |> list.index_map(fn(char, index) {
    let key = int.to_string(row_num) <> "-" <> int.to_string(index)
    #(key, split_flap_char.element(char))
  })
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
