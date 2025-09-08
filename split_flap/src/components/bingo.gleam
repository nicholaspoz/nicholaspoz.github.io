import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

import components/display.{type Content, Link, Text}
import components/progress_bar
import utils

pub type Frame {
  Frame(lines: List(Content), ms: Int)
}

pub type Scene {
  Scene(name: String, frames: List(Frame))
}

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.component(init, update, view, [])
  lustre.register(component, "nick-dot-bingo")
}

type Model {
  Model(scenes: List(Scene), current: Frame, auto_play: Bool)
}

type Msg {
  FrameStarted
  FrameFinished
  BackClicked
  ForwardClicked
  Progressed
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  let scenes = scenes()
  let assert Ok(first_scene) = list.first(scenes)
  let assert Ok(first_frame) = list.first(first_scene.frames)

  #(Model(scenes, first_frame, True), {
    use dispatch <- effect.from
    dispatch(FrameStarted)
    dispatch(Progressed)
  })
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FrameStarted -> #(model, {
      use dispatch <- effect.from
      use <- utils.set_timeout(model.current.ms)
      dispatch(FrameFinished)
    })

    FrameFinished -> {
      case model.auto_play {
        True -> {
          let next = next_frame(model.scenes, model.current)

          #(Model(..model, current: next), {
            use dispatch <- effect.from
            dispatch(FrameStarted)
          })
        }

        False -> #(model, effect.none())
      }
    }

    Progressed -> {
      // hmmm
      #(model, effect.none())
    }

    BackClicked -> {
      echo "BackClicked"
      #(model, effect.none())
    }
    ForwardClicked -> {
      echo "ForwardClicked"
      #(model, effect.none())
    }
  }
}

fn next_frame(scenes: List(Scene), current: Frame) -> Frame {
  let all_frames = scenes |> list.flat_map(fn(scene) { scene.frames })

  case next_frame_recursive(all_frames, current) {
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

fn view(model: Model) -> Element(Msg) {
  let _current_scene_name = current_scene_name(model)

  element.fragment([
    html.style([], css),

    html.div([attribute.class("panel")], [
      html.div([attribute.class("matrix")], [
        display.element(model.current.lines, cols: 28, rows: 7, chars: None),

        progress_bar.element(
          progress: calculate_progress_scenes(model),
          cols: 28,
          on_back: Some(BackClicked),
          on_forward: Some(ForwardClicked),
        ),
      ]),
    ]),
  ])
}

fn calculate_progress_scenes(model: Model) -> Int {
  let total_scenes = list.length(model.scenes) |> int.max(1)
  let current_scene_index =
    list.fold_until(model.scenes, 0, fn(acc, scene) {
      case list.contains(scene.frames, model.current) {
        True -> Stop(acc)
        False -> Continue(acc + 1)
      }
    })

  current_scene_index * 100 / total_scenes
}

fn current_scene_name(model: Model) -> String {
  let assert Ok(scene) =
    list.find(model.scenes, fn(scene) {
      list.find(scene.frames, fn(frame) { frame == model.current })
      |> result.is_ok()
    })

  scene.name
}

// Data for nick.bingo

fn scenes() -> List(Scene) {
  [
    Scene("HOME", [
      Frame(ms: 1000, lines: [
        Text(text: "NICK"),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
      ]),
      Frame(ms: 1000, lines: [
        Text(text: "NICK"),
        Text(text: ""),
        Text(text: "DOT"),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
      ]),

      Frame(ms: 1200, lines: [
        Text(text: "NICK"),
        Text(text: ""),
        Text(text: "DOT"),
        Text(text: ""),
        Text(text: "BINGO"),
        Text(text: ""),
      ]),
      Frame(ms: 7000, lines: [
        Text(text: "NICK (POZOULAKIS)"),
        Text(text: ""),
        Text(text: "DOT"),
        Text(text: ""),
        Text(text: "BINGO"),
        Text(text: ""),
      ]),
    ]),

    Scene("TECH", [
      Frame(ms: 8000, lines: [
        Text(text: "FREELANCE"),
        Text(text: "TECHNOLOGIST"),
        Text(text: ""),
        linked_in(),
        github(),
        email(),
      ]),
    ]),

    Scene("MUSIC", [
      Frame(ms: 1000, lines: [
        Text(text: "FREELANCE"),
        Text(text: "CELLIST"),
        Text(text: ""),
        Text(text: ""),
        Text(text: ""),
        email(),
      ]),
      Frame(ms: 7000, lines: [
        Text(text: "FREELANCE"),
        Text(text: "CELLIST  ___   |0     "),
        Text(text: "        |   |  |      "),
        Text(text: "        | #0|  |/     "),
        Text(text: "       0|             "),
        email(),
      ]),
    ]),

    Scene("!", [
      Frame(ms: 3000, lines: [
        Text("              WHAT"),
        Text("            A"),
        Text("       TIME"),
        Text("    TO"),
        Text("       BE"),
        Text("          ALIVE"),
      ]),
      Frame(ms: 4000, lines: [
        Text("              WHAT"),
        Text("            A"),
        Text("       TIME"),
        Text("    TO"),
        Text("       BE"),
        Text("          ALIVE?"),
      ]),
    ]),
  ]
}

fn linked_in() {
  Link(
    text: "LINKEDIN >" |> string.pad_start(22, " "),
    url: "https://www.linkedin.com/in/nicholaspozoulakis/",
  )
}

fn github() {
  Link(
    text: "GITHUB >" |> string.pad_start(22, " "),
    url: "https://github.com/nicholaspoz",
  )
}

fn email() {
  Link(
    text: "EMAIL >" |> string.pad_start(22, " "),
    url: "mailto:nicholaspoz@gmail.com",
  )
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
