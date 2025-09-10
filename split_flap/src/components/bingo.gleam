import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result.{lazy_or, or, try}
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
        use cols <- try(int.parse(val))
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

type BingoState {
  BingoState(scene: Scene, frame: Frame)
}

type Model {
  Model(
    scenes: List(Scene),
    columns: Int,
    current: Result(BingoState, Nil),
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
      Ok(BingoState(_, frame)) -> start_timeout(frame, current_timeout: None)
      Error(_) -> effect.none()
    },
  )
}

fn initial_state(scenes: List(Scene)) -> Result(BingoState, Nil) {
  use first_scene <- try(list.first(scenes))
  use first_frame <- try(list.first(first_scene.frames))
  Ok(BingoState(first_scene, first_frame))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case reduce(model, msg) {
    Ok(next) -> next
    // somebody should DO something about this
    Error(_) -> #(model, effect.none())
  }
}

fn reduce(model: Model, msg: Msg) -> Result(#(Model, Effect(Msg)), Nil) {
  case msg {
    ColumnsAttrChanged(columns) -> {
      Ok(#(Model(..model, scenes: scenes(columns), columns:), effect.none()))
    }

    TimeoutStarted(id) ->
      Ok(#(Model(..model, timeout: Some(id)), effect.none()))

    TimeoutEnded -> {
      use current <- try(model.current)
      use next <- try(find_next_state(model.scenes, current))
      // even when paused, continue the scene to the end
      let continue = { current.scene == next.scene } || model.auto_play

      case continue {
        False -> Ok(#(Model(..model, timeout: None), effect.none()))
        True ->
          Ok(#(
            Model(..model, current: Ok(next), timeout: None),
            start_timeout(next.frame, current_timeout: None),
          ))
      }
    }

    BackClicked -> {
      use current <- try(model.current)
      let reversed = list.reverse(model.scenes)
      use scene <- try(or(
        find_next(reversed, current.scene),
        list.first(reversed),
      ))
      use frame <- try(list.first(scene.frames))

      Ok(#(
        Model(..model, auto_play: False, current: Ok(BingoState(scene, frame))),
        start_timeout(frame, model.timeout),
      ))
    }

    ForwardClicked -> {
      use current <- try(model.current)
      use scene <- try(or(
        find_next(model.scenes, current.scene),
        list.first(model.scenes),
      ))
      use frame <- try(list.first(scene.frames))

      Ok(#(
        Model(..model, auto_play: False, current: Ok(BingoState(scene, frame))),
        start_timeout(frame, model.timeout),
      ))
    }

    AutoPlayClicked -> {
      let next_value = !model.auto_play
      Ok(
        #(Model(..model, timeout: None, auto_play: next_value), {
          case model.timeout {
            Some(id) -> utils.clear_timeout(id)
            None -> Nil
          }
          use dispatch <- effect.from
          dispatch(TimeoutEnded)
        }),
      )
    }
  }
}

fn start_timeout(frame: Frame, current_timeout id: Option(Int)) -> Effect(Msg) {
  case id {
    None -> {
      use dispatch <- effect.from
      let id = utils.set_timeout(frame.ms, fn() { dispatch(TimeoutEnded) })
      dispatch(TimeoutStarted(id))
    }

    Some(_) -> {
      // Skip the timeout if there is already one in progress. Otherwise, we get
      // a snowball of transitions/timeouts weee
      effect.none()
    }
  }
}

fn find_next_state(
  scenes: List(Scene),
  current: BingoState,
) -> Result(BingoState, Nil) {
  case find_next(current.scene.frames, current.frame) {
    Ok(frame) -> Ok(BingoState(current.scene, frame))
    Error(_) ->
      lazy_or(
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

fn view(model: Model) -> Element(Msg) {
  let lines = case model.current {
    Ok(BingoState(_, frame)) -> frame.lines
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
    Ok(BingoState(scene, _)) -> {
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
