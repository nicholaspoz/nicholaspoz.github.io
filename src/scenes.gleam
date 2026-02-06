import gleam/option.{None, Some}

import model.{
  BoxBottom, BoxContent, BoxTitle, C, EmptyLine, Frame, L, Link, R, Scene, Text,
}

const hello = Text(L("HELLO"))

const i_am = Text(L("I'M NICK"))

const welcome = Text(L("WELCOME TO"))

const nick = Text(L("    NICK"))

const poz = Text(L("    POZOULAKIS"))

const dot = Text(C("(DOT)"))

const bingo = Text(R("BINGO    "))

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
      ms: 1000,
      lines: [
        EmptyLine,
        hello,
      ],
    ),
    Frame(
      ms: 3000,
      lines: [
        EmptyLine,
        hello,
        i_am,
        poz,
      ],
    ),
    Frame(
      ms: 500,
      lines: [
        welcome,
        EmptyLine,
        nick,
      ],
    ),
    Frame(
      ms: 500,
      lines: [
        welcome,
        EmptyLine,
        nick,
        EmptyLine,
        dot,
      ],
    ),
    Frame(
      ms: 1500,
      lines: [
        welcome,
        EmptyLine,
        nick,
        EmptyLine,
        dot,
        EmptyLine,
        bingo,
      ],
    ),
    Frame(
      ms: 2500,
      lines: [
        EmptyLine,
        EmptyLine,
        nick,
        EmptyLine,
        dot,
        EmptyLine,
        bingo,
      ],
    ),
  ],
)

const freelance = Text(L("FREELANCE"))

const engineer = BoxContent("ENGINEER")

const technologist = BoxTitle("TECHNOLOGIST")

const tech = Scene(
  name: "TECH",
  chars: None,
  frames: [
    Frame(
      ms: 1500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent(""),
        BoxContent(""),
        BoxContent(""),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent("SOFTWARE"),
        engineer,
        BoxContent(""),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent("FULL-STACK"),
        engineer,
        BoxContent(""),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent("BACKEND"),
        engineer,
        BoxContent(""),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent("PAYMENTS"),
        engineer,
        BoxContent(""),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent("ACCOUNTING"),
        engineer,
        BoxContent(""),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 4500,
      lines: [
        technologist,
        BoxContent(""),
        BoxContent("A.I."),
        engineer,
        BoxContent(""),
        BoxBottom,
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
  chars: Some(" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789▶#┏━┓┗┛┃●╹╻"),
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
        EmptyLine,
        Text(L("LET'S BE")),
        Text(C("FRIENDS!")),
      ],
    ),
    Frame(
      ms: 7000,
      lines: [
        EmptyLine,
        EmptyLine,
        Text(L("LET'S BE")),
        Text(C("FRIENDS!")),
        EmptyLine,
        EmptyLine,
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
