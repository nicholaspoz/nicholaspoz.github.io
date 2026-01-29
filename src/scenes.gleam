import gleam/option.{None, Some}
import gleam/string

import display_fns as row
import model.{type Scene, Frame, Link, Scene, Text}

const linkedin_url = "https://www.linkedin.com/in/nicholaspozoulakis/"

const github_url = "https://github.com/nicholaspoz"

const mailto = "mailto:nicholaspoz@gmail.com"

pub fn scenes(columns: Int) -> List(Scene) {
  let blank_line = string.repeat(" ", columns)
  let left = row.left(_, against: blank_line)
  let center = row.center(_, against: blank_line)
  let right = row.right(_, against: blank_line)

  let #(nick, poz, dot, bingo) = #(
    left("NICK"),
    left("((POZOULAKIS))"),
    center("(DOT)"),
    right("BINGO"),
  )

  let #(freelance, tech, cellist) = #(
    left("FREELANCE"),
    left("TECHNOLOGIST"),
    left("CELLIST"),
  )

  let #(notes_1, notes_2, notes_3, notes_4) = #(
    center(" ┏━━━┓ ╻●    "),
    center(" ┃   ┃ ┃   ╻●"),
    center(" ┃ #●╹ ┗━━━┛ "),
    center("●╹           "),
  )

  let linked_in = Link(text: right("LINKEDIN ▶"), url: linkedin_url)
  let github = Link(text: right("GITHUB ▶"), url: github_url)
  let email = Link(text: right("EMAIL ▶"), url: mailto)

  let #(what, a, time, to, be, alive, exclaim) = #(
    center("         WHAT"),
    center("       A     "),
    center("  TIME       "),
    center("TO           "),
    center("   BE        "),
    center("      ALIVE  "),
    center("            !"),
  )

  [
    Scene(name: "HOME", chars: None, frames: [
      Frame(ms: 400, lines: [
        Text(nick),
        Text(""),
        Text(""),
        Text(""),
        Text(""),
        Text(""),
      ]),
      Frame(ms: 400, lines: [
        Text(nick),
        Text(""),
        Text(""),
        Text(dot),
        Text(""),
        Text(""),
        Text(""),
      ]),

      Frame(ms: 400, lines: [
        Text(nick),
        Text(""),
        Text(""),
        Text(dot),
        Text(""),
        Text(""),
        Text(bingo),
      ]),
      Frame(ms: 3000, lines: [
        Text(nick),
        Text(poz),
        Text(""),
        Text(dot),
        Text(""),
        Text(""),
        Text(bingo),
      ]),
    ]),

    Scene(name: "TECH", chars: None, frames: [
      Frame(ms: 5000, lines: [
        Text(freelance),
        Text(tech),
        Text(""),
        Text(""),
        linked_in,
        github,
        email,
      ]),
    ]),

    Scene(
      name: "MUSIC",
      chars: Some(" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789▶#┏━┓┃●╹╻┗┛"),
      frames: [
        Frame(ms: 1000, lines: [
          Text(freelance),
          Text(cellist),
          Text(""),
          Text(""),
          Text(""),
          Text(""),
          email,
        ]),
        Frame(ms: 5000, lines: [
          Text(freelance),
          Text(cellist),
          Text(notes_1),
          Text(notes_2),
          Text(notes_3),
          Text(notes_4),
          email,
        ]),
      ],
    ),

    Scene(name: "!", chars: None, frames: [
      Frame(ms: 2000, lines: [
        Text(what),
        Text(a),
        Text(time),
        Text(to),
        Text(be),
        Text(alive),
        Text(""),
      ]),
      Frame(ms: 4500, lines: [
        Text(what),
        Text(a),
        Text(time),
        Text(to),
        Text(be),
        Text(alive),
        Text(exclaim),
      ]),
    ]),
  ]
}
