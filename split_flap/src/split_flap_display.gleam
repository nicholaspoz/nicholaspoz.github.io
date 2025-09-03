import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
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

fn decode_error_string(error: decode.DecodeError) -> String {
  case error {
    decode.DecodeError(expected:, found:, path:) ->
      expected <> " | " <> found <> " | " <> string.join(path, ", ")
  }
}

// fn line_decoder() -> decode.Decoder(Line) {
//   decode.list(content_decoder())
// }

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
        // echo "on_attribute_change" <> val
        let lines = json.parse(val, using: decode.list(of: content_decoder()))
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
  SetLines(List(Content))
  Noop
}

type Model {
  Model(rows: Int, cols: Int, lines: List(Content))
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

fn first_is_some(pair: #(Option(a), b)) -> Result(b, Nil) {
  case pair {
    #(Some(_), b) -> Ok(b)
    _ -> Error(Nil)
  }
}

fn view(model: Model) -> Element(msg) {
  let sanitized_lines =
    model.lines
    |> zip_longest(list.range(0, model.rows - 1), _)
    |> list.filter_map(first_is_some)

  element.fragment([
    html.style([], css),

    keyed.div(
      [attribute.class("display")],
      list.index_map(sanitized_lines, fn(line, line_num) {
        #(int.to_string(line_num), row(line, row: line_num, cols: model.cols))
      }),
    ),
  ])
}

fn row(line: Option(Content), row row_num: Int, cols cols: Int) -> Element(msg) {
  let href_attr = case line {
    Some(Link(_, url:)) -> attribute.href(url)
    _ -> attribute.none()
  }

  let chars = case line {
    Some(content) ->
      content.text
      |> string.pad_end(cols, " ")
      |> string.slice(0, cols)

    None -> string.repeat(" ", cols)
  }

  let children =
    chars
    |> string.to_graphemes
    |> list.index_map(fn(char, idx) {
      let key = int.to_string(row_num) <> "-" <> int.to_string(idx)
      #(key, split_flap_char.element(char))
    })

  keyed.element(
    "a",
    [
      attribute.class("row"),
      attribute.target("_blank"),
      href_attr,
    ],
    children,
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
    /* background: rgb(40, 40, 40); */
    background: linear-gradient(250deg, rgb(40, 40, 40) 0%,rgb(50, 50, 50) 25%,rgba(40,40,40,1) 80%);
    padding: 1cqw 3cqw;
    box-shadow: inset 0cqw -0.3cqw 1cqw 0.3cqw rgba(0, 0, 0, 0.4)
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 0rem;

    cursor: default;
  }

  .row[href] {
    cursor: pointer;
  }
"
