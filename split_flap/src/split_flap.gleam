import components/bingo
import components/char
import components/display
import components/office
import components/progress_bar

pub fn main() {
  let assert Ok(_) = char.register()
  let assert Ok(_) = display.register()
  let assert Ok(_) = progress_bar.register()
  let assert Ok(_) = bingo.register()
  let assert Ok(_) = office.register()
  Nil
}
