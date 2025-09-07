import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"
  echo greeting
  assert greeting == "Hello, Joe!"
}

pub fn scope_test() {
  let x = "1"
  echo "1: " <> x

  let y = fn() {
    echo "2: " <> x
    let x = "2"
    echo "3: " <> x
    Nil
  }
  y()
  echo "4: " <> x
}
