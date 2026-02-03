import gleam/option.{None, Some}

import model.{C, EmptyLine, Frame, L, Link, R, Scene, Text}

const nick = Text(L("NICK"))

const poz = Text(L("((POZOULAKIS))"))

const dot = Text(C("(DOT)"))

const bingo = Text(R("BINGO"))

const linked_in = Link(
  text: R("LINKEDIN ▶"),
  url: "https://www.linkedin.com/in/nicholaspozoulakis/",
)

const github = Link(text: R("GITHUB ▶"), url: "https://github.com/nicholaspoz")

const email = Link(text: R("EMAIL ▶"), url: "mailto:nicholaspoz@gmail.com")

const home = Scene(
  name: "HOME",
  chars: None,
  frames: [
    Frame(
      ms: 1500,
      lines: [
        nick,
        EmptyLine,
        EmptyLine,
        dot,
        EmptyLine,
        EmptyLine,
        bingo,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        nick,
        poz,
        EmptyLine,
        dot,
        EmptyLine,
        EmptyLine,
        bingo,
      ],
    ),
  ],
)

const freelance = Text(L("FREELANCE"))

const engineer = Text(R("ENGINEER  "))

const technologist = Text(L("TECHNOLOGIST"))

const tech = Scene(
  name: "TECH",
  chars: None,
  frames: [
    Frame(
      ms: 4500,
      lines: [
        freelance,
        Text(C("SOFTWARE")),
        engineer,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        freelance,
        Text(C("FULL-STACK")),
        engineer,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        freelance,
        Text(C("BACKEND")),
        engineer,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        freelance,
        Text(C("PAYMENTS")),
        engineer,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        freelance,
        Text(C("ACCOUNTING")),
        engineer,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        freelance,
        Text(C("A.I.")),
        engineer,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 6000,
      lines: [
        freelance,
        technologist,
        EmptyLine,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
  ],
)

const cellist = Text(L("CELLIST"))

const music = Scene(
  name: "MUSIC",
  chars: Some(" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789▶#┏━┓┃●╹╻┗┛"),
  frames: [
    Frame(
      ms: 1000,
      lines: [
        freelance,
        cellist,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        email,
      ],
    ),
    Frame(
      ms: 6500,
      lines: [
        freelance,
        cellist,
        Text(C(" ┏━━━┓ ╻●    ")),
        Text(C(" ┃   ┃ ┃   ╻●")),
        Text(C(" ┃ #●╹ ┗━━━┛ ")),
        Text(C("●╹           ")),
        email,
      ],
    ),
  ],
)

const friends = Scene(
  name: "FRIENDS",
  chars: None,
  frames: [
    Frame(
      ms: 2000,
      lines: [
        EmptyLine,
        Text(L("LET'S BE")),
        Text(C("FRIENDS :)")),
      ],
    ),
    Frame(
      ms: 7000,
      lines: [
        EmptyLine,
        Text(L("LET'S BE")),
        Text(C("FRIENDS :)")),
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
  ],
)

const alive = Scene(
  name: "!",
  chars: None,
  frames: [
    Frame(
      ms: 2000,
      lines: [
        Text(C("         WHAT")),
        Text(C("       A     ")),
        Text(C("  TIME       ")),
        Text(C("TO           ")),
        Text(C("   BE        ")),
        Text(C("      ALIVE  ")),
        EmptyLine,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        Text(C("         WHAT")),
        Text(C("       A     ")),
        Text(C("  TIME       ")),
        Text(C("TO           ")),
        Text(C("   BE        ")),
        Text(C("      ALIVE  ")),
        Text(C("            !")),
      ],
    ),
  ],
)

pub const scenes = [home, tech, music, alive, friends]
