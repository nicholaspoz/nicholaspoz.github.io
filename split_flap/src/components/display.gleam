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

import components/char as sf_char

const default_rows = 6

const default_cols = 22

type Model {
  Model(lines: List(Content), cols: Int, rows: Int, chars: Option(String))
}

pub type Content {
  Text(text: String)
  Link(text: String, url: String)
}

fn content_to_json(content: Content) -> json.Json {
  case content {
    Text(text:) ->
      json.object([
        #("type", json.string("text")),
        #("text", json.string(text)),
      ])
    Link(text:, url:) ->
      json.object([
        #("type", json.string("link")),
        #("text", json.string(text)),
        #("url", json.string(url)),
      ])
  }
}

fn contents_to_json(contents: List(Content)) -> json.Json {
  json.array(contents, content_to_json)
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

type Msg {
  ColsAttrChanged(Int)
  RowsAttrChanged(Int)
  LinesAttrChanged(List(Content))
  CharsAttrChanged(String)
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("lines", fn(val) {
        // echo "lines " <> val
        let lines = json.parse(val, using: decode.list(of: content_decoder()))
        case lines {
          Ok(lines) -> Ok(LinesAttrChanged(lines))
          Error(error) -> {
            echo "error " <> error_string(error)
            Error(Nil)
          }
        }
      }),

      component.on_attribute_change("cols", fn(val) {
        case int.parse(val) {
          Ok(cols) -> Ok(ColsAttrChanged(cols))
          Error(_) -> Error(Nil)
        }
      }),

      component.on_attribute_change("rows", fn(val) {
        case int.parse(val) {
          Ok(rows) -> Ok(RowsAttrChanged(rows))
          Error(_) -> Error(Nil)
        }
      }),

      component.on_attribute_change("chars", fn(val) {
        Ok(CharsAttrChanged(val))
      }),
    ])

  lustre.register(component, "split-flap-display")
}

pub fn element(
  contents: List(Content),
  cols cols: Int,
  rows rows: Int,
  chars chars: Option(String),
) -> Element(msg) {
  element.element(
    "split-flap-display",
    [
      attribute.attribute("lines", json.to_string(contents_to_json(contents))),
      attribute.attribute("cols", int.to_string(cols)),
      attribute.attribute("rows", int.to_string(rows)),
      case chars {
        Some(stack) -> attribute.attribute("chars", stack)
        None -> attribute.none()
      },
    ],
    [],
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  // Rows and cols are currently hardcoded and never changed
  #(Model([], default_cols, default_rows, None), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    LinesAttrChanged(lines) -> #(Model(..model, lines:), effect.none())
    ColsAttrChanged(cols) -> #(Model(..model, cols:), effect.none())
    RowsAttrChanged(rows) -> #(Model(..model, rows:), effect.none())
    CharsAttrChanged(chars) -> #(
      Model(..model, chars: Some(chars)),
      effect.none(),
    )
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
        #(
          int.to_string(line_num),
          row(line, row: line_num, cols: model.cols, chars: model.chars),
        )
      }),
    ),
  ])
}

fn row(
  line: Option(Content),
  row row_num: Int,
  cols num_cols: Int,
  chars char_stack: Option(String),
) -> Element(msg) {
  let chars = case line {
    Some(content) ->
      content.text
      |> string.pad_end(num_cols, " ")
      |> string.slice(0, num_cols)

    None -> string.repeat(" ", num_cols)
  }

  let children =
    chars
    |> string.to_graphemes
    |> list.index_map(fn(char, idx) {
      let key = int.to_string(row_num) <> "-" <> int.to_string(idx)
      #(key, sf_char.element(char:, char_stack:, on_click: None))
    })

  let link_attrs = case line {
    Some(Link(_, url:)) -> [attribute.href(url), attribute.target("_blank")]
    _ -> []
  }

  keyed.element(
    "a",
    [attribute.class("row"), component.part("row"), ..link_attrs],
    children,
  )
}

/// probs a better way to do this
fn zip_longest(list1: List(a), list2: List(b)) -> List(#(Option(a), Option(b))) {
  let #(head1, rest1) = case list1 {
    [] -> #(None, [])
    [h, ..rest] -> #(Some(h), rest)
  }

  let #(head2, rest2) = case list2 {
    [] -> #(None, [])
    [h, ..rest] -> #(Some(h), rest)
  }

  let el = case head1, head2 {
    None, None -> None
    Some(h1), None -> Some(#(Some(h1), None))
    None, Some(h2) -> Some(#(None, Some(h2)))
    Some(h1), Some(h2) -> Some(#(Some(h1), Some(h2)))
  }

  case el {
    None -> []
    Some(el) -> [el, ..zip_longest(rest1, rest2)]
  }
}

fn first_is_some(pair: #(Option(a), b)) -> Result(b, Nil) {
  case pair {
    #(Some(_), b) -> Ok(b)
    _ -> Error(Nil)
  }
}

fn decode_error_string(error: decode.DecodeError) -> String {
  case error {
    decode.DecodeError(expected:, found:, path:) ->
      expected <> " | " <> found <> " | " <> string.join(path, ", ")
  }
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

const css = "
  :host {
    display: block;
  }

  split-flap-char {
    padding: 0.9cqw 0.3cqw;
  }

  .display {
    display: flex;
    flex-direction: column;
    gap: 0; 
    width: 100%;
    height: 100%;
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
