import components/display.{type Content}
import gleam/option.{type Option}

pub type Frame {
  Frame(lines: List(Content), ms: Int)
}

pub type Scene {
  Scene(name: String, frames: List(Frame), chars: Option(String))
}
