import gleam/option.{type Option}

pub type Justify {
  /// Left
  L(String)
  /// Center
  C(String)
  /// Right
  R(String)
}

pub type Content {
  Text(text: Justify)
  Link(text: Justify, url: String)
  BoxTitle(text: String)
  BoxContent(text: Justify)
  BoxBottom
  EmptyLine
}

pub type Frame {
  Frame(ms: Int, lines: List(Content))
}

pub type Scene {
  Scene(name: String, chars: Option(String), frames: List(Frame))
}

pub type BingoState {
  BingoState(scene: Scene, frame: Frame)
}
