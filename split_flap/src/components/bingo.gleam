import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

import components/display.{type Content, Link, Text}
import components/display_fns as row
import components/progress_bar
import utils

pub type Frame {
  Frame(lines: List(Content), ms: Int)
}

pub type Scene {
  Scene(name: String, frames: List(Frame))
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("columns", fn(val) {
        use cols <- result.try(int.parse(val))
        Ok(ColumnsAttrChanged(cols))
      }),
    ])
  lustre.register(component, "nick-dot-bingo")
}

type Bingo {
  Bingo(scenes: List(Scene), current: Frame, auto_play: Bool, columns: Int)
}

type Msg {
  ColumnsAttrChanged(Int)
  FrameStarted
  FrameFinished
  BackClicked
  ForwardClicked
  AutoPlayClicked
}

fn init(_) -> #(Bingo, effect.Effect(Msg)) {
  let scenes = scenes(28)
  let assert Ok(first_scene) = list.first(scenes)
  let assert Ok(first_frame) = list.first(first_scene.frames)

  #(Bingo(scenes, first_frame, True, 28), {
    use dispatch <- effect.from
    dispatch(FrameStarted)
  })
}

fn update(model: Bingo, msg: Msg) -> #(Bingo, Effect(Msg)) {
  case msg {
    ColumnsAttrChanged(columns) -> {
      #(
        Bingo(..model, scenes: scenes(columns), columns:),
        // Any cleanup to do here?
        effect.none(),
      )
    }

    FrameStarted -> #(model, {
      use dispatch <- effect.from
      use <- utils.set_timeout(model.current.ms)
      dispatch(FrameFinished)
    })

    FrameFinished -> {
      let curr_scene_name = case get_scene_name(model) {
        Ok(name) -> name
        Error(_) -> {
          let assert Ok(first_scene) = list.first(model.scenes)
          first_scene.name
        }
      }

      let next_model = Bingo(..model, current: next_frame(model))
      let assert Ok(next_scene_name) = get_scene_name(next_model)
      case curr_scene_name == next_scene_name || model.auto_play {
        True -> {
          #(next_model, {
            use dispatch <- effect.from
            dispatch(FrameStarted)
          })
        }

        False -> #(model, effect.none())
      }
    }

    BackClicked -> {
      let next = previous_scene(model.scenes, model.current)
      let assert Ok(frame) = list.first(next.frames)
      #(Bingo(..model, current: frame, auto_play: False), {
        use dispatch <- effect.from
        dispatch(FrameStarted)
      })
    }

    ForwardClicked -> {
      let next = next_scene(model.scenes, model.current)
      let assert Ok(frame) = list.first(next.frames)
      #(Bingo(..model, current: frame, auto_play: False), {
        use dispatch <- effect.from
        dispatch(FrameStarted)
      })
    }

    AutoPlayClicked -> #(Bingo(..model, auto_play: !model.auto_play), {
      use dispatch <- effect.from
      dispatch(FrameFinished)
    })
  }
}

fn next_frame(model: Bingo) -> Frame {
  let all_frames =
    model.scenes
    |> list.flat_map(fn(scene) { scene.frames })

  case next_frame_recursive(all_frames, model.current) {
    Ok(next) -> next
    Error(_) -> {
      let assert Ok(next) = list.first(all_frames)
      next
    }
  }
}

fn next_frame_recursive(
  frames: List(Frame),
  current: Frame,
) -> Result(Frame, Nil) {
  case frames {
    [head, next, ..rest] -> {
      case head == current {
        True -> Ok(next)
        _ -> next_frame_recursive([next, ..rest], current)
      }
    }
    _ -> Error(Nil)
  }
}

fn previous_scene(scenes: List(Scene), current: Frame) -> Scene {
  scenes
  |> list.window_by_2
  |> list.find_map(fn(pair) {
    let #(a, b) = pair
    case list.contains(b.frames, current) {
      True -> Ok(a)
      False -> Error(Nil)
    }
  })
  |> result.unwrap({
    let assert Ok(last) = scenes |> list.reverse |> list.first
    last
  })
}

fn next_scene(scenes: List(Scene), current: Frame) -> Scene {
  scenes
  |> list.reverse
  |> previous_scene(current)
}

fn view(model: Bingo) -> Element(Msg) {
  element.fragment([
    html.style([], css),

    html.div([attribute.class("panel")], [
      html.div([attribute.class("matrix"), component.part("matrix")], [
        display.element(
          model.current.lines,
          cols: model.columns,
          rows: 7,
          chars: None,
        ),

        progress_bar.element(
          progress: calculate_progress_scenes(model),
          cols: model.columns,
          on_back: Some(BackClicked),
          on_forward: Some(ForwardClicked),
          auto_play: model.auto_play,
          on_auto_play: Some(AutoPlayClicked),
        ),
      ]),
    ]),
  ])
}

fn calculate_progress_scenes(model: Bingo) -> Int {
  let total_scenes = list.length(model.scenes) |> int.max(1)
  let current_scene_index =
    // Start at 1 for nonempty progress indicator
    list.fold_until(model.scenes, 1, fn(acc, scene) {
      case list.contains(scene.frames, model.current) {
        True -> Stop(acc)
        False -> Continue(acc + 1)
      }
    })

  current_scene_index * 100 / total_scenes
}

fn get_scene_name(model: Bingo) -> Result(String, Nil) {
  list.find(model.scenes, fn(scene) {
    list.find(scene.frames, fn(frame) { frame == model.current })
    |> result.is_ok()
  })
  |> result.map(fn(scene) { scene.name })
}

// Data for nick.bingo

fn scenes(columns: Int) -> List(Scene) {
  let blank_line = string.repeat(" ", columns)

  let nick = row.left("NICK", against: blank_line)
  let poz = row.left("((POZOULAKIS))", against: blank_line)
  let dot = row.center("(DOT)", against: blank_line)
  let bingo = row.right("BINGO", against: blank_line)
  let freelance = row.left("FREELANCE", against: blank_line)
  let tech = row.left("TECHNOLOGIST", against: blank_line)
  let cellist = row.left("CELLIST", against: blank_line)
  let linked_in =
    Link(
      text: row.right("LINKEDIN >", against: blank_line),
      url: "https://www.linkedin.com/in/nicholaspozoulakis/",
    )
  let github =
    Link(
      text: row.right("GITHUB >", against: blank_line),
      url: "https://github.com/nicholaspoz",
    )
  let email =
    Link(
      text: row.right("EMAIL >", against: blank_line),
      url: "mailto:nicholaspoz@gmail.com",
    )
  let what = row.center("         WHAT", against: blank_line)
  let a = row.center("        A     ", against: blank_line)
  let time = row.center("   TIME       ", against: blank_line)
  let to = row.center("TO            ", against: blank_line)
  let be = row.center("   BE         ", against: blank_line)
  let alive = row.center("      ALIVE   ", against: blank_line)
  let question = row.center("             ? ", against: blank_line)

  [
    Scene("HOME", [
      Frame(ms: 1000, lines: [
        Text(text: nick),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
      ]),
      Frame(ms: 1000, lines: [
        Text(text: nick),
        Text(text: ""),
        Text(text: ""),
        Text(text: dot),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
      ]),

      Frame(ms: 1200, lines: [
        Text(text: nick),
        Text(text: ""),
        Text(text: ""),
        Text(text: dot),
        Text(text: ""),
        Text(text: ""),
        Text(text: bingo),
      ]),
      Frame(ms: 7000, lines: [
        Text(text: nick),
        Text(text: poz),
        Text(text: ""),
        Text(text: dot),
        Text(text: ""),
        Text(text: ""),
        Text(text: bingo),
      ]),
    ]),

    Scene("TECH", [
      Frame(ms: 8000, lines: [
        Text(text: freelance),
        Text(text: tech),
        Text(text: ""),
        Text(text: ""),
        linked_in,
        github,
        email,
      ]),
    ]),

    Scene("MUSIC", [
      Frame(ms: 1000, lines: [
        Text(text: freelance),
        Text(text: cellist),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        email,
      ]),
      Frame(ms: 7000, lines: [
        Text(text: freelance),
        Text(text: cellist),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        email,
      ]),
    ]),

    Scene("!", [
      Frame(ms: 3000, lines: [
        Text(text: what),
        Text(text: a),
        Text(text: time),
        Text(text: to),
        Text(text: be),
        Text(text: alive),
      ]),
      Frame(ms: 4000, lines: [
        Text(what),
        Text(a),
        Text(time),
        Text(to),
        Text(be),
        Text(alive),
        Text(question),
      ]),
    ]),
  ]
}

const css = "
  :host {
    position: relative;
    container-type: inline-size;
  }

  .panel {
    position: relative;
    width: 100%;
    height: 100%;
    background: linear-gradient(
      250deg,
      rgb(40, 40, 40) 0%,
      rgb(50, 50, 50) 25%,
      rgb(40, 40, 40) 80%
    );
    padding: 2cqh 10cqw;
    /* This is in px on purpose */
    box-shadow: inset 0px 3px 10px 10px rgba(0, 0, 0, 0.25);

    display: flex;
    flex-direction: column;
    justify-content: center;
    align-content: center;
    overflow: scroll;
  }

  .matrix {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-content: center;
  }
  
  @container (aspect-ratio < 1) {
    .panel {
      padding: 5cqh 5cqw;
    }
  }
  "
