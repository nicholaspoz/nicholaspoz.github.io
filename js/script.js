(() => {
  const __EMPTY__ = { text: "", type: "text" };

  function row(str, url) {
    return {
      type: url ? "link" : "text",
      text: str ? str : "",
      url,
    };
  }

  function linkedIn() {
    return row(
      "LINKEDIN >".padStart(22),
      "https://www.linkedin.com/in/nicholaspozoulakis/"
    );
  }

  function email() {
    return row("EMAIL >".padStart(22), "mailto:nicholaspoz@gmail.com");
  }

  function github() {
    return row("GITHUB >".padStart(22), "https://github.com/nicholaspoz");
  }

  const NICK = [
    row("NICK"), //
    row(),
    row(),
    row(),
    row(),
    row(),
  ];

  const NICK_DOT = [
    row("NICK"), //
    row(),
    row("DOT"),
    row(),
    row(),
    row(),
  ];

  const NICK_DOT_BINGO = [
    row("NICK"),
    row(),
    row("DOT"),
    row(),
    row("BINGO"),
    row(),
  ];

  const FULL_NAME = [
    row("NICK (POZOULAKIS)"),
    row(),
    row("DOT"),
    row(),
    row("BINGO"),
    row(),
  ];

  const TECH = [
    row("FREELANCE"),
    row("TECHNOLOGIST"),
    row(),
    linkedIn(),
    github(),
    email(),
  ];

  const MUSICIAN = [
    row("FREELANCE"),
    row("CELLIST"),
    row("  ___ ".padStart(10)),
    row(" |   |".padStart(10)),
    row("0   0 ".padStart(10)),
    email(),
  ];

  const WHAT = [
    row("              WHAT"),
    row("            A"),
    row("       TIME"),
    row("    TO"),
    row("       BE"),
    row("           ALIVE?"),
  ];

  function frame(contents, ms) {
    return { contents, ms };
  }

  const frames = [
    frame(NICK, 1_500),
    frame(NICK_DOT, 1_500),
    frame(NICK_DOT_BINGO, 2_000),
    frame(FULL_NAME, 7_000),
    frame(TECH, 8_000),
    frame(MUSICIAN, 8_000),
    frame(WHAT, 7_000),
  ];

  let index = 0;
  function nextFrame() {
    const { contents, ms } = frames[index];
    document
      .querySelector("split-flap-display")
      .setAttribute("lines", JSON.stringify(contents));
    index = (index + 1) % frames.length;
    setTimeout(nextFrame, ms);
  }

  document.addEventListener("DOMContentLoaded", (event) => {
    console.log("Split-flap components loaded???!");
    nextFrame();
  });

  // defer to next tick so the blur placeholder paints first
  requestAnimationFrame(() => {
    document.querySelector(".site-hero").classList.add("ready");
  });

  // Dynamic scaling based on aspect ratio
  function updateDynamicScale() {
    const minScale = 100;
    const maxScale = 180;
    const targetAspectRatio = 16 / 9;
    const aspectRatio = window.innerWidth / window.innerHeight;

    // Calculate scale: more narrow = more scaling
    const delta = Math.abs(targetAspectRatio - aspectRatio);
    const normalizedDelta = delta / targetAspectRatio;

    const normalizedRatio = Math.max(0, Math.min(1, normalizedDelta));
    const scale = minScale + (maxScale - minScale) * normalizedRatio;
    console.log(scale);

    document.documentElement.style.setProperty("--dynamic-scale", `${scale}%`);
    document.documentElement.style.setProperty(
      "--dynamic-factor",
      `${scale / 100}`
    );
  }

  // Update on resize and initial load
  window.addEventListener("resize", updateDynamicScale);
  updateDynamicScale();
})();
