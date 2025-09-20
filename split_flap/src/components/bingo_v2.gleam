import gleam/bool
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result.{lazy_or, try}
import lustre
import lustre/attribute
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import components/bingo/model.{type Frame, type Scene}
import components/bingo/scenes.{scenes}
import components/display_v2
import components/progress_bar
import utils.{find_next}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [component.open_shadow_root(True)])
  lustre.register(component, "nick-dot-bingo-v2")
}

pub fn element() -> Element(msg) {
  element.element("nick-dot-bingo-v2", [], [])
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
  Resized
  ColumnsChanged(Int)
  PageClicked(Int)
  AutoPlayClicked
  TimeoutStarted(Int)
  TimeoutEnded
  Clicked
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  let cols = 0
  let scenes = []
  let state = initial_state(scenes)

  #(
    Model(
      scenes:,
      columns: cols,
      current: state,
      auto_play: True,
      timeout: None,
    ),
    {
      use dispatch, root_element <- effect.before_paint
      utils.on_resize(root_element, fn() { dispatch(Resized) })
    },
  )
}

fn get_cols_effect() -> Effect(Msg) {
  use dispatch, root_element <- effect.before_paint
  let cols = case utils.measure_orientation(root_element) {
    "portrait" -> 15
    _ -> 27
  }
  dispatch(ColumnsChanged(cols))
}

fn initial_state(scenes: List(Scene)) -> Result(BingoState, Nil) {
  use first_scene <- try(list.first(scenes))
  use first_frame <- try(list.first(first_scene.frames))
  Ok(BingoState(first_scene, first_frame))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case reduce(model, msg) {
    Ok(next) -> next
    Error(_) -> {
      // SOMEBODY should DO SOMETHING about this!
      echo "ERROR"
      #(model, effect.none())
    }
  }
}

fn reduce(model: Model, msg: Msg) -> Result(#(Model, Effect(Msg)), Nil) {
  case msg {
    Resized -> Ok(#(model, get_cols_effect()))
    Clicked ->
      Ok(
        #(model, {
          utils.animate_stuff()
          effect.none()
        }),
      )

    ColumnsChanged(columns) -> {
      use <- bool.guard(columns == model.columns, Ok(#(model, effect.none())))
      case model.timeout {
        Some(id) -> utils.clear_timeout(id)
        None -> Nil
      }
      let scenes = scenes(columns)
      use initial_state <- try(initial_state(scenes))
      Ok(#(
        Model(
          ..model,
          scenes: scenes,
          columns: columns,
          current: Ok(initial_state),
          timeout: None,
        ),
        start_timeout(initial_state.frame, None),
      ))
    }

    TimeoutStarted(id) ->
      Ok(#(Model(..model, timeout: Some(id)), effect.none()))

    TimeoutEnded -> {
      use current <- try(model.current)
      use next <- try(find_next_state(model.scenes, current))
      // even when paused, continue the current scene to its last frame
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

    PageClicked(page) -> {
      use scene <- try(find_scene(model.scenes, page))
      use frame <- try(list.first(scene.frames))
      let next =
        result.map(model.current, fn(current) {
          case current.scene != scene {
            True -> BingoState(scene, frame)
            False -> current
          }
        })

      Ok(#(
        Model(..model, auto_play: False, current: next),
        start_timeout(frame, model.timeout),
      ))
    }

    AutoPlayClicked ->
      Ok(
        #(Model(..model, timeout: None, auto_play: !model.auto_play), {
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

fn find_scene(scenes: List(Scene), page: Int) -> Result(Scene, Nil) {
  case scenes, page {
    _, 1 -> list.first(scenes)
    [], _ -> Error(Nil)
    [_, ..rest], _ -> find_scene(rest, page - 1)
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
  let #(lines, chars) = case model.current {
    Ok(BingoState(scene, frame)) -> #(frame.lines, scene.chars)
    Error(_) -> #([], None)
  }

  element.fragment([
    html.style([], css),

    html.div(
      [
        attribute.class("panel"),
        component.part("panel"),
        event.on_click(Clicked),
      ],
      [
        html.div([attribute.class("matrix"), component.part("matrix")], [
          display_v2.display(lines, chars, cols: model.columns, rows: 7),

          progress_bar.element(
            pages: list.length(model.scenes),
            page: list.fold_until(model.scenes, 1, fn(acc, s) {
              case model.current {
                Ok(state) if s == state.scene -> {
                  Stop(acc)
                }
                Ok(_) -> Continue(acc + 1)
                Error(_) -> Stop(0)
              }
            }),
            cols: model.columns,
            auto_play: model.auto_play,
            on_auto_play: AutoPlayClicked,
            on_page: PageClicked,
          ),
        ]),
      ],
    ),
  ])
}

const css = "
  :host {
    display: block;
    container-type: inline-size;
    height: 100%;
    width: 100%;
    min-height: fit-content;
  }

  .panel {
    position: relative;
    width: 100%;
    height: 100%;
    min-height: fit-content;
    overflow: hidden;

    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .matrix {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
    min-height: fit-content;
  }
  "
