import gleam/int
import gleam/string

pub fn center(text: String, against background: String) -> String {
  let len = string.length(background)
  let text = string.slice(text, 0, len)

  let middle_idx = string.length(text)
  let start_idx = int.max(0, { len - middle_idx } / 2)
  let end_idx = int.max(0, len - start_idx - middle_idx)

  string.slice(background, 0, start_idx)
  <> text
  <> string.slice(background, start_idx + middle_idx, end_idx)
}

pub fn left(text: String, against background: String) -> String {
  let bg_len = string.length(background)
  let text = string.slice(text, 0, bg_len)
  let text_len = string.length(text)
  text <> string.slice(background, text_len, bg_len)
}

pub fn right(text: String, against background: String) -> String {
  let bg_len = string.length(background)
  let text = string.slice(text, 0, bg_len)
  let text_len = string.length(text)
  string.slice(background, 0, bg_len - text_len) <> text
}
