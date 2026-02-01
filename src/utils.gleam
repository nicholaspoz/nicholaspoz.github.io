import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result.{try}
import gleam/string

import model.{type BingoState, type Scene, BingoState}

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
        fn() { initial_state(scenes) },
      )
  }
}

pub fn initial_state(scenes: List(Scene)) -> Result(BingoState, Nil) {
  use first_scene <- try(list.first(scenes))
  use first_frame <- try(list.first(first_scene.frames))
  Ok(BingoState(first_scene, first_frame))
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

/// probs a better way to do this
pub fn zip_longest(
  list1: List(a),
  list2: List(b),
) -> List(#(Option(a), Option(b))) {
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

pub fn first_is_some(pair: #(Option(a), b)) -> Result(b, Nil) {
  case pair {
    #(Some(_), b) -> Ok(b)
    _ -> Error(Nil)
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
