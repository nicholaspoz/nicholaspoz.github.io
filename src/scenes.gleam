import gleam/option.{None, Some}

import model.{
  BoxBottom, BoxContent, BoxTitle, C, EmptyLine, Frame, L, Link, R, Scene, Text,
}

// const hello = Text(L("HELLO"))

// const i_am = Text(L("I'M NICK"))

// const welcome = Text(L("    WELCOME TO"))

const nick = Text(L("    NICK"))

const poz = Text(R("POZOULAKIS'  "))

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
      ],
    ),

    Frame(
      ms: 500,
      lines: [
        Text(C("WELCOME    ")),
      ],
    ),
    Frame(
      ms: 300,
      lines: [
        Text(C("WELCOME TO ")),
      ],
    ),
    Frame(
      ms: 300,
      lines: [
        Text(C("WELCOME TO ")),
        EmptyLine,
        nick,
      ],
    ),
    Frame(
      ms: 300,
      lines: [
        Text(C("WELCOME TO ")),
        EmptyLine,
        nick,
        EmptyLine,
        poz,
      ],
    ),
    Frame(
      ms: 2000,
      lines: [
        Text(C("WELCOME TO ")),
        EmptyLine,
        nick,
        EmptyLine,
        poz,
        EmptyLine,
        Text(C("   WEBSITE")),
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
  ],
)

const technologist = BoxTitle("TECHNOLOGIST")

const empty_box = BoxContent(L(""))

const tech = Scene(
  name: "TECH",
  chars: None,
  frames: [
    Frame(
      ms: 1000,
      lines: [
        EmptyLine,
        EmptyLine,
      ],
    ),
    Frame(
      ms: 750,
      lines: [
        Text(L(" TECHNOLOGIST")),
      ],
    ),
    Frame(
      ms: 1200,
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
        BoxContent(L("SOFTWARE")),
        BoxContent(L("ENGINEERING")),
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
        BoxContent(L("SOFTWARE")),
        BoxContent(L("ARCHITECTURE")),
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
        BoxContent(L("FULL-STACK")),
        BoxContent(R("APPLICATIONS")),
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
        BoxContent(L("WEB & MOBILE")),
        BoxContent(R("APPLICATIONS")),
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
        BoxContent(C("A.I. & AGENTIC")),
        BoxContent(R("APPLICATIONS")),
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
        BoxContent(C("A.I. & AGENTIC")),
        BoxContent(C("SYSTEMS")),
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
        BoxContent(C("BACKEND")),
        BoxContent(C("SYSTEMS")),
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
        BoxContent(C("PAYMENTS")),
        BoxContent(C("SYSTEMS")),
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
        BoxContent(C("ACCOUNTING")),
        BoxContent(C("SYSTEMS")),
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
        BoxContent(C("ACCOUNTING")),
        BoxContent(C("SYSTEMS")),
        BoxContent(C("ENTHUSIAST")),
        BoxBottom,
        EmptyLine,
        linked_in,
        github,
        email,
      ],
    ),
  ],
)

const cellist = Text(C("CELLIST"))

const music = Scene(
  name: "MUSIC",
  chars: Some(" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789▶&()#┏━┓┗┛┃●╹╻"),
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
      ms: 500,
      lines: [
        cellist,
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
      ms: 3000,
      lines: [
        cellist,
        Text(C("(FREELANCE) ")),
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
    Frame(
      ms: 2500,
      lines: [
        cellist,
        EmptyLine,
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
    Frame(
      ms: 3000,
      lines: [
        cellist,
        EmptyLine,
        Text(C("CLASSICAL")),
        Text(C(" ┏━━━┓ ╻●    ")),
        Text(C(" ┃   ┃ ┃   ╻●")),
        Text(C(" ┃ #●╹ ┗━━━┛ ")),
        Text(C("●╹           ")),
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3000,
      lines: [
        cellist,
        EmptyLine,
        EmptyLine,
        Text(C(" ┏━━━┓ ╻●    ")),
        Text(C("M┃O D┃E┃R N╻●")),
        Text(C(" ┃ #●╹ ┗━━━┛ ")),
        Text(C("●╹           ")),
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 3000,
      lines: [
        cellist,
        EmptyLine,
        Text(C("MUSICAL THEATER")),
        Text(C(" ┏━━━┓ ╻●    ")),
        Text(C(" ┃   ┃ ┃   ╻●")),
        Text(C(" ┃ #●╹ ┗━━━┛ ")),
        Text(C("●╹           ")),
        linked_in,
        github,
        email,
      ],
    ),
    Frame(
      ms: 1000,
      lines: [
        cellist,
        EmptyLine,
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

pub const scenes = [
  home,
  tech,
  music,
  friends,
]
