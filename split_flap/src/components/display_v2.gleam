import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/component
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed

import components/bingo/model.{type Content, Link}
import utils

pub fn display(
  lines: List(Content),
  chars: Option(String),
  cols cols: Int,
  rows rows: Int,
) -> Element(msg) {
  let sanitized_lines =
    lines
    |> utils.zip_longest(list.range(0, rows - 1), _)
    |> list.filter_map(utils.first_is_some)

  element.fragment([
    html.style([], css),

    keyed.div(
      [attribute.class("display")],
      list.index_map(sanitized_lines, fn(line, line_num) {
        #(
          int.to_string(line_num),
          row(line, row: line_num, cols: cols, chars: chars),
        )
      }),
    ),
  ])
}

fn row(
  line: Option(Content),
  row row_num: Int,
  cols num_cols: Int,
  chars _char_stack: Option(String),
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
    |> list.index_map(fn(_char, idx) {
      let key = int.to_string(row_num) <> "-" <> int.to_string(idx)
      #(key, char(key))
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

fn char(id: String) {
  html.div([attribute.id(id), attribute.class("split-flap")], [
    // TOP FLAP (always visible)
    html.div([attribute.class("flap top")], [
      html.span([attribute.class("flap-content")], [
        html.text(" "),
      ]),
    ]),

    // BOTTOM FLAP
    html.div([attribute.class("flap bottom")], [
      html.span([attribute.class("flap-content")], [
        html.text(" "),
      ]),
    ]),

    // FLIPPING BOTTOM
    html.div([attribute.class("flap flipping-bottom")], [
      html.span([attribute.class("flap-content")], [
        html.text(" "),
      ]),
    ]),
  ])
}

const css = "
  :host {
    display: block;
    width: 100%;
    height: 100%;
    container-type: inline-size;
  }

  .display {
    container-type: inline-size;
    display: flex;
    flex-direction: column;
    gap: 1cqh; 
    width: 100%;
    height: 100%;
    background-color: rgb(40, 40, 40);
  }

  .row {
    container-type: inline-size;
    display: flex;
    flex-direction: row;
    gap: 1cqw;
    cursor: default;
  }

  .row[href] {
    cursor: pointer;
  }
  
  .split-flap {
    position: relative;
    width: 100%;
    aspect-ratio: 1/1.618; /* golden ratio ;) */
    display: inline-block;
    container-type: inline-size;
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
    font-size: 120cqw;
    font-weight: 500;
    color: #d2d1d1;
    overflow: hidden;
    user-select: none;
    border-radius: 5cqw;
    perspective: 400cqw;
    background: rgb(40, 40, 40);
    box-shadow: inset 1cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.5);
    z-index: 1;
    
    display: flex;
    align-items: center;
    justify-content: center;
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
    opacity: 1;
  }

  .flap.bottom {
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 5cqw 5cqw;
    opacity: 1;
  }

  .flap.flipping-bottom {
    opacity: 1;
    pointer-events: none;
    bottom: 0;
    transform-origin: top;
    border-radius: 0 0 5cqw 5cqw;
    z-index: 10;
    box-shadow: inset -2cqw -3cqw 10cqw 6cqw rgba(0, 0, 0, 0.05), 0cqw -3cqw 2cqw 2cqw rgba(0, 0, 0, 0.05);
    transform: rotateX(90deg);
  }
  
  .flap.top .flap-content {
    top: 0;
    height: 100%
  }

  .flap.bottom .flap-content {
    bottom: 0;
  }

  .flap.flipping-bottom .flap-content {
    bottom: 0;
  }
"
