import gleam/option.{None, Some}

import model.{
  BoxBottom, BoxContent, BoxTitle, C, EmptyLine, Frame, L, Link, R, Scene, Text,
}

// const hello = Text(L("HELLO"))

// const i_am = Text(L("I'M NICK"))

// const welcome = Text(L("    WELCOME TO"))

const nick = Text(L("    NICK"))

const poz = Text(L(" POZOULAKIS'"))

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
      ms: 500,
      lines: [
        EmptyLine,
      ],
    ),

    Frame(
      ms: 500,
      lines: [
        EmptyLine,
        Text(L(" WELCOME")),
      ],
    ),
    Frame(
      ms: 300,
      lines: [
        EmptyLine,
        Text(L(" WELCOME TO")),
      ],
    ),
    Frame(
      ms: 300,
      lines: [
        EmptyLine,
        Text(L(" WELCOME TO")),
        EmptyLine,
        Text(L(" NICK")),
      ],
    ),
    Frame(
      ms: 300,
      lines: [
        EmptyLine,
        Text(L(" WELCOME TO")),
        EmptyLine,
        Text(L(" NICK")),
        poz,
      ],
    ),
    Frame(
      ms: 2000,
      lines: [
        EmptyLine,
        Text(L(" WELCOME TO")),
        EmptyLine,
        Text(L(" NICK")),
        poz,
        EmptyLine,
        Text(L(" WEBSITE")),
      ],
    ),

    Frame(
      ms: 3000,
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
    Frame(
      ms: 1500,
      lines: [
        EmptyLine,
        EmptyLine,
      ],
    ),
  ],
)

const freelance = Text(L("FREELANCE"))

const technologist = BoxTitle("TECHNOLOGIST")

const empty_box = BoxContent("")

const tech = Scene(
  name: "TECH",
  chars: None,
  frames: [
    Frame(
      ms: 500,
      lines: [
        Text(L(" TECHNOLOGIST")),
      ],
    ),
    Frame(
      ms: 500,
      lines: [
        Text(L(" TECHNOLOGIST")),
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 1250,
      lines: [
        technologist,
        empty_box,
        empty_box,
        empty_box,
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("SOFTWARE"),
        BoxContent("ENGINEERING"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("SOFTWARE"),
        BoxContent("ARCHITECTURE"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("FULL-STACK"),
        BoxContent("APPLICATIONS"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("WEB & MOBILE"),
        BoxContent("APPLICATIONS"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("A.I. & AGENTIC"),
        BoxContent("SYSTEMS"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("BACKEND"),
        BoxContent("SYSTEMS"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("PAYMENTS"),
        BoxContent("SYSTEMS"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("ACCOUNTING"),
        BoxContent("SYSTEMS"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3000,
      lines: [
        technologist,
        empty_box,
        BoxContent("ACCOUNTING"),
        BoxContent("ENTHUSIAST"),
        empty_box,
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3200,
      lines: [
        technologist,
        empty_box,
        BoxContent("ACCOUNTING"),
        BoxContent("ENTHUSIAST!"),
        empty_box,
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
      ms: 500,
      lines: [
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 1000,
      lines: [
        freelance,
        cellist,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 6500,
      lines: [
        freelance,
        cellist,
        EmptyLine,
        Text(C(" ┏━━━┓ ╻●    ")),
        Text(C(" ┃   ┃ ┃   ╻●")),
        Text(C(" ┃ #●╹ ┗━━━┛ ")),
        Text(C("●╹           ")),
        linked_in,
        github,
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
      ms: 1500,
      lines: [
        EmptyLine,
        EmptyLine,
        Text(L("    LET'S BE")),
        Text(R("FRIENDS!    ")),
      ],
    ),
    Frame(
      ms: 7000,
      lines: [
        EmptyLine,
        EmptyLine,
        Text(L("    LET'S BE")),
        Text(R("FRIENDS!    ")),
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
        EmptyLine,
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
      ms: 3000,
      lines: [
        EmptyLine,
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

pub const scenes = [
  home,
  tech,
  music,
  // alive,
  friends,
]
