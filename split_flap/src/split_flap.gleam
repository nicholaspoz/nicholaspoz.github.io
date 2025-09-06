import bingo
import progress_bar
import split_flap_char
import split_flap_display

pub fn main() {
  let assert Ok(_) = split_flap_char.register()
  let assert Ok(_) = split_flap_display.register()
  let assert Ok(_) = progress_bar.register()
  let assert Ok(_) = bingo.register()
  Nil
}
