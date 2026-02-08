import gleam/dict
import gleam/int
import gleam/list
import gleam/result.{try}
import gleam/string

import model.{type BingoState, type Content, type Scene, BingoState, EmptyLine}

pub fn center(text: String, against bg: String) -> String {
  let bg_length = string.length(bg)
  let text = string.slice(text, 0, bg_length)
  let text_length = string.length(text)

  let assert Ok(pad_round_up) = int.modulo({ bg_length - text_length }, 2)
  let start_idx = int.max(0, { bg_length - text_length } / 2) + pad_round_up
  let end_idx = int.max(0, bg_length - start_idx - text_length)

  string.slice(bg, 0, start_idx)
  <> text
  <> string.slice(bg, start_idx + text_length, end_idx)
}

pub fn left(text: String, against bg: String) -> String {
  let bg_len = string.length(bg)
  let text = string.slice(text, 0, bg_len)
  let text_len = string.length(text)
  text <> string.slice(bg, text_len, bg_len)
}

pub fn right(text: String, against bg: String) -> String {
  let bg_len = string.length(bg)
  let text = string.slice(text, 0, bg_len)
  let text_len = string.length(text)
  string.slice(bg, 0, bg_len - text_len) <> text
}

pub fn find_scene(scenes: List(Scene), page: Int) -> Result(Scene, Nil) {
  case scenes, page {
    _, 1 -> list.first(scenes)
    [], _ -> Error(Nil)
    [_, ..rest], _ -> find_scene(rest, page - 1)
  }
}

pub fn find_next_state(
  scenes: List(Scene),
  current: BingoState,
) -> Result(BingoState, Nil) {
  case find_next(current.scene.frames, current.frame) {
    Ok(frame) -> Ok(BingoState(current.scene, frame))
    Error(_) ->
      result.lazy_or(
        {
          use scene <- try(find_next(scenes, current.scene))
          use frame <- try(list.first(scene.frames))
          Ok(BingoState(scene, frame))
        },
        // Start over
        fn() { Ok(initial_state(scenes)) },
      )
  }
}

pub fn initial_state(scenes: List(Scene)) -> BingoState {
  let assert Ok(first_scene) = list.first(scenes)
  let assert Ok(first_frame) = list.first(first_scene.frames)
  BingoState(first_scene, first_frame)
}

/// Find the item in the list directly after the `current` item.
/// Will return `Error(Nil)` if the `current` item is the last item,
/// or if it is not found in the list.
pub fn find_next(l: List(a), current: a) -> Result(a, Nil) {
  case l {
    [h1, h2, ..rest] -> {
      case h1 == current {
        True -> Ok(h2)
        False -> find_next([h2, ..rest], current)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn pad_empty_rows(lines: List(Content), rows: Int) -> List(Content) {
  case rows, lines {
    0, _ -> []
    length, [] -> list.repeat(EmptyLine, length)
    length, [h, ..rest] -> [h, ..pad_empty_rows(rest, length - 1)]
  }
}

pub fn to_adjacency_list(chars: String) -> dict.Dict(String, String) {
  string.first(chars)
  |> result.map(fn(char) { chars <> char })
  |> result.unwrap("")
  |> string.to_graphemes
  |> list.window_by_2
  |> dict.from_list
}
