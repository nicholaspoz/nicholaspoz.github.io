import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import lustre
import lustre/attribute
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

import components/bingo/model.{type Frame, type Scene}
import components/bingo/scenes.{scenes}
import components/display
import components/progress_bar
import utils.{find_next}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.adopt_styles(True),
      component.on_attribute_change("columns", fn(val) {
        use cols <- result.try(int.parse(val))
        Ok(ColumnsAttrChanged(cols))
      }),
    ])
  lustre.register(component, "nick-dot-bingo")
}

pub fn element(cols cols: Int) -> Element(msg) {
  element.element(
    "nick-dot-bingo",
    [attribute.attribute("columns", int.to_string(cols))],
    [],
  )
}

type Model {
  Model(
    scenes: List(Scene),
    columns: Int,
    current: Result(#(Scene, Frame), Nil),
    auto_play: Bool,
    timeout: Option(Int),
  )
}

type Msg {
  ColumnsAttrChanged(Int)
  BackClicked
  ForwardClicked
  AutoPlayClicked
  TimeoutStarted(Int)
  TimeoutEnded
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  let scenes = scenes(28)
  let state = initial_state(scenes)

  #(
    Model(scenes:, columns: 28, current: state, auto_play: True, timeout: None),
    case state {
      Ok(#(_, frame)) -> start_timeout(frame, current: None)
      Error(_) -> effect.none()
    },
  )
}

fn initial_state(scenes: List(Scene)) -> Result(#(Scene, Frame), Nil) {
  use first_scene <- result.try(list.first(scenes))
  use first_frame <- result.try(list.first(first_scene.frames))
  Ok(#(first_scene, first_frame))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ColumnsAttrChanged(columns) -> {
      #(
        Model(..model, scenes: scenes(columns), columns:),
        // Any cleanup to do here?
        effect.none(),
      )
    }

    TimeoutStarted(id) -> #(Model(..model, timeout: Some(id)), effect.none())

    TimeoutEnded ->
      handler(
        model: model,
        next: {
          use state <- result.try(model.current)
          find_next_state(model.scenes, state)
        },
        predicate: Some(fn(state) {
          let is_same_scene =
            model.current
            |> result.map(pair.first)
            |> result.map(fn(scene) { scene == pair.first(state) })
            |> result.unwrap(False)

          model.auto_play || is_same_scene
        }),
        translate: fn(state) {
          #(
            Model(..model, current: Ok(state)),
            start_timeout(pair.second(state), current: None),
          )
        },
      )

    BackClicked ->
      handler(
        model: model,
        predicate: None,
        next: {
          use #(scene, _) <- result.try(model.current)
          use prev_scene <- result.try(find_next(
            list.reverse(model.scenes),
            scene,
          ))
          use frame <- result.try(list.first(prev_scene.frames))
          Ok(#(prev_scene, frame))
        },
        translate: fn(next_state) {
          #(
            Model(..model, auto_play: False, current: Ok(next_state)),
            start_timeout(pair.second(next_state), current: model.timeout),
          )
        },
      )

    ForwardClicked ->
      handler(
        model: model,
        next: {
          use #(scene, _) <- result.try(model.current)
          use next_scene <- result.try(find_next(model.scenes, scene))
          use frame <- result.try(list.first(next_scene.frames))
          Ok(#(next_scene, frame))
        },
        predicate: None,
        translate: fn(next_state) {
          #(
            Model(..model, auto_play: False, current: Ok(next_state)),
            start_timeout(pair.second(next_state), current: model.timeout),
          )
        },
      )

    AutoPlayClicked -> {
      let next_value = !model.auto_play
      #(Model(..model, timeout: None, auto_play: next_value), {
        case model.timeout {
          Some(id) -> utils.clear_timeout(id)
          None -> Nil
        }
        use dispatch <- effect.from
        dispatch(TimeoutEnded)
      })
    }
  }
}

/// Completely overbaked handler to handle defaults and errors while
/// deriving the next state.
/// 
fn handler(
  model model: Model,
  next state: Result(#(Scene, Frame), Nil),
  predicate predicate: Option(fn(#(Scene, Frame)) -> Bool),
  translate fun: fn(#(Scene, Frame)) -> #(Model, Effect(Msg)),
) -> #(Model, Effect(Msg)) {
  // Recover the initial state if no next state can be evaluated
  let next_state =
    result.try_recover(state, fn(_) { initial_state(model.scenes) })

  // Apply the predicate to the next state
  let next_state = case next_state, predicate {
    Ok(next_state), Some(predicate) -> {
      case predicate(next_state) {
        True -> Ok(next_state)
        False -> Error(Nil)
      }
    }
    _, _ -> next_state
  }

  case next_state {
    Ok(state) -> fun(state)
    // Handle the error case (by doing nothing for now)
    Error(_) -> #(model, effect.none())
  }
}

fn start_timeout(frame: Frame, current timeout_id: Option(Int)) -> Effect(Msg) {
  case timeout_id {
    None -> {
      use dispatch <- effect.from
      let id = utils.set_timeout(frame.ms, fn() { dispatch(TimeoutEnded) })
      dispatch(TimeoutStarted(id))
    }

    // Skip the timeout if there is already one in progress. Otherwise, we get a
    // snowball of transitions/timeouts weee
    Some(_) -> effect.none()
  }
}

pub fn find_next_state(
  scenes: List(Scene),
  current: #(Scene, Frame),
) -> Result(#(Scene, Frame), Nil) {
  let scene = pair.first(current)
  let frame = pair.second(current)

  case find_next(scene.frames, frame) {
    Ok(next_frame) -> Ok(#(scene, next_frame))
    Error(_) -> {
      use next_scene <- result.try(find_next(scenes, scene))
      use next_frame <- result.try(list.first(next_scene.frames))
      Ok(#(next_scene, next_frame))
    }
  }
}

fn view(model: Model) -> Element(Msg) {
  let lines = case model.current {
    Ok(#(_, frame)) -> frame.lines
    Error(_) -> []
  }

  element.fragment([
    html.style([], css),

    html.div([attribute.class("panel"), component.part("panel")], [
      html.div([attribute.class("matrix"), component.part("matrix")], [
        display.element(lines, cols: model.columns, rows: 7, chars: None),

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

fn calculate_progress_scenes(model: Model) -> Int {
  let total_scenes = list.length(model.scenes) |> int.max(1)
  case model.current {
    Ok(#(scene, _)) -> {
      // Start at 1 for nonempty progress indicator
      let idx =
        list.fold_until(model.scenes, 1, fn(acc, item) {
          case item == scene {
            True -> Stop(acc)
            False -> Continue(acc + 1)
          }
        })

      idx * 100 / total_scenes
    }
    Error(_) -> 0
  }
}

const css = "
  :host {
    display: block;
    container-type: inline-size;
    height: 100%;
    width: 100%;
  }

  .panel {
    position: relative;
    width: 100%;
    height: 100%;
    min-height: fit-content;
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
