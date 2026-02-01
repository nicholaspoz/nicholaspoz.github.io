import gleam/option.{type Option}

pub type Content {
  Text(text: String)
  Link(text: String, url: String)
}

pub type Frame {
  Frame(lines: List(Content), ms: Int)
}

pub type Scene {
  Scene(name: String, frames: List(Frame), chars: Option(String))
}

pub type BingoState {
  BingoState(scene: Scene, frame: Frame)
}
