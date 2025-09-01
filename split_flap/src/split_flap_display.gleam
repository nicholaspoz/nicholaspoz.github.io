import gleam/int
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

pub fn register() -> Result(Nil, lustre.Error) {
  let assert Ok(_) = split_flap_char.register()

  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("letter", fn(val) { Ok(Noop) }),
    ])

  lustre.register(component, "split-flap-display")
}

pub fn element() -> Element(msg) {
  element.element("split-flap-display", [], [])
}

type Msg {
  Noop
}

type Model {
  Model(rows: Int, cols: Int, lines: List(String))
}

fn init(_) -> #(Model, Effect(Msg)) {
  #(
    Model(6, 25, [
      "NICK POZOULAKIS",
    ]),
    effect.none(),
  )
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  #(model, effect.none())
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
  keyed.div(
    [attribute.class("row")],
    list.index_map(chars, fn(char, col_num) {
      let key = int.to_string(index) <> "-" <> int.to_string(col_num)
      #(key, split_flap_char.element(char))
    }),
  )
}

const css = "
  :host {
    display: inline-block;
    width: 100%;
  }

  split-flap-char {
    padding: 1rem 0.25rem;
    background: rgb(40, 40, 40);
    border: 1px solid rgb(20, 20, 20);
  }

  .display {
    display: flex;
    flex-direction: column;
    gap: 0rem;
    background: rgb(20, 20, 20);
    padding: 0.5rem;
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 0rem;
  }

"
